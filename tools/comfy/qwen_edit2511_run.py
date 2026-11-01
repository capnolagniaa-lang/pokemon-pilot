# Qwen-Image-Edit 2511 (GGUF) + Lightning 8 pasos + LoRA opcional (LORA, LORA_W). run_edit.py <nombre> <prompt> <imagen>
import json, sys, time, urllib.request, uuid, os, shutil
URL = "http://127.0.0.1:8188"
name, prompt, img = sys.argv[1], sys.argv[2], sys.argv[3]
fn = "anim_edit_%s.png" % name
shutil.copy(img, os.path.join(r"C:\Users\Gusti\ComfyUI\ComfyUI_windows_portable\ComfyUI\input", fn))
m = ["4", 0]
g = {
 "1": {"class_type": "UnetLoaderGGUF", "inputs": {"unet_name": "qwen-image-edit-2511-Q4_K_M.gguf"}},
 "2": {"class_type": "CLIPLoader", "inputs": {"clip_name": "qwen_2.5_vl_7b_fp8_scaled.safetensors", "type": "qwen_image", "device": "default"}},
 "3": {"class_type": "VAELoader", "inputs": {"vae_name": "qwen_image_vae.safetensors"}},
 "4": {"class_type": "LoraLoaderModelOnly", "inputs": {"model": ["1", 0], "lora_name": "Qwen-Image-Edit-2511-Lightning-8steps-V1.0-bf16.safetensors", "strength_model": 1.0}},
 "20": {"class_type": "LoadImage", "inputs": {"image": fn}},
 "21": {"class_type": "ImageScaleToTotalPixels", "inputs": {"image": ["20", 0], "upscale_method": "nearest-exact", "megapixels": 1.0, "resolution_steps": 8}},
 "22": {"class_type": "VAEEncode", "inputs": {"pixels": ["21", 0], "vae": ["3", 0]}},
 "30": {"class_type": "TextEncodeQwenImageEditPlus", "inputs": {"clip": ["2", 0], "vae": ["3", 0], "image1": ["21", 0], "prompt": prompt}},
 "31": {"class_type": "TextEncodeQwenImageEditPlus", "inputs": {"clip": ["2", 0], "vae": ["3", 0], "image1": ["21", 0], "prompt": ""}},
 "32": {"class_type": "FluxKontextMultiReferenceLatentMethod", "inputs": {"conditioning": ["30", 0], "reference_latents_method": "index_timestep_zero"}},
 "33": {"class_type": "FluxKontextMultiReferenceLatentMethod", "inputs": {"conditioning": ["31", 0], "reference_latents_method": "index_timestep_zero"}},
}
if os.environ.get("LORA"):
    g["7"] = {"class_type": "LoraLoaderModelOnly", "inputs": {"model": m, "lora_name": os.environ["LORA"], "strength_model": float(os.environ.get("LORA_W", "1.0"))}}
    m = ["7", 0]
g["5"] = {"class_type": "ModelSamplingAuraFlow", "inputs": {"model": m, "shift": 3.1}}
g["6"] = {"class_type": "CFGNorm", "inputs": {"model": ["5", 0], "strength": 1.0}}
g["9"] = {"class_type": "KSampler", "inputs": {"model": ["6", 0], "positive": ["32", 0], "negative": ["33", 0], "latent_image": ["22", 0],
          "seed": int(os.environ.get("SEED", "1234")), "steps": 8, "cfg": 1.0, "sampler_name": "euler", "scheduler": "simple", "denoise": 1.0}}
g["10"] = {"class_type": "VAEDecode", "inputs": {"samples": ["9", 0], "vae": ["3", 0]}}
g["11"] = {"class_type": "SaveImage", "inputs": {"images": ["10", 0], "filename_prefix": "pruebas_anim/" + name}}
req = urllib.request.Request(URL + "/prompt", json.dumps({"prompt": g, "client_id": str(uuid.uuid4())}).encode(), {"Content-Type": "application/json"})
try: pid = json.load(urllib.request.urlopen(req))["prompt_id"]
except urllib.error.HTTPError as e: print(e.read().decode()[:3000]); sys.exit(1)
t0 = time.time()
while True:
    time.sleep(2)
    h = json.load(urllib.request.urlopen(URL + "/history/" + pid))
    if pid in h:
        if h[pid].get("status", {}).get("status_str") == "error": print(json.dumps(h[pid]["status"])[:3000]); sys.exit(1)
        o = h[pid]["outputs"]["11"]["images"][0]; break
os.makedirs(os.environ.get("OUT", "out"), exist_ok=True)
dst = os.path.join(os.environ.get("OUT", "out"), name + ".png")
shutil.copy(os.path.join(r"C:\Users\Gusti\ComfyUI\ComfyUI_windows_portable\ComfyUI\output", o["subfolder"], o["filename"]), dst)
print("OK %.0fs %s" % (time.time() - t0, dst))
