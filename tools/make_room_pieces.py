"""Piezas de las "Salas por piezas" del Modo Desafío (sección 10 de docs/PROPUESTA_ROGUELIKE.md). Por cada pieza de la
tabla PIECES: recorta la pintura de Qwen (art_src/piezas/<bioma>/<id>.png, un objeto sobre blanco) con
tools/prop_from_image.py a su alto en píxeles del juego (pixel art de verdad: 1 píxel = 1 píxel del juego, paleta chica,
alfa duro) → sprites/rogue/piezas/<bioma>/<id>.png, y arma el catálogo data/rogue/piezas/<bioma>.json que lee RoomPieces:
  kind  "solida" (choca, se pasa por detrás), "zona" (agua: dibujo en el piso + celdas de agua) o "decorado";
  base  [ancho, alto] en px de la elipse de colisión (sólidas) o de la mancha de agua (zonas); None = sale del dibujo;
  sink  px que el dibujo baja respecto de la base (para que no "flote");
  size  [ancho, alto] del sprite y foot (dónde pisa, en x) (los completa este script).
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
        "naufragio": (150, "solida", None, 8, 24),
        "mastil": (70, "solida", None, 4, 20),
        "red_pesca": (52, "solida", None, 2, 16),
        "fogata": (26, "solida", None, 2, 20),
        "canasta": (26, "solida", None, 2, 16),
        "palmera_baja": (72, "solida", [18, 10], 3, 24),
        "palmera_inclinada": (100, "solida", [16, 10], 2, 24),
        "poza_a": (96, "zona", None, 0, 24),
        "poza_b": (84, "zona", None, 0, 24),
        "tablas": (34, "decorado", [0, 0], 0, 12),
        "remo": (22, "decorado", [0, 0], 0, 12),
        "cocos": (16, "decorado", [0, 0], 0, 12),
        "pasto_duna": (16, "decorado", [0, 0], 0, 12),
        "cangrejo": (9, "decorado", [0, 0], 0, 8),
        "piedritas": (16, "decorado", [0, 0], 0, 8),
        "madera": (14, "decorado", [0, 0], 0, 8),
        "linea_marea": (12, "decorado", [0, 0], 0, 12),
        "ancla": (44, "solida", None, 3, 16),
        "charco": (64, "zona", None, 0, 16),
        "laguna": (120, "zona", None, 0, 20),
        "concha": (9, "decorado", [0, 0], 0, 8),
        "estrella": (11, "decorado", [0, 0], 0, 8),
        "algas": (12, "decorado", [0, 0], 0, 8),
    },
    "volcan": {
        "roca_chica": (26, "solida", None, 2, 20),
        "roca": (64, "solida", None, 4, 20),
        "roca_grande": (112, "solida", None, 5, 20),
        "obsidiana": (60, "solida", None, 2, 20),
        "fumarola": (72, "solida", None, 3, 20),
        "azufre": (18, "decorado", [0, 0], 0, 12),
        "esqueleto": (124, "solida", None, 5, 20),
        "craneo": (40, "solida", None, 2, 20),
        "huesos": (16, "decorado", [0, 0], 0, 12),
        "arbol_quemado": (106, "solida", [16, 10], 2, 20),
        "tronco_carbon": (36, "solida", None, 3, 20),
        "brasas": (14, "decorado", [0, 0], 0, 12),
        "horno": (112, "solida", None, 4, 20),
        "yunque": (44, "solida", None, 2, 20),
        "carbon": (34, "solida", None, 2, 20),
        "losa": (20, "decorado", [0, 0], 0, 12),
        "ceniza": (14, "decorado", [0, 0], 0, 12),
        "cristal_fuego": (54, "solida", None, 2, 20),
    },
    "bosque": {
        "arbol": (116, "solida", [22, 12], 3, 24),
        "arbol_b": (116, "solida", [18, 10], 3, 24),
        "arbusto": (30, "solida", None, 2, 20),
        "tocon": (24, "solida", None, 2, 20),
        "tocon_hacha": (44, "solida", None, 2, 20),
        "tronco_caido": (34, "solida", None, 3, 20),
        "roca_chica": (24, "solida", None, 2, 20),
        "roca_grande": (76, "solida", None, 4, 20),
        "carpa": (98, "solida", None, 4, 20),
        "fogata": (36, "solida", None, 2, 20),
        "lena": (38, "solida", None, 2, 20),
        "asiento": (20, "solida", None, 2, 20),
        "arco_ruina": (118, "solida", None, 5, 24),
        "columna_rota": (58, "solida", None, 2, 20),
        "estatua": (72, "solida", None, 2, 20),
        "altar": (94, "solida", None, 3, 20),
        "farol_piedra": (52, "solida", [14, 9], 2, 20),
        "estanque": (104, "zona", None, 0, 24),
        "juncos": (32, "decorado", [0, 0], 0, 12),
        "hongos": (14, "decorado", [0, 0], 0, 12),
        "helecho": (16, "decorado", [0, 0], 0, 12),
        "flores": (12, "decorado", [0, 0], 0, 12),
    },
    "cueva": {
        "estalagmita": (74, "solida", [18, 10], 2, 20),
        "estalagmitas": (86, "solida", None, 3, 20),
        "roca_chica": (24, "solida", None, 2, 20),
        "roca_grande": (86, "solida", None, 4, 20),
        "cristal_chico": (38, "solida", None, 2, 20),
        "cristal_grande": (92, "solida", None, 3, 20),
        "cristal_violeta": (88, "solida", None, 3, 20),
        "vagoneta": (60, "solida", None, 3, 20),
        "via": (14, "decorado", [0, 0], 0, 12),
        "tope": (50, "solida", None, 2, 20),
        "mineral": (44, "solida", None, 2, 20),
        "viga": (98, "solida", None, 2, 20),
        "cajas": (54, "solida", None, 2, 20),
        "herramientas": (40, "solida", None, 2, 20),
        "farol": (54, "solida", [10, 8], 2, 20),
        "fosil": (98, "solida", None, 4, 20),
        "andamio": (98, "solida", None, 3, 20),
        "hongos": (16, "decorado", [0, 0], 0, 12),
        "esquirlas": (12, "decorado", [0, 0], 0, 12),
        "piedritas": (12, "decorado", [0, 0], 0, 12),
    },
    "hielo": {
        "pino": (126, "solida", [18, 10], 3, 24),
        "pino_chico": (70, "solida", [14, 9], 2, 20),
        "roca_chica": (26, "solida", None, 2, 20),
        "roca_grande": (90, "solida", None, 4, 20),
        "cristal_chico": (40, "solida", None, 2, 20),
        "cristal_grande": (98, "solida", None, 3, 20),
        "cabana": (152, "solida", None, 5, 24),
        "lena": (40, "solida", None, 2, 20),
        "pozo": (78, "solida", None, 3, 20),
        "trineo": (42, "solida", None, 2, 20),
        "columna": (78, "solida", None, 2, 20),
        "estatua": (98, "solida", None, 3, 20),
        "brasero": (52, "solida", [14, 9], 2, 20),
        "pesca": (46, "solida", None, 2, 20),
        "agujero": (26, "decorado", [0, 0], 0, 12),
        "tronco": (36, "solida", None, 3, 20),
        "nieve": (14, "decorado", [0, 0], 0, 12),
        "tocon": (24, "solida", None, 2, 20),
    },
    "cementerio": {
        "lapida": (34, "solida", None, 2, 20),
        "lapida_cruz": (42, "solida", None, 2, 20),
        "lapida_rota": (30, "solida", None, 2, 20),
        "mausoleo": (124, "solida", None, 5, 24),
        "angel": (66, "solida", None, 2, 20),
        "arbol_seco": (92, "solida", [18, 10], 2, 20),
        "arbol_viejo": (156, "solida", [44, 18], 4, 24),
        "reja": (30, "solida", [44, 8], 2, 20),
        "farol": (72, "solida", [10, 8], 2, 20),
        "ataud": (36, "solida", None, 2, 20),
        "fosa": (46, "solida", None, 3, 20),
        "calabaza": (18, "solida", None, 2, 20),
        "velas": (14, "decorado", [0, 0], 0, 12),
        "flores": (12, "decorado", [0, 0], 0, 12),
        "banco": (28, "solida", None, 2, 20),
        "altar": (48, "solida", None, 2, 20),
        "campana": (42, "solida", None, 2, 20),
        "hojas": (12, "decorado", [0, 0], 0, 12),
    },
}
# Biomas con piezas claras (nieve, hielo): el fondo es solo el blanco que toca el borde de la imagen.
OUTER_BG = {"hielo"}


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
                            "--height", str(height), "--colors", str(colors)] + (["--outer-bg"] if biome in OUTER_BG else []),
                           check=True, capture_output=True)
            w, h = Image.open(dst).size
            if base is None:  # la base sale del dibujo: casi todo su ancho, acostada (vista 3/4); el agua, casi todo el dibujo
                base = [round(w * 0.8), round(h * 0.72)] if kind == "zona" else [round(w * 0.85), max(8, round(w * 0.36))]
            catalog[pid] = {"kind": kind, "base": base, "sink": sink, "size": [w, h]}
            if kind == "solida":
                # Dónde pisa: el centro de lo que hay en el tercio de abajo del dibujo (una palmera inclinada no pisa en
                # el medio de su imagen). `foot` = px desde el centro del sprite; RoomPieces lo corre para que pise ahí.
                im = Image.open(dst).convert("RGBA")
                xs = [x for y in range(h - max(3, h // 8), h) for x in range(w) if im.getpixel((x, y))[3] > 128]
                if xs:
                    catalog[pid]["foot"] = round((min(xs) + max(xs)) / 2.0 - w / 2.0)
        os.makedirs(os.path.join(root, "data/rogue/piezas"), exist_ok=True)
        with open(os.path.join(root, "data/rogue/piezas/%s.json" % biome), "w", encoding="utf8", newline="\n") as f:
            f.write("{\n" + ",\n".join('  "%s": %s' % (k, json.dumps(v)) for k, v in catalog.items()) + "\n}\n")
        print("%s: %d piezas" % (biome, len(catalog)))


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else None)
