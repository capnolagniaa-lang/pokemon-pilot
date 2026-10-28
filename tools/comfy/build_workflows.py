"""Arma los workflows de ComfyUI del flujo de creación de efectos (formato de la interfaz y formato API).

    python -I -B tools/comfy/build_workflows.py <carpeta ComfyUI>      # los copia a user/default/workflows
    python -I -B tools/comfy/build_workflows.py --run <workflow> <clave=valor>...  # lo encola en ComfyUI (prueba)

Usa los modelos que ya tiene el ComfyUI del usuario (Qwen-Image, Qwen-Image-Edit 2511, Wan 2.2 I2V, todos GGUF) y los
LoRAs de pixel art (ver docs/COMFYUI.md). Para retocar un workflow: cambiarlo acá y volver a correr, no a mano.
"""
import json
import os
import sys
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(HERE, "workflows")

# Tipos de salida de cada nodo (para las conexiones del formato de la interfaz).
OUT_TYPES = {
    "UnetLoaderGGUF": ["MODEL"], "CLIPLoader": ["CLIP"], "VAELoader": ["VAE"], "LoraLoaderModelOnly": ["MODEL"],
    "ModelSamplingAuraFlow": ["MODEL"], "ModelSamplingSD3": ["MODEL"], "CLIPTextEncode": ["CONDITIONING"],
    "EmptySD3LatentImage": ["LATENT"], "KSampler": ["LATENT"], "KSamplerAdvanced": ["LATENT"], "VAEDecode": ["IMAGE"],
    "SaveImage": [], "LoadImage": ["IMAGE", "MASK"], "WanImageToVideo": ["CONDITIONING", "CONDITIONING", "LATENT"],
    "CreateVideo": ["VIDEO"], "SaveVideo": [], "Note": [], "ImageScale": ["IMAGE"],
}
OUT_NAMES = {"WanImageToVideo": ["positive", "negative", "latent"]}


class Workflow:
    def __init__(self, name):
        self.name = name
        self.nodes = {}
        self.groups = []

    def node(self, i, t, widgets, links=None, api=None, title=None, pos=(0, 0), size=None):
        self.nodes[i] = dict(t=t, w=widgets, links=links or {}, api=api or {}, title=title, pos=pos, size=size)

    def group(self, title, x, y, w, h, color="#3f3f3f"):
        self.groups.append({"title": title, "bounding": [x, y, w, h], "color": color})

    def ui(self):
        links, out_links, lid = [], {}, 0
        for i, n in self.nodes.items():
            for name, (src, slot) in n["links"].items():
                lid += 1
                links.append([lid, src, slot, i, name, OUT_TYPES[self.nodes[src]["t"]][slot]])
                out_links.setdefault((src, slot), []).append(lid)
        nodes = []
        for order, (i, n) in enumerate(self.nodes.items()):
            inputs = [{"name": l[4], "type": l[5], "link": l[0]} for l in links if l[3] == i]
            outs = [{"name": OUT_NAMES.get(n["t"], OUT_TYPES[n["t"]])[s], "type": typ, "links": out_links.get((i, s))}
                    for s, typ in enumerate(OUT_TYPES[n["t"]])]
            d = {"id": i, "type": n["t"], "pos": list(n["pos"]), "flags": {}, "order": order, "mode": 0,
                 "inputs": inputs, "outputs": outs, "properties": {"Node name for S&R": n["t"]},
                 "widgets_values": n["w"]}
            if n["size"]:
                d["size"] = n["size"]
            if n["title"]:
                d["title"] = n["title"]
            nodes.append(d)
        for l in links:  # el formato de la interfaz usa el índice de la entrada, no su nombre
            tgt = next(x for x in nodes if x["id"] == l[3])
            l[4] = [k for k, inp in enumerate(tgt["inputs"]) if inp["link"] == l[0]][0]
        return {"last_node_id": max(self.nodes), "last_link_id": lid, "nodes": nodes, "links": links,
                "groups": self.groups, "config": {}, "extra": {"ds": {"scale": 0.75, "offset": [0, 0]}}, "version": 0.4}

    def api(self, overrides=None):
        p = {}
        for i, n in self.nodes.items():
            if n["t"] == "Note":
                continue
            inp = dict(n["api"])
            for name, (src, slot) in n["links"].items():
                inp[name] = [str(src), slot]
            p[str(i)] = {"class_type": n["t"], "inputs": inp}
        for key, value in (overrides or {}).items():  # "9.seed" = 5
            nid, field = key.split(".", 1)
            p[nid]["inputs"][field] = value
        return p


