# Actualizaciones automáticas del cliente (plan, 2026-11-01)

Decisión del usuario (2026-11-01): **el juego se actualiza solo** (sin launcher aparte ni itch.io) y la actualización
es **obligatoria** (si hay versión nueva, se baja antes de jugar).

## Idea
El zip trae `PokemonPilot.exe` (Godot sin tocar, no cambia) + `PokemonPilot.pck` (el juego). Una actualización es
**solo un .pck nuevo** (~56 MB), igual para Windows y Mac. No hace falta numerar versiones: la versión es la **huella
SHA-256 del .pck**.

1. **Publicar** (en tu PC, `tools/build_portable.py` + `tools/server/subir_servidor.bat`): se exporta el .pck, se arma
   `update.json` (`sha256`, tamaño, nombre del archivo, versión de Godot, fecha) y `update.sig` (firma RSA de
   `update.json` con la **clave privada**, que queda solo en tu PC: `%USERPROFILE%\.pokemon_pilot\update_private.key`).
   El bat sube todo al VPS: el servidor online se actualiza con ese mismo .pck y nginx sirve
   `http://<servidor>/pokemon-pilot/update.json`, `update.sig` y `PokemonPilot-<huella>.pck`. Así el servidor y los
   clientes nunca quedan desfasados.
2. **El juego, al abrir** (autoload `Updater`, solo en la versión portable y nunca con `--server` ni en los tests):
   baja `update.json` y `update.sig` (5 s como mucho), verifica la firma con la **clave pública** que viene adentro del
   juego (`data/update_key.pub`), y compara la huella con la de su .pck.
   - Igual → a jugar.
   - Distinta → pantalla "Actualizando…" con barra; baja el .pck nuevo a `user://updates/`, comprueba tamaño y
     huella, y se vuelve a abrir con él (`--main-pack`). Al arrancar con el nuevo, lo copia encima del .pck de la
     carpeta del juego (así la próxima vez abre directo); si no puede (carpeta sin permiso), cada vez abre el de
     `user://updates/` (se relanza solo, un par de segundos más).
   - Sin conexión o servidor caído → juega con lo que tiene (el online igual pide la misma versión).
   - Otra versión de Godot en `update.json` → avisa que hay que bajar el zip nuevo (un .pck no alcanza).
3. **Seguridad**: la descarga es HTTP común; la firma garantiza que el .pck es el tuyo (sin la clave privada nadie puede
   hacer un `update.json` válido, y el .pck tiene que tener esa huella). Si la firma no da, no se baja nada.

## Fases
- **U-0 (hecha 2026-11-01)**: `Updater` (chequear, bajar, verificar, relanzar, reemplazar), claves y firma (`tools/update_keys.gd`),
  `build_portable.py` arma `update.json` + `update.sig`, el VPS sirve las actualizaciones (nginx en
  `instalar_servidor.sh`), test `--autotest-updater` (servidor HTTP de prueba adentro del test).
- Después (si hace falta): parches por diferencia (bajar solo lo que cambió), notas de la versión en pantalla.

## Ojo
- Los amigos tienen que bajar **una vez más** el zip a mano (el primero con el `Updater`); de ahí en más se actualiza solo.
- Si se pierde la clave privada, hay que hacer claves nuevas y volver a pasar el zip a mano.
- Las partidas no se tocan (están en `app_userdata`).

## Lo que se aprendió armándolo
- Godot se "come" `--main-pack` y `--headless`: no aparecen en `OS.get_cmdline_args()`. Por eso el juego relanzado
  recibe además `--pck <ruta>` (y el lanzador de Mac también lo pasa), y un `--relanzado` que evita relanzar en bucle.
- `HTTPRequest.timeout` suma el delta de los cuadros: el primer cuadro después de abrir trae segundos y cortaba el
  pedido al instante. El tiempo de espera se mide con el reloj.
- La exportación del .pck sale igual cada vez (misma huella si no cambió nada).
