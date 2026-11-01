# prep.py <n.º> <fila> <nombre>: fila de Idle (fila 0 = de frente, 2 = perfil derecha) -> <nombre>_orig.png y _strip.png (×8, fondo blanco)
import sys
from PIL import Image
num, row, name = sys.argv[1], int(sys.argv[2]), sys.argv[3]
base = r"C:/Users/Gusti/Documents/claude/pokemon-tiempo-real/sprites/pokemon/%04d/" % int(num)
im = Image.open(base + "Idle-Anim.png").convert("RGBA")
import xml.etree.ElementTree as ET
for a in ET.parse(base + "AnimData.xml").getroot().iter("Anim"):
    if a.findtext("Name") == "Idle":
        fw, fh = int(a.findtext("FrameWidth")), int(a.findtext("FrameHeight"))
n = min(4, im.width // fw)
strip = im.crop((0, row*fh, n*fw, (row+1)*fh)); strip.save(name + "_orig.png")
bg = Image.new("RGBA", strip.size, (255, 255, 255, 255)); bg.alpha_composite(strip)
bg.convert("RGB").resize((strip.width*8, strip.height*8), Image.NEAREST).save(name + "_strip.png")
print(n, fw, fh, strip.width*8, strip.height*8)
