#!/bin/bash
# Instala (o actualiza) el servidor online de Pokémon Pilot en un VPS con Ubuntu (docs/SERVIDOR_ONLINE.md).
# Se corre como root en el VPS, con el PokemonPilot.pck subido al lado (lo hace tools/server/subir_servidor.bat):
#   bash /root/instalar_servidor.sh
# Deja el servidor como servicio (pokemon-pilot): arranca solo con la máquina y se reinicia si se cae.
set -euo pipefail
GODOT_VERSION="4.7.2-stable"
DIR=/opt/pokemon-pilot
PORT=24680
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

# Firewall: SSH y el puerto del juego (UDP).
if command -v ufw >/dev/null; then
	ufw allow 22/tcp >/dev/null
	ufw allow $PORT/udp >/dev/null
	ufw --force enable >/dev/null
fi

systemctl daemon-reload
systemctl enable pokemon-pilot >/dev/null 2>&1
systemctl restart pokemon-pilot
sleep 8
if systemctl is-active --quiet pokemon-pilot && journalctl -u pokemon-pilot -n 30 --no-pager | grep -q "escuchando"; then
	journalctl -u pokemon-pilot -n 30 --no-pager | grep "escuchando" | tail -1
	echo "LISTO: el servidor está prendido en el puerto $PORT (UDP)."
else
	echo "OJO: el servidor no arrancó bien. Últimas líneas:" >&2
	journalctl -u pokemon-pilot -n 30 --no-pager >&2
	exit 1
fi
