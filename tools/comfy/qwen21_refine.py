"""Refinado en alta resolución de una pintura con Qwen-Image 2.1 Turbo (ComfyUI local, docs/COMFYUI.md), por mosaicos.
Pedido del usuario 2026-11-11: las salas del Modo Desafío se veían pixeladas en juego (la pintura era de 1600x1200 para
1024x768 px de juego, y con el zoom cada píxel pintado ocupaba 2-3 de pantalla).

Qué hace: agranda la pintura (Lanczos) a `--size`, la corta en mosaicos de 1600x1200 que se pisan a la mitad, y a cada
uno lo **redibuja entero con el mosaico como imagen de referencia** (`--denoise 1`, lo que quedó después de probar: con
menos ruido, imagen a imagen, salía limpio pero blando y con el suelo liso): Qwen pinta de nuevo cada cosa en su lugar,
con bordes nítidos y textura de verdad en el suelo. `--prompt` describe el lugar y pide que no mueva nada. Los mosaicos
se funden con bordes suaves. La composición no cambia: el plano de colisión sigue saliendo de la original.
Con `--denoise` < 1 hace imagen a imagen (parte de la pintura y repinta solo esa parte del ruido).

Uso: python -I -B tools/comfy/qwen21_refine.py <entrada.png> <salida.png> --prompt "..." [--size 3200x2400]
        [--denoise 1] [--steps 0] [--blur 2.5] [--ramp 160] [--seed 1] [--sat 1.0]   (necesita Pillow y ComfyUI prendido en 127.0.0.1:8188)
`--sat` < 1 baja la saturación de toda la imagen antes de refinar (la arena de la Costa salía amarillo chillón).
"""
import argparse
import json
import os
import shutil
import sys
import time
import urllib.request
import uuid

from PIL import Image, ImageEnhance

URL = "http://127.0.0.1:8188"
COMFY = r"C:\Users\Gusti\ComfyUI\ComfyUI_windows_portable\ComfyUI"
TILE = (1600, 1200)
# Los pasos (sigmas) de Qwen 2.1 Turbo; el refinado arranca desde el primero que sea <= denoise.
TURBO = [1.0, 0.978453, 0.95418, 0.926626, 0.89508, 0.845148, 0.704534, 0.414568, 0.0]


def sigmas_for(denoise, steps=0):
    """Con `steps` > 0, esa cantidad de pasos parejos de `denoise` a 0 (más pasos = más prolijo); si no, los del Turbo."""
    if steps > 0:
        return ", ".join("%g" % (denoise * (steps - i) / steps) for i in range(steps + 1))
    if denoise >= 1.0:
        return ", ".join("%g" % s for s in TURBO)
    rest = [s for s in TURBO if s < denoise]
    return ", ".join("%g" % s for s in [denoise] + rest)


MODEL = "qwen_image_2.1_turbo_int8_convrot.safetensors"
FULL_STEPS = 30


def refine_tile(path, prompt, denoise, seed, tag, steps=0):
    name = "refine_%s.png" % tag
    shutil.copy(path, os.path.join(COMFY, "input", name))
    g = {
        "1": {"class_type": "UNETLoader", "inputs": {"unet_name": MODEL, "weight_dtype": "default"}},
        "2": {"class_type": "CLIPLoader", "inputs": {"clip_name": "qwen3vl_8b_int8_convrot.safetensors", "type": "qwen_image", "device": "default"}},
        "3": {"class_type": "VAELoader", "inputs": {"vae_name": "qwen_image_2.1_vae_bf16.safetensors"}},
        "4": {"class_type": "QwenImage21Cache", "inputs": {"model": ["1", 0], "device": "auto", "dtype": "default"}},
        "5": {"class_type": "TextEncodeQwenImage21", "inputs": {"clip": ["2", 0], "vae": ["3", 0], "prompt": prompt, "negative_prompt": "", "resolution": 0,
                                                                "images.image_1": ["20", 0]}},  # el mosaico, de referencia
        "20": {"class_type": "LoadImage", "inputs": {"image": name}},
        "6": {"class_type": "VAEEncode", "inputs": {"pixels": ["20", 0], "vae": ["3", 0]}},
        "7": {"class_type": "RandomNoise", "inputs": {"noise_seed": seed}},
        "8": {"class_type": "KSamplerSelect", "inputs": {"sampler_name": "euler"}},
        "9": {"class_type": "ManualSigmas", "inputs": {"sigmas": sigmas_for(denoise, steps)}},
        "10": {"class_type": "CFGGuider", "inputs": {"model": ["4", 0], "positive": ["5", 0], "negative": ["5", 1], "cfg": 1.0 if "turbo" in MODEL else 4.0}},
        "11": {"class_type": "SamplerCustomAdvanced", "inputs": {"noise": ["7", 0], "guider": ["10", 0], "sampler": ["8", 0], "sigmas": ["9", 0], "latent_image": ["6", 0]}},
        "12": {"class_type": "VAEDecode", "inputs": {"samples": ["11", 0], "vae": ["3", 0]}},
        "13": {"class_type": "SaveImage", "inputs": {"images": ["12", 0], "filename_prefix": "refinado/" + tag}},
    }
    if "turbo" not in MODEL:  # el modelo completo: 30 pasos con CFG de verdad (unas 8 veces más lento que el Turbo)
        g["9"] = {"class_type": "BasicScheduler", "inputs": {"model": ["4", 0], "scheduler": "simple", "steps": steps or FULL_STEPS, "denoise": min(1.0, denoise)}}
    req = urllib.request.Request(URL + "/prompt", json.dumps({"prompt": g, "client_id": str(uuid.uuid4())}).encode(), {"Content-Type": "application/json"})
    try:
        pid = json.load(urllib.request.urlopen(req))["prompt_id"]
    except urllib.error.HTTPError as e:
        sys.exit(e.read().decode()[:3000])
    while True:
        time.sleep(1.5)
        hist = json.load(urllib.request.urlopen(URL + "/history/" + pid))
        if pid in hist:
            st = hist[pid].get("status", {})
            if st.get("status_str") == "error":
                sys.exit(json.dumps(st)[:3000])
            o = hist[pid]["outputs"]["13"]["images"][0]
            return Image.open(os.path.join(COMFY, "output", o["subfolder"], o["filename"])).convert("RGB")


