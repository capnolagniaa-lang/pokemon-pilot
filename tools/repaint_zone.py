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

from PIL import Image, ImageChops, ImageFilter

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
## Trozo sin edificios (rutas): KEEP y RICH nombran casas, techos y puertas y Qwen las inventa (Ruta 1: dos casitas en
## un claro). Además le explica qué es cada cosa de FireRed: las líneas marrones son salientes (no cercas) y los bloques
## de pasto alto son pasto silvestre (no cultivos).
KEEP_WILD = ("Repaint this top-down 2D RPG screenshot of a countryside route as a beautiful HD-2D game scene. Keep EXACTLY "
             "the same layout and composition: every tree, every patch of tall grass, every ledge, flower bed and path stays "
             "at exactly the same position, size and outline. The camera stays straight top-down; no isometric angle, no "
             "perspective change, no zoom, no crop. There are no houses or buildings anywhere in this route: do not draw any "
             "house, roof, hut, barn or building.")
WILD_LEGEND = ("What the shapes are: the thin brown horizontal lines are low grassy ledges, small one-way earth steps with a "
               "grass edge on top and bare soil below, not fences; the blocks of darker grass are patches of tall wild grass "
               "drawn as thick untidy clumps, not crops or fields; the sandy areas are dirt paths.")
RICH_WILD = ("Make it look like a polished modern HD-2D game: much richer detail and texture everywhere, every surface hand "
             "painted, varied grass with darker and lighter patches, small stones, clover and wildflowers scattered in the "
             "grass, worn edges on the paths, trees with depth and volume, gentle ambient occlusion at the base of trees and "
             "ledges. Neutral soft daylight from above, no strong cast shadows, no fog, no vignette. No text, no characters, "
             "no animals.")
## Trozo mayormente bosque (sin edificios, >60 % árboles) con una franja abierta: con KEEP + la lista de edificios, Qwen
## raleaba el bosque en un claro e inventaba casitas; con este, respeta el bosque y la franja (prueba Ruta 1, 2026-10-30).
FOREST_MOSTLY = ("Repaint this top-down 2D RPG screenshot as a beautiful HD-2D game scene. This area is mostly a dense forest: "
                 "rows of trees seen from above, packed tightly together. Keep exactly the same trees at the same positions, "
                 "as dense as in the original, with the same camera straight top-down. Paint lush, detailed tree crowns with "
                 "depth and volume, varied greens. Where the original has open ground without trees, keep it open and keep "
                 "what is in it exactly where it is: %s. The thin brown horizontal lines are low grassy ledges (earth "
                 "steps), not fences. Absolutely no houses, no roofs, no buildings, no huts, no fences "
                 "or paths that are not in the original. Neutral soft daylight from above, no strong cast shadows, no fog, "
                 "no vignette. No text, no characters, no animals.")
## Acabado de cada skin (reemplaza a RICH / RICH_WILD en los prompts). "pixel" = estilo "indie rico", elegido por el
## usuario entre 6 estilos de pixel art (2026-10-30).
FINISH = {
    "pixel": ("Make it look like a lush modern indie pixel art game (like the most beautiful pixel art adventure games): "
              "dense hand-placed pixel detail, rich color ramps, careful dithering, small flowers, stones and grass tufts "
              "drawn pixel by pixel, depth with darker pixel shadows under roofs and trees. Neutral soft daylight from "
              "above, no strong cast shadows, no fog, no vignette. No text, no characters, no animals."),
}
## Pasto de pueblo (en FireRed es casi blanco, con brillitos): sin esto, en pixel art Qwen llena el claro con caminos y
## matas de pasto alto de RPG.
PLAIN_GRASS = ("The large plain pale green areas are open lawn of short grass: paint them as short grass richly detailed pixel "
               "by pixel, with subtle color variation, tiny flowers, clover and small pebbles scattered evenly; but do not "
               "add dirt paths, borders, tall grass patches, bushes or trees that are not in the original.")
