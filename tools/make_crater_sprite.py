"""Sprite de cráter/pozo estilo GBA para los estados de celda "crater" (Excavar, Tumba Rocas, Terremoto...).

Uso: python -I -B tools/make_crater_sprite.py <proyecto>   ->  art/fx/crater.png (4 discos de 28×28 en fila)

Son las capas de un pozo, de afuera hacia adentro: contorno, labio de tierra removida, pared y fondo. El juego
(EnvironmentGrid) dibuja cada capa en todas las celdas del cráter antes de pasar a la siguiente, centradas en la
celda y más grandes que ella: así las celdas vecinas se funden en un solo cráter de cualquier forma, sin costuras
ni esquinas raras. Una celda sola es un pozo redondo. Afuera es transparente (va encima de cualquier piso).
Paleta: tierras del pozo de cueva de FireRed (metatile 6006, MB_FALL_WARP) en 5 bits por canal; luz desde arriba
como en los mapas (el labio claro arriba, la pared de arriba en sombra y la de abajo iluminada).
"""
import math
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__))))
import pret_import as P  # noqa: E402

SIZE = 28  # cada disco; el juego lo centra en la celda de 16


def gba(r, g, b):
    return (r * 8, g * 8, b * 8)


OUTLINE = gba(7, 5, 4)
LIP_LIGHT = gba(27, 23, 17)
LIP = gba(22, 17, 12)
LIP_DARK = gba(16, 12, 9)
PEBBLE = gba(25, 22, 18)
WALL_SHADE = gba(9, 7, 6)
WALL_LIT = gba(15, 11, 8)
DEEP = gba(6, 5, 5)
DEEPEST = gba(4, 3, 4)


def noise(x, y, salt=0):
    h = (x * 374761393 + y * 668265263 + salt * 2246822519) & 0xFFFFFFFF
    h = (h ^ (h >> 13)) * 1274126177 & 0xFFFFFFFF
    return (h ^ (h >> 16)) % 1000 / 1000.0


def disc(layer, x, y):
    """Color del píxel (x, y) del disco de la capa `layer` (None = transparente)."""
    c = SIZE / 2.0
    dx, dy = x + 0.5 - c, y + 0.5 - c
    r = math.hypot(dx, dy * 1.08)
    ny = dy / (r or 1.0)  # -1 = arriba
    n = noise(x, y, layer)
    if layer == 0:  # contorno
        return OUTLINE if r <= 12.6 else None
    if layer == 1:  # labio de tierra removida
        if r > 11.6:
            return None
        if n > 0.965:
            return PEBBLE
        return LIP_LIGHT if ny < -0.35 else (LIP if ny < 0.45 else LIP_DARK)
    if layer == 2:  # pared (corrida hacia abajo: arriba se ve más pared en sombra)
        r2 = math.hypot(dx, (dy + 1.0) * 1.08)
        if r2 > 9.3:
            return None
        return WALL_SHADE if (dy + 1.0) < 1.5 else WALL_LIT
    r3 = math.hypot(dx, (dy - 0.5) * 1.08)  # fondo
    if r3 > 7.0:
        return None
    if n > 0.985:
        return WALL_LIT
    return DEEPEST if n < 0.45 else DEEP


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else "."
    w, h = SIZE * 4, SIZE
    img = type("Img", (), {})()
    img.w, img.h = w, h
    data = bytearray(w * h * 4)
    for layer in range(4):
        for y in range(SIZE):
            for x in range(SIZE):
                c = disc(layer, x, y)
                if c is not None:
                    o = (y * w + layer * SIZE + x) * 4
                    data[o:o + 4] = bytes(c + (255,))
    img.data = data
    out = os.path.join(root, "art", "fx", "crater.png")
    P.write_png(out, img)
    print(out)


if __name__ == "__main__":
    main()
