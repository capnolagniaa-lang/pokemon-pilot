# Página para revisar las animaciones por familia (family_anims.py): out/animaciones/revision.html.
# Por Pokémon, cada familia con su GIF (8 direcciones, Idle en el centro) y los ataques que la usan; botones Bien /
# Rehacer / No va y una nota. Lo marcado queda en el navegador (localStorage) y "Copiar revisión" arma el texto para
# pasárselo a Claude.   python -I -B tools/comfy/review_page.py
import html, json, os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "out", "animaciones")

PAGE = """<!doctype html>
<html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Revisión de animaciones</title>
<style>
:root { --bg:#16181d; --card:#20232b; --line:#323743; --text:#e8eaf0; --dim:#9aa1b2; --ok:#3fb06a; --redo:#e0a030;
        --no:#d0504a; }
* { box-sizing:border-box }
body { margin:0; background:var(--bg); color:var(--text); font:15px/1.4 system-ui, sans-serif }
header { position:sticky; top:0; z-index:2; background:#101216ee; border-bottom:1px solid var(--line);
         padding:10px 16px; display:flex; gap:12px; flex-wrap:wrap; align-items:center }
header h1 { font-size:17px; margin:0 12px 0 0 }
header .count { color:var(--dim) }
button, select { background:#2b2f3a; color:var(--text); border:1px solid var(--line); border-radius:6px;
                 padding:6px 10px; font:inherit; cursor:pointer }
main { padding:12px 16px 80px; max-width:1500px; margin:0 auto }
section { margin:22px 0 }
section h2 { font-size:18px; margin:0 0 8px; display:flex; gap:10px; align-items:baseline }
section h2 small { color:var(--dim); font-weight:normal; font-size:13px }
.grid { display:grid; grid-template-columns:repeat(auto-fill, minmax(330px, 1fr)); gap:12px }
.card { background:var(--card); border:2px solid var(--line); border-radius:10px; padding:10px }
.card.bien { border-color:var(--ok) } .card.rehacer { border-color:var(--redo) } .card.no { border-color:var(--no) }
.card img { width:100%; image-rendering:pixelated; border-radius:6px; background:#3c783c }
.card h3 { margin:6px 0 2px; font-size:15px }
.card .moves { color:var(--dim); font-size:13px; min-height:2.6em }
.card .row { display:flex; gap:6px; margin-top:8px }
.card .row button { flex:1 }
.card .row button.on.bien { background:var(--ok); color:#000 }
.card .row button.on.rehacer { background:var(--redo); color:#000 }
.card .row button.on.no { background:var(--no); color:#000 }
.card input { width:100%; margin-top:6px; background:#15171c; color:var(--text); border:1px solid var(--line);
              border-radius:6px; padding:6px }
.hide { display:none !important }
#copied { color:var(--ok) }
</style></head><body>
<header><h1>Revisión de animaciones</h1>
<span class="count" id="count"></span>
<select id="filter"><option value="all">Todas</option><option value="todo">Sin revisar</option>
<option value="rehacer">Para rehacer / no va</option></select>
<button id="copy">Copiar revisión</button><span id="copied"></span></header>
<main>
<p style="color:var(--dim)">Cada GIF muestra las 8 direcciones (en el centro, el Pokémon quieto como está hoy en el juego),
más lento que en el juego. El efecto del ataque (fuego, agua, cortes) va aparte: acá solo se mira el cuerpo. Marcá cada
una y, si hace falta, escribí qué está mal. Lo marcado queda guardado en este navegador; al final tocá
"Copiar revisión" y pegámelo.</p>
@SECCIONES@
</main>
<script>
const KEY = "revision_animaciones";
let state = {};
try { state = JSON.parse(localStorage.getItem(KEY) || "{}"); } catch (e) {}
function save() { try { localStorage.setItem(KEY, JSON.stringify(state)); } catch (e) {} }
function paint() {
  let done = 0, total = 0;
  document.querySelectorAll(".card").forEach(c => {
    const s = state[c.dataset.id] || {};
    total++; if (s.v) done++;
    c.className = "card " + (s.v || "");
    c.querySelectorAll(".row button").forEach(b => b.classList.toggle("on", b.dataset.v === s.v));
    const f = document.getElementById("filter").value;
    c.classList.toggle("hide", (f === "todo" && s.v) || (f === "rehacer" && !(s.v === "rehacer" || s.v === "no")));
  });
  document.querySelectorAll("section").forEach(sec =>
    sec.classList.toggle("hide", !sec.querySelector(".card:not(.hide)")));
  document.getElementById("count").textContent = done + " de " + total + " revisadas";
}
document.querySelectorAll(".card").forEach(c => {
  const s = state[c.dataset.id] || {};
  const inp = c.querySelector("input"); inp.value = s.note || "";
  inp.addEventListener("input", () => { state[c.dataset.id] = {...(state[c.dataset.id] || {}), note: inp.value}; save(); });
  c.querySelectorAll(".row button").forEach(b => b.addEventListener("click", () => {
    const cur = state[c.dataset.id] || {};
    state[c.dataset.id] = {...cur, v: cur.v === b.dataset.v ? "" : b.dataset.v}; save(); paint();
  }));
});
document.getElementById("filter").addEventListener("change", paint);
document.getElementById("copy").addEventListener("click", () => {
  const lines = [];
  document.querySelectorAll(".card").forEach(c => {
    const s = state[c.dataset.id] || {};
    const word = {bien: "bien", rehacer: "REHACER", no: "NO VA"}[s.v] || "sin revisar";
    lines.push(c.dataset.id + ": " + word + (s.note ? " (" + s.note + ")" : ""));
  });
  const text = lines.join("\\n");
  const done = () => { document.getElementById("copied").textContent = "Copiado"; };
  if (navigator.clipboard) navigator.clipboard.writeText(text).then(done, () => prompt("Copiá esto:", text));
  else prompt("Copiá esto:", text);
});
paint();
</script></body></html>
"""


def write():
    sections = []
    for folder in sorted(os.listdir(OUT)) if os.path.isdir(OUT) else []:
        path = os.path.join(OUT, folder, "info.json")
        if not os.path.exists(path):
            continue
        info = json.load(open(path, encoding="utf-8"))
        cards = []
        for fam, f in info["families"].items():
            gif = "%s/%s/%s.gif" % (folder, fam, fam)
            if not os.path.exists(os.path.join(OUT, gif)):
                continue
            cid = "%s/%s" % (info["name"], fam)
            cards.append('<div class="card" data-id="%s"><img loading="lazy" src="%s?v=%d" alt="%s">'
                         '<h3>%s</h3><div class="moves">%s</div><div class="row">'
                         '<button data-v="bien">Bien</button><button data-v="rehacer">Rehacer</button>'
                         '<button data-v="no">No va</button></div><input placeholder="Nota (qué está mal)"></div>'
                         % (html.escape(cid), gif, int(os.path.getmtime(os.path.join(OUT, gif))),
                            html.escape(f["title"]), html.escape(f["title"]), html.escape(", ".join(f["moves"]))))
        sections.append('<section><h2>N.º %d %s <small>%d familias</small></h2><div class="grid">%s</div></section>'
                        % (info["dex"], html.escape(info["name"]), len(cards), "".join(cards)))
    os.makedirs(OUT, exist_ok=True)
    open(os.path.join(OUT, "revision.html"), "w", encoding="utf-8").write(PAGE.replace("@SECCIONES@", "\n".join(sections)))


if __name__ == "__main__":
    write()
