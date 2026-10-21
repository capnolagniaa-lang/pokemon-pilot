"""Genera art/icon.png e icon.ico (Poké Ball ampliada en pixel art) para el acceso directo y la ventana.
Uso: python -I tools/make_icon.py <carpeta del proyecto>
"""
import os
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pret_import as P  # noqa: E402  (lector/escritor de PNG sin dependencias)


def scaled(src, size):
    """Escala con vecino más cercano a size x size, centrado y con margen."""
    w, h = src["w"], src["h"]
    inner = int(size * 0.9)
    s = inner / max(w, h)
    off = (size - inner) // 2
    c = P.Canvas(size, size)
    for y in range(size):
        for x in range(size):
            sx, sy = int((x - off) / s), int((y - off) / s)
            if 0 <= sx < w and 0 <= sy < h:
                p = src["px"][sy][sx]
                if isinstance(p, int):  # PNG con paleta: color + transparencia (tRNS)
                    a = src["trns"][p] if p < len(src["trns"]) else 255
                    p = (*src["plte"][p], a)
                elif len(p) == 3:
                    p = (*p, 255)
                if p[3]:
                    c.set(x, y, p)
    return c


def main():
    root = sys.argv[1]
    src = P.read_png(os.path.join(root, "sprites", "items", "poke-ball.png"))
    png_path = os.path.join(root, "art", "icon.png")
    P.write_png(png_path, scaled(src, 256))
    # ICO con varias resoluciones embebidas como PNG (soportado desde Windows Vista).
    images = []
    for size in (16, 32, 48, 64, 128, 256):
        tmp = os.path.join(root, "art", "_icon_%d.png" % size)
        P.write_png(tmp, scaled(src, size))
        images.append((size, open(tmp, "rb").read()))
        os.remove(tmp)
    header = struct.pack("<HHH", 0, 1, len(images))
    entries, data = b"", b""
    offset = 6 + 16 * len(images)
    for size, blob in images:
        dim = 0 if size == 256 else size
        entries += struct.pack("<BBBBHHII", dim, dim, 0, 0, 1, 32, len(blob), offset)
        data += blob
        offset += len(blob)
    with open(os.path.join(root, "icon.ico"), "wb") as f:
        f.write(header + entries + data)
    print("icon.ico y art/icon.png listos")


if __name__ == "__main__":
    main()
