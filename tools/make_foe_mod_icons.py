"""Íconos de las mejoras enemigas del Modo Desafío (pixel art de 16×16 hecho por código) → sprites/ui/mejoras_enemigas/.
Uso: python -I -B tools/make_foe_mod_icons.py .   (después: godot --headless --path . --import)   Necesita Pillow."""
import os
import sys
from PIL import Image

# '.' = transparente, '#' = borde oscuro, 'a' = color principal, 'b' = claro, 'c' = sombra
ICONS = {
    "furioso": ((225, 60, 50), [
        "................",
        "...........###..",
        "..........#bb#..",
        ".........#bab#..",
        "........#bab#...",
        ".......#bab#....",
        "......#bab#.....",
        "..#..#bab#......",
        ".#c##bab#.......",
        ".#cc#ab#........",
        "..#ccc#.........",
        ".#cc#cc#........",
        "#cc#.#cc#.......",
        "#c#...##........",
        ".#..............",
        "................"]),
    "blindado": ((120, 150, 190), [
        "................",
        "..############..",
        ".#bbbbbaaaaaac#.",
        ".#bbbbaaaaaacc#.",
        ".#bbbaaaaaaccc#.",
        ".#bbaaaaaacccc#.",
        ".#baaaaaaccccc#.",
        ".#aaaaaacccccc#.",
        ".#aaaaaccccccc#.",
        "..#aaaccccccc#..",
        "..#aacccccccc#..",
        "...#acccccc#....",
        "....#ccccc#.....",
        ".....#ccc#......",
        "......###.......",
        "................"]),
    "ardiente": ((240, 120, 30), [
        "................",
        ".......#........",
        "......#a#.......",
        "......#a#..#....",
        ".....#aa#.#a#...",
        "....#aaa##aa#...",
        "...#aaaa#aaa#...",
        "...#aabaaaaaa#..",
        "..#aabbaaabaa#..",
        "..#aabbbabbaa#..",
        "..#aabbbbbbaa#..",
        "..#caabbbbaac#..",
        "...#caabbaac#...",
        "....#ccaacc#....",
        ".....######.....",
        "................"]),
    "electrico": ((245, 210, 50), [
        "................",
        ".........####...",
        "........#bba#...",
        ".......#bba#....",
        "......#bba#.....",
        ".....#bba#......",
        "....#bbaa####...",
        "...#bbaaaaaa#...",
        "...####aaac#....",
        "......#aac#.....",
        ".....#aac#......",
        "....#aac#.......",
        "....#ac#........",
        "...#ac#.........",
        "...###..........",
        "................"]),
    "curtido": ((190, 150, 100), [
        "................",
        "......####......",
        "....##bbaa##....",
        "...#bbbaaaac#...",
        "..#bbbaaaaacc#..",
        "..#bbaaa#aacc#..",
        ".#bbaaa#aaaccc#.",
        ".#baaa####accc#.",
        ".#aaaaaa#aaccc#.",
        ".#aaa#aaaacccc#.",
        "..#aa##aacccc#..",
        "..#aaaaaccccc#..",
        "...#aacccccc#...",
        "....##cccc##....",
        "......####......",
        "................"]),
    "regenerador": ((70, 200, 110), [
        "................",
        "................",
        "......####......",
        "......#bb#......",
        "......#ba#......",
        "......#ba#......",
        "..#####aa#####..",
        "..#bbbaaaaaac#..",
        "..#aaaaaaaacc#..",
        "..#####aa#####..",
        "......#ac#......",
        "......#ac#......",
        "......#cc#......",
        "......####......",
        "................",
        "................"]),
}


def main(root):
    out = os.path.join(root, "sprites/ui/mejoras_enemigas")
    os.makedirs(out, exist_ok=True)
    for name, (col, rows) in ICONS.items():
        img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
        light = tuple(min(255, int(c + (255 - c) * 0.55)) for c in col)
        dark = tuple(int(c * 0.6) for c in col)
        pal = {"#": (25, 18, 30, 255), "a": col + (255,), "b": light + (255,), "c": dark + (255,)}
        for y, row in enumerate(rows):
            assert len(row) == 16, (name, y)
            for x, ch in enumerate(row):
                if ch in pal:
                    img.putpixel((x, y), pal[ch])
        img.save(os.path.join(out, name + ".png"))
    print("%d íconos" % len(ICONS))


if __name__ == "__main__":
    main(sys.argv[1])
