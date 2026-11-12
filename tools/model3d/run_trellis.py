# Uso: run_trellis.py <imagen.png> <nombre> [caras] [textura]  -> ComfyUI/output/3d/<nombre>_*.glb
import json, sys, time, urllib.request, uuid, os, shutil
URL = "http://127.0.0.1:8188"
HERE = os.path.dirname(os.path.abspath(__file__))
COMFY = r"C:\Users\Gusti\ComfyUI\ComfyUI_windows_portable\ComfyUI"
img, name = sys.argv[1], sys.argv[2]
faces = int(sys.argv[3]) if len(sys.argv) > 3 else 30000
tex = int(sys.argv[4]) if len(sys.argv) > 4 else 2048
g = json.load(open(os.path.join(HERE, "api_trellis2.json"), encoding="utf-8"))
if "--show" in sys.argv:
    for k in ("322", "246", "323"):
        print(k, json.dumps({a: b for a, b in g[k]["inputs"].items() if a != "viewport_state"}))
    sys.exit(0)
fn = "m3d_%s.png" % name
shutil.copy(img, os.path.join(COMFY, "input", fn))
g["122"]["inputs"]["image"] = fn
g["186"]["inputs"]["target_face_count"] = faces
g["288"]["inputs"]["value"] = tex
g["224"]["inputs"]["resolution"] = tex
g["322"]["inputs"]["filename_prefix"] = "3d/" + name
# los nodos de vista previa no tienen salida: lo que colgaba de ellos va a lo que ellos recibian
PASS = {"PreviewImage": "images", "MaskPreview": "mask"}
for n in g.values():
    for k, v in n["inputs"].items():
        while isinstance(v, list) and len(v) == 2 and str(v[0]) in g and g[str(v[0])]["class_type"] in PASS:
            v = g[str(v[0])]["inputs"][PASS[g[str(v[0])]["class_type"]]]
            n["inputs"][k] = v
# sin la rama de Pixal3D (no esta bajado): todo directo a TRELLIS.2
DIRECT = {"318": ["40", 0], "314": ["299", 0], "315": ["299", 1]}
for n in g.values():
    for k, v in n["inputs"].items():
        if isinstance(v, list) and len(v) == 2 and str(v[0]) in DIRECT:
            n["inputs"][k] = DIRECT[str(v[0])]
for k in ("246", "323", "319", "298", "314", "315", "318", "316", "55", "56", "242"):
    g.pop(k, None)
seed = int(os.environ.get("SEED", "42"))
for k in ("3", "12", "18", "23"):
    g[k]["inputs"]["seed"] = seed
req = urllib.request.Request(URL + "/prompt", json.dumps({"prompt": g, "client_id": str(uuid.uuid4())}).encode(), {"Content-Type": "application/json"})
try:
    resp = json.load(urllib.request.urlopen(req))
    pid = resp["prompt_id"]
    if resp.get("node_errors"):
        print(json.dumps(resp["node_errors"])[:3000])
except urllib.error.HTTPError as e:
    print(e.read().decode()[:4000]); sys.exit(1)
t0 = time.time()
while True:
    time.sleep(3)
    hist = json.load(urllib.request.urlopen(URL + "/history/" + pid))
    if pid in hist:
        st = hist[pid].get("status", {})
        if st.get("status_str") == "error":
            print(json.dumps(st)[:4000]); sys.exit(1)
        print("OK %.0fs" % (time.time() - t0))
        for k, o in hist[pid]["outputs"].items():
            for kind, items in o.items():
                for it in items:
                    if isinstance(it, dict) and str(it.get("filename", "")).lower().endswith((".glb", ".obj", ".ply")):
                        print(k, kind, it)
        break
