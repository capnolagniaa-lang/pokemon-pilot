"""Pasadas de balance 1 y 2 (pedido del usuario 2026-10-28: "subir a los débiles"; "los dragón tienen que ser casi los más
fuertes del juego"). Sale de la batería `--autotest-balance` (docs/BALANCE_INFORME.md): los que casi no ganaban hacían
muy poco daño (ataques básicos de 15-20, dos de estado, o pegaban con el stat equivocado: Chansey tiene Ataque 5).

Los valores se calculan desde la versión de los kits en el commit BASE (antes de esta pasada), así correrlo dos veces
deja lo mismo. Tabla AJUSTES: kit -> {archivo del ataque: {campo: valor o "×factor"}}.

Uso: python -I -B tools/balance_pass.py <carpeta del proyecto>
Después: tools/build_learnsets.gd (los learnsets guardan los ataques del kit) y volver a correr la batería.
"""
import os
import re
import subprocess
import sys

BASE = "23761d44"

AJUSTES = {
    # Tanque que no pegaba: ataca con At. Esp. (35) en vez de Ataque (5).
    "chansey": {"destructor_chansey": {"category": 1, "power": "×1.6"},
                "bomba_huevo_chansey": {"category": 1, "power": "×1.5", "cooldown": 3.0}},
    "clefairy": {"doble_bofeton_clefairy": {"power": 45}, "metronomo_clefairy": {"cooldown": 3.5}},
    "caterpie": {"placaje_caterpie": {"power": "×1.6"}},
    "metapod": {"placaje_metapod": {"power": "×1.3"}, "derribo_metapod": {"power": "×1.3"}},
    # Dragón (pedido del usuario): de los más fuertes.
    "dratini": {"atadura_dratini": {"power": 55, "cooldown": 0.9},
                "furia_dragon_dratini": {"power": 110, "cooldown": 2.0},
                "onda_trueno_dratini": {"cooldown": 6.0}},
    "horsea": {"burbuja_horsea": {"power": 30}},
    "exeggcute": {"bombardeo_exeggcute": {"power": 30}, "rayo_solar_exeggcute": {"cooldown": 5.0}},
    "goldeen": {"picotazo_goldeen": {"power": 60}, "cornada_goldeen": {"power": 95, "cooldown": 4.0},
                "hidrochorro_goldeen": {"power": 40}},
    "mr_mime": {"doble_bofeton_mr_mime": {"power": 35}, "confusion_mr_mime": {"power": 75, "cooldown": 1.0},
                "psiquico_mr_mime": {"cooldown": 4.5}},
    "voltorb": {"chispa_voltorb": {"power": 65}, "rodar_voltorb": {"power": 55, "cooldown": 1.8},
                "bomba_sonica_voltorb": {"power": 45}},
    "poliwag": {"burbuja_kit": {"cooldown": 2.0}, "pistola_agua_poliwag": {"power": 55, "cooldown": 1.0}},
    "ditto": {"pegote_ditto": {"power": 50}, "gel_ditto": {"power": 35}, "transformacion_ditto": {"cooldown": 20.0}},
    "ekans": {"picotazo_veneno_ekans": {"power": 35}, "constriccion_ekans": {"power": 30}, "acido_ekans": {"power": 35}},
    "jigglypuff": {"destructor_jigglypuff": {"power": 50}, "rodar_jigglypuff": {"power": 55, "cooldown": 2.5}},
    "sandshrew": {"aranazo_sandshrew": {"power": 50}, "picotazo_veneno_sandshrew": {"power": 35}},
    "diglett": {"aranazo_diglett": {"power": 60}, "excavar_diglett": {"cooldown": 4.0},
                "terremoto_diglett": {"cooldown": 6.0}},
    "jynx": {"doble_bofeton_jynx": {"power": 25}, "polvo_nieve_jynx": {"power": 50}},
}


def base_text(root, rel):
    out = subprocess.run(["git", "-C", root, "show", "%s:%s" % (BASE, rel)], capture_output=True)
    return out.stdout.decode("utf-8") if out.returncode == 0 else None


def fmt(field, v):
    if field in ("category", "kind", "combo_steps", "projectile_count"):
        return str(int(v))
    return repr(float(v))


def main():
    root = sys.argv[1]
    n = 0
    for kit, moves in AJUSTES.items():
        for stem, fields in moves.items():
            rel = "data/kits/%s/%s.tres" % (kit, stem)
            text = base_text(root, rel)
            if text is None:
                sys.exit("no está en %s: %s" % (BASE, rel))
            for field, v in fields.items():
                cur = re.search(r"^%s = (.+)$" % field, text, re.M)
                if isinstance(v, str) and v.startswith("×"):
                    v = round(float(cur.group(1) if cur else 40.0) * float(v[1:]))
                line = "%s = %s" % (field, fmt(field, v))
                if cur:
                    text = text[:cur.start()] + line + text[cur.end():]
                else:  # campo con su valor por defecto: se agrega al final del [resource]
                    text = text.rstrip("\n") + "\n" + line + "\n"
            with open(os.path.join(root, rel), "w", encoding="utf-8", newline="\n") as f:
                f.write(text)
            n += 1
    print("ajustados %d ataques" % n)


if __name__ == "__main__":
    main()
