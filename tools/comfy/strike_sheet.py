# Golpe (Strike) en 8 direcciones para una especie que no lo tiene, con Qwen-Image 2.1 Turbo (ComfyUI en :8188).
#
#   python -I -B tools/comfy/strike_sheet.py gen <n.º> "<especie (descripción)>" "<acción con {dir}>" <carpeta> [semillas]
#       5 corridas por semilla (frente, abajo-der., perfil der., arriba-der., espalda), cada una sobre la fila de
#       Idle de esa dirección; deja <carpeta>/d<fila>_s<semilla>.png (la IA) y elegir.png (a 32 px). Lo que ya está
#       generado no se repite (correrlo de nuevo solo rehace elegir.png).
#   python -I -B tools/comfy/strike_sheet.py build <n.º> <carpeta> <semilla fila 0>,<fila 1>,...,<fila 4>
#       (semilla con "i" al final, ej. 777i: el último cuadro salió mal y se usa el Idle original en su lugar; sin la
#       "i" se decide solo: si el último cuadro no se parece de forma al Idle y el primero sí)
#       Arma sprites/pokemon/<n.º>/Strike-Anim.png (8 filas: las 3 de la izquierda espejadas), lo anota en su
#       AnimData.xml (pisa un Strike "CopyOf") y en scripts/generated/sprite_data.gd. Después: --import.
#
# Paso a 32 px (como qwen21_down.py): fondo blanco fuera en grande, escala tal que la pose de reposo (último cuadro)
# mida como el Idle, paleta del original, contorno oscuro. La celda entera se achica y se corre
# igual en los 4 cuadros (así el avance del golpe se conserva) para que la pose de reposo quede donde está el Idle.
import os, re, subprocess, sys
import xml.etree.ElementTree as ET
from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
HERE = os.path.dirname(os.path.abspath(__file__))
N = 4  # cuadros
PAD = 12  # margen de la celda del golpe alrededor de la del Idle (px a cada lado)
DURATIONS = [3, 5, 4, 6]  # preparación, arranque, golpe, vuelta
VIEWS = ["facing down toward the viewer", "in three-quarter view facing down-right", "seen from the side facing right",
         "in three-quarter back view facing up-right", "seen from behind, facing away from the viewer"]
DIRS = ["toward the viewer", "toward the lower right", "to the right", "toward the upper right, away from the viewer",
        "away from the viewer"]
# Prompt afinado el 2026-11-01 ("que se parezcan más al modelo"): imagen 1 = la fila de Idle; imagen 2 = su animación
# Attack de PMD (referencia de estilo: así copia el dibujo, los colores pálidos y las proporciones del sprite y no los
# del arte oficial); sin líneas de velocidad (quedaban rayitas sueltas a 32 px).
HEAD = ("Image 1 is a pixel art sprite sheet: 4 animation frames of %s side by side in one row, %s, on a plain white "
        "background. Redraw it as a 4-frame %s animation, keeping exactly 4 cells of equal width in one row: %s "
        "Use exaggerated, readable key poses with strong anticipation and follow-through, so the silhouette clearly "
        "changes from frame to frame. ")
REFERENCE = ("Image 2 shows the same character in its original game attack animation: draw in exactly that pixel art "
             "style, colors and proportions. ")
TAIL = ("It must look like the very same sprite from the input, only in new poses: copy its exact colors (the same "
        "shades as the input, not the official artwork colors), its shading, its proportions, its outline and its pixel "
        "size, and keep its facing direction. Do not redesign it, do not add detail, do not add colors that are not in "
        "the input. Each cell is a tiny low-resolution game sprite enlarged 8 times: big square pixels on a strict grid, "
        "a 1-pixel dark outline, flat colors, no gradients, no anti-aliasing, no blur. Same character size in every "
        "cell. Plain pure white background everywhere, no floor, no ground line, no shadow, no motion lines, no speed "
        "lines, no text.")


def folder_of(num):
    return os.path.join(ROOT, "sprites", "pokemon", "%04d" % num)


def anim_info(num, name):
    """(archivo, ancho, alto) de una animación siguiendo los CopyOf (el Idle de Beedrill es una copia de Walk), o None."""
    anims = {a.findtext("Name"): a for a in ET.parse(os.path.join(folder_of(num), "AnimData.xml")).getroot().iter("Anim")}
    a = anims.get(name)
    while a is not None and a.findtext("CopyOf"):
        a = anims.get(a.findtext("CopyOf"))
    if a is None or not a.findtext("FrameWidth"):
        return None
    return (os.path.join(folder_of(num), "%s-Anim.png" % a.findtext("Name")), int(a.findtext("FrameWidth")),
            int(a.findtext("FrameHeight")))


def idle_info(num):
    info = anim_info(num, "Idle")
    if info is None:
        raise SystemExit("sin Idle")
    return info[1], info[2]


