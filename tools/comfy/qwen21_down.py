# down2.py <ia.png> <orig_strip.png> <frames> <out>: corta la hoja de la IA en cuadros, saca el fondo blanco en grande,
# escala para que el cuerpo mida como el original (mediana de altos), achica promediando solo el sprite y pasa a la
# paleta del original (+ colores de efectos). Saca hoja, GIF ×6 y comparación ×4.
import sys, statistics
from PIL import Image
src, orig, n, out = sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4]
O = Image.open(orig).convert("RGBA"); fw, fh = O.width // n, O.height
def bb(im): b = im.getchannel("A").point(lambda a: 255 if a > 0 else 0).getbbox(); return ((b[2]-b[0]), (b[3]-b[1])) if b else (0, 0)
def bbox_h(im): return bb(im)[1]
oh = statistics.median([bbox_h(O.crop((i*fw, 0, (i+1)*fw, fh))) for i in range(n)])
ow = statistics.median([bb(O.crop((i*fw, 0, (i+1)*fw, fh)))[0] for i in range(n)])
im = Image.open(src).convert("RGB"); cw = im.width // n
big = []
for i in range(n):
    m = int(cw * 0.04)  # sin los bordes de la celda (a veces dibuja una grilla)
    c = im.crop((i*cw + m, m, (i+1)*cw - m, im.height - m)).convert("RGBA"); px = c.load()
    for y in range(c.height):
        for x in range(c.width):
            r, g, b, _ = px[x, y]
            if min(r, g, b) > 232: px[x, y] = (255, 255, 255, 0)
    # líneas de grilla: filas o columnas casi llenas se borran
    for y in range(c.height):
        if sum(1 for x in range(c.width) if px[x, y][3]) > c.width * 0.9:
            for x in range(c.width): px[x, y] = (255, 255, 255, 0)
    for x in range(c.width):
        if sum(1 for y in range(c.height) if px[x, y][3]) > c.height * 0.9:
            for y in range(c.height): px[x, y] = (255, 255, 255, 0)
    big.append(c)
# escala: el cuerpo (mediana de altos de los cuadros, sin contar los más altos por efectos) = alto del original
hs = sorted(bbox_h(c) for c in big); bh = hs[len(hs)//2 - (1 if len(hs) % 2 == 0 else 0)]
ws = sorted(bb(c)[0] for c in big); bw = ws[len(ws)//2 - (1 if len(ws) % 2 == 0 else 0)]
bh = bbox_h(big[-1]); bw = bb(big[-1])[0]  # el último cuadro es la pose de reposo: esa mide como el original
k = min(oh / max(1, bh), fw * 1.0 / max(1, bw))
cols = {c[:3] for _, c in O.getcolors(4096) if c[3] > 0}
cols = list(cols) + [(255,200,40),(255,120,20),(220,50,20),(255,245,170),(235,235,235),(170,170,180),(120,200,255),(40,110,220)]
OUTLINE = min({c[:3] for _, c in O.getcolors(4096) if c[3] > 0}, key=sum)
pal = Image.new("P", (1, 1)); flat = [v for c in cols for v in c]; pal.putpalette(flat + flat[:3]*(256-len(cols)))
frames = []
for c in big:
    w2, h2 = max(1, round(c.width * k)), max(1, round(c.height * k))
    # promedio premultiplicado: el blanco del fondo no tiñe el borde
    s = c.resize((w2, h2), Image.BOX, reducing_gap=None)
    a = s.getchannel("A")
    rgb = Image.composite(s.convert("RGB"), s.convert("RGB"), a)
    pre = c.copy(); pp = pre.load()
    for y in range(pre.height):
        for x in range(pre.width):
            r, g, b, al = pp[x, y]
            if al == 0: pp[x, y] = (0, 0, 0, 0)
    s = pre.resize((w2, h2), Image.BOX); sp = s.load()
    q = s.convert("RGB").quantize(palette=pal, dither=Image.Dither.NONE).convert("RGBA"); qp = q.load()
    for y in range(h2):
        for x in range(w2):
            if sp[x, y][3] < 128: qp[x, y] = (0, 0, 0, 0)
    a2 = [[qp[x, y][3] > 0 for x in range(w2)] for y in range(h2)]
    for y in range(h2):
        for x in range(w2):
            if a2[y][x] and any(not (0 <= x+dx < w2 and 0 <= y+dy < h2) or not a2[y+dy][x+dx] for dx, dy in ((1,0),(-1,0),(0,1),(0,-1))):
                r, g, b, _ = qp[x, y]
                if r + g + b < 600: qp[x, y] = OUTLINE + (255,)
    # (BOX en Pillow promedia RGBA premultiplicado, así que el color ya no trae blanco)
    f = Image.new("RGBA", (fw, fh)); f.alpha_composite(q, ((fw - w2)//2, fh - h2 - max(0, (fh - h2)//6)) if w2 <= fw else (0, 0))
    if w2 > fw or h2 > fh:  # más grande que el cuadro: se centra recortando
        f = q.crop(((w2-fw)//2, max(0, h2-fh), (w2-fw)//2+fw, max(0, h2-fh)+fh))
    frames.append(f)
sheet = Image.new("RGBA", (fw*n, fh))
for i, f in enumerate(frames): sheet.paste(f, (i*fw, 0))
sheet.save(out + "_hoja.png")
bg = (60, 120, 60, 255)
g = [Image.alpha_composite(Image.new("RGBA", f.size, bg), f).resize((fw*6, fh*6), Image.NEAREST) for f in frames]
g[0].save(out + ".gif", save_all=True, append_images=g[1:], duration=140, loop=0)
cmp = Image.new("RGBA", (fw*n, fh*2 + 4), bg); cmp.alpha_composite(O, (0, 0)); cmp.alpha_composite(sheet, (0, fh + 4))
cmp.resize((cmp.width*4, cmp.height*4), Image.NEAREST).save(out + "_comparar.png")
print("escala %.3f" % k)
