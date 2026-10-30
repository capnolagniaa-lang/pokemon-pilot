"""Repinta una zona entera con IA (docs/PLAN_TERRENO_PROPIO.md, "Repintado"): maquetas limpias de la zona en trozos,
Qwen-Image 2.1 (ComfyUI local) repinta cada uno respetando la distribución, y se cosen con un corte de mínimo error.
Sale art/skins/<skin>/<zona>.png (+ .json con la escala y el prompt): la skin del mundo que se elige en Ajustes del
juego (PaintedZone la dibuja en lugar de los tiles).

Uso:
  python -I -B tools/repaint_zone.py <proyecto> <zona> [--skin hd] [--forest 0,1] [--redo 0] [--night] [--seed 21] [--width 40] [--overlap 8] [--size 1792]
         [--style "texto extra de estilo"] [--only-stitch]

Pasos: 1) Godot renderiza cada trozo (--overview --overview-rect --clean). 2) Los sube a ComfyUI y encola Qwen.
3) Espera, baja los resultados y cose en horizontal (la zona va en una fila de trozos del alto completo).
Necesita ComfyUI corriendo en 127.0.0.1:8188 con los modelos de Qwen-Image 2.1 (docs/COMFYUI.md) y Pillow.
"""
import argparse, json, os, re, shutil, subprocess, sys, time, urllib.request, uuid

from PIL import Image, ImageFilter

GODOT = r"C:\Users\Gusti\Documents\claude\tools\godot\Godot_v4.7.2-stable_win64_console.exe"
COMFY = "http://127.0.0.1:8188"
COMFY_OUT = r"C:\Users\Gusti\ComfyUI\ComfyUI_windows_portable\ComfyUI\output"
TILE = 16

KEEP = ("Repaint this top-down 2D RPG screenshot as a beautiful HD-2D game scene. Keep EXACTLY the same layout and "
        "composition: every building, every tree, every fence, sign, mailbox, flower bed, ledge and object stays at exactly "
        "the same position, size and outline, and every path, water and grass area keeps its exact shape. The camera "
        "stays straight top-down with walls facing the viewer; no isometric angle, no perspective change, no zoom, no crop. "
        "Do not add anything that is not in the original image: no new houses, buildings, paths or objects; an area that "
        "is only trees stays only trees.")
RICH = ("Make it look like a polished modern HD-2D game: much richer detail and texture everywhere, every surface hand "
        "painted with many small details, varied grass with darker and lighter patches, small stones, clover and "
        "wildflowers scattered in the grass, worn dirt at the doorsteps, weathered roofs with individual tiles, plants and "
        "small details around the houses, trees with depth and volume, gentle ambient occlusion at the base of walls and "
        "trees. Neutral soft daylight from above, no strong cast shadows, no fog, no vignette. No text, no characters, no "
        "animals.")
## Trozo que es solo bosque (--forest 0,1): sin la lista de edificios (Qwen los inventa en una grilla de árboles).
FOREST = ("Repaint this top-down 2D RPG screenshot as a beautiful HD-2D game scene. This area is only a dense forest: "
          "rows of trees seen from above. Keep exactly the same trees at the same positions and the same grass between "
          "them, the same camera straight top-down. Paint lush, detailed tree crowns with depth and volume, varied greens, "
          "grass and small plants between them. Only trees and grass: absolutely no houses, no roofs, no buildings, no "
          "paths, no fences, no objects. Neutral soft daylight from above, no strong cast shadows, no fog, no vignette. "
          "No text, no characters, no animals.")
PALETTE = "Use a natural, harmonious palette: deep natural greens for grass and trees, warm terracotta roofs, cream plaster walls."


## Noche (--night): se pinta desde la misma maqueta en una sola pasada, con la luz de noche en el prompt (re-iluminar la
## pintura de día con Qwen rompe la textura: docs/QWEN_PROMPTS.md). Sale <zona>@noche.png; las ondas, el Daylight y
## la mezcla con la de día los pone el juego (PaintedZone).
NIGHT = ("It is night: a calm dark blue moonlit night. Every house window glows warm yellow and casts a soft pool of warm "
         "light on the ground right in front of it; doors stay closed. Cool blue moonlight from above, deep but readable "
         "shadows, the scene clearly at night but every shape still visible. No street lamps, no fireflies, no stars, no "
         "fog, no sparkles, nothing added.")
