"""Sinergia de los ataques oficiales con los kits (pedido del usuario 2026-10-26: "todos los movimientos de la wiki
tienen que poder elegirse y hacer sinergia con el kit").

Los ataques automáticos de mejora propia (data/moves, `kind = 9` = SELF_BUFF) salieron sin estado: Refugio, Foco
Energía, Rizo Defensa, Fortaleza, Síntesis... no hacían nada, así que aprenderlos no activaba la firma (Caparazón de
Squirtle, Instinto de Rattata, Impulso de Geodude...). Este script les copia la forma en tiempo real de su versión de
kit con el **mismo nombre** (el estado propio, la duración, o la forma entera si el del kit es otra cosa, como
Teletransporte, que en el kit es un desplazamiento). El id del oficial no cambia (las partidas y learnsets lo usan).

Uso: python -I -B tools/link_official_moves.py <carpeta del proyecto>
Ojo: `apply_official_data.gd -- --regen-auto` vuelve a armar los automáticos: correr este script después.
"""
import glob
import os
import re
import sys


def read(p):
    return open(p, encoding="utf-8").read()


def field(s, name):
    m = re.search(r"^%s = (.*)$" % name, s, re.M)
    return m.group(1) if m else None


# Los demás de mejora propia sin versión de kit: un efecto genérico según lo que hacen en los juegos.
BUFF_GROUPS = {
    "potenciado": ["afilar", "aullido", "danza_espada", "meditacion", "danza_dragon", "corpulencia", "tambor", "carga",
                   "paz_mental", "amnesia", "desarrollo", "luminicola"],
    "fortaleza": ["armadura_acida", "barrera", "defensa_ferrea", "masa_cosmica", "reflejo", "pantalla_de_luz",
                  "velo_sagrado", "neblina"],
    "agilidad": ["doble_equipo"],
    "refugio": ["proteccion", "deteccion"],  # con Squirtle activan el parry de Caparazón
    "recuperando": ["alivio", "deseo", "aromaterapia", "cascabel_cura", "reserva"],
}


def link_generic(root):
    done = []
    for status, ids in BUFF_GROUPS.items():
        for mid in ids:
            p = os.path.join(root, "data", "moves", mid + ".tres")
            if not os.path.exists(p):
                continue
            s = read(p)
            if field(s, "self_status") is not None:
                continue
            ext = '[ext_resource type="Resource" path="res://data/status/%s.tres" id="9_self"]' % status
            lines = s.rstrip("\n").split("\n")
            last_ext = max(i for i, l in enumerate(lines) if l.startswith("[ext_resource"))
            lines.insert(last_ext + 1, ext)
            lines.append('self_status = ExtResource("9_self")')
            with open(p, "w", encoding="utf-8", newline="\n") as f:
                f.write("\n".join(lines) + "\n")
            done.append(mid)
    print("con efecto genérico:", done)


def main():
    root = sys.argv[1]
    kit_by_name = {}
    for p in sorted(glob.glob(os.path.join(root, "data", "kits", "*", "*.tres"))):
        s = read(p)
        if 'script_class="MoveData"' not in s:
            continue
        name = field(s, "display_name")
        useful = field(s, "self_status") is not None or field(s, "kind") not in (None, "9")
        if name and useful and name not in kit_by_name:
            kit_by_name[name] = s
    # Los automáticos (official.json "auto": su forma la inventó _shape) toman la forma de su versión de kit; los
    # hechos a mano (MOVES del fetcher) se respetan, salvo los de mejora propia que quedaron sin estado.
    import json
    official = json.load(open(os.path.join(root, "data", "source", "official.json"), encoding="utf-8"))["moves"]
    done = []
    for p in sorted(glob.glob(os.path.join(root, "data", "moves", "*.tres"))):
        s = read(p)
        mid = os.path.basename(p)[:-5]
        empty_buff = field(s, "kind") == "9" and field(s, "self_status") is None
        if not empty_buff and not official.get(mid, {}).get("auto", False):
            continue
        name = field(s, "display_name")
        kit = kit_by_name.get(name)
        if kit is None:
            continue
        new = re.sub(r'^id = ".*"$', "id = %s" % field(s, "id"), kit, count=1, flags=re.M)
        # El costo de recurso es de la firma de ese kit: en otro Pokémon no tiene que gastarle su barra.
        new = re.sub(r"^resource_(cost|scaling) = .*\n", "", new, flags=re.M)
        with open(p, "w", encoding="utf-8", newline="\n") as f:
            f.write(new)
        done.append(os.path.basename(p)[:-5])
    print("enlazados con su versión de kit:", done)
    link_generic(root)


if __name__ == "__main__":
    main()
