# Uso: run.py <nombre> <ancho> <alto> <prompt> [imagen1 ...]  -> <scratchpad>/qwen/out/<nombre>_N.png
import json, sys, time, urllib.request, uuid, os, shutil
URL = "http://127.0.0.1:8188"
name, w, h, prompt = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
images = sys.argv[5:]
seed = int(os.environ.get("SEED", "1234"))
model = os.environ.get("MODEL", "qwen_image_2.1_turbo_int8_convrot.safetensors")
turbo = "turbo" in model
COMFY_IN = r"C:\Users\Gusti\ComfyUI\ComfyUI_windows_portable\ComfyUI\input"
g = {
 "1": {"class_type": "UNETLoader", "inputs": {"unet_name": model, "weight_dtype": "default"}},
 "2": {"class_type": "CLIPLoader", "inputs": {"clip_name": "qwen3vl_8b_int8_convrot.safetensors", "type": "qwen_image", "device": "default"}},
 "3": {"class_type": "VAELoader", "inputs": {"vae_name": "qwen_image_2.1_vae_bf16.safetensors"}},
 "4": {"class_type": "QwenImage21Cache", "inputs": {"model": ["1", 0], "device": "auto", "dtype": "default"}},
 "5": {"class_type": "TextEncodeQwenImage21", "inputs": {"clip": ["2", 0], "vae": ["3", 0], "prompt": prompt,
       "negative_prompt": "", "resolution": 0}},
 "6": {"class_type": "EmptyLatentImage", "inputs": {"width": w, "height": h, "batch_size": 1}},
 "7": {"class_type": "RandomNoise", "inputs": {"noise_seed": seed}},
 "8": {"class_type": "KSamplerSelect", "inputs": {"sampler_name": "euler"}},
 "10": {"class_type": "CFGGuider", "inputs": {"model": ["4", 0], "positive": ["5", 0], "negative": ["5", 1], "cfg": 1.0 if turbo else 4.0}},
 "11": {"class_type": "SamplerCustomAdvanced", "inputs": {"noise": ["7", 0], "guider": ["10", 0], "sampler": ["8", 0], "sigmas": ["9", 0], "latent_image": ["6", 0]}},
 "12": {"class_type": "VAEDecode", "inputs": {"samples": ["11", 0], "vae": ["3", 0]}},
 "13": {"class_type": "SaveImage", "inputs": {"images": ["12", 0], "filename_prefix": "pruebas_anim/" + name}},
}
if os.environ.get("LORA"):
    g["30"] = {"class_type": "LoraLoaderModelOnly", "inputs": {"model": ["1", 0], "lora_name": os.environ["LORA"], "strength_model": float(os.environ.get("LORA_W", "1.0"))}}
    g["4"]["inputs"]["model"] = ["30", 0]
if turbo:
    g["9"] = {"class_type": "ManualSigmas", "inputs": {"sigmas": "1.0, 0.978453, 0.95418, 0.926626, 0.89508, 0.845148, 0.704534, 0.414568, 0"}}
else:
    g["9"] = {"class_type": "BasicScheduler", "inputs": {"model": ["4", 0], "scheduler": "simple", "steps": 30, "denoise": 1.0}}
for i, p in enumerate(images):
    fn = "anim_%s_%d.png" % (name, i)
    shutil.copy(p, os.path.join(COMFY_IN, fn))
    g["20%d" % i] = {"class_type": "LoadImage", "inputs": {"image": fn}}
    g["5"]["inputs"]["images.image_%d" % (i + 1)] = ["20%d" % i, 0]
req = urllib.request.Request(URL + "/prompt", json.dumps({"prompt": g, "client_id": str(uuid.uuid4())}).encode(), {"Content-Type": "application/json"})
try:
    pid = json.load(urllib.request.urlopen(req))["prompt_id"]
except urllib.error.HTTPError as e:
    print(e.read().decode()[:3000]); sys.exit(1)
t0 = time.time()
while True:
    time.sleep(2)
    hist = json.load(urllib.request.urlopen(URL + "/history/" + pid))
    if pid in hist:
        st = hist[pid].get("status", {})
        if st.get("status_str") == "error":
            print(json.dumps(st)[:3000]); sys.exit(1)
        outs = hist[pid]["outputs"]["13"]["images"]
        break
os.makedirs(os.path.join(os.environ.get("OUT", "out")), exist_ok=True)
for o in outs:
    src = os.path.join(r"C:\Users\Gusti\ComfyUI\ComfyUI_windows_portable\ComfyUI\output", o["subfolder"], o["filename"])
    dst = os.path.join(os.environ.get("OUT", "out"), name + ".png")
    shutil.copy(src, dst); print("OK %.0fs %s" % (time.time() - t0, dst))
