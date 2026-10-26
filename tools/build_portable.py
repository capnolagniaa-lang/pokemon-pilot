"""Arma la versión portable del juego para pasarle a los amigos (pedido del usuario 2026-10-24):
export/Pokemon Pilot/ (PokemonPilot.exe + PokemonPilot.pck + LEEME.txt) y export/PokemonPilot-<fecha>.zip.

No hacen falta las plantillas de exportación de Godot: el .exe es el mismo Godot del proyecto renombrado; al
arrancar carga solo el .pck que tiene su mismo nombre al lado. El .pck sale del preset "Windows Desktop"
(export_presets.cfg, que deja afuera tools/, art_src/ y docs/). Las partidas de cada uno quedan en su PC
(%APPDATA%/Godot/app_userdata/Pokémon Pilot/saves), nunca en el zip.

Uso: python -I -B tools/build_portable.py <carpeta del proyecto> <Godot_v4.7.2-stable_win64.exe>  (el de ventana, no el _console)
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

Si no sabés qué hacer: Esc -> Guía (y Esc -> Mapa para ver dónde estás y adónde ir).
Tus partidas se guardan en %APPDATA%\\Godot\\app_userdata\\Pokémon Pilot\\saves (si actualizás el juego,
se conservan).
Si encontrás un error, anotá qué estabas haciendo y avisale a quien te pasó el juego.
"""


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


if __name__ == "__main__":
    main()