def idle_row(num, row):
    """Los cuadros de Idle de esa fila, repetidos hasta 4."""
    fw, fh = idle_info(num)
    im = Image.open(anim_info(num, "Idle")[0]).convert("RGBA")
    n = im.width // fw
    return [im.crop(((i % n) * fw, row * fh, (i % n + 1) * fw, (row + 1) * fh)) for i in range(N)], fw, fh


def attack_strip(num, row, path):
    """4 cuadros de la animación Attack de PMD en esa dirección (×4, fondo blanco), o None si la especie no la tiene."""
    info = anim_info(num, "Attack")
    if info is None or not os.path.exists(info[0]):
        return None
    src, fw, fh = info
    im = Image.open(src).convert("RGBA")
    n = im.width // fw
    strip = Image.new("RGBA", (fw * N, fh), (255, 255, 255, 255))
    for i, j in enumerate([0, n // 3, (2 * n) // 3, n - 1]):
        strip.alpha_composite(im.crop((j * fw, row * fh, (j + 1) * fw, (row + 1) * fh)), (i * fw, 0))
    strip.convert("RGB").resize((strip.width * 4, strip.height * 4), Image.NEAREST).save(path)
    return path


def bbox(im):
    return im.getchannel("A").point(lambda a: 255 if a > 0 else 0).getbbox()


def gen(num, desc, action, out, seeds, kind="melee attack", preview=True):
    os.makedirs(out, exist_ok=True)
    rows = []
    for row in range(5):
        frames, fw, fh = idle_row(num, row)
        strip = Image.new("RGBA", (fw * N, fh), (255, 255, 255, 255))
        for i, f in enumerate(frames):
            strip.alpha_composite(f, (i * fw, 0))
        big = os.path.join(out, "d%d_entrada.png" % row)
        strip.convert("RGB").resize((strip.width * 8, strip.height * 8), Image.NEAREST).save(big)
        ref = attack_strip(num, row, os.path.join(out, "d%d_referencia.png" % row))
        prompt = HEAD % (desc, VIEWS[row], kind, action.replace("{dir}", DIRS[row])) + (REFERENCE if ref else "") + TAIL
        if not ref:
            prompt = prompt.replace("Image 1 is", "This image is")
        line = []
        for seed in seeds:
            name = "d%d_s%d" % (row, seed)
            env = dict(os.environ, SEED=str(seed), OUT=out)
            only = os.environ.get("ROWS")  # ROWS=4 → solo genera esa(s) fila(s) (las demás, si ya están)
            if not os.path.exists(os.path.join(out, name + ".png")) and (not only or str(row) in only.split(",")):
                subprocess.run([sys.executable, "-I", os.path.join(HERE, "qwen21_run.py"), name, str(strip.width * 8),
                               str(strip.height * 8), prompt, big] + ([ref] if ref else []), check=True, env=env,
                               stdout=subprocess.DEVNULL)
            if os.path.exists(os.path.join(out, name + ".png")):
                line.append(convert(num, row, os.path.join(out, name + ".png")))
            else:
                line.append([])
        rows.append(line)
    if not preview:
        return
    # elegir.png: por fila (dirección) el Idle y cada semilla, ×4 sobre verde
    fw, fh = idle_info(num)
    cw, ch = fw + 2 * PAD, fh + 2 * PAD
    sheet = Image.new("RGBA", (cw * N, ch * len(seeds) * 5 + 5 * 6), (60, 120, 60, 255))
    for r, line in enumerate(rows):
        for s, cells in enumerate(line):
            for i, c in enumerate(cells):
                sheet.alpha_composite(c, (i * cw, (r * len(seeds) + s) * ch + r * 6))
    sheet.resize((sheet.width * 3, sheet.height * 3), Image.NEAREST).save(os.path.join(out, "elegir.png"))
    print("semillas por fila, de arriba abajo:", seeds)


def _lab(c):
    """Aproximación perceptual barata: luz (pesa el doble) y dos ejes de color."""
    r, g, b = [v / 255.0 for v in c[:3]]
    y = 0.299 * r + 0.587 * g + 0.114 * b
    return (y * 2.0, b - y, r - y)


def _pixels(im):
    return getattr(im, "get_flattened_data", im.getdata)()


def _stats(pixels):
    n = float(len(pixels))
    mean = [sum(p[i] for p in pixels) / n for i in range(3)]
    sd = [max(1.0, (sum((p[i] - mean[i]) ** 2 for p in pixels) / n) ** 0.5) for i in range(3)]
    return mean, sd


def convert(num, row, ai_path, idle_last=None):
    """La salida de la IA → 4 cuadros de (Idle + 2·PAD), alineados con el Idle de esa fila. idle_last: el último cuadro
    salió mal (ej. Geodude como plato volador): se mide con el primero y el último pasa a ser el Idle original."""
    orig, fw, fh = idle_row(num, row)
    cw, ch = fw + 2 * PAD, fh + 2 * PAD
    ob = bbox(orig[0])
    oh, ocx, obot = ob[3] - ob[1], (ob[0] + ob[2]) / 2.0, ob[3]
    owid = ob[2] - ob[0]
    im = Image.open(ai_path).convert("RGB")
    aw = im.width // N
    big = []
    for i in range(N):
        m = int(aw * 0.04)  # sin los bordes de la celda (a veces dibuja una grilla)
        c = im.crop((i * aw + m, m, (i + 1) * aw - m, im.height - m)).convert("RGBA")
        px = c.load()
        for y in range(c.height):
            for x in range(c.width):
                r, g, b, _ = px[x, y]
                if min(r, g, b) > 232:
                    px[x, y] = (0, 0, 0, 0)
                else:
                    px[x, y] = (r, g, b, 255)
        for y in range(c.height):  # líneas de grilla
            if sum(1 for x in range(c.width) if px[x, y][3]) > c.width * 0.9:
                for x in range(c.width):
                    px[x, y] = (0, 0, 0, 0)
        for x in range(c.width):
            if sum(1 for y in range(c.height) if px[x, y][3]) > c.height * 0.9:
                for y in range(c.height):
                    px[x, y] = (0, 0, 0, 0)
        big.append(c)
    if idle_last is None:  # automático: el último cuadro no se parece de forma al Idle (ej. plato volador)
        ob0 = bbox(orig[0])
        lb, fb = bbox(big[-1]), bbox(big[0])
        aspect = lambda b: (b[2] - b[0]) / max(1, b[3] - b[1])
        idle_last = lb is None or (fb is not None and abs(aspect(lb) / aspect(ob0) - 1) > 0.6
                                   and abs(aspect(fb) / aspect(ob0) - 1) < abs(aspect(lb) / aspect(ob0) - 1))
    ref = big[0] if idle_last else big[-1]
    rb = bbox(ref) or (0, 0, ref.width, ref.height)
    k = min(oh / max(1, rb[3] - rb[1]), owid * 1.15 / max(1, rb[2] - rb[0]))
    # corrimiento: el centro abajo de la pose de reposo achicada cae en el del Idle (dentro de la celda con margen)
    dx = round(PAD + ocx - (rb[0] + rb[2]) / 2.0 * k)
    dy = round(PAD + obot - rb[3] * k)
    # Colores (2026-11-01, "algunos están feos"): la IA pinta con los colores del arte oficial (Bulbasaur turquesa) y el
    # sprite de PMD es más pálido; promediar y pasar a la paleta dejaba otros tonos y puntitos sueltos. Ahora: se igualan
    # la media y el desvío de cada canal a los del sprite original, cada pixel grande va al color de la paleta más
    # parecido (luz pesa más que tono) y cada pixel chico es el color que más votos tiene en su bloque.
    opx = [p[:3] for o in orig for p in _pixels(o) if p[3] > 0]
    pal = sorted(set(opx))
    outline = min(pal, key=sum)
    palab = [_lab(p) for p in pal]
    apx = [p[:3] for c in big for p in _pixels(c) if p[3] > 0] or opx
    om, osd = _stats(opx)
    am, asd = _stats(apx)
    cache = {}
    out = []
    for c in big:
        src = c.load()
        w2, h2 = max(1, round(c.width * k)), max(1, round(c.height * k))
        q = Image.new("RGBA", (w2, h2))
        qp = q.load()
        for oy in range(h2):
            y0, y1 = int(oy / k), max(int(oy / k) + 1, int((oy + 1) / k))
            for ox in range(w2):
                x0, x1 = int(ox / k), max(int(ox / k) + 1, int((ox + 1) / k))
                votes, total, solid = {}, 0, 0
                for y in range(y0, min(y1, c.height)):
                    for x in range(x0, min(x1, c.width)):
                        total += 1
                        p = src[x, y]
                        if p[3] == 0:
                            continue
                        solid += 1
                        t = tuple(max(0, min(255, int((p[i] - am[i]) / asd[i] * osd[i] + om[i]))) // 8 * 8
                                  for i in range(3))
                        if t not in cache:
                            lt = _lab(t)
                            cache[t] = min(range(len(pal)), key=lambda j: sum((a - b) ** 2 for a, b in zip(lt, palab[j])))
                        votes[cache[t]] = votes.get(cache[t], 0) + 1
                if total and solid * 2 >= total:
                    qp[ox, oy] = pal[max(votes, key=votes.get)] + (255,)
        on = [[qp[x, y][3] > 0 for x in range(w2)] for y in range(h2)]
        for y in range(h2):
            for x in range(w2):
                if on[y][x] and any(not (0 <= x + ex < w2 and 0 <= y + ey < h2) or not on[y + ey][x + ex]
                                    for ex, ey in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                    qp[x, y] = outline + (255,)
        f = Image.new("RGBA", (cw, ch))
        f.alpha_composite(q.crop((max(0, -dx), max(0, -dy), w2, h2)), (max(0, dx), max(0, dy)))
        out.append(f)
    if idle_last:
        out[-1] = Image.new("RGBA", (cw, ch))
        out[-1].alpha_composite(orig[0], (PAD, PAD))
    return out


def sheet_of(num, out, picks):
    """Hoja de 8 filas (las 3 de la izquierda espejadas) con la semilla elegida por fila."""
    fw, fh = idle_info(num)
    cw, ch = fw + 2 * PAD, fh + 2 * PAD
    rows = [convert(num, r, os.path.join(out, "d%d_s%s.png" % (r, str(picks[r]).rstrip("i"))),
                    True if str(picks[r]).endswith("i") else None) for r in range(5)]
    # 5 = arriba-izq. (espejo de 3), 6 = izq. (de 2), 7 = abajo-izq. (de 1)
    rows += [[f.transpose(Image.FLIP_LEFT_RIGHT) for f in rows[m]] for m in (3, 2, 1)]
    sheet = Image.new("RGBA", (cw * N, ch * 8))
    for r, cells in enumerate(rows):
        for i, c in enumerate(cells):
            sheet.paste(c, (i * cw, r * ch))
    return sheet, cw, ch


def build(num, out, picks):
    sheet, cw, ch = sheet_of(num, out, picks)
    folder = folder_of(num)
    sheet.save(os.path.join(folder, "Strike-Anim.png"))
    # AnimData.xml: Strike propio (pisa el "CopyOf Attack" si estaba)
    xml_path = os.path.join(folder, "AnimData.xml")
    text = open(xml_path, encoding="utf-8").read()
    durs = "".join("\t\t\t\t<Duration>%d</Duration>\n" % d for d in DURATIONS)
    anim = ("<Anim>\n\t\t\t<Name>Strike</Name>\n\t\t\t<Index>%s</Index>\n\t\t\t<FrameWidth>%d</FrameWidth>\n"
            "\t\t\t<FrameHeight>%d</FrameHeight>\n\t\t\t<RushFrame>1</RushFrame>\n\t\t\t<HitFrame>2</HitFrame>\n"
            "\t\t\t<ReturnFrame>3</ReturnFrame>\n\t\t\t<Durations>\n%s\t\t\t</Durations>\n\t\t</Anim>")
    old = re.search(r"<Anim>\s*<Name>Strike</Name>.*?</Anim>", text, re.S)
    if old:
        index = re.search(r"<Index>(\d+)</Index>", old.group(0))
        text = text[:old.start()] + anim % (index.group(1) if index else "99", cw, ch, durs) + text[old.end():]
    else:
        text = text.replace("</Anims>", "\t" + anim % ("99", cw, ch, durs) + "\n\t</Anims>")
    open(xml_path, "w", encoding="utf-8", newline="\n").write(text)
    # sprite_data.gd: la misma línea que escribiría download_sprites.py
    sd = os.path.join(ROOT, "scripts", "generated", "sprite_data.gd")
    lines = open(sd, encoding="utf-8").read().split("\n")
    entry = '\t\t"Strike": {"file": "res://sprites/pokemon/%04d/Strike-Anim.png", "w": %d, "h": %d, "durations": [%s]},' \
            % (num, cw, ch, ", ".join(str(d) for d in DURATIONS))
    start = lines.index("\t%d: {" % num)
    end = lines.index("\t},", start)
    for i in range(start, end):
        if lines[i].startswith('\t\t"Strike":'):
            lines[i] = entry
            break
    else:
        after = start
        for i in range(start, end):  # va después de Charge / QuickStrike (el orden de download_sprites.py)
            if re.match(r'\t\t"(Idle|Walk|Attack|Hurt|Shoot|Charge|QuickStrike)":', lines[i]):
                after = i
        lines.insert(after + 1, entry)
    open(sd, "w", encoding="utf-8", newline="\n").write("\n".join(lines))
    print("Strike-Anim.png %dx%d (celda %dx%d)" % (sheet.width, sheet.height, cw, ch))


if __name__ == "__main__":
    mode = sys.argv[1]
    if mode == "gen":
        seeds = [int(s) for s in (sys.argv[6] if len(sys.argv) > 6 else "1234,777").split(",")]
        gen(int(sys.argv[2]), sys.argv[3], sys.argv[4], sys.argv[5], seeds)
    else:
        build(int(sys.argv[2]), sys.argv[3], sys.argv[4].split(","))
