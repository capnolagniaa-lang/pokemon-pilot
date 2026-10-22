"""Descarga los sprites PMD (PMDCollab/SpriteCollab) de los Pokémon por número de Pokédex y genera
scripts/generated/sprite_data.gd. Reemplaza a download_sprites.ps1.

Uso: python -I tools/download_sprites.py <carpeta del proyecto> [hasta_dex=386]
No vuelve a bajar lo que ya está. Si a una especie le falta una animación o el retrato, se saltea (el juego
usa lo que haya).
"""
import os
import sys
import urllib.error
import urllib.request
import xml.etree.ElementTree as ET
from concurrent.futures import ThreadPoolExecutor

BASE = "https://raw.githubusercontent.com/PMDCollab/SpriteCollab/master"
ANIMS = ["Idle", "Walk", "Attack", "Hurt"]


def fetch(url):
    req = urllib.request.Request(url, headers={"User-Agent": "pokemon-pilot-fangame"})
    with urllib.request.urlopen(req, timeout=40) as r:
        return r.read()


def save(url, dest):
    if os.path.exists(dest):
        return True
    try:
        data = fetch(url)
    except urllib.error.HTTPError:
        return False
    with open(dest, "wb") as f:
        f.write(data)
    return True


def species(root, n):
    sid = "%04d" % n
    folder = os.path.join(root, "sprites", "pokemon", sid)
    os.makedirs(folder, exist_ok=True)
    entry = {}
    xml_path = os.path.join(folder, "AnimData.xml")
    if save("%s/sprite/%s/AnimData.xml" % (BASE, sid), xml_path):
        by_name = {a.findtext("Name"): a for a in ET.parse(xml_path).getroot().iter("Anim")}
        for name in ANIMS:
            a = by_name.get(name)
            while a is not None and a.findtext("CopyOf"):
                a = by_name.get(a.findtext("CopyOf"))
            if a is None:
                continue
            file = "%s-Anim.png" % a.findtext("Name")
            if not save("%s/sprite/%s/%s" % (BASE, sid, file), os.path.join(folder, file)):
                continue
            durs = [int(d.text) for d in a.find("Durations").iter("Duration")]
            entry[name] = {"file": "res://sprites/pokemon/%s/%s" % (sid, file), "w": int(a.findtext("FrameWidth")),
                           "h": int(a.findtext("FrameHeight")), "durations": durs}
    if save("%s/portrait/%s/Normal.png" % (BASE, sid), os.path.join(folder, "portrait.png")):
        entry["portrait"] = "res://sprites/pokemon/%s/portrait.png" % sid
    return n, entry


def main():
    root = sys.argv[1]
    last = int(sys.argv[2]) if len(sys.argv) > 2 else 386
    with ThreadPoolExecutor(8) as pool:
        results = sorted(pool.map(lambda n: species(root, n), range(1, last + 1)))
    lines = ["extends RefCounted", "## Generado por tools/download_sprites.py - no editar a mano.", "", "const ANIMS := {"]
    missing = []
    for n, entry in results:
        if "Idle" not in entry:
            missing.append(n)
        if not entry:
            continue
        lines.append("\t%d: {" % n)
        if "portrait" in entry:
            lines.append('\t\t"portrait": "%s",' % entry["portrait"])
        for name in ANIMS:
            if name in entry:
                a = entry[name]
                lines.append('\t\t"%s": {"file": "%s", "w": %d, "h": %d, "durations": [%s]},'
                             % (name, a["file"], a["w"], a["h"], ", ".join(str(d) for d in a["durations"])))
        lines.append("\t},")
    lines.append("}")
    with open(os.path.join(root, "scripts", "generated", "sprite_data.gd"), "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lines) + "\n")
    print("especies con sprites:", len(results) - len(missing), "| sin animación Idle:", missing)


if __name__ == "__main__":
    main()