col = lambda c: c * 340 + 60

# ---------------------------------------------------------------- 1) cuadro clave del efecto (Qwen-Image)
PIXEL_LORA = "Qwen-Image-2512-Master-Pixel-Art-LoRA.safetensors"
EFFECT_PROMPT = (
    "Pixel Art. A single fire explosion impact effect for a 2D action game, bright orange, red and yellow flames and "
    "sparks bursting outward from the center, chunky 16-bit pixel art, limited color palette, hard pixel edges, "
    "centered in the image with empty space around it, isolated on a pure solid black background, "
    "no ground, no characters, no text, no frame."
)


def effect_keyframe():
    w = Workflow("efecto_1_cuadro_clave")
    w.node(1, "UnetLoaderGGUF", ["qwen-image-Q4_K_M.gguf"], api={"unet_name": "qwen-image-Q4_K_M.gguf"},
           title="Modelo: Qwen-Image", pos=(col(0), 60))
    w.node(2, "CLIPLoader", ["qwen_2.5_vl_7b_fp8_scaled.safetensors", "qwen_image", "default"],
           api={"clip_name": "qwen_2.5_vl_7b_fp8_scaled.safetensors", "type": "qwen_image", "device": "default"},
           pos=(col(0), 200))
    w.node(3, "VAELoader", ["qwen_image_vae.safetensors"], api={"vae_name": "qwen_image_vae.safetensors"}, pos=(col(0), 370))
    w.node(4, "LoraLoaderModelOnly", ["Qwen-Image-Lightning-8steps-V2.0.safetensors", 1], {"model": (1, 0)},
           {"lora_name": "Qwen-Image-Lightning-8steps-V2.0.safetensors", "strength_model": 1}, "Lightning 8 pasos",
           pos=(col(1), 60))
    w.node(5, "LoraLoaderModelOnly", [PIXEL_LORA, 1], {"model": (4, 0)},
           {"lora_name": PIXEL_LORA, "strength_model": 1}, "LoRA pixel art (fuerza: 0,7-1,2)", pos=(col(1), 220))
    w.node(6, "ModelSamplingAuraFlow", [3.1, "flow"], {"model": (5, 0)}, {"shift": 3.1, "sampling": "flow"},
           pos=(col(1), 380))
    w.node(7, "CLIPTextEncode", [EFFECT_PROMPT], {"clip": (2, 0)}, {"text": EFFECT_PROMPT},
           "1) QUÉ EFECTO (en inglés; empezá con 'Pixel Art.' y dejá 'pure solid black background')",
           pos=(col(2), 60), size=[480, 300])
    w.node(8, "CLIPTextEncode", [""], {"clip": (2, 0)}, {"text": ""}, "negativo (vacío)", pos=(col(2), 400))
    w.node(9, "EmptySD3LatentImage", [1024, 1024, 1], api={"width": 1024, "height": 1024, "batch_size": 1},
           title="tamaño (cuadrado)", pos=(col(2), 560))
    w.node(10, "KSampler", [42, "randomize", 8, 1, "euler", "simple", 1],
           {"model": (6, 0), "positive": (7, 0), "negative": (8, 0), "latent_image": (9, 0)},
           {"seed": 42, "steps": 8, "cfg": 1, "sampler_name": "euler", "scheduler": "simple", "denoise": 1},
           "2) Generar (otra semilla = otra versión)", pos=(col(4) - 40, 60), size=[310, 270])
    w.node(11, "VAEDecode", [], {"samples": (10, 0), "vae": (3, 0)}, pos=(col(4) - 40, 380))
    w.node(12, "SaveImage", ["efectos/clave"], {"images": (11, 0)}, {"filename_prefix": "efectos/clave"},
           "Cuadro clave (output/efectos/)", pos=(col(5), 60), size=[460, 500])
    w.node(50, "Note", [NOTE_KEYFRAME], title="LEEME", pos=(col(2), 720), size=[720, 330])
    w.group("Modelo (no tocar)", 40, 0, 700, 520)
    return w


