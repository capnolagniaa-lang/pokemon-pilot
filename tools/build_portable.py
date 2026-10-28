"""Arma la versión portable del juego para pasarle a los amigos (pedido del usuario 2026-10-24):
export/Pokemon Pilot/ (PokemonPilot.exe + PokemonPilot.pck + LEEME.txt) y export/PokemonPilot-<fecha>.zip.

No hacen falta las plantillas de exportación de Godot: el .exe es el mismo Godot del proyecto renombrado; al
arrancar carga solo el .pck que tiene su mismo nombre al lado. El .pck sale del preset "Windows Desktop"
(export_presets.cfg, que deja afuera tools/, art_src/ y docs/). Las partidas de cada uno quedan en su PC
(%APPDATA%/Godot/app_userdata/Pokémon Pilot/saves), nunca en el zip.

Uso: python -I -B tools/build_portable.py <carpeta del proyecto> <Godot_v4.7.2-stable_win64.exe>  (el de ventana, no el _console)
     [--mac <Godot_v4.7.2-stable_macos.universal.zip>]

Mac (pedido del usuario 2026-10-28): export/PokemonPilot-Mac-<fecha>.zip con el Godot.app oficial (universal: Intel y
Apple Silicon) **sin tocar** (si se le agrega o cambia algo se rompe su firma y macOS dice que está "dañado"), el mismo
.pck y un lanzador "Jugar Pokemon Pilot.command" que lo abre con --main-pack. Las entradas del zip de Godot se copian
tal cual (permisos de ejecución y enlaces). Las partidas quedan en ~/Library/Application Support/Godot/app_userdata.
"""
import datetime
import os
import shutil
import subprocess
import sys
import zipfile

README = """POKÉMON PILOT — versión de prueba
==================================

Cómo jugar
- Descomprimí la carpeta entera en cualquier lado y abrí PokemonPilot.exe (tienen que quedar juntos
  PokemonPilot.exe y PokemonPilot.pck).
- Si Windows avisa "Windows protegió su PC": "Más información" -> "Ejecutar de todas formas" (el juego no está
  firmado, es un proyecto casero).
- En el título: "Nueva partida" (elegís un nombre) y "Empezar la historia".

Teclas
- Moverse: WASD o flechas · Correr: Shift
- Ataques: Clic izquierdo, Clic derecho, Q, R (apuntás con el mouse)
- Esquivar / saltar cráteres: Espacio
- Hablar / mirar / lanzar Poké Ball: E · Objeto rápido: C
- Cambiar de Pokémon: 1 a 6 · Menú (Guía, Mapa, equipo, mochila, Pokédex, guardar): Esc

Música: poné tus canciones en una carpeta "audio\\musica" al lado de PokemonPilot.exe, con estos nombres
(.ogg o .mp3): titulo, pueblo_paleta, ruta_1, ciudad_verde, batalla_salvaje, batalla_entrenador, batalla_lider...
(la lista completa está en docs/AUDIO.md del proyecto).

Si no sabés qué hacer: Esc -> Guía (y Esc -> Mapa para ver dónde estás y adónde ir).
Tus partidas se guardan en %APPDATA%\\Godot\\app_userdata\\Pokémon Pilot\\saves (si actualizás el juego,
se conservan).
Si encontrás un error, anotá qué estabas haciendo y avisale a quien te pasó el juego.
"""


