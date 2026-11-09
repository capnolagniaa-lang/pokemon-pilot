"""Informe de las peleas grabadas contra la IA (S-2 de docs/PLAN_SPARRING_IA.md, Fase 1 de docs/IA_AUDITORIA.md).

Lee los JSON que graba SparringRecorder (ajuste "Grabar peleas" o consola GM `sparring`) y escribe un informe en Markdown:
una fila por pelea con las métricas de AiFightStats, los totales, los errores de la IA que se ven en los hechos (golpes que
se comió viniendo de frente, esquives al vacío), tus costumbres y, para cada marca F8, lo que pasó en los 5 s anteriores.

Python sin dependencias:
    python -I -B tools/sparring_report.py [carpeta con los .json] [--out docs/SPARRING_INFORME.md]
Sin carpeta usa la de la partida: %APPDATA%/Godot/app_userdata/Pokémon Pilot/sparring.
"""

import json
import os
import sys
from collections import Counter

MARK_WINDOW = 5.0


def default_dir():
    base = os.environ.get("APPDATA") or os.path.expanduser("~/.local/share")
    return os.path.join(base, "Godot", "app_userdata", "Pokémon Pilot", "sparring")


def load(folder):
    fights = []
    for name in sorted(os.listdir(folder)):
        if not name.endswith(".json"):
            continue
        try:
            with open(os.path.join(folder, name), encoding="utf-8") as f:
                d = json.load(f)
        except (OSError, ValueError) as e:
            print("  salteo %s: %s" % (name, e))
            continue
        d["_file"] = name
        fights.append(d)
    return fights


def metrics_of(d):
    """Las métricas de AiFightStats (versión 2) o, en archivos viejos, lo que se puede sacar de los hechos."""
    m = dict(d.get("metrics") or {})
    if m:
        return m
    ev = d.get("events", [])
    m["dano_hecho_ia"] = sum(e.get("amount", 0.0) for e in ev if e.get("k") == "hit" and e.get("who") == "me")
    m["dano_hecho_vos"] = sum(e.get("amount", 0.0) for e in ev if e.get("k") == "hit" and e.get("who") == "foe")
    m["esquives_ia"] = sum(1 for e in ev if e.get("k") == "dodge" and e.get("who") == "foe")
    m["esquives_ia_utiles"] = sum(1 for e in ev if e.get("k") == "dodge" and e.get("who") == "foe" and e.get("threat"))
    return m


def pct(x):
    return "%d%%" % round(100 * x)


def fight_row(d):
    m = metrics_of(d)
    rep = m.get("repeticion_ia", {})
    return "| %s | %s | %s | %s | %.0f s | %.2f / %.2f | %s / %s | %s (%s) | %s | %s (%s) | %s | %s |" % (
        d.get("date", "")[:16].replace("T", " "), d.get("trainer", ""), d.get("difficulty", ""),
        {"win": "ganaste", "lose": "perdiste"}.get(d.get("result", ""), d.get("result", "")), d.get("duration", 0.0),
        m.get("dano_hecho_ia", 0.0), m.get("dano_hecho_vos", 0.0),
        m.get("castigos_ia", "-"), m.get("castigos_perdidos_ia", "-"),
        m.get("esquives_ia", 0), m.get("esquives_ia_utiles", 0), m.get("pasos_ia", "-"),
        m.get("cambios_ia", "-"), m.get("cambios_ia_buenos", "-"),
        pct(rep.get("mas_usado", 0.0)) if rep else "-", rep.get("variedad", "-") if rep else "-")


def errors(fights):
    """Errores de la IA que se ven en los hechos."""
    front = total_hits = empty_dodges = dodges = 0
    for d in fights:
        for e in d.get("events", []):
            if e.get("k") == "hit" and e.get("who") == "foe":
                total_hits += 1
                front += 1 if e.get("closing") else 0
            elif e.get("k") == "dodge" and e.get("who") == "foe":
                dodges += 1
                empty_dodges += 0 if e.get("threat") else 1
    return front, total_hits, empty_dodges, dodges


def your_habits(fights):
    moves = Counter()
    dodges = 0
    dists = []
    for d in fights:
        for e in d.get("events", []):
            if e.get("k") == "use" and e.get("who") == "me":
                moves[e.get("move", "")] += 1
            elif e.get("k") == "dodge" and e.get("who") == "me":
                dodges += 1
        cols = d.get("columns", [])
        if "dist" in cols:
            i = cols.index("dist")
            dists += [s[i] for s in d.get("samples", []) if len(s) > i]
    return moves, dodges, dists