NOTE_KEYFRAME = """PASO 1 DE 3: el cuadro clave del efecto.
- Describí el efecto en "1) QUÉ EFECTO" (en inglés). Fondo NEGRO puro siempre: el paso 3 lo usa para sacar el fondo.
  Para efectos oscuros (Fantasma, Siniestro) pedí "pure solid white background".
- Ejemplos: "a crackling yellow electric shock burst with zigzag lightning bolts", "a splash of blue water droplets",
  "a swirling green leaf tornado", "a purple ghostly shadow ball with dark wisps", "an icy blue crystal shatter".
- Para proyectiles (Ascuas, Pistola Agua...) pedí que apunte a la derecha: "a fireball flying to the right".
- Cuando te guste uno, pasá al workflow "efecto_2_animar" y cargá esa imagen (arrastrala desde la cola al nodo
  "Cuadro clave")."""


# ---------------------------------------------------------------- 2) animarlo (Wan 2.2 I2V)
ANIM_PROMPT = (
    "The fire explosion bursts outward quickly, the flames and sparks expand, then break apart into embers and fade "
    "out completely, leaving only the black background. 2D pixel art game effect animation, static camera, "
    "the background stays pure black."
)
ANIM_NEG = ("camera movement, zoom, pan, ground, floor, scenery, background objects, characters, text, watermark, "
            "smooth gradients, blurry, photorealistic, 3D render")


def effect_animate():
    w = Workflow("efecto_2_animar")
    w.node(1, "UnetLoaderGGUF", ["Wan2.2-I2V-A14B-HighNoise-Q4_K_M.gguf"],
           api={"unet_name": "Wan2.2-I2V-A14B-HighNoise-Q4_K_M.gguf"}, title="Wan 2.2 (ruido alto)", pos=(col(0), 60))
    w.node(2, "UnetLoaderGGUF", ["Wan2.2-I2V-A14B-LowNoise-Q4_K_M.gguf"],
           api={"unet_name": "Wan2.2-I2V-A14B-LowNoise-Q4_K_M.gguf"}, title="Wan 2.2 (ruido bajo)", pos=(col(0), 180))
    w.node(3, "LoraLoaderModelOnly", ["wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors", 1], {"model": (1, 0)},
           {"lora_name": "wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors", "strength_model": 1},
           pos=(col(1), 60))
    w.node(4, "LoraLoaderModelOnly", ["wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors", 1], {"model": (2, 0)},
           {"lora_name": "wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors", "strength_model": 1},
           pos=(col(1), 200))
    w.node(5, "ModelSamplingSD3", [5], {"model": (3, 0)}, {"shift": 5}, pos=(col(2), 60))
    w.node(6, "ModelSamplingSD3", [5], {"model": (4, 0)}, {"shift": 5}, pos=(col(2), 160))
    w.node(7, "CLIPLoader", ["umt5_xxl_fp8_e4m3fn_scaled.safetensors", "wan", "default"],
           api={"clip_name": "umt5_xxl_fp8_e4m3fn_scaled.safetensors", "type": "wan", "device": "default"},
           pos=(col(0), 320))
    w.node(8, "VAELoader", ["wan_2.1_vae.safetensors"], api={"vae_name": "wan_2.1_vae.safetensors"}, pos=(col(0), 460))
    w.node(9, "LoadImage", ["efecto_clave.png", "image"], api={"image": "efecto_clave.png"},
           title="1) Cuadro clave (del paso 1)", pos=(col(0), 600), size=[320, 360])
    w.node(10, "CLIPTextEncode", [ANIM_PROMPT], {"clip": (7, 0)}, {"text": ANIM_PROMPT},
           "2) CÓMO SE MUEVE (en inglés)", pos=(col(3), 60), size=[460, 260])
    w.node(11, "CLIPTextEncode", [ANIM_NEG], {"clip": (7, 0)}, {"text": ANIM_NEG}, "negativo", pos=(col(3), 360),
           size=[460, 160])
    w.node(12, "WanImageToVideo", [480, 480, 33, 1],
           {"positive": (10, 0), "negative": (11, 0), "vae": (8, 0), "start_image": (9, 0)},
           {"width": 480, "height": 480, "length": 33, "batch_size": 1},
           "3) Tamaño y cuadros (33 = 2 s a 16 fps)", pos=(col(3), 560))
    w.node(13, "KSamplerAdvanced", ["enable", 42, "randomize", 4, 1, "euler", "simple", 0, 2, "enable"],
           {"model": (5, 0), "positive": (12, 0), "negative": (12, 1), "latent_image": (12, 2)},
           {"add_noise": "enable", "noise_seed": 42, "steps": 4, "cfg": 1, "sampler_name": "euler",
            "scheduler": "simple", "start_at_step": 0, "end_at_step": 2, "return_with_leftover_noise": "enable"},
           "4) Generar (otra semilla = otra versión)", pos=(col(5) - 60, 60), size=[310, 330])
    w.node(14, "KSamplerAdvanced", ["disable", 42, "fixed", 4, 1, "euler", "simple", 2, 10000, "disable"],
           {"model": (6, 0), "positive": (12, 0), "negative": (12, 1), "latent_image": (13, 0)},
           {"add_noise": "disable", "noise_seed": 42, "steps": 4, "cfg": 1, "sampler_name": "euler",
            "scheduler": "simple", "start_at_step": 2, "end_at_step": 10000, "return_with_leftover_noise": "disable"},
           pos=(col(5) - 60, 430), size=[310, 330])
    w.node(15, "VAEDecode", [], {"samples": (14, 0), "vae": (8, 0)}, pos=(col(6), 60))
    w.node(16, "SaveImage", ["efectos/cuadros/fuego"], {"images": (15, 0)}, {"filename_prefix": "efectos/cuadros/fuego"},
           "5) Cuadros (cambiá 'fuego' por el nombre del efecto)", pos=(col(7), 60), size=[460, 420])
    w.node(17, "CreateVideo", [16, "auto", "sRGB", "none"], {"images": (15, 0)}, {"fps": 16}, pos=(col(6), 200))
    w.node(18, "SaveVideo", ["efectos/video", "auto", "auto", "auto"], {"video": (17, 0)},
           {"filename_prefix": "efectos/video", "format": "auto", "codec": "auto"}, "Vista previa (video)",
           pos=(col(7), 520), size=[460, 420])
    w.node(50, "Note", [NOTE_ANIM], title="LEEME", pos=(col(3), 760), size=[760, 300])
    w.group("Modelo (no tocar)", 40, 0, 1000, 560)
    return w