README_MAC = """POKÉMON PILOT — versión de prueba para Mac
==========================================

Cómo jugar
- Descomprimí el zip (doble clic). Tienen que quedar juntos, en la misma carpeta: Godot.app, PokemonPilot.pck y
  "Jugar Pokemon Pilot.command".
- Abrí el juego con "Jugar Pokemon Pilot.command" (NO con Godot.app directo: eso abre el editor vacío).
- La primera vez macOS no lo deja abrir porque el lanzador no está firmado (es un proyecto casero): clic derecho
  (o Control + clic) sobre "Jugar Pokemon Pilot.command" -> Abrir -> Abrir. Si igual no aparece la opción:
  Ajustes del Sistema -> Privacidad y seguridad -> abajo de todo, "Abrir igualmente". Después ya abre con doble clic.
- Se abre una ventana de Terminal junto con el juego: dejala abierta (si la cerrás, se cierra el juego).
- Funciona en Mac con Intel y con chip Apple (M1, M2...). Necesita macOS 10.15 o más nuevo.

Teclas
- Moverse: WASD o flechas · Correr: Shift
- Ataques: Clic izquierdo, Clic derecho, Q, R (apuntás con el mouse; con trackpad, clic derecho = dos dedos)
- Esquivar / saltar cráteres: Espacio
- Hablar / mirar / lanzar Poké Ball: E · Objeto rápido: C
- Cambiar de Pokémon: 1 a 6 · Menú (Guía, Mapa, equipo, mochila, Pokédex, guardar): Esc

Si no sabés qué hacer: Esc -> Guía (y Esc -> Mapa para ver dónde estás y adónde ir).
Tus partidas se guardan en ~/Library/Application Support/Godot/app_userdata/Pokémon Pilot/saves (si actualizás el
juego, se conservan).
Si encontrás un error, anotá qué estabas haciendo y avisale a quien te pasó el juego.
"""

LAUNCHER = """#!/bin/bash
# Abre Pokémon Pilot: el Godot.app de al lado con el juego (PokemonPilot.pck).
cd "$(dirname "$0")"
exec "./Godot.app/Contents/MacOS/Godot" --main-pack "./PokemonPilot.pck"
"""


def build_mac(root, pck, godot_zip):
    zip_path = os.path.join(root, "export", "PokemonPilot-Mac-%s.zip" % datetime.date.today().isoformat())
    with zipfile.ZipFile(godot_zip) as src, zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        for info in src.infolist():  # Godot.app tal cual: mismos permisos y enlaces (external_attr)
            data = src.read(info)
            info.filename = "Pokemon Pilot/" + info.filename
            z.writestr(info, data)
        z.write(pck, "Pokemon Pilot/PokemonPilot.pck")
        for name, text, mode in (("Jugar Pokemon Pilot.command", LAUNCHER, 0o755), ("LEEME.txt", README_MAC, 0o644)):
            zi = zipfile.ZipInfo("Pokemon Pilot/" + name, date_time=datetime.datetime.now().timetuple()[:6])
            zi.create_system = 3  # Unix: que se respeten los permisos al descomprimir
            zi.external_attr = (0o100000 | mode) << 16
            zi.compress_type = zipfile.ZIP_DEFLATED
            z.writestr(zi, text.encode("utf-8"))
    print("zip Mac:", zip_path, "%.1f MB" % (os.path.getsize(zip_path) / 1e6))


def main():
    root, godot = sys.argv[1], sys.argv[2]
    out = os.path.join(root, "export", "Pokemon Pilot")
    os.makedirs(out, exist_ok=True)
    pck = os.path.join(out, "PokemonPilot.pck")
    subprocess.run([godot, "--headless", "--path", root, "--quit-after", "600000", "--export-pack", "Windows Desktop",
                    pck], check=True, stdout=subprocess.DEVNULL)
    shutil.copyfile(godot, os.path.join(out, "PokemonPilot.exe"))
    with open(os.path.join(out, "LEEME.txt"), "w", encoding="utf-8-sig", newline="\r\n") as f:
        f.write(README)
    zip_path = os.path.join(root, "export", "PokemonPilot-%s.zip" % datetime.date.today().isoformat())
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        for name in ("PokemonPilot.exe", "PokemonPilot.pck", "LEEME.txt"):
            z.write(os.path.join(out, name), "Pokemon Pilot/" + name)
    print("zip:", zip_path, "%.1f MB" % (os.path.getsize(zip_path) / 1e6))
    if "--mac" in sys.argv:
        build_mac(root, pck, sys.argv[sys.argv.index("--mac") + 1])


if __name__ == "__main__":
    main()
