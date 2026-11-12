# Imágenes de concepto de Pokémon para pasarlas a 3D (Qwen 2.1 por ComfyUI).
# Uso: python -I -B tools/model3d/concepts.py <carpeta de salida> [nombre ...]   (sin nombres: todos los de SPECIES)
import json, os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
RUN = os.path.join(ROOT, "tools", "comfy", "qwen21_run.py")
DESC = json.load(open(os.path.join(ROOT, "tools", "comfy", "species_desc.json"), encoding="utf-8"))

# nombre -> (n.º de Pokédex, pose). Hasta Ciudad Plateada: salvajes, iniciales, entrenadores, Brock y evoluciones cercanas.
STAND = "standing still on the ground in a neutral relaxed pose"
FLY = "hovering in the air with wings spread wide open"
SPECIES = {
    "bulbasaur": (1, STAND), "charmander": (4, STAND), "squirtle": (7, STAND),
    "caterpie": (10, "crawling on the ground, body stretched out"), "metapod": (11, "upright cocoon standing on the ground"),
    "butterfree": (12, FLY), "weedle": (13, "crawling on the ground, body stretched out"),
    "kakuna": (14, "upright cocoon standing on the ground"), "beedrill": (15, FLY),
    "pidgey": (16, "standing on the ground on its two feet, wings folded"), "rattata": (19, STAND),
    "spearow": (21, "standing on the ground on its two feet, wings folded"), "pikachu": (25, STAND),
    "sandshrew": (27, STAND), "psyduck": (54, STAND), "mankey": (56, STAND),
    "tentacool": (72, "floating upright, tentacles hanging down"), "geodude": (74, "floating just above the ground, both arms raised to the sides"),
    "onix": (95, "coiled upright like a rearing snake, head held high"),
}
STYLE = ("3D render of a stylized video game character, cute chunky toy-like proportions, smooth clean shapes, "
         "flat hand-painted colors, big clearly visible bright eyes, soft even studio lighting, no cast shadow, "
         "single character centered, whole body visible, three-quarter front view from slightly above, "
         "head facing the same direction as the body, mouth closed, plain pure white background")

out = sys.argv[1]
names = sys.argv[2:] or list(SPECIES)
os.makedirs(out, exist_ok=True)
for n in names:
    num, pose = SPECIES[n]
    prompt = "%s the Pokemon: %s. It is %s. %s" % (n.capitalize(), DESC[str(num)], pose, STYLE)
    env = dict(os.environ, OUT=out, MODEL="qwen_image_2.1_int8_convrot.safetensors", SEED=os.environ.get("SEED", "1234"))
    subprocess.run([sys.executable, "-I", "-B", RUN, n, "1024", "1024", prompt], env=env, cwd=ROOT)