NOTE_ANIM = """PASO 2 DE 3: animar el cuadro clave.
- Cargá en "1) Cuadro clave" la imagen del paso 1 (arrastrala desde la cola o desde output/efectos/).
- Describí el movimiento en "2) CÓMO SE MUEVE": que crezca/estalle y después se desvanezca, cámara fija, fondo negro.
- Los cuadros quedan en output/efectos/cuadros/ (uno por PNG). Mirá el video para ver si te gusta.

PASO 3: pasarlo al juego (desde la carpeta del proyecto):
  python -I -B tools/fx_from_frames.py <ComfyUI>/output/efectos/cuadros/fuego --out sprites/fx/types/fuego_impacto.png --size 32 --frames 7
  (proyectil: --out sprites/fx/moves/<id>.png --size 16 --frames 4 ; mirá antes con --preview)"""


WORKFLOWS = {"efecto_1_cuadro_clave": effect_keyframe, "efecto_2_animar": effect_animate}


def main(argv):
    if argv and argv[0] == "--run":
        w = WORKFLOWS[argv[1]]()
        overrides = {}
        for kv in argv[2:]:
            k, v = kv.split("=", 1)
            try:
                v = json.loads(v)
            except ValueError:
                pass
            overrides[k] = v
        body = json.dumps({"prompt": w.api(overrides)}).encode()
        req = urllib.request.Request("http://127.0.0.1:8188/prompt", body, {"Content-Type": "application/json"})
        print(json.load(urllib.request.urlopen(req)))
        return
    os.makedirs(OUT_DIR, exist_ok=True)
    dests = [OUT_DIR]
    if argv:
        dests.append(os.path.join(argv[0], "user", "default", "workflows"))
    for name, make in WORKFLOWS.items():
        data = make().ui()
        for d in dests:
            with open(os.path.join(d, name + ".json"), "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False, indent=1)
        print("ok", name)


if __name__ == "__main__":
    main(sys.argv[1:])
