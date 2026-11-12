"""Batería de balance del Modo Desafío (pedido del usuario 2026-11-11): corre cientos de partidas con un bot, en varios
procesos de Godot a la vez, y arma docs/ROGUE_BALANCE_INFORME.md. El bot y lo que registra están en
scripts/tests/rogue_balance_tests.gd (`--autotest-rogue-balance`).

  python -I -B tools/rogue_balance.py run <Godot_console.exe> <carpeta_de_datos> [--jobs 8] [--base 150] [--iso 15]
        [--ids a,b,c | --no-iso] [--dodge 0.7] [--policy azar] [--set clave=valor,...] [--give id,id]
  python -I -B tools/rogue_balance.py report <carpeta_de_datos> [--out docs/ROGUE_BALANCE_INFORME.md]
        [--before <otra carpeta>] [--title "..."]

`run` hace dos cosas: la **línea base** (`--base` partidas con los 3 iniciales, eligiendo al azar) y las **aisladas**
(`--iso` partidas por cada objeto y bendición, arrancando con ese solo: así se mide cuánto empuja cada uno sin el sesgo
de "lo tenía porque llegó lejos"). `--give` suma cosas de entrada a TODAS las partidas (simular desbloqueos permanentes).
Cada proceso deja un .jsonl en la carpeta; se puede cortar y retomar (las tandas ya completas no se repiten).
Sin dependencias (no necesita Pillow).
"""
import glob
import json
import math
import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

STARTERS = ["charmander", "squirtle", "bulbasaur"]
# Potenciadores de tipo: todos hacen lo mismo, así que se mide uno por inicial (con su tipo) y el de Normal.
BOOSTER_OF = {"carbon": "charmander", "agua_mistica": "squirtle", "semilla_milagro": "bulbasaur"}
RARITY_MULT = {"comun": 1.0, "rara": 1.25, "epica": 1.5, "legendaria": 1.8}


def arg(args, key, default=None):
    return args[args.index(key) + 1] if key in args else default


def catalog(root):
    """id -> (nombre, clase, efecto) leyendo los .tres de bendiciones y objetos."""
    out = {}
    for folder, kind in (("data/boons", "bendición"), ("data/rogue_items", "objeto")):
        for path in sorted(glob.glob(os.path.join(root, folder, "*.tres"))):
            text = open(path, encoding="utf8").read()
            get = lambda key: text.split("\n%s = \"" % key)[1].split('"')[0] if ("\n%s = \"" % key) in text else ""
            out[get("id")] = (get("display_name"), kind, get("effect"), get("giver"))
    return out


def count_lines(path):
    return sum(1 for _ in open(path, encoding="utf8")) if os.path.exists(path) else 0


def run(args):
    godot, data = args[0], args[1]
    root = os.getcwd()
    os.makedirs(data, exist_ok=True)
    jobs = int(arg(args, "--jobs", "8"))
    base = int(arg(args, "--base", "150"))
    iso = int(arg(args, "--iso", "15"))
    common = ["--dodge", arg(args, "--dodge", "0.7"), "--policy", arg(args, "--policy", "azar")]
    if arg(args, "--set"):
        common.append("--rogue-set=" + arg(args, "--set"))
    extra_give = [x for x in (arg(args, "--give", "") or "").split(",") if x]
    cat = catalog(root)
    tasks = []  # (archivo, runs, argumentos)
    per = max(3, math.ceil(base / max(1, jobs) / 3) * 3)
    for k in range(math.ceil(base / per)):
        tasks.append(("base_%02d" % k, per, ["--tag", "", "--starter", ",".join(STARTERS[k % 3:] + STARTERS[:k % 3])]
                      + (["--give", ",".join(extra_give)] if extra_give else [])))
    if "--no-iso" not in args and iso > 0:
        ids = arg(args, "--ids")
        ids = ids.split(",") if ids else [i for i in cat if cat[i][2] != "bonus_type" or i in BOOSTER_OF or i == "panuelo_seda"]
        for i in ids:
            starters = [BOOSTER_OF[i]] if i in BOOSTER_OF else STARTERS
            tasks.append(("iso_" + i, iso, ["--tag", i, "--give", ",".join([i] + extra_give), "--starter", ",".join(starters)]))

    def one(task):
        name, runs, more = task
        path = os.path.join(data, name + ".jsonl")
        left = runs - count_lines(path)
        if left <= 0:
            return name, 0
        cmd = [godot, "--headless", "--path", root, "--fixed-fps", "60", "--quit-after", "90000000", "--",
               "--autotest-rogue-balance", "--runs", str(left), "--json", os.path.abspath(path)] + common + more
        with open(os.path.join(data, name + ".log"), "a", encoding="utf8") as log:
            subprocess.run(cmd, stdout=log, stderr=subprocess.STDOUT, timeout=runs * 240 + 600)
        return name, left

    done = 0
    with ThreadPoolExecutor(max_workers=jobs) as pool:
        for name, n in pool.map(one, tasks):
            done += n
            print("  %s: %d partidas" % (name, n), flush=True)
    print("%d partidas nuevas en %s" % (done, data))


