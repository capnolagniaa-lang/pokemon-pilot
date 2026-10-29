# Servidor online (fase O-5)

El servidor del juego es un **VPS de Vultr** en São Paulo (Ubuntu 24.04, 1 vCPU / 1 GB, unos US$7,50 por mes), con
la IP fija **216.238.99.5**. Esa IP está adentro del juego (`Net.OFFICIAL_SERVER`), así que los zips se conectan
solos: no hace falta Tailscale ni abrir puertos. Puerto: **24680 UDP** (ENet).

## Cómo está armado
- En el VPS corre el mismo juego, headless, con el `.pck` de la versión portable:
  `/opt/pokemon-pilot/godot --headless --main-pack /opt/pokemon-pilot/PokemonPilot.pck -- --server --port 24680`.
- Es un servicio de systemd (`pokemon-pilot`): arranca con la máquina y se reinicia solo si se cae. Corre con su
  propio usuario (`pokemon`), no como root. El firewall (ufw) deja pasar SSH y el 24680/udp.
- Lo instala `tools/server/instalar_servidor.sh` (baja Godot 4.7.2 para Linux la primera vez, 1 GB de swap, el
  servicio y el firewall). Correrlo de nuevo actualiza el `.pck` y reinicia.

## Sacar una versión nueva (siempre los dos juntos)
El servidor rechaza un juego de otra versión (`Net.game_version`: huella de ataques y especies). Por eso, cada vez:
1. Armar el zip: `python -I -B tools/build_portable.py . <Godot_v4.7.2-stable_win64.exe>`. Mejor desde lo commiteado
   (si hay cambios a medio hacer de otra sesión, desde un `git worktree` limpio, y copiar su `export/` acá).
2. Doble clic en `tools/server/subir_servidor.bat`: sube `export/Pokemon Pilot/PokemonPilot.pck` y el instalador
   con `scp` y lo corre con `ssh` (pide la contraseña de root del VPS dos veces; está en el panel de Vultr).
3. Pasar el zip nuevo a los amigos.

## Mirar o tocar el servidor
- Entrar: `ssh root@216.238.99.5` (la contraseña, del panel de Vultr).
- Estado y últimas líneas: `systemctl status pokemon-pilot` · `journalctl -u pokemon-pilot -f` (las líneas
  `[servidor]` dicen quién se conecta y las peleas).
- Reiniciar: `systemctl restart pokemon-pilot`.
- **Dejar de pagar**: en Vultr, el servidor → Destroy (apagado igual cobra). Si se crea otro, cambia la IP: ponerla en
  `Net.OFFICIAL_SERVER` y en `tools/server/subir_servidor.bat`, y sacar zip nuevo.
