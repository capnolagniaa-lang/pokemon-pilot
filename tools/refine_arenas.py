"""Pinturas en alta resolución de las salas del Modo Desafío y del castillo de Mew (pedido del usuario 2026-11-11: en
juego se veían pixeladas y con el suelo granulado). Por cada arena de data/arenas/pinturas.json que tenga `hd`:
  1. redibuja la pintura original entera (art_src/arenas/<id>.png, 1600x1200) con Qwen-Image 2.1 usándola de referencia:
     misma composición, pero pintada "HD-2D" (sin escalones de pixel art y con textura de verdad en el suelo);
  2. la agranda a 3200x2400 y le suma detalle fino por mosaicos (imagen a imagen, `--denoise` 0,85, con el mosaico de
     referencia), que es lo que la deja nítida con el zoom del juego;
  3. la guarda en sprites/arenas/<id>.jpg a 3072x2304 (x3 la resolución del juego en las salas; JPG: 1,6 MB contra 10 MB
     de PNG). tools/build_arenas.gd usa el .jpg si existe.
El plano de colisión NO cambia: tools/paint_arenas.py lo sigue sacando de la pintura original. `hd` del JSON = la
descripción del lugar para Qwen (qué hay y cómo es el suelo); `hd_sat` baja la saturación antes de redibujar.
Todo en tools/comfy/qwen21_refine.py (necesita ComfyUI prendido y Pillow).

Uso: python -I -B tools/refine_arenas.py . [<id> ...]     (sin ids: todas las que tienen `hd` y todavía no tienen .jpg)
Después: godot --headless --path . --import  y  build_arenas.gd -- --only <id>
"""
import json
import os
import subprocess
import sys

from PIL import Image

HEAD = ("Redraw this exact top-down RPG map as a sharp high-resolution HD-2D digital painting, keeping every object in exactly "
        "the same place, size and shape, adding no new objects and removing none. ")
TAIL = (" Sharp focus, crisp clean edges, intricate fine texture detail, rich lighting and soft shadows. No pixel art, no blur, "
        "no grain, no noise. No characters, no creatures, no text.")
SIZE = (3072, 2304)


def refine(root, arena_id, cfg, tmp):
    src = os.path.join(root, "art_src/arenas/%s.png" % arena_id)
    dst = os.path.join(root, "sprites/arenas/%s.jpg" % arena_id)
    tool = os.path.join(root, "tools/comfy/qwen21_refine.py")
    prompt = HEAD + cfg["hd"] + TAIL
    s1 = os.path.join(tmp, "%s_1.png" % arena_id)
    s2 = os.path.join(tmp, "%s_2.png" % arena_id)
    seed = str(int(cfg.get("seed", 1)))
    for args in (
        [src, s1, "--size", "1600x1200", "--blur", "0.8", "--sat", str(cfg.get("hd_sat", 1.0)), "--seed", seed],
        [s1, s2, "--size", "3200x2400", "--blur", "0", "--denoise", str(cfg.get("hd_denoise", 0.85)), "--seed", seed],
    ):
        r = subprocess.run([sys.executable, "-I", "-B", tool] + args + ["--prompt", prompt, "--tmp", tmp], capture_output=True, text=True)
        if r.returncode != 0:
            sys.exit("%s: %s" % (arena_id, (r.stderr or r.stdout)[-1500:]))
    Image.open(s2).convert("RGB").resize(SIZE, Image.LANCZOS).save(dst, quality=92)
    for old in (dst[:-4] + ".png", dst[:-4] + ".png.import"):  # (la pintura de antes, a x1,56)
        if os.path.exists(old):
            os.remove(old)
    point_to_jpg(root, arena_id)
    print("%-24s -> %s (%d KB)" % (arena_id, os.path.relpath(dst, root), os.path.getsize(dst) // 1024), flush=True)


def point_to_jpg(root, arena_id):
    """El ArenaData (data/arenas/<id>.tres) pasa a apuntar al .jpg (si quedara apuntando al .png borrado, no carga)."""
    import re
    path = os.path.join(root, "data/arenas/%s.tres" % arena_id)
    if not os.path.exists(path):
        return
    text = open(path, encoding="utf8").read()
    new = re.sub(r'\[ext_resource type="Texture2D"[^\]]*path="res://sprites/arenas/%s\.png"[^\]]*id="([^"]+)"\]' % re.escape(arena_id),
                 lambda m: '[ext_resource type="Texture2D" path="res://sprites/arenas/%s.jpg" id="%s"]' % (arena_id, m.group(1)), text)
    if new != text:
        open(path, "w", encoding="utf8", newline="\n").write(new)


def main(root, only):
    cfgs = json.load(open(os.path.join(root, "data/arenas/pinturas.json"), encoding="utf8"))
    tmp = os.path.join(os.environ.get("TEMP", "."), "refine_arenas")
    os.makedirs(tmp, exist_ok=True)
    for arena_id, cfg in cfgs.items():
        if arena_id.startswith("_") or not cfg.get("hd"):
            continue
        if only and arena_id not in only:
            continue
        if not only and os.path.exists(os.path.join(root, "sprites/arenas/%s.jpg" % arena_id)):
            continue
        refine(root, arena_id, cfg, tmp)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2:])
