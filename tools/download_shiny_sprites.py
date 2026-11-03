"""Baja la versión shiny de los sprites PMD (PMDCollab/SpriteCollab, carpeta 0000/0001 de cada especie) de las mismas
hojas que usa el juego (las de scripts/generated/sprite_data.gd) → sprites/pokemon/<n.º>/shiny/<hoja>.png + el retrato.
Son el mismo dibujo recoloreado (mismo AnimData.xml: igual tamaño de cuadros y tiempos), así que el juego cambia la
textura y listo (CreatureSprite con CreatureInstance.shiny). Lo que falte se saltea: se usa la hoja normal.

Uso: python -I -B tools/download_shiny_sprites.py <carpeta del proyecto>
No vuelve a bajar lo que ya está. Ojo: las hojas retocadas a mano (Sleep con ojos cerrados de tools/sleep_eyes.py, golpes
hechos con Qwen) en shiny son las originales de PMDCollab.
"""
import os
import re
import sys
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor

BASE = "https://raw.githubusercontent.com/PMDCollab/SpriteCollab/master"


def save(url, dest):
    if os.path.exists(dest):
        return True
    req = urllib.request.Request(url, headers={"User-Agent": "pokemon-pilot-fangame"})
    try:
        with urllib.request.urlopen(req, timeout=40) as r:
            data = r.read()
    except urllib.error.HTTPError:
        return False
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    with open(dest, "wb") as f:
        f.write(data)
    return True


def main():
    root = sys.argv[1]
    data = open(os.path.join(root, "scripts", "generated", "sprite_data.gd"), encoding="utf-8").read()
    jobs = set()
    for sid, file in re.findall(r'res://sprites/pokemon/(\d{4})/([\w-]+\.png)', data):
        folder = os.path.join(root, "sprites", "pokemon", sid, "shiny")
        if file == "portrait.png":
            jobs.add(("%s/portrait/%s/0000/0001/Normal.png" % (BASE, sid), os.path.join(folder, file)))
        else:
            jobs.add(("%s/sprite/%s/0000/0001/%s" % (BASE, sid, file), os.path.join(folder, file)))
    with ThreadPoolExecutor(12) as pool:
        ok = list(pool.map(lambda j: save(*j), sorted(jobs)))
    print("hojas shiny: %d de %d (faltan %d)" % (sum(ok), len(ok), len(ok) - sum(ok)))


if __name__ == "__main__":
    main()
