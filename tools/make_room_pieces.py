"""Piezas de las "Salas por piezas" del Modo Desafío (sección 10 de docs/PROPUESTA_ROGUELIKE.md). Por cada pieza de la
tabla PIECES: recorta la pintura de Qwen (art_src/piezas/<bioma>/<id>.png, un objeto sobre blanco) con
tools/prop_from_image.py a su alto en píxeles del juego (pixel art de verdad: 1 píxel = 1 píxel del juego, paleta chica,
alfa duro) → sprites/rogue/piezas/<bioma>/<id>.png, y arma el catálogo data/rogue/piezas/<bioma>.json que lee RoomPieces:
  kind  "solida" (choca, se pasa por detrás), "zona" (agua: dibujo en el piso + celdas de agua) o "decorado";
  base  [ancho, alto] en px de la elipse de colisión (sólidas) o de la mancha de agua (zonas); None = sale del dibujo;
  sink  px que el dibujo baja respecto de la base (para que no "flote");
  size  [ancho, alto] del sprite (lo completa este script).
Escala: una celda = 16 px; un entrenador mide ~24 px.

Uso: python -I -B tools/make_room_pieces.py . [<bioma>]     (después: godot --headless --path . --import)
"""
import json
import os
import subprocess
import sys

from PIL import Image

# bioma -> id -> (alto px, kind, base [ancho, alto], sink, colores)
PIECES = {
    "costa": {
        "roca_chica": (26, "solida", None, 2, 16),
        "roca_percebes": (52, "solida", None, 4, 20),
        "roca_grande": (80, "solida", None, 5, 20),
        "palmera": (96, "solida", [16, 10], 2, 24),
        "tronco": (34, "solida", None, 3, 16),
        "bote": (46, "solida", None, 4, 20),
        "cajas": (46, "solida", None, 3, 16),
        "barril": (30, "solida", None, 2, 16),
        "coral": (32, "solida", None, 2, 16),
        "naufragio": (130, "solida", None, 8, 24),
        "ancla": (44, "solida", None, 3, 16),
        "charco": (64, "zona", None, 0, 16),
        "laguna": (120, "zona", None, 0, 20),
        "concha": (9, "decorado", [0, 0], 0, 8),
        "estrella": (11, "decorado", [0, 0], 0, 8),
        "algas": (12, "decorado", [0, 0], 0, 8),
    },
}


def main(root, only=None):
    for biome, pieces in PIECES.items():
        if only and biome != only:
            continue
        src_dir = os.path.join(root, "art_src/piezas", biome)
        dst_dir = os.path.join(root, "sprites/rogue/piezas", biome)
        os.makedirs(dst_dir, exist_ok=True)
        catalog = {}
        for pid, (height, kind, base, sink, colors) in pieces.items():
            src = os.path.join(src_dir, pid + ".png")
            dst = os.path.join(dst_dir, pid + ".png")
            if not os.path.exists(src):
                print("falta", src)
                continue
            subprocess.run([sys.executable, "-I", "-B", os.path.join(root, "tools/prop_from_image.py"), src, dst,
                            "--height", str(height), "--colors", str(colors)], check=True, capture_output=True)
            w, h = Image.open(dst).size
            if base is None:  # la base sale del dibujo: casi todo su ancho, acostada (vista 3/4); el agua, casi todo el dibujo
                base = [round(w * 0.8), round(h * 0.72)] if kind == "zona" else [round(w * 0.85), max(8, round(w * 0.36))]
            catalog[pid] = {"kind": kind, "base": base, "sink": sink, "size": [w, h]}
        os.makedirs(os.path.join(root, "data/rogue/piezas"), exist_ok=True)
        with open(os.path.join(root, "data/rogue/piezas/%s.json" % biome), "w", encoding="utf8", newline="\n") as f:
            f.write("{\n" + ",\n".join('  "%s": %s' % (k, json.dumps(v)) for k, v in catalog.items()) + "\n}\n")
        print("%s: %d piezas" % (biome, len(catalog)))


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else None)