def describe_event(e):
    k = e.get("k")
    who = {"me": "vos", "foe": "IA"}.get(e.get("who", ""), "")
    if k == "ia":
        extra = ", ".join("%s=%s" % (a, b) for a, b in e.items() if a not in ("k", "t", "what"))
        return "IA decide %s (%s)" % (e.get("what", ""), extra)
    if k == "hit":
        return "golpe a %s (%s, %s de vida%s)" % (who, e.get("move", ""), pct(e.get("amount", 0.0)),
                                                  ", venía de frente" if e.get("closing") else "")
    if k == "use":
        return "%s usa %s" % (who, e.get("move", ""))
    if k == "dodge":
        return "%s esquiva%s" % (who, " (%s)" % e["threat"] if e.get("threat") else " al vacío")
    if k == "send":
        return "%s saca a %s" % (who, e.get("species", ""))
    if k == "wary":
        return "la IA se pone a cubierto (bajo fuego)"
    if k == "faint":
        return "cae el de %s" % who
    return "%s %s" % (k, who)


def report(fights):
    out = ["# Informe de sparring (peleas grabadas contra la IA)", "",
           "> Generado por `tools/sparring_report.py` con %d pelea(s). Qué mide cada columna: `AiFightStats`"
           " (`scripts/creatures/ai/ai_fight_stats.gd`). Daño en vidas enteras del que lo recibe." % len(fights), ""]
    if not fights:
        out.append("No hay peleas grabadas. Prendé \"Grabar peleas\" (Opciones → Ajustes del juego) o usá `sparring` en la consola GM.")
        return "\n".join(out)
    out += ["## Peleas", "",
            "| Fecha | Entrenador | Dificultad | Resultado | Duración | Daño IA / vos | Castigos IA hechos / perdidos | Esquives IA (útiles) | Pasos IA | Cambios IA (buenos) | Ataque más usado | Variedad |",
            "|---|---|---|---|---|---|---|---|---|---|---|---|"]
    out += [fight_row(d) for d in fights]
    wins = sum(1 for d in fights if d.get("result") == "win")
    ms = [metrics_of(d) for d in fights]
    def tot(k):
        return sum(m.get(k, 0) or 0 for m in ms)
    out += ["", "## Totales", "",
            "- Ganaste %d de %d (%s)." % (wins, len(fights), pct(wins / len(fights))),
            "- Castigos de la IA: %d hechos, %d perdidos. Tuyos: %d hechos, %d perdidos." % (
                tot("castigos_ia"), tot("castigos_perdidos_ia"), tot("castigos_vos"), tot("castigos_perdidos_vos")),
            "- Cambios de la IA: %d (%d buenos por cruce). Tuyos: %d." % (tot("cambios_ia"), tot("cambios_ia_buenos"), tot("cambios_vos")),
            "- La IA juntó PP %d veces, amagó %d y te leyó el ataque repetido %d." % (tot("juntar_pp_ia"), tot("fintas_ia"), tot("lecturas_ia"))]
    front, hits, empty, dodges = errors(fights)
    out += ["", "## Errores de la IA", "",
            "- Golpes que se comió viniendo de frente: %d de %d." % (front, hits),
            "- Esquives al vacío (sin nada que esquivar): %d de %d." % (empty, dodges)]
    moves, your_dodges, dists = your_habits(fights)
    out += ["", "## Tus costumbres", "",
            "- Ataques: %s." % (", ".join("%s ×%d" % (k, v) for k, v in moves.most_common(6)) or "—"),
            "- Esquives: %d." % your_dodges]
    if dists:
        dists.sort()
        out.append("- Distancia: mediana %d px (la mitad del tiempo entre %d y %d)." % (
            dists[len(dists) // 2], dists[len(dists) // 4], dists[3 * len(dists) // 4]))
    marks = [(d, t) for d in fights for t in d.get("marks", [])]
    out += ["", "## Tus marcas (F8)", ""]
    if not marks:
        out.append("Ninguna.")
    for d, t in marks:
        out.append("### %s, %.1f s (%s)" % (d.get("trainer", ""), t, d["_file"]))
        near = [e for e in d.get("events", []) if t - MARK_WINDOW <= e.get("t", -99) <= t and e.get("k") != "slot"]
        out += ["- %.1f s: %s" % (e.get("t", 0.0), describe_event(e)) for e in near] or ["- (nada en los 5 s anteriores)"]
        out.append("")
    return "\n".join(out) + "\n"


def main(argv):
    out_path = "docs/SPARRING_INFORME.md"
    args = list(argv)
    if "--out" in args:
        i = args.index("--out")
        out_path = args[i + 1]
        del args[i:i + 2]
    folder = args[0] if args else default_dir()
    if not os.path.isdir(folder):
        print("No existe la carpeta %s" % folder)
        return 1
    fights = load(folder)
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(report(fights))
    print("Informe: %s (%d peleas)" % (out_path, len(fights)))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
