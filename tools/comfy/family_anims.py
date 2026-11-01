# Animaciones por familia de movimiento (move_families.py), por especie, con Qwen-Image 2.1 Turbo (ComfyUI en :8188).
# NO toca el juego: todo queda en out/animaciones/ (no se sube) para revisarlo antes (pedido del usuario 2026-11-01).
#
#   python -I -B tools/comfy/family_anims.py <n.º | desde-hasta | n.º,n.º,...> [--seeds 1234] [--only familia,familia]
#
# Por especie y familia: out/animaciones/<n.º>_<nombre>/<familia>/d<fila>_s<semilla>.png (lo de la IA, 5 direcciones),
# <familia>.png (hoja de 8 filas a 32 px, como iría al juego) y <familia>.gif (las 8 direcciones en rosa de los vientos,
# lento, con el Idle en el centro). Lo ya generado no se repite. Al terminar cada especie rehace la página de revisión
# (review_page.py). Descripciones de cada especie para el prompt: species_desc.json.
import json, os, sys, time
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import move_families as mf  # noqa: E402
import strike_sheet as ss  # noqa: E402

OUT = os.path.join(ss.ROOT, "out", "animaciones")
DESC = json.load(open(os.path.join(HERE, "species_desc.json"), encoding="utf-8"))
# dónde va cada fila de la hoja en la rosa de 3×3 (columna, fila): 0 abajo, 1 abajo-der., 2 der., 3 arriba-der., 4 arriba,
# 5 arriba-izq., 6 izq., 7 abajo-izq.
COMPASS = [(1, 2), (2, 2), (2, 1), (2, 0), (1, 0), (0, 0), (0, 1), (0, 2)]
GIF_MS = [100, 170, 140, 200]  # los cuadros, más lentos que en el juego para poder mirarlos
GIF_REST = 500
BG = (60, 120, 60, 255)


def species_name(d, dex):
    return next(s for s in d["species"].values() if s["dex"] == dex)["name_es"]


def folder_name(d, dex):
    n = species_name(d, dex)
    keep = "".join(c for c in n.lower() if c.isalnum())
    return "%04d_%s" % (dex, keep)


def compass_gif(num, sheet, cw, ch, path):
    fw, fh = ss.idle_info(num)
    idle, _, _ = ss.idle_row(num, 0)
    center = Image.new("RGBA", (cw, ch))
    center.alpha_composite(idle[0], (ss.PAD, ss.PAD))
    frames = []
    for i in range(ss.N + 1):
        f = Image.new("RGBA", (cw * 3, ch * 3), BG)
        f.alpha_composite(center, (cw, ch))
        for r, (cx, cy) in enumerate(COMPASS):
            col = min(i, ss.N - 1)
            f.alpha_composite(sheet.crop((col * cw, r * ch, (col + 1) * cw, (r + 1) * ch)), (cx * cw, cy * ch))
        frames.append(f.resize((f.width * 3, f.height * 3), Image.NEAREST).convert("RGB"))
    frames[0].save(path, save_all=True, append_images=frames[1:], duration=GIF_MS + [GIF_REST], loop=0)


def run_species(d, dex, seeds, only=None):
    name = species_name(d, dex)
    desc = DESC.get(str(dex))
    if desc is None:
        print("%d %s: sin descripción en species_desc.json, la salteo" % (dex, name))
        return False
    label = desc if desc.startswith(name) else "%s (%s)" % (name, desc)
    fams = mf.species_families(d, dex)
    base = os.path.join(OUT, folder_name(d, dex))
    info = {"dex": dex, "name": name, "families": {}}
    for fam, moves in fams.items():
        if only and fam not in only:
            continue
        out = os.path.join(base, fam)
        t0 = time.time()
        title, action = mf.FAMILIES[fam]
        ss.gen(dex, label, action.replace("{n}", name), out, seeds, kind="attack", preview=False)
        sheet, cw, ch = ss.sheet_of(dex, out, [seeds[0]] * 5)
        sheet.save(os.path.join(out, fam + ".png"))
        compass_gif(dex, sheet, cw, ch, os.path.join(out, fam + ".gif"))
        info["families"][fam] = {"title": title, "moves": moves}
        print("%d %s / %s: %.0f s" % (dex, name, fam, time.time() - t0), flush=True)
    os.makedirs(base, exist_ok=True)
    old = os.path.join(base, "info.json")
    if os.path.exists(old):  # (con --only se suman a lo que ya estaba)
        prev = json.load(open(old, encoding="utf-8"))
        prev["families"].update(info["families"])
        info = prev
    json.dump(info, open(old, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    return True


def parse_dexes(arg):
    out = []
    for part in arg.split(","):
        if "-" in part:
            a, b = part.split("-")
            out += list(range(int(a), int(b) + 1))
        else:
            out.append(int(part))
    return out


if __name__ == "__main__":
    args = sys.argv[1:]
    seeds = [1234]
    only = None
    if "--seeds" in args:
        seeds = [int(s) for s in args[args.index("--seeds") + 1].split(",")]
    if "--only" in args:
        only = set(args[args.index("--only") + 1].split(","))
    d = mf.data()
    import review_page  # noqa: E402
    for dex in parse_dexes(args[0]):
        if run_species(d, dex, seeds, only):
            review_page.write()