def harshness(img):
    """Cuánto "raspa" una imagen: promedio de la diferencia con su versión suavizada, a 800x600. Una pasada buena da
    8-14; cuando a Qwen se le va la mano con una semilla (sobrecontraste, todo granulado y con halos), más de 30."""
    from PIL import ImageChops, ImageFilter, ImageStat
    small = img.convert("L").resize((800, 600), Image.BOX)
    return ImageStat.Stat(ImageChops.difference(small, small.filter(ImageFilter.GaussianBlur(4)))).mean[0]


def refine_checked(path, prompt, denoise, seed, tag, steps, limit, tries=4):
    """Como refine_tile, pero si el resultado sale "pasado" (harshness > limit) prueba con otra semilla y se queda con
    el más suave. (Con algunas semillas el Turbo devuelve la imagen sobrecontrastada: 1 de cada tantas.)"""
    best, best_h = None, 1e9
    for k in range(tries):
        out = refine_tile(path, prompt, denoise, seed + 1000 * k, tag, steps)
        h = harshness(out)
        if h < best_h:
            best, best_h = out, h
        if h <= limit:
            break
        print("  (%s: semilla %d salio pasada, %.0f; va otra)" % (tag, seed + 1000 * k, h), flush=True)
    return best


def feather(size, left, top, ramp):
    """Máscara del mosaico: sube de 0 a 255 en el borde izquierdo y/o de arriba (donde pisa a los que ya están)."""
    w, h = size
    m = Image.new("L", size, 255)
    px = m.load()
    for y in range(h):
        ky = min(1.0, y / ramp) if top else 1.0
        for x in range(w if top else (ramp if left else 0)):
            kx = min(1.0, x / ramp) if left else 1.0
            px[x, y] = int(255 * min(kx, ky))
    if left and not top:
        pass
    return m


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("src")
    ap.add_argument("dst")
    ap.add_argument("--prompt", required=True)
    ap.add_argument("--size", default="3200x2400")
    ap.add_argument("--denoise", type=float, default=1.0)
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--sat", type=float, default=1.0)
    ap.add_argument("--steps", type=int, default=0)
    ap.add_argument("--blur", type=float, default=2.5)
    ap.add_argument("--ramp", type=int, default=160)
    ap.add_argument("--limit", type=float, default=22.0)
    ap.add_argument("--model", default="qwen_image_2.1_turbo_int8_convrot.safetensors")
    ap.add_argument("--tmp", default=os.environ.get("TEMP", "."))
    a = ap.parse_args()
    globals()["MODEL"] = a.model
    W, H = [int(x) for x in a.size.split("x")]
    big = Image.open(a.src).convert("RGB")
    if a.sat != 1.0:
        big = ImageEnhance.Color(big).enhance(a.sat)
    big = big.resize((W, H), Image.LANCZOS)
    if a.blur > 0.0:  # (borra los escalones de pixel art de la original: Qwen dibuja el borde limpio encima)
        from PIL import ImageFilter
        big = big.filter(ImageFilter.GaussianBlur(a.blur))
    out = big.copy()
    tw, th = TILE
    xs = sorted(set(list(range(0, W - tw, tw // 2)) + [W - tw]))
    ys = sorted(set(list(range(0, H - th, th // 2)) + [H - th]))
    tag = os.path.splitext(os.path.basename(a.dst))[0]
    t0 = time.time()
    for j, y in enumerate(ys):
        for i, x in enumerate(xs):
            tile_path = os.path.join(a.tmp, "refine_in_%s.png" % tag)
            big.crop((x, y, x + tw, y + th)).save(tile_path)
            done = refine_checked(tile_path, a.prompt, a.denoise, a.seed + j * 10 + i, "%s_%d_%d" % (tag, j, i), a.steps, a.limit)
            if done.size != TILE:
                done = done.resize(TILE, Image.LANCZOS)
            out.paste(done, (x, y), feather(TILE, i > 0, j > 0, a.ramp))
    out.save(a.dst)
    print("OK %s %dx%d, %d mosaicos, %.0f s" % (a.dst, W, H, len(xs) * len(ys), time.time() - t0))


if __name__ == "__main__":
    main()
