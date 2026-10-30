"""Repinta una zona entera con IA (docs/PLAN_TERRENO_PROPIO.md, "Repintado"): maquetas limpias de la zona en trozos,
Qwen-Image 2.1 (ComfyUI local) repinta cada uno respetando la distribución, y se cosen con un corte de mínimo error.
Sale art/skins/<skin>/<zona>.png (+ .json con la escala y el prompt): la skin del mundo que se elige en Ajustes del
juego (PaintedZone la dibuja en lugar de los tiles).

Uso:
  python -I -B tools/repaint_zone.py <proyecto> <zona> [--skin hd] [--forest 0,1] [--redo 0] [--seed 21] [--width 40] [--overlap 8] [--size 1792]
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


## Luz horneada por momento del día (--relight): Qwen re-ilumina cada trozo ya repintado y se cose igual. Sale
## <zona>@<momento>.png; la imagen sin @ es el mediodía.
## Solo luz, color de la luz y sombras: nada que se pueda "dibujar" (brillitos, rocío, niebla, luciérnagas, partículas),
## porque Qwen lo pinta encima de la textura (ver docs/QWEN_PROMPTS.md).
RELIGHT_KEEP = ("Relight this top-down 2D game scene while keeping absolutely everything else identical: the same layout, the "
                "same buildings, trees, paths, fences, flowers, water and every object at exactly the same position, shape "
                "and size, the same camera and the same pixel art details and textures. Do not add anything: no new flowers, "
                "plants, particles, sparkles or details. Only change the lighting, the color of the light and the shadows:")
RELIGHT = {
    "manana": "early morning: a low, soft golden sun from the right; every house and tree casts a long soft shadow to the "
              "left; the shadows are slightly cool blue; the lit sides are warm and pale; the whole scene is a bit cooler "
              "and softer than at noon, with gentle contrast.",
    "atardecer": "sunset light: deep orange sun from the left casting long soft shadows to the right, warm rim light on "
                 "roofs and treetops, purple shade, soft contact shadows and ambient occlusion, a gentle warm glow in the air.",
    "noche": "night: dark blue moonlit scene, every house window glowing warm yellow and casting a soft pool of light on "
             "the ground below it, soft contact shadows, ambient occlusion, everything still readable but clearly night. "
             "No street lamps added, no fireflies, no stars.",
}


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


def queue(image_name, prompt, seed, size, prefix):
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
        "8": {"class_type": "VAEDecode", "inputs": {"samples": ["7", 0], "vae": ["3", 0]}},
        "9": {"class_type": "SaveImage", "inputs": {"images": ["8", 0], "filename_prefix": prefix}},
    }
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
    ap.add_argument("--overlap", type=int, default=8)
    ap.add_argument("--size", type=int, default=1792, help="presupuesto de píxeles de Qwen (lado)")
    ap.add_argument("--style", default=PALETTE)
    ap.add_argument("--skin", default="hd", help="skin del mundo (carpeta art/skins/<skin>/)")
    ap.add_argument("--only-stitch", action="store_true")
    ap.add_argument("--redo", default="", help="repintar solo estos trozos (ej.: 0,2) y volver a coser")
    ap.add_argument("--forest", default="", help="trozos que son solo bosque (ej.: 0): prompt de bosque")
    ap.add_argument("--relight", default="", help="momentos del día a hornear desde lo ya pintado (ej.: manana,atardecer,noche)")
    a = ap.parse_args()
    root = os.path.abspath(a.root)
    zx, zy, zw, zh = zone_rect(root, a.zone)
    work = os.path.join(root, "out", "repintado", a.zone)
    os.makedirs(work, exist_ok=True)
    open(os.path.join(root, "out", ".gdignore"), "a").close()  # que Godot no importe los cuadros de trabajo
    xs = chunks(zx, zw, a.width, a.overlap)
    cw = min(a.width, zw)
    print("%s: %dx%d celdas, %d trozos de %dx%d en x=%s" % (a.zone, zw, zh, len(xs), cw, zh, xs))
    prompt = " ".join([KEEP, RICH, a.style])
    results = []
    if a.relight:
        relight(root, a, work, xs, cw, zw, zh)
        return
    redo = {int(v) for v in a.redo.split(",") if v.strip()} if a.redo else None
    if not a.only_stitch:
        ids = []
        for i, x in enumerate(xs):
            if redo is not None and i not in redo:
                ids.append(None)
                continue
            maq = os.path.join(work, "maqueta_%d.png" % i)
            render_maqueta(root, (x, zy, cw, zh), maq)
            forest = {int(v) for v in a.forest.split(",") if v.strip()}
            p = " ".join([FOREST, a.style]) if i in forest else prompt
            ids.append(queue(upload(maq), p, a.seed, a.size, "repintado/%s_%d" % (a.zone, i)))
            print("  trozo %d encolado" % i, flush=True)
        for i, pid in enumerate(ids):
            if pid is None:
                continue
            src = wait_output(pid)
            dst = os.path.join(work, "pintado_%d.png" % i)
            shutil.copy(src, dst)
            print("  trozo %d listo" % i, flush=True)
    stitch(root, a.skin, a.zone, [os.path.join(work, "pintado_%d.png" % i) for i in range(len(xs))], xs, cw, zw, zh,
           {"seed": a.seed, "prompt": prompt})


def relight(root, a, work, xs, cw, zw, zh):
    moments = [m.strip() for m in a.relight.split(",") if m.strip()]
    jobs = []
    for m in moments:
        for i in range(len(xs)):
            src = os.path.join(work, "pintado_%d.png" % i)
            jobs.append((m, i, queue(upload(src), RELIGHT_KEEP + " " + RELIGHT[m], a.seed, a.size,
                                     "repintado/%s_%s_%d" % (a.zone, m, i))))
    print("  %d re-iluminaciones encoladas" % len(jobs), flush=True)
    for m, i, pid in jobs:
        shutil.copy(wait_output(pid), os.path.join(work, "luz_%s_%d.png" % (m, i)))
        print("  %s %d listo" % (m, i), flush=True)
    for m in moments:
        stitch(root, a.skin, a.zone + "@" + m, [os.path.join(work, "luz_%s_%d.png" % (m, i)) for i in range(len(xs))],
               xs, cw, zw, zh, {"moment": m, "prompt": RELIGHT_KEEP + " " + RELIGHT[m]})


def stitch(root, skin, name, files, xs, cw, zw, zh, info):
    paints = [Image.open(f).convert("RGB") for f in files]
    # Escala común: píxeles por celda del primer trozo.
    ppc = paints[0].width / cw
    H = round(zh * ppc)
    paints = [p.resize((round(cw * ppc), H), Image.LANCZOS) for p in paints]
    full = paints[0]
    for i in range(1, len(xs)):
        ov_cells = (xs[i - 1] + cw) - xs[i]
        # Lo que ya está cosido termina en xs[i-1]+cw; el trozo nuevo empieza ov_cells antes.
        full = min_cut_join(full, paints[i], round(ov_cells * ppc))
    full = full.resize((round(zw * ppc), H), Image.LANCZOS)
    out_dir = os.path.join(root, "art", "skins", skin)
    os.makedirs(out_dir, exist_ok=True)
    full.save(os.path.join(out_dir, name + ".png"))
    info = dict(info, cells=[zw, zh], px_per_cell=full.width / zw)
    with open(os.path.join(out_dir, name + ".json"), "w", encoding="utf8", newline="\n") as f:
        json.dump(info, f, ensure_ascii=False, indent=1)
    print("listo:", os.path.join(out_dir, name + ".png"), full.size)


if __name__ == "__main__":
    main()