## Noche de un trozo de puro bosque: sin ventanas (si no, Qwen inventa casitas con la ventana prendida entre los árboles).
NIGHT_FOREST = ("It is night: a calm moonlit night. Soft cool blue moonlight from above on the tree crowns, the grass between "
                "them in deep but readable shade, every tree still clearly visible. No lights at all: no windows, no lamps, "
                "no houses, no fireflies, no stars, no fog, no sparkles, nothing added.")


def zone_rect(root, zone):
    s = open(os.path.join(root, "data/world/kanto.tres"), encoding="utf8").read()
    i = s.index('id = "%s"' % zone)
    block = s[s.rfind("[sub_resource", 0, i):s.find("[sub_resource", i)]
    o = re.search(r"origin = Vector2i\((-?\d+), (-?\d+)\)", block)
    z = re.search(r"\nsize = Vector2i\((\d+), (\d+)\)", block)
    return int(o.group(1)), int(o.group(2)), int(z.group(1)), int(z.group(2))


def chunks(x0, w, cw, ov):
    """Comienzos (en celdas) de los trozos de ancho cw con solapamiento ov que cubren [x0, x0+w)."""
    if w <= cw:
        return [x0]
    out, x = [], x0
    while x + cw < x0 + w:
        out.append(x)
        x += cw - ov
    out.append(x0 + w - cw)
    return out