def load(data):
    rows = []
    for path in sorted(glob.glob(os.path.join(data, "*.jsonl"))):
        for line in open(path, encoding="utf8"):
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows


def score(r):
    """Avance de una partida: salas limpiadas (0-5) + 1 si le ganó al jefe."""
    return r["rooms"] + (1 if r["result"] == "win" else 0)


def stats(rows):
    ok = [r for r in rows if r["result"] != "trabado"]
    n = len(ok)
    if n == 0:
        return None
    sc = [score(r) for r in ok]
    mean = sum(sc) / n
    var = sum((x - mean) ** 2 for x in sc) / max(1, n - 1)
    reach = sum(1 for r in ok if r["boss_level"] > 0)
    win = sum(1 for r in ok if r["result"] == "win")
    rooms = sum(max(1, r["rooms"] + (1 if r["boss_level"] > 0 else 0)) for r in ok)
    lv = [r["boss_level"] for r in ok if r["boss_level"] > 0]
    return {"n": n, "score": mean, "se": math.sqrt(var / n), "reach": reach / n, "win": win / n, "wins": win, "reached": reach,
            "taken": sum(r["taken_dmg"] for r in ok) / rooms, "dealt": sum(r["dealt"] for r in ok) / rooms,
            "time": sum(r["time"] for r in ok) / n, "level": sum(lv) / len(lv) if lv else 0.0,
            "stuck": len(rows) - n}


def pct(x):
    return "%d %%" % round(x * 100)


def summary_table(title, groups):
    out = ["| %s | Partidas | Llega a Brock | Le gana | Avance medio (0-6) | Nivel al jefe | Daño recibido por sala | Trabadas |" % title,
           "|---|---|---|---|---|---|---|---|"]
    for name, rows in groups:
        s = stats(rows)
        if s:
            out.append("| %s | %d | %s (%d) | %s (%d) | %.2f | %.1f | %d | %d |" % (name, s["n"], pct(s["reach"]), s["reached"],
                       pct(s["win"]), s["wins"], s["score"], s["level"], round(s["taken"]), s["stuck"]))
    return out