PALETTE = "Use a natural, harmonious palette: deep natural greens for grass and trees, warm terracotta roofs, cream plaster walls."


## Noche (--night): se pinta desde la misma maqueta en una sola pasada, con la luz de noche en el prompt (re-iluminar la
## pintura de día con Qwen rompe la textura: docs/QWEN_PROMPTS.md). Sale <zona>@noche.png; las ondas, el Daylight y
## la mezcla con la de día los pone el juego (PaintedZone).
NIGHT = ("It is night: a calm dark blue moonlit night. Every house window glows warm yellow and casts a soft pool of warm "
         "light on the ground right in front of it; doors stay closed. Cool blue moonlight from above, deep but readable "
         "shadows, the scene clearly at night but every shape still visible. No street lamps, no fireflies, no stars, no "
         "fog, no sparkles, nothing added. Dirt paths, sand and paving are in the same dim cool blue moonlight as the "
         "grass, darker and greyer than by day, never bright beige. Every roof keeps its original color (a green roof "
         "stays green), only darker.")
## Noche de un trozo de puro bosque: sin ventanas (si no, Qwen inventa casitas con la ventana prendida entre los árboles).
NIGHT_FOREST = ("It is night: a calm moonlit night. Soft cool blue moonlight from above on the tree crowns, the grass between "
                "them in deep but readable shade, every tree still clearly visible. No lights at all: no windows, no lamps, "
                "no houses, no fireflies, no stars, no fog, no sparkles, nothing added. Dirt paths and sand are in the same "
                "dim cool blue moonlight, darker and greyer than by day, never bright beige.")


## Atardecer (--dusk; el juego también lo usa al amanecer, con otro tinte): luz dorada baja, sin sombras largas (al
## usuario no le gustaban las sombras proyectadas de casas y árboles), algunas ventanas recién prendidas.
DUSK = ("It is sunset: the sun is low in the west and the light is warm and golden, slightly dimmer than at midday. The "
        "grass and trees stay lush green, lit by warm golden-peach highlights on the sides facing the sun and soft "
        "rose-violet tones in the shade; roofs and walls glow warm. This is real warm evening light with color contrast, "
        "not a uniform yellow or orange filter over everything. No long cast shadows, no sun or sky visible, no lens "
        "flare, no fog. A few house windows are just starting to glow warm yellow. Every roof keeps its original color.")
DUSK_FOREST = ("It is sunset: the sun is low in the west and the light is warm and golden, slightly dimmer than at midday. "
               "The trees and grass stay lush green, lit by warm golden-peach highlights on the sides facing the sun and "
               "soft rose-violet tones in the shade. Real warm evening light with color contrast, not a uniform yellow or "
               "orange filter. No long cast shadows, no sun or sky visible, no lens flare, no fog, no lights, no houses.")


## Noche de un trozo abierto sin casas (rutas): NIGHT_FOREST habla de copas de árboles y pintaba árboles sobre el pasto
## alto (Ruta 22).
NIGHT_WILD = ("It is night: a calm moonlit night over the countryside. Soft cool blue moonlight from above on the grass, "
              "the patches of tall grass, the paths and the trees, everything in deep but readable shade and every shape "
              "the same as by day: tall grass stays tall grass. No lights at all: no windows, no lamps, no houses, no "
              "fireflies, no stars, no fog, no sparkles, nothing added. Dirt paths and sand are in the same dim cool blue "
              "moonlight, darker and greyer than by day, never bright beige.")


## Con pocas celdas de edificio (una puntita en el borde del trozo) el prompt con ventanas hacía que Qwen inventara casas
## prendidas (Ciudad Verde trozo 6: una en el estanque): ahí va el de sin luces.
LIT_MIN_CELLS = 20


def is_forest_prompt(p):
    return p.startswith(FOREST[:60]) and ("only a dense forest" in p or "mostly a dense forest" in p)


