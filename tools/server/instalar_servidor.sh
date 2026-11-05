#!/bin/bash
# Instala (o actualiza) el servidor online de Pokémon Pilot en un VPS con Ubuntu (docs/SERVIDOR_ONLINE.md).
# Se corre como root en el VPS, con el PokemonPilot.pck subido al lado (lo hace tools/server/subir_servidor.bat):
#   bash /root/instalar_servidor.sh
# Deja el servidor como servicio (pokemon-pilot): arranca solo con la máquina y se reinicia si se cae.
set -euo pipefail
GODOT_VERSION="4.7.2-stable"
DIR=/opt/pokemon-pilot
PORT=24680
PARTIDAS_PORT=24681
cd "$(dirname "$0")"

if [ ! -f PokemonPilot.pck ]; then
	echo "Falta PokemonPilot.pck al lado de este script." >&2
	exit 1
fi
mkdir -p "$DIR"

# Godot para Linux (el mismo que el del juego), una sola vez.
if [ ! -x "$DIR/godot" ]; then
	echo "Bajando Godot $GODOT_VERSION para Linux..."
	apt-get update -qq && apt-get install -y -qq unzip curl >/dev/null
	curl -fsSL -o /tmp/godot.zip \
		"https://github.com/godotengine/godot/releases/download/$GODOT_VERSION/Godot_v${GODOT_VERSION}_linux.x86_64.zip"
	unzip -o -q /tmp/godot.zip -d /tmp/godot
	mv /tmp/godot/Godot_v${GODOT_VERSION}_linux.x86_64 "$DIR/godot"
	chmod +x "$DIR/godot"
	rm -rf /tmp/godot /tmp/godot.zip
fi

# 1 GB de memoria de respaldo (el plan de 1 GB anda justo al cargar el juego).
if ! swapon --show | grep -q /swapfile; then
	fallocate -l 1G /swapfile && chmod 600 /swapfile && mkswap /swapfile >/dev/null && swapon /swapfile
	grep -q /swapfile /etc/fstab || echo "/swapfile none swap sw 0 0" >> /etc/fstab
fi

# Usuario propio (el servidor no corre como root).
id pokemon >/dev/null 2>&1 || useradd --system --home "$DIR" --shell /usr/sbin/nologin pokemon
install -m 644 PokemonPilot.pck "$DIR/PokemonPilot.pck"
chown -R pokemon:pokemon "$DIR"

cat > /etc/systemd/system/pokemon-pilot.service <<UNIT
[Unit]
Description=Servidor online de Pokemon Pilot
After=network-online.target
Wants=network-online.target

[Service]
User=pokemon
WorkingDirectory=$DIR
Environment=HOME=$DIR
ExecStart=$DIR/godot --headless --main-pack $DIR/PokemonPilot.pck -- --server --port $PORT
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
UNIT

# Partidas de los jugadores y panel (partidas_server.py; la base queda en $DIR/partidas y sobrevive a las actualizaciones).
command -v python3 >/dev/null || { apt-get update -qq && apt-get install -y -qq python3 >/dev/null; }
install -m 644 partidas_server.py "$DIR/partidas_server.py"
mkdir -p "$DIR/partidas"
chmod 700 "$DIR/partidas"
chown -R pokemon:pokemon "$DIR/partidas"
cat > /etc/systemd/system/pokemon-pilot-partidas.service <<UNIT
[Unit]
Description=Partidas de Pokemon Pilot
After=network-online.target

[Service]
User=pokemon
ExecStart=/usr/bin/env python3 $DIR/partidas_server.py --port $PARTIDAS_PORT --db $DIR/partidas/partidas.db
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
UNIT

# Actualizaciones automáticas de los clientes (docs/PLAN_ACTUALIZACIONES.md): nginx sirve en
# http://<IP>/pokemon-pilot/ el update.json, su firma y el .pck (con el nombre que dice update.json). El .pck va
# primero y el update.json al final, así nadie ve un update.json que apunte a un archivo que todavía no está.
WWW=/var/www/pokemon-pilot
if [ -f update.json ] && [ -f update.sig ]; then
	if ! command -v nginx >/dev/null; then
		echo "Instalando nginx (para las actualizaciones)..."
		apt-get update -qq && apt-get install -y -qq nginx >/dev/null
	fi
	cat > /etc/nginx/sites-available/pokemon-pilot <<SITE
server {
	listen 80 default_server;
	listen [::]:80 default_server;
	location /pokemon-pilot/partidas/ {
		proxy_pass http://127.0.0.1:$PARTIDAS_PORT/;
		proxy_set_header X-Real-IP \$remote_addr;
		client_max_body_size 5m;
		access_log off;
	}
	location /pokemon-pilot/ {
		alias $WWW/;
		autoindex off;
		add_header Cache-Control "no-cache";
	}
	location / { return 404; }
}
SITE
	ln -sf /etc/nginx/sites-available/pokemon-pilot /etc/nginx/sites-enabled/pokemon-pilot
	rm -f /etc/nginx/sites-enabled/default
	mkdir -p "$WWW"
	PCK_NAME=$(grep -o '"file": *"[^"]*"' update.json | sed 's/.*"\([^"]*\)"$/\1/')
	install -m 644 PokemonPilot.pck "$WWW/$PCK_NAME"
	install -m 644 update.sig "$WWW/update.sig.nuevo"
	install -m 644 update.json "$WWW/update.json.nuevo"
	mv -f "$WWW/update.sig.nuevo" "$WWW/update.sig"
	mv -f "$WWW/update.json.nuevo" "$WWW/update.json"
	# los .pck viejos: queda solo el que dice update.json
	find "$WWW" -name 'PokemonPilot-*.pck' ! -name "$PCK_NAME" -delete
	nginx -t >/dev/null 2>&1 && systemctl enable nginx >/dev/null 2>&1 && systemctl reload-or-restart nginx
	echo "Actualización publicada: http://$(hostname -I | awk '{print $1}')/pokemon-pilot/$PCK_NAME"
fi

# Firewall: SSH, el puerto del juego (UDP) y HTTP (actualizaciones).
if command -v ufw >/dev/null; then
	ufw allow 22/tcp >/dev/null
	ufw allow $PORT/udp >/dev/null
	ufw allow 80/tcp >/dev/null
	ufw --force enable >/dev/null
fi

systemctl daemon-reload
systemctl enable pokemon-pilot >/dev/null 2>&1
systemctl restart pokemon-pilot
systemctl enable pokemon-pilot-partidas >/dev/null 2>&1
systemctl restart pokemon-pilot-partidas
sleep 8
if [ -f "$DIR/partidas/panel_token" ]; then
	echo "Panel de partidas: http://$(hostname -I | awk '{print $1}')/pokemon-pilot/partidas/panel?k=$(cat "$DIR/partidas/panel_token")"
else
	echo "OJO: el servicio de partidas no arrancó: journalctl -u pokemon-pilot-partidas" >&2
fi
if systemctl is-active --quiet pokemon-pilot && journalctl -u pokemon-pilot -n 30 --no-pager | grep -q "escuchando"; then
	journalctl -u pokemon-pilot -n 30 --no-pager | grep "escuchando" | tail -1
	echo "LISTO: el servidor está prendido en el puerto $PORT (UDP)."
else
	echo "OJO: el servidor no arrancó bien. Últimas líneas:" >&2
	journalctl -u pokemon-pilot -n 30 --no-pager >&2
	exit 1
fi