def report(args):
    data = args[0]
    root = os.getcwd()
    out_path = arg(args, "--out", "docs/ROGUE_BALANCE_INFORME.md")
    before = arg(args, "--before")
    cat = catalog(root)
    rows = load(data)
    base = [r for r in rows if r["tag"] == ""]
    b = stats(base)
    floor = json.load(open(os.path.join(root, "data/rogue/desafio.json"), encoding="utf8"))
    L = ["# Modo Desafío — informe de balance", "",
         "Generado por `tools/rogue_balance.py` (no editar a mano: se pisa). %s" % (arg(args, "--title", "") or ""), "",
         "Un bot juega partidas enteras: salas al azar, puertas, recompensas, Tienda y la pelea con Brock de verdad. "
         "El bot esquiva %s de los golpes que ve venir, tira ataques de daño al azar, toma la Poción bajo 45 %% de vida y "
         "elige bendiciones y objetos al azar. **Juega peor que una persona atenta** (no arma combinaciones, no apunta "
         "con criterio, no guarda PP): sus números son un piso." % pct(base[0]["dodge"] if base else 0.7), "",
         "Números del piso al medir: EXP ×%s, esbirros con %s de vida, %d atacando a la vez, %d Pociones, cura %s por sala." % (
             floor["exp_mult"], pct(floor["minion_hp"]), floor["attackers"], floor["potions"], pct(floor["heal_on_clear"])), ""]
    notes = os.path.join(root, "docs/ROGUE_BALANCE_NOTAS.md")  # conclusiones escritas a mano (se versionan aparte)
    if os.path.exists(notes):
        L += [open(notes, encoding="utf8").read().rstrip(), ""]
    L += ["## Línea base (sin nada de entrada)", ""]
    L += summary_table("", [("Todos", base)] + [(s.capitalize(), [r for r in base if r["starter"] == s]) for s in STARTERS])
    if before:
        old = [r for r in load(before) if r["tag"] == ""]
        L += ["", "**Antes de los ajustes** (misma batería, datos de `%s`):" % os.path.basename(os.path.normpath(before)), ""]
        L += summary_table("", [("Todos", old)] + [(s.capitalize(), [r for r in old if r["starter"] == s]) for s in STARTERS])
    ok = [r for r in base if r["result"] != "trabado"]
    if ok:
        died = {}
        for r in ok:
            key = "Ganó" if r["result"] == "win" else ("Brock" if r["boss_level"] > 0 else "Sala %d" % (r["rooms"] + 1))
            died[key] = died.get(key, 0) + 1
        L += ["", "**Dónde termina la partida**: " + " · ".join("%s: %s" % (k, pct(died[k] / len(ok))) for k in sorted(died)), ""]
        rew = {}
        for r in ok:
            for t in r["rewards"]:
                rew[t] = rew.get(t, 0) + 1
        total = sum(rew.values()) or 1
        L += ["**Recompensas que tocaron** (por sala limpiada): " + " · ".join("%s %s" % (k, pct(v / total)) for k, v in sorted(rew.items(), key=lambda x: -x[1])), ""]
        helped = {}
        for r in rows:
            for h in r.get("helped", []):
                helped[h] = helped.get(h, 0) + 1
        if helped:
            L += ["**Al bot se le trabó el camino** (más de 25 s para llegar a una puerta o al paso; se lo llevó ahí y la partida "
                  "siguió): " + ", ".join("%s ×%d" % kv for kv in sorted(helped.items(), key=lambda x: -x[1])[:20]), ""]
        stuck = [r for r in base if r["result"] == "trabado"]
        if stuck:
            where = {}
            for r in stuck:
                where[r.get("stuck_at", "?")] = where.get(r.get("stuck_at", "?"), 0) + 1
            L += ["**Partidas trabadas** (nadie pega por 45 s; no cuentan): %d — %s" % (len(stuck), ", ".join("%s ×%d" % kv for kv in sorted(where.items()))), ""]

    # --- Aisladas: cada cosa sola, de entrada ---
    iso = {}
    for r in rows:
        if r["tag"] and r["tag"] in cat:
            iso.setdefault(r["tag"], []).append(r)
    if iso and b:
        table = []
        for i, rs in iso.items():
            s = stats(rs)
            if not s:
                continue
            ref = stats([r for r in base if r["starter"] == BOOSTER_OF[i]]) if i in BOOSTER_OF else b
            ref = ref or b
            delta = s["score"] - ref["score"]
            se = math.sqrt(s["se"] ** 2 + ref["se"] ** 2)
            table.append((delta, i, s, ref, delta / se if se > 0 else 0.0))
        table.sort(reverse=True)
        deltas = [t[0] for t in table]
        mean = sum(deltas) / len(deltas)
        sd = math.sqrt(sum((d - mean) ** 2 for d in deltas) / max(1, len(deltas) - 1))
        L += ["## Cada objeto y cada bendición, sola (arrancando la partida con esa sola, común, Nv. 1)", "",
              "Así se ve cuánto empuja cada una sin el sesgo de \"la tenía porque llegó lejos\". **Avance** = salas limpiadas "
              "+ 1 si le ganó a Brock (0 a 6). **Δ** = cuánto más avanza que la línea base (del mismo inicial en los "
              "potenciadores de tipo). **z** = Δ en errores estándar (|z| < 2 = puede ser azar). Media de los Δ: %+.2f; "
              "desvío: %.2f. **ROTO** = Δ más de 1,5 desvíos por encima de la media y z ≥ 2. **Flojo** = Δ ≤ 0 (no se nota "
              "que ayude)." % (mean, sd), "",
              "| | Clase | Partidas | Avance | Δ | z | Llega a Brock | Le gana | Daño recibido por sala | Daño hecho por sala | |",
              "|---|---|---|---|---|---|---|---|---|---|---|"]
        for delta, i, s, ref, z in table:
            flag = "**ROTO**" if delta > mean + 1.5 * sd and z >= 2.0 else ("fuerte" if delta > mean + 0.75 * sd and z >= 1.5 else ("flojo" if delta <= 0.0 else ""))
            L.append("| %s | %s | %d | %.2f | %+.2f | %+.1f | %s | %s | %d | %d | %s |" % (cat[i][0], cat[i][1] + (" (%s)" % cat[i][3] if cat[i][1] == "bendición" else ""),
                     s["n"], s["score"], delta, z, pct(s["reach"]), pct(s["win"]), round(s["taken"]), round(s["dealt"]), flag))
        L.append("")
    # --- En las partidas de la línea base: quién lo tuvo ---
    if ok:
        have = {}
        for r in ok:
            for e in r["boons"] + r["items"]:
                have.setdefault(e["id"], []).append(r)
        L += ["## En las partidas de la línea base: qué se llevó y cómo le fue", "",
              "Ojo: acá hay sesgo (cuanto más lejos llega una partida, más cosas junta). Sirve para ver **qué aparece y cuánto**, no para "
              "decidir nerfeos; para eso está la tabla de arriba.", "",
              "| | Clase | La tuvo | Avance con ella | Avance sin ella | Le gana a Brock con ella |", "|---|---|---|---|---|---|"]
        for i, rs in sorted(have.items(), key=lambda kv: -len(kv[1])):
            if i not in cat:
                continue
            without = [r for r in ok if r not in rs]
            L.append("| %s | %s | %s (%d) | %.2f | %.2f | %s |" % (cat[i][0], cat[i][1], pct(len(rs) / len(ok)), len(rs),
                     sum(score(r) for r in rs) / len(rs), sum(score(r) for r in without) / max(1, len(without)),
                     pct(sum(1 for r in rs if r["result"] == "win") / len(rs))))
        L.append("")
    # --- Otras tandas (simulaciones "con X de entrada") ---
    other = {}
    for r in rows:
        if r["tag"] and r["tag"] not in cat:
            other.setdefault(r["tag"], []).append(r)
    if other:
        L += ["## Simulaciones con cosas de entrada (para el progreso permanente futuro)", ""]
        L += summary_table("De entrada", [("(nada)", base)] + sorted(other.items()))
        L.append("")
    with open(os.path.join(root, out_path), "w", encoding="utf8", newline="\n") as f:
        f.write("\n".join(L) + "\n")
    print("%s: %d partidas (%d de línea base, %d cosas aisladas)" % (out_path, len(rows), len(base), len(iso)))


if __name__ == "__main__":
    if len(sys.argv) < 3 or sys.argv[1] not in ("run", "report"):
        sys.exit(__doc__)
    (run if sys.argv[1] == "run" else report)(sys.argv[2:])
