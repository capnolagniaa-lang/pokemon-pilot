"""Ruleta de Pokémon y dibujo del joystick (Controles), de imágenes de Qwen 2.1 Turbo (art_src/ui/, 2026-11-05): les saca el fondo
negro, recorta y achica a sprites/ui/. En el joystick tapa un garabato con forma de logo que inventó Qwen en el centro.
Después de correrlo: godot --import.   Uso: python -I -B tools/make_wheel_art.py .
Ruleta: "Game UI asset, a radial selection wheel menu ... exactly 6 equal empty wedge slots ... a capture ball: a polished red and
white metal ring with a black band, a glowing golden selection rim" (semilla 32). Joystick: "a generic game controller seen straight
from the front ... Matte dark graphite body with thin golden trim lines" (semilla 31).
"""
import os
import sys
from collections import deque

from PIL import Image


def key_black(im, lo, hi):
    """Lo negro se vuelve transparente (la ruleta: los gajos y el centro también)."""
    out = im.convert("RGBA")
    px = out.load()
    for y in range(out.height):
        for x in range(out.width):
            r, g, b, _ = px[x, y]
            m = max(r, g, b)
            px[x, y] = (r, g, b, 0 if m <= lo else 255 if m >= hi else (m - lo) * 255 // (hi - lo))
    return out


def key_outside(im, limit):
    """Solo lo negro de afuera, unido a las esquinas (el joystick tiene sombras negras adentro)."""
    out = im.convert("RGBA")
    px = out.load()
    w, h = out.size
    queue = deque([(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)])
    seen = set(queue)
    while queue:
        x, y = queue.popleft()
        px[x, y] = (0, 0, 0, 0)
        for n in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if 0 <= n[0] < w and 0 <= n[1] < h and n not in seen and max(px[n][:3]) < limit:
                seen.add(n)
                queue.append(n)
    return out


def main(root):
    ring = key_black(Image.open(os.path.join(root, "art_src/ui/ruleta_qwen.png")), 12, 40)
    ring = ring.crop(ring.getbbox()).resize((1000, 1000), Image.LANCZOS)
    ring.save(os.path.join(root, "sprites/ui/ruleta.png"))
    pad = Image.open(os.path.join(root, "art_src/ui/joystick_qwen.png")).convert("RGB")
    pad.paste(pad.crop((650, 325, 760, 415)), (650, 415))
    pad = key_outside(pad, 26)
    pad.resize((pad.width // 2, pad.height // 2), Image.LANCZOS).save(os.path.join(root, "sprites/ui/joystick.png"))


if __name__ == "__main__":
    main(sys.argv[1])