def render_maqueta(root, rect, path):
    tmp = os.path.join(os.path.dirname(path), "_movie")
    shutil.rmtree(tmp, ignore_errors=True)
    os.makedirs(tmp)
    # La vista general se cierra sola cuando el encuadre está listo (y avisa en qué cuadro); --quit-after es de seguridad.
    run = subprocess.run([GODOT, "--path", root, "--quit-after", "20000", "--write-movie", os.path.join(tmp, "f.png"),
                          "--fixed-fps", "30", "--", "--overview", "--overview-rect", "%d,%d,%d,%d" % rect, "--clean"],
                         capture_output=True, text=True, encoding="utf8", errors="replace", timeout=900)
    if "[overview] listo" not in run.stdout:
        raise SystemExit("La maqueta no llegó a encuadrarse (¿la vista general no corrió?):\n" + run.stdout[-2000:])
    last = sorted(f for f in os.listdir(tmp) if f.endswith(".png"))[-1]
    im = Image.open(os.path.join(tmp, last)).convert("RGB")
    # La cámara encuadra el rect con el zoom que entra: recortar justo el rect (centrado en la pantalla).
    vw, vh = im.size
    z = min(vw / (rect[2] * TILE), vh / (rect[3] * TILE))
    rw, rh = round(rect[2] * TILE * z), round(rect[3] * TILE * z)
    im = im.crop(((vw - rw) // 2, (vh - rh) // 2, (vw - rw) // 2 + rw, (vh - rh) // 2 + rh))
    im.save(path)
    shutil.rmtree(tmp, ignore_errors=True)


def upload(path):
    name = "rep_" + os.path.basename(path)
    b = uuid.uuid4().hex
    body = (f'--{b}\r\nContent-Disposition: form-data; name="image"; filename="{name}"\r\nContent-Type: image/png\r\n\r\n').encode() \
        + open(path, "rb").read() + f'\r\n--{b}\r\nContent-Disposition: form-data; name="overwrite"\r\n\r\ntrue\r\n--{b}--\r\n'.encode()
    urllib.request.urlopen(urllib.request.Request(COMFY + "/upload/image", body, {"Content-Type": f"multipart/form-data; boundary={b}"}))
    return name


## Qwen-Image 2.1 Turbo (8 pasos): como en la plantilla oficial de ComfyUI (image_qwen_image_2_1_turbo_image_edit).
TURBO_SIGMAS = "1.0, 0.978453, 0.95418, 0.926626, 0.89508, 0.845148, 0.704534, 0.414568, 0"


def queue(image_name, prompt, seed, size, prefix, turbo=False):
    api = {
        "1": {"class_type": "UNETLoader", "inputs": {"unet_name": "qwen_image_2.1_int8_convrot.safetensors", "weight_dtype": "default"}},
        "2": {"class_type": "CLIPLoader", "inputs": {"clip_name": "qwen3vl_8b_w4a8.safetensors", "type": "qwen_image", "device": "default"}},
        "3": {"class_type": "VAELoader", "inputs": {"vae_name": "qwen_image_2.1_vae_bf16.safetensors"}},
        "4": {"class_type": "QwenImage21Cache", "inputs": {"model": ["1", 0], "device": "auto", "dtype": "default"}},
        "5": {"class_type": "LoadImage", "inputs": {"image": image_name}},
        "6": {"class_type": "TextEncodeQwenImage21", "inputs": {"clip": ["2", 0], "vae": ["3", 0], "prompt": prompt,
              "negative_prompt": "", "resolution": size, "images.image_1": ["5", 0]}},
        "7": {"class_type": "KSampler", "inputs": {"model": ["4", 0], "positive": ["6", 0], "negative": ["6", 1],
              "latent_image": ["6", 2], "seed": seed, "steps": 25, "cfg": 1.0, "sampler_name": "euler", "scheduler": "simple", "denoise": 1.0}},
        "7b": None,
        "8": {"class_type": "VAEDecode", "inputs": {"samples": ["7", 0], "vae": ["3", 0]}},
        "9": {"class_type": "SaveImage", "inputs": {"images": ["8", 0], "filename_prefix": prefix}},
    }
    del api["7b"]
    if turbo:
        api["1"]["inputs"]["unet_name"] = "qwen_image_2.1_turbo_int8_convrot.safetensors"
        api["7"] = {"class_type": "SamplerCustomAdvanced", "inputs": {"noise": ["20", 0], "guider": ["21", 0],
                    "sampler": ["22", 0], "sigmas": ["23", 0], "latent_image": ["6", 2]}}
        api["20"] = {"class_type": "RandomNoise", "inputs": {"noise_seed": seed}}
        api["21"] = {"class_type": "CFGGuider", "inputs": {"model": ["4", 0], "positive": ["6", 0], "negative": ["6", 1], "cfg": 1.0}}
        api["22"] = {"class_type": "KSamplerSelect", "inputs": {"sampler_name": "euler"}}
        api["23"] = {"class_type": "ManualSigmas", "inputs": {"sigmas": TURBO_SIGMAS}}
    r = json.load(urllib.request.urlopen(urllib.request.Request(COMFY + "/prompt", json.dumps({"prompt": api}).encode(),
                                                                {"Content-Type": "application/json"})))
    return r["prompt_id"]


def wait_output(prompt_id):
    while True:
        h = json.load(urllib.request.urlopen(COMFY + "/history/" + prompt_id))
        if prompt_id in h:
            st = h[prompt_id]["status"]
            if st.get("status_str") == "error":
                raise SystemExit("ComfyUI falló en " + prompt_id)
            for out in h[prompt_id]["outputs"].values():
                for img in out.get("images", []):
                    return os.path.join(COMFY_OUT, img.get("subfolder", ""), img["filename"])
        time.sleep(5)


def min_cut_join(left, right, ovp):
    """Une `right` a la derecha de `left` (solapan ovp px) con un corte vertical de mínimo error."""
    H = left.height
    A = left.crop((left.width - ovp, 0, left.width, H))
    B = right.crop((0, 0, ovp, H))
    pa, pb = A.load(), B.load()
    margin = max(4, ovp // 10)
    prev = None
    back = []
    for y in range(H):
        row = []
        for x in range(ovp):
            ca, cb = pa[x, y], pb[x, y]
            e = abs(ca[0] - cb[0]) + abs(ca[1] - cb[1]) + abs(ca[2] - cb[2])
            if x < margin or x >= ovp - margin:
                e += 400
            row.append(e)
        if prev is None:
            cur, choice = row, [0] * ovp
        else:
            cur, choice = [0.0] * ovp, [0] * ovp
            for x in range(ovp):
                best, bx = prev[x], x
                if x > 0 and prev[x - 1] < best:
                    best, bx = prev[x - 1], x - 1
                if x < ovp - 1 and prev[x + 1] < best:
                    best, bx = prev[x + 1], x + 1
                cur[x], choice[x] = row[x] + best, bx
        back.append(choice)
        prev = cur
    x = min(range(ovp), key=lambda i: prev[i])
    path = [0] * H
    for y in range(H - 1, -1, -1):
        path[y] = x
        x = back[y][x]
    mask = Image.new("L", (ovp, H))
    mp = mask.load()
    F = 3
    for y in range(H):
        for xx in range(ovp):
            mp[xx, y] = int(255 * min(1.0, max(0.0, (xx - path[y] + F) / (2 * F))))
    seam = Image.composite(B, A, mask)
    out = Image.new("RGB", (left.width + right.width - ovp, H))
    out.paste(left, (0, 0))
    out.paste(right.crop((ovp, 0, right.width, H)), (left.width, 0))
    out.paste(seam, (left.width - ovp, 0))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("root")
    ap.add_argument("zone")
    ap.add_argument("--seed", type=int, default=21)
    ap.add_argument("--width", type=int, default=40, help="ancho de cada trozo en celdas")
    ap.add_argument("--height", type=int, default=36, help="alto máximo de cada trozo en celdas")
    ap.add_argument("--overlap", type=int, default=8)
    ap.add_argument("--size", type=int, default=1792, help="presupuesto de píxeles de Qwen (lado)")
    ap.add_argument("--style", default=PALETTE)
    ap.add_argument("--skin", default="hd", help="skin del mundo (carpeta art/skins/<skin>/)")
    ap.add_argument("--quality", action="store_true", help="modelo normal (25 pasos) en vez de Turbo (8): un poco más detalle, 3x más lento")
    ap.add_argument("--only-stitch", action="store_true")
    ap.add_argument("--redo", default="", help="repintar solo estos trozos (ej.: 0,2) y volver a coser")
    ap.add_argument("--forest", default="auto", help="trozos que son solo bosque (ej.: 0), o auto (mira las maquetas)")
    ap.add_argument("--night", action="store_true", help="pintar la versión de noche (<zona>@noche.png) desde las maquetas")
    a = ap.parse_args()
    root = os.path.abspath(a.root)
    zx, zy, zw, zh = zone_rect(root, a.zone)
    work = os.path.join(root, "out", "repintado", a.zone)
    os.makedirs(work, exist_ok=True)
    open(os.path.join(root, "out", ".gdignore"), "a").close()  # que Godot no importe los cuadros de trabajo
    g = Grid(zx, zy, zw, zh, a.width, a.height, a.overlap)
    print("%s: %dx%d celdas, %d trozos de %dx%d (filas y=%s, columnas x=%s); trozo i = fila*%d + columna"
          % (a.zone, zw, zh, len(g.rects), g.cw, g.ch, g.ys, g.xs, len(g.xs)))
    forest = {int(v) for v in a.forest.split(",") if v.strip()}
    if a.forest == "auto":
        forest = {i for i, rect in enumerate(g.rects) if only_trees(os.path.join(work, "maqueta_%d.png" % i))}
        print("  trozos de puro bosque:", sorted(forest))
    redo = {int(v) for v in a.redo.split(",") if v.strip()} if a.redo else None
    day = " ".join([KEEP, RICH, a.style])
    tag = "noche" if a.night else "pintado"
    if not a.only_stitch:
        jobs = []
        for i, rect in enumerate(g.rects):
            if redo is not None and i not in redo:
                continue
            maq = os.path.join(work, "maqueta_%d.png" % i)
            if not a.night or not os.path.exists(maq):
                render_maqueta(root, rect, maq)
            if a.night:
                base = " ".join([FOREST if i in forest else " ".join([KEEP, RICH]), a.style])
                base = base.replace("Neutral soft daylight from above, no strong cast shadows, no fog, no vignette.", "")
                p = base + " " + (NIGHT_FOREST if i in forest else NIGHT)
            else:
                p = " ".join([FOREST, a.style]) if i in forest else day
            jobs.append((i, queue(upload(maq), p, a.seed, a.size, "repintado/%s_%s_%d" % (a.zone, tag, i), turbo=not a.quality)))
            print("  trozo %d encolado" % i, flush=True)
        for i, pid in jobs:
            shutil.copy(wait_output(pid), os.path.join(work, "%s_%d.png" % (tag, i)))
            print("  trozo %d listo" % i, flush=True)
    name = a.zone + ("@noche" if a.night else "")
    stitch(root, a.skin, name, g, [os.path.join(work, "%s_%d.png" % (tag, i)) for i in range(len(g.rects))],
           {"moment": "noche" if a.night else "dia", "seed": a.seed, "prompt": NIGHT if a.night else day,
            "turbo": not a.quality})


def only_trees(maq_path):
    """¿La maqueta (si ya existe) es puro verde (árboles y pasto, sin techos, caminos ni agua)? Mira los colores."""
    if not os.path.exists(maq_path):
        return False
    im = Image.open(maq_path).convert("RGB").resize((96, 96))
    px = list(im.get_flattened_data()) if hasattr(im, "get_flattened_data") else list(im.getdata())
    # Pasto de ciudad (verde claro, casi blanco) y techos/paredes no cuentan como bosque: verde saturado y oscuro.
    trees = sum(1 for r, g, b in px if g > r + 20 and g > b + 10 and g < 230)
    return trees / len(px) > 0.78


class Grid:
    """Trozos de la zona: columnas en x, filas en y, con solapamiento; rects en celdas del mundo."""

    def __init__(self, zx, zy, zw, zh, width, height, overlap):
        self.cw, self.ch = min(width, zw), min(height, zh)
        self.xs = chunks(zx, zw, width, overlap)
        self.ys = chunks(zy, zh, height, overlap)
        self.zx, self.zy, self.zw, self.zh = zx, zy, zw, zh
        self.rects = [(x, y, self.cw, self.ch) for y in self.ys for x in self.xs]


def stitch(root, skin, name, g, files, info):
    paints = [Image.open(f).convert("RGB") for f in files]
    ppc = paints[0].width / g.cw  # píxeles por celda (del primer trozo)
    W, H = round(g.cw * ppc), round(g.ch * ppc)
    paints = [p.resize((W, H), Image.LANCZOS) for p in paints]
    rows = []
    for r in range(len(g.ys)):
        row = paints[r * len(g.xs)]
        for c in range(1, len(g.xs)):
            ov = (g.xs[c - 1] + g.cw) - g.xs[c]
            row = min_cut_join(row, paints[r * len(g.xs) + c], round(ov * ppc))
        rows.append(row)
    full = rows[0]
    for r in range(1, len(rows)):
        ov = (g.ys[r - 1] + g.ch) - g.ys[r]
        # Costura horizontal = la vertical sobre las imágenes traspuestas.
        t = min_cut_join(full.transpose(Image.Transpose.TRANSPOSE), rows[r].transpose(Image.Transpose.TRANSPOSE), round(ov * ppc))
        full = t.transpose(Image.Transpose.TRANSPOSE)
    full = full.resize((round(g.zw * ppc), round(g.zh * ppc)), Image.LANCZOS)
    out_dir = os.path.join(root, "art", "skins", skin)
    os.makedirs(out_dir, exist_ok=True)
    full.save(os.path.join(out_dir, name + ".png"))
    info = dict(info, cells=[g.zw, g.zh], px_per_cell=full.width / g.zw, chunks=[len(g.xs), len(g.ys)])
    with open(os.path.join(out_dir, name + ".json"), "w", encoding="utf8", newline="\n") as f:
        json.dump(info, f, ensure_ascii=False, indent=1)
    print("listo:", os.path.join(out_dir, name + ".png"), full.size)


if __name__ == "__main__":
    main()