def lit(c):
    return c is None or c.get("edificio", 0) > LIT_MIN_CELLS


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
    """Maqueta limpia del pedazo + <path>.cells.json (cuántas celdas son árbol, pasto liso u otra cosa)."""
    tmp = os.path.join(os.path.dirname(path), "_movie")
    shutil.rmtree(tmp, ignore_errors=True)
    os.makedirs(tmp)
    # La vista general se cierra sola cuando el encuadre está listo (y avisa en qué cuadro); --quit-after es de seguridad.
    run = subprocess.run([GODOT, "--path", root, "--quit-after", "20000", "--write-movie", os.path.join(tmp, "f.png"),
                          "--fixed-fps", "30", "--", "--overview", "--overview-rect", "%d,%d,%d,%d" % rect, "--clean",
                          "--cells-out", os.path.abspath(path + ".cells.json")],
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
    # El nombre lleva la carpeta (skin y zona): con solo "maqueta_6" una tanda de otra zona pisaba la imagen en ComfyUI
    # antes de que corriera el trabajo encolado.
    parts = os.path.normpath(os.path.abspath(path)).split(os.sep)
    name = "rep_" + "_".join(parts[-3:])
    b = uuid.uuid4().hex
    body = (f'--{b}\r\nContent-Disposition: form-data; name="image"; filename="{name}"\r\nContent-Type: image/png\r\n\r\n').encode() \
        + open(path, "rb").read() + f'\r\n--{b}\r\nContent-Disposition: form-data; name="overwrite"\r\n\r\ntrue\r\n--{b}--\r\n'.encode()
    urllib.request.urlopen(urllib.request.Request(COMFY + "/upload/image", body, {"Content-Type": f"multipart/form-data; boundary={b}"}))
    return name


## Qwen-Image 2.1 Turbo (8 pasos): como en la plantilla oficial de ComfyUI (image_qwen_image_2_1_turbo_image_edit).
TURBO_SIGMAS = "1.0, 0.978453, 0.95418, 0.926626, 0.89508, 0.845148, 0.704534, 0.414568, 0"


def queue(image_name, prompt, seed, size, prefix, turbo=False, negative="", cfg=1.0):
    """`negative` y `cfg` > 1: solo con el modelo normal (Turbo usa cfg 1, que ignora el negativo)."""
    api = {
        "1": {"class_type": "UNETLoader", "inputs": {"unet_name": "qwen_image_2.1_int8_convrot.safetensors", "weight_dtype": "default"}},
        "2": {"class_type": "CLIPLoader", "inputs": {"clip_name": "qwen3vl_8b_w4a8.safetensors", "type": "qwen_image", "device": "default"}},
        "3": {"class_type": "VAELoader", "inputs": {"vae_name": "qwen_image_2.1_vae_bf16.safetensors"}},
        "4": {"class_type": "QwenImage21Cache", "inputs": {"model": ["1", 0], "device": "auto", "dtype": "default"}},
        "5": {"class_type": "LoadImage", "inputs": {"image": image_name}},
        "6": {"class_type": "TextEncodeQwenImage21", "inputs": {"clip": ["2", 0], "vae": ["3", 0], "prompt": prompt,
              "negative_prompt": negative, "resolution": size, "images.image_1": ["5", 0]}},
        "7": {"class_type": "KSampler", "inputs": {"model": ["4", 0], "positive": ["6", 0], "negative": ["6", 1],
              "latent_image": ["6", 2], "seed": seed, "steps": 25, "cfg": cfg, "sampler_name": "euler", "scheduler": "simple", "denoise": 1.0}},
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
    ap.add_argument("--dusk", action="store_true", help="pintar la del atardecer (<zona>@atardecer.png; también es el amanecer)")
    a = ap.parse_args()
    root = os.path.abspath(a.root)
    zx, zy, zw, zh = zone_rect(root, a.zone)
    work = os.path.join(root, "out", "repintado" if a.skin == "hd" else "repintado_" + a.skin, a.zone)
    os.makedirs(work, exist_ok=True)
    open(os.path.join(root, "out", ".gdignore"), "a").close()  # que Godot no importe los cuadros de trabajo
    g = Grid(zx, zy, zw, zh, a.width, a.height, a.overlap)
    print("%s: %dx%d celdas, %d trozos de %dx%d (filas y=%s, columnas x=%s); trozo i = fila*%d + columna"
          % (a.zone, zw, zh, len(g.rects), g.cw, g.ch, g.ys, g.xs, len(g.xs)))
    redo = {int(v) for v in a.redo.split(",") if v.strip()} if a.redo else None
    todo = [i for i in range(len(g.rects)) if redo is None or i in redo]
    # Primero las maquetas (de día; la noche reusa las que ya están), así se puede ver cuáles son puro bosque.
    if not a.only_stitch:
        for i in todo:
            maq = os.path.join(work, "maqueta_%d.png" % i)
            if not (a.night or a.dusk) or not os.path.exists(maq):
                render_maqueta(root, g.rects[i], maq)
                print("  maqueta %d lista" % i, flush=True)
    if a.forest == "auto":
        forest = {i for i in range(len(g.rects)) if only_trees(os.path.join(work, "maqueta_%d.png" % i))}
        print("  trozos de puro bosque:", sorted(forest))
    else:
        forest = {int(v) for v in a.forest.split(",") if v.strip()}
    day = " ".join([KEEP, RICH, a.style])
    tag = "noche" if a.night else ("atardecer" if a.dusk else "pintado")
    if not a.only_stitch:
        jobs = []
        for i in todo:
            maq = os.path.join(work, "maqueta_%d.png" % i)
            p = finish(day_prompt(maq, a.style, i in forest), a.skin, maq)
            if a.night:
                p = p.replace("Neutral soft daylight from above, no strong cast shadows, no fog, no vignette.", "")
                c = cells_info(maq)
                p += " " + (NIGHT if lit(c) else (NIGHT_FOREST if is_forest_prompt(p) else NIGHT_WILD))
            elif a.dusk:
                p = p.replace("Neutral soft daylight from above, no strong cast shadows, no fog, no vignette.", "")
                c = cells_info(maq)
                p += " " + (DUSK if lit(c) else DUSK_FOREST)
            jobs.append((i, queue(upload(maq), p, a.seed, a.size, "repintado/%s_%s_%d" % (a.zone, tag, i), turbo=not a.quality)))
            print("  trozo %d encolado" % i, flush=True)
        for i, pid in jobs:
            shutil.copy(wait_output(pid), os.path.join(work, "%s_%d.png" % (tag, i)))
            print("  trozo %d listo" % i, flush=True)
    name = a.zone + ("@noche" if a.night else ("@atardecer" if a.dusk else ""))
    stitch(root, a.skin, name, g, [os.path.join(work, "%s_%d.png" % (tag, i)) for i in range(len(g.rects))],
           {"moment": tag if tag != "pintado" else "dia", "seed": a.seed,
            "prompt": NIGHT if a.night else (DUSK if a.dusk else day),
            "turbo": not a.quality})
    if a.night:
        darken_night_paths(os.path.join(root, "art", "skins", a.skin), a.zone)


def cells_info(maq_path):
    info = maq_path + ".cells.json"
    return json.load(open(info, encoding="utf8")) if os.path.exists(info) else None


def things_in(c):
    """Lo que hay en el suelo abierto del pedazo, en palabras (de las celdas)."""
    names = [name for key, name in [("camino", "dirt paths"), ("pasto_alto", "patches of tall wild grass"),
             ("saliente", "low grassy ledges (small earth steps)"), ("flores", "small flower beds"), ("cerca", "short fences"),
             ("agua", "water")] if c.get(key, 0) > 0]
    return ", ".join(names) if names else "short grass"


def finish(prompt, skin, maq_path=None):
    """Cambia el párrafo de acabado según la skin y, si el trozo tiene mucho pasto liso (pueblos), suma la aclaración
    del pasto (en un trozo de bosque esa frase hacía que Qwen abriera un claro)."""
    if skin not in FINISH:
        return prompt
    out = prompt.replace(RICH, FINISH[skin]).replace(RICH_WILD, FINISH[skin])
    if FINISH[skin] not in out:  # prompts de bosque: no tienen RICH, el acabado va al final
        out += " " + FINISH[skin]
    c = cells_info(maq_path) if maq_path else None
    if c is not None:
        total = max(1, c["arbol"] + c["pasto"] + c["otro"])
        if c["pasto"] / total > 0.3:
            out += " " + PLAIN_GRASS
    return out


## Aclaraciones según lo que hay en el trozo (cells.json): sin esto, las mesetas de roca escalonadas de FireRed salen
## como techos de tejas (Ciudad Verde, 2026-10-30).
ROCK_LEGEND = ("The pinkish-brown stepped areas are a raised natural rocky plateau with layered stone cliff terraces, "
               "seen from above: bare rock and earth, not roofs, not buildings, not tiles. Where that rock has vertical "
               "stripes it is a tall natural stone cliff face with rough vertical crevices, not a row of roofs, sheds or "
               "greenhouses. The thin rows of small green tree tops lying on the rock are glitches, not trees: remove them "
               "and fill the top of the plateau with what fits a wild rocky highland: scattered boulders, dry grass "
               "tufts, a few small hardy shrubs and wildflowers growing in the cracks. The plateau top stays open rocky "
               "ground: no forest, no rows of trees and no buildings on it. Long narrow strips of the same rock (one or "
               "two cells wide, with rounded ends) are low natural rock ridges of piled stones and boulders, not "
               "buildings, not greenhouses, not roofs.")


## Pasto alto en trozos con edificios (garitas, pueblos): sin esto salía como pasto liso (Ruta 2).
TALL_LEGEND = ("The blocks of darker green grass with small tufts are patches of tall wild grass: paint them as thick "
               "untidy clumps of tall grass, clearly taller and darker than the short lawn around them, not crops.")


## Bosques grandes en trozos que no son de bosque (con garitas o pueblos): la grilla de copitas iguales salía como una
## masa verde lisa o una pradera con matas (Ruta 2).
TREES_LEGEND = ("The large areas filled with a grid of identical small round tree crowns are a dense forest: paint every "
                "tree crown individually as a real tree seen from above, packed tightly in the same grid, never as grass, "
                "a meadow, hedges or a flat green mass. Blocks of tall grass are not trees: they stay tall grass.")


## Trozo sin agua: el pasto verde claro de FireRed salía como agua turquesa (Ruta 4).
NO_WATER = "There is no water anywhere in this area: the light mint green areas are short grass, the pale yellow areas are sand."


## Arena amarilla pálida (plazas y caminos de arena): sin esto, parte salía como pasto (Ciudad Celeste).
SAND_LEGEND = ("The large pale yellow areas are open ground of warm light packed sand (town square and sandy paths): "
               "paint all of them as sand with small pebbles, never as grass.")


## Plazas y calles de ciudad (gris casi blanco en FireRed): con PLAIN_GRASS salían como pasto claro.
PAVED_LEGEND = ("The very light grey, almost white areas are the paved town square and streets, not grass: paint them as "
                "a light warm packed-earth and sandy stone plaza with subtle paving stones, clearly different from the lawn.")


def sand_share(maq_path):
    """Parte de la maqueta que es arena amarilla pálida (plaza de Celeste, caminos de arena): esas celdas cuentan como
    pasto y, con PLAIN_GRASS, la mitad de la plaza salía verde."""
    if not maq_path or not os.path.exists(maq_path):
        return 0.0
    px = Image.open(maq_path).convert("RGB").resize((160, 144)).get_flattened_data()
    return sum(1 for r, g, b in px if r > 205 and g > 195 and b < 175 and r - b > 55) / len(px)


def paved_share(maq_path):
    """Parte de la maqueta que es pavimento de ciudad (gris casi blanco); no hay tag de celda que lo distinga del pasto."""
    if not maq_path or not os.path.exists(maq_path):
        return 0.0
    px = Image.open(maq_path).convert("RGB").resize((160, 144)).get_flattened_data()
    return sum(1 for r, g, b in px if min(r, g, b) > 195 and max(r, g, b) - min(r, g, b) < 22) / len(px)


def rock_share(maq_path):
    """Parte de la maqueta que es roca de meseta (rosado-marrón de FireRed). Hace falta además de las celdas: en la Ruta 22
    esas celdas tienen el tag "arbol" (son sólidas) y se contaban como bosque (salía bosque encima de la meseta)."""
    if not maq_path or not os.path.exists(maq_path):
        return 0.0
    px = Image.open(maq_path).convert("RGB").resize((160, 144)).get_flattened_data()
    return sum(1 for r, g, b in px if r > 170 and 35 <= r - b <= 70 and b < g < r and r - g > 15) / len(px)


def legends(c, maq_path=None):
    out = []
    # Solo por el color: las celdas de "roca" también cuentan paredes (garitas) y en la Ruta 2 la leyenda hacía que
    # Qwen inventara mesetas en medio del bosque.
    if rock_share(maq_path) > 0.1:  # (un techo rosado de edificio da ~0,06; las mesetas, 0,15 o más)
        out.append(ROCK_LEGEND)
    if c is not None and c.get("pasto_alto", 0) > 0:
        out.append(TALL_LEGEND)
    # (La roca de meseta a veces tiene el tag "arbol": se descuenta.)
    if c is not None and c["arbol"] / max(1, c["arbol"] + c["pasto"] + c["otro"]) - rock_share(maq_path) > 0.3:
        out.append(TREES_LEGEND)
    if c is not None and c.get("agua", 0) == 0:
        out.append(NO_WATER)
    if sand_share(maq_path) > 0.05:
        out.append(SAND_LEGEND)
    if paved_share(maq_path) > 0.05:
        out.append(PAVED_LEGEND)
    return " ".join(out)


def day_prompt(maq_path, style, pure_forest):
    """El prompt de día de un trozo según lo que tiene: puro bosque, mayormente bosque o lo general (con aviso de que no
    hay edificios cuando no los hay)."""
    c = cells_info(maq_path)
    extra = legends(c, maq_path)
    rocky = rock_share(maq_path) > 0.12  # mucha meseta: nunca los prompts de bosque (la llenaban de árboles)
    if pure_forest and not rocky:
        return " ".join([FOREST, style])
    if c is not None:
        total = max(1, c["arbol"] + c["pasto"] + c["otro"])
        if c.get("edificio", 0) == 0 and c["arbol"] / total > 0.6 and not rocky:
            return " ".join([FOREST_MOSTLY % things_in(c), extra, style])
        if c.get("edificio", 0) == 0:
            return " ".join([KEEP_WILD, WILD_LEGEND, extra, RICH_WILD, style])
    return " ".join([KEEP, extra, RICH, style])


def only_trees(maq_path):
    """¿El pedazo es puro bosque? Solo árboles y pasto liso (sin caminos, salientes, flores, agua ni edificios), y
    mayormente árboles. Sale de las celdas (render_maqueta escribe <maqueta>.cells.json)."""
    info = maq_path + ".cells.json"
    if not os.path.exists(info):
        return False
    c = json.load(open(info, encoding="utf8"))
    total = max(1, c["arbol"] + c["pasto"] + c["otro"])
    return c["otro"] <= total * 0.005 and c["arbol"] / total > 0.6


class Grid:
    """Trozos de la zona: columnas en x, filas en y, con solapamiento; rects en celdas del mundo."""

    def __init__(self, zx, zy, zw, zh, width, height, overlap):
        self.cw, self.ch = min(width, zw), min(height, zh)
        self.xs = chunks(zx, zw, width, overlap)
        self.ys = chunks(zy, zh, height, overlap)
        self.zx, self.zy, self.zw, self.zh = zx, zy, zw, zh
        self.rects = [(x, y, self.cw, self.ch) for y in self.ys for x in self.xs]


def darken_night_paths(out_dir, zone):
    """Caminos de tierra de la noche: Qwen los deja claros (beige o gris lavanda) aunque se le pida que no, y resaltan
    sobre el pasto oscuro. Día y noche salen de la misma maqueta y coinciden píxel a píxel: la tierra de la pintura de
    día (tostada) es la máscara, agrandada un poco para no dejar un filo claro, y ahí la noche se oscurece y enfría."""
    day_path = os.path.join(out_dir, zone + ".png")
    night_path = os.path.join(out_dir, zone + "@noche.png")
    if not os.path.exists(day_path):
        return
    d = Image.open(day_path).convert("RGB")
    n = Image.open(night_path).convert("RGB")
    if d.size != n.size:
        return
    r, g, b = d.split()
    over = lambda im, t: im.point(lambda v: 255 if v > t else 0)
    m = ImageChops.multiply(ImageChops.multiply(over(r, 140), over(g, 100)),
                            ImageChops.multiply(over(ImageChops.subtract(r, b), 40), over(ImageChops.subtract(r, g), 0)))
    # Primero se borran las manchas chicas (piedritas y flores color tierra en el pasto: de noche quedaban puntitos
    # oscuros) y después se agranda para cubrir el filo del camino.
    m = m.filter(ImageFilter.MinFilter(7)).filter(ImageFilter.MaxFilter(15)).filter(ImageFilter.GaussianBlur(2))
    nr, ng, nb = n.split()
    dark = Image.merge("RGB", (nr.point(lambda v: int(v * 0.55)), ng.point(lambda v: int(v * 0.58)),
                               nb.point(lambda v: int(v * 0.66))))
    Image.composite(dark, n, m).save(night_path)
    print("  caminos de noche oscurecidos", flush=True)


def rock_mask(maq, size):
    """Máscara (L, del tamaño de la pintura) de lo que en la maqueta es roca de meseta (rosado-marrón)."""
    m = Image.open(maq).convert("RGB")
    r, g, b = m.split()
    over = lambda im, t: im.point(lambda v: 255 if v > t else 0)
    mask = ImageChops.multiply(ImageChops.multiply(over(r, 150), over(ImageChops.subtract(r, g), 15)),
                               ImageChops.multiply(over(ImageChops.subtract(r, b), 34),
                                                   ImageChops.invert(over(ImageChops.subtract(r, b), 70))))
    return mask.filter(ImageFilter.MaxFilter(5)).resize(size, Image.BILINEAR)


def fix_rock_roofs(paint, maq):
    """Las crestas finas y los bordes de roca salen como techos de tejas naranjas con cualquier prompt, semilla o
    negativo (Rutas 3 y 4): donde la maqueta es roca, el naranja de teja se pasa a color de roca (misma luz y
    textura). Los techos de verdad no se tocan (los edificios no son roca en la maqueta)."""
    if rock_share(maq) < 0.01:
        return paint
    mask = rock_mask(maq, paint.size)
    r, g, b = paint.split()
    over = lambda im, t: im.point(lambda v: 255 if v > t else 0)
    # Teja: el verde por debajo del 62 % del rojo (de día y de noche); la tierra marrón anda por el 75-85 %.
    orange = ImageChops.multiply(over(ImageChops.subtract(r, g.point(lambda v: min(255, int(v * 1.6)))), 0), over(r, 45))
    orange = orange.filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.GaussianBlur(1.5))
    lum = paint.convert("L")
    rock = Image.merge("RGB", (lum.point(lambda v: min(255, int(v * 1.02 + 10))), lum.point(lambda v: int(v * 0.88 + 6)),
                               lum.point(lambda v: int(v * 0.74))))
    return Image.composite(rock, paint, ImageChops.multiply(mask, orange))


def stitch(root, skin, name, g, files, info):
    maq_of = lambda f: os.path.join(os.path.dirname(f), "maqueta_" + os.path.basename(f).split("_", 1)[1])
    paints = [fix_rock_roofs(Image.open(f).convert("RGB"), maq_of(f)) for f in files]
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
