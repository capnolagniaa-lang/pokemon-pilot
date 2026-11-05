#!/usr/bin/env python3
"""Partidas de los jugadores en el servidor (docs/SERVIDOR_ONLINE.md, pedido del usuario 2026-11-05).

El juego manda cada partida (scripts/autoload/save_sync.gd) y este servicio guarda la última y un historial en SQLite. El
panel, con el token del archivo `panel_token` (se crea solo, al lado de la base), muestra quién tiene qué y por dónde anda.
Solo la biblioteca estándar. No guarda IP ni nada de la PC: el código de instalación lo genera el juego al azar.

  python3 partidas_server.py [--port 24681] [--db /opt/pokemon-pilot/partidas/partidas.db]

Corre detrás de nginx, que lo publica en /pokemon-pilot/partidas/ (subir = POST /subir, panel = GET /panel?k=<token>).
"""
import argparse
import hmac
import html
import json
import os
import re
import secrets
import sqlite3
import threading
import time
import unicodedata
import zlib
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, quote, urlparse

MAX_BODY = 4 * 1024 * 1024
MAX_DB = 1024 * 1024 * 1024  # con 1 GB deja de aceptar: que un error no llene el disco
MAX_SAVES_PER_INSTALL = 30
MAX_SNAPSHOTS_PER_SAVE = 1000
SNAPSHOT_EVERY = 600  # el historial guarda, jugando, una foto cada 10 minutos (al guardar, siempre)
RATE_WINDOW = 600
RATE_PER_INSTALL = 120
RATE_PER_ADDRESS = 400
UTC_OFFSET = -3 * 3600  # hora de Argentina en el panel
INSTALL_RE = re.compile(r"^[0-9a-f]{32}$")

DB_PATH = ""
TOKEN = ""
_lock = threading.Lock()
_hits: dict = {}


def db() -> sqlite3.Connection:
    con = sqlite3.connect(DB_PATH, timeout=20)
    con.row_factory = sqlite3.Row
    return con


def init_db() -> None:
    with db() as con:
        con.executescript(
            """
            CREATE TABLE IF NOT EXISTS saves (
                install TEXT NOT NULL, name TEXT NOT NULL, player TEXT, game_version TEXT, zone TEXT,
                updated REAL NOT NULL, data BLOB NOT NULL, PRIMARY KEY (install, name));
            CREATE TABLE IF NOT EXISTS snapshots (
                id INTEGER PRIMARY KEY, install TEXT NOT NULL, name TEXT NOT NULL, at REAL NOT NULL, live INTEGER NOT NULL,
                zone TEXT, data BLOB NOT NULL);
            CREATE INDEX IF NOT EXISTS snapshots_save ON snapshots (install, name, at);
            CREATE TABLE IF NOT EXISTS names (norm TEXT PRIMARY KEY, install TEXT NOT NULL, name TEXT NOT NULL);
            """
        )
        # Las primeras subidas llamaron "slot_1" a la partida vieja que en el juego se llama "Partida 1".
        for table in ("saves", "snapshots"):
            con.execute("UPDATE OR IGNORE %s SET name='Partida 1' WHERE name='slot_1'" % table)
        con.execute("DELETE FROM saves WHERE name='slot_1'")
        for r in con.execute("SELECT install, name FROM saves ORDER BY updated").fetchall():
            con.execute("INSERT OR IGNORE INTO names (norm, install, name) VALUES (?,?,?)", (norm_name(r["name"]), r["install"], r["name"]))


def load_token(folder: str) -> str:
    path = os.path.join(folder, "panel_token")
    if not os.path.exists(path):
        fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        with os.fdopen(fd, "w") as f:
            f.write(secrets.token_urlsafe(24))
    with open(path) as f:
        return f.read().strip()


def rate_ok(key: str, limit: int) -> bool:
    now = time.time()
    with _lock:
        hits = [t for t in _hits.get(key, []) if now - t < RATE_WINDOW]
        if len(hits) >= limit:
            _hits[key] = hits
            return False
        hits.append(now)
        _hits[key] = hits
        return True


def norm_name(name: str) -> str:
    """Para comparar nombres: "Ash", "ÁSH" y "a s-h!" son el mismo."""
    plain = unicodedata.normalize("NFKD", name)
    return "".join(c for c in plain if c.isalnum()).casefold()


def reserve_name(body: dict) -> int:
    """Nombre de un personaje nuevo: 200 si queda para esta instalación, 409 si ya es de otra."""
    install = str(body.get("install", ""))
    name = str(body.get("name", "")).strip()[:60]
    norm = norm_name(name)
    if not INSTALL_RE.match(install) or not norm:
        return 400
    if not rate_ok("i:" + install, RATE_PER_INSTALL):
        return 429
    with db() as con:
        con.execute("INSERT OR IGNORE INTO names (norm, install, name) VALUES (?,?,?)", (norm, install, name))
        owner = con.execute("SELECT install FROM names WHERE norm=?", (norm,)).fetchone()[0]
    return 200 if owner == install else 409


def store(body: dict) -> int:
    """Guarda una partida. Devuelve el código HTTP."""
    install = str(body.get("install", ""))
    name = str(body.get("save_name", "")).strip()[:60]
    data = body.get("data")
    if not INSTALL_RE.match(install) or not name or not isinstance(data, dict):
        return 400
    if not rate_ok("i:" + install, RATE_PER_INSTALL):
        return 429
    if os.path.getsize(DB_PATH) > MAX_DB:
        return 507
    live = 1 if body.get("live") else 0
    zone = str(data.get("zone_name", ""))[:80]
    blob = zlib.compress(json.dumps(data, ensure_ascii=False).encode("utf-8"), 6)
    now = time.time()
    with db() as con:
        con.execute("INSERT OR IGNORE INTO names (norm, install, name) VALUES (?,?,?)", (norm_name(name), install, name))
        known = con.execute("SELECT 1 FROM saves WHERE install=? AND name=?", (install, name)).fetchone()
        if not known and con.execute("SELECT COUNT(*) FROM saves WHERE install=?", (install,)).fetchone()[0] >= MAX_SAVES_PER_INSTALL:
            return 429
        con.execute(
            "INSERT OR REPLACE INTO saves (install, name, player, game_version, zone, updated, data) VALUES (?,?,?,?,?,?,?)",
            (install, name, str(body.get("player", ""))[:40], str(body.get("game_version", ""))[:40], zone, now, blob),
        )
        last = con.execute("SELECT MAX(at) FROM snapshots WHERE install=? AND name=?", (install, name)).fetchone()[0]
        if not live or last is None or now - last >= SNAPSHOT_EVERY:
            con.execute("INSERT INTO snapshots (install, name, at, live, zone, data) VALUES (?,?,?,?,?,?)", (install, name, now, live, zone, blob))
            con.execute(
                "DELETE FROM snapshots WHERE install=? AND name=? AND id NOT IN "
                "(SELECT id FROM snapshots WHERE install=? AND name=? ORDER BY at DESC LIMIT ?)",
                (install, name, install, name, MAX_SNAPSHOTS_PER_SAVE),
            )
    return 200


def unpack(blob: bytes) -> dict:
    return json.loads(zlib.decompress(blob).decode("utf-8"))


# --- Panel ------------------------------------------------------------------------------------------------------------

def e(value) -> str:
    return html.escape(str(value), quote=True)


def ago(ts: float) -> str:
    s = int(time.time() - ts)
    if s < 180:
        return "ahora"
    if s < 3600:
        return "hace %d min" % (s // 60)
    if s < 86400:
        return "hace %d h" % (s // 3600)
    return "hace %d días" % (s // 86400)


def when(ts: float) -> str:
    return time.strftime("%d/%m %H:%M", time.gmtime(ts + UTC_OFFSET))


def play_time(seconds) -> str:
    mins = int(float(seconds or 0) / 60)
    return "%d h %02d min" % (mins // 60, mins % 60) if mins >= 60 else "%d min" % mins


def num(value) -> str:
    """Los números vienen de JSON: 3100.0 se muestra 3100."""
    return str(int(value)) if isinstance(value, float) and value.is_integer() else str(value)


def species(m: dict) -> str:
    name = str(m.get("species_id", "?")).replace("_", " ").capitalize()
    nick = str(m.get("nickname", "") or "")
    return ("★ " if m.get("shiny") else "") + name + (" «%s»" % nick if nick else "")


def team_text(data: dict) -> str:
    return ", ".join("%s Nv. %s" % (e(species(m)), e(num(m.get("level", "?")))) for m in data.get("party", []) if isinstance(m, dict)) or "—"


def medals(data: dict) -> list:
    return sorted(str(f)[8:].capitalize() for f in data.get("story_flags", []) if str(f).startswith("medalla_"))


def dex(data: dict, kind: str) -> int:
    d = data.get("pokedex", {})
    return len(d.get(kind, [])) if isinstance(d, dict) else 0


PAGE = """<!doctype html><html lang="es"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>%s</title>%s<style>
:root{color-scheme:light dark;--bg:#f6f6f4;--fg:#1e1e1c;--mut:#6c6c66;--line:#d9d9d3;--card:#fff}
@media (prefers-color-scheme:dark){:root{--bg:#191917;--fg:#ecece8;--mut:#9c9c94;--line:#34342f;--card:#22221f}}
body{font:15px/1.45 system-ui,sans-serif;background:var(--bg);color:var(--fg);margin:0;padding:20px 16px;}
main{max-width:1200px;margin:auto}h1{font-size:22px;margin:0 0 4px}h2{font-size:16px;margin:24px 0 8px}p{color:var(--mut);margin:0 0 16px}
.scroll{overflow-x:auto;background:var(--card);border:1px solid var(--line);border-radius:8px}
table{border-collapse:collapse;width:100%%}th,td{text-align:left;padding:8px 10px;border-bottom:1px solid var(--line);vertical-align:top}
th{font-weight:600;color:var(--mut);font-size:13px;white-space:nowrap}tr:last-child td{border:0}a{color:inherit}.n{white-space:nowrap}
</style><main>%s</main></html>"""


def page(title: str, body: str, refresh: bool = False) -> str:
    return PAGE % (e(title), '<meta http-equiv="refresh" content="60">' if refresh else "", body)


def panel() -> str:
    with db() as con:
        rows = con.execute("SELECT * FROM saves ORDER BY updated DESC").fetchall()
    lines = []
    for r in rows:
        d = unpack(r["data"])
        link = "detalle?k=%s&i=%s&n=%s" % (quote(TOKEN), r["install"], quote(r["name"]))
        lines.append(
            "<tr><td><a href='%s'><b>%s</b></a></td><td>%s</td><td class=n>%s</td><td>%s</td><td class=n>%s</td><td>%d</td><td class=n>$%s</td><td>%s</td><td>%d</td><td>%d</td></tr>"
            % (e(link), e(r["name"]), e(r["player"] or r["install"][:6]), e(ago(r["updated"])), e(r["zone"] or "—"), e(play_time(d.get("play_time"))),
               len(medals(d)), e(num(d.get("money", 0))), team_text(d), len(d.get("box", [])), dex(d, "caught"))
        )
    table = "<tr><td colspan=10>Todavía no llegó ninguna partida.</td></tr>" if not lines else "".join(lines)
    return page("Partidas", "<h1>Partidas</h1><p>Personajes: %d. Jugadores: %d. Se actualiza solo cada minuto.</p><div class=scroll><table><tr><th>Personaje<th>Nombre online<th>Última vez<th>Por dónde anda<th>Tiempo<th>Medallas<th>Dinero<th>Equipo<th>Caja<th>Atrapados</tr>%s</table></div>"
                % (len(rows), len({r["install"] for r in rows}), table), True)


def mon_rows(mons: list) -> str:
    out = []
    for m in mons:
        if isinstance(m, dict):
            moves = ", ".join(e(x) for x in m.get("equipped_moves", []) if x)
            out.append("<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>" % (e(species(m)), e(num(m.get("level", "?"))), e(m.get("ability", "") or "—"), moves or "—"))
    return "".join(out) or "<tr><td colspan=4>—</td></tr>"


def detail(install: str, name: str):
    with db() as con:
        r = con.execute("SELECT * FROM saves WHERE install=? AND name=?", (install, name)).fetchone()
        if r is None:
            return None
        snaps = con.execute("SELECT at, live, zone, data FROM snapshots WHERE install=? AND name=? ORDER BY at DESC LIMIT 100", (install, name)).fetchall()
    d = unpack(r["data"])
    head = "<tr><th>Pokémon<th>Nv.<th>Habilidad<th>Ataques</tr>"
    bag = d.get("bag", {})
    bag_rows = "".join("<tr><td>%s</td><td>%s</td></tr>" % (e(k), e(v)) for k, v in sorted(bag.items())) if isinstance(bag, dict) else ""
    hist = []
    for s in snaps:
        x = unpack(s["data"])
        party = [m for m in x.get("party", []) if isinstance(m, dict)]
        top = max((int(m.get("level", 0) or 0) for m in party), default=0)
        hist.append("<tr><td class=n>%s</td><td>%s</td><td class=n>%s</td><td>%d</td><td>%d</td><td class=n>$%s</td><td>%d</td><td>%s</td></tr>"
                    % (e(when(s["at"])), e(s["zone"] or "—"), e(play_time(x.get("play_time"))), top, len(medals(x)), e(num(x.get("money", 0))), len(x.get("box", [])), "jugando" if s["live"] else "guardó"))
    back = "panel?k=%s" % quote(TOKEN)
    body = ("<p><a href='%s'>← Todas las partidas</a></p><h1>%s</h1><p>%s · %s · %s · %s · $%s · versión %s</p>" % (
        e(back), e(r["name"]), e(r["player"] or r["install"][:6]), e(ago(r["updated"])), e(r["zone"] or "—"), e(play_time(d.get("play_time"))), e(num(d.get("money", 0))), e(r["game_version"] or "?"))
        + "<p>Medallas: %s. Pokédex: %d vistos, %d atrapados.</p>" % (e(", ".join(medals(d)) or "ninguna"), dex(d, "seen"), dex(d, "caught"))
        + "<h2>Equipo</h2><div class=scroll><table>%s%s</table></div>" % (head, mon_rows(d.get("party", [])))
        + "<h2>Caja (%d)</h2><div class=scroll><table>%s%s</table></div>" % (len(d.get("box", [])), head, mon_rows(d.get("box", [])))
        + "<h2>Mochila</h2><div class=scroll><table><tr><th>Objeto<th>Cantidad</tr>%s</table></div>" % (bag_rows or "<tr><td colspan=2>—</td></tr>")
        + "<h2>Historial (últimas %d fotos)</h2><div class=scroll><table><tr><th>Cuándo<th>Dónde<th>Tiempo<th>Nivel más alto<th>Medallas<th>Dinero<th>Caja<th></tr>%s</table></div>" % (len(hist), "".join(hist)))
    return page(r["name"], body)


class Handler(BaseHTTPRequestHandler):
    server_version = "partidas"
    timeout = 30

    def log_message(self, *_args) -> None:
        pass  # sin registro de direcciones

    def _send(self, code: int, text: str = "", kind: str = "text/plain; charset=utf-8") -> None:
        raw = text.encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", kind)
        self.send_header("Content-Length", str(len(raw)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("Referrer-Policy", "no-referrer")
        self.end_headers()
        self.wfile.write(raw)

    def do_POST(self) -> None:
        route = urlparse(self.path).path
        if route not in ("/subir", "/nombre"):
            return self._send(404)
        try:
            size = int(self.headers.get("Content-Length", "0"))
        except ValueError:
            return self._send(400)
        if size <= 0 or size > MAX_BODY:
            return self._send(413)
        if not rate_ok("a:" + self.headers.get("X-Real-IP", self.client_address[0]), RATE_PER_ADDRESS):
            return self._send(429)
        try:
            body = json.loads(self.rfile.read(size).decode("utf-8"))
        except (ValueError, UnicodeDecodeError):
            return self._send(400)
        if not isinstance(body, dict):
            return self._send(400)
        self._send(store(body) if route == "/subir" else reserve_name(body))

    def do_GET(self) -> None:
        url = urlparse(self.path)
        q = parse_qs(url.query)
        if not hmac.compare_digest(q.get("k", [""])[0].encode(), TOKEN.encode()):
            return self._send(404)
        if url.path == "/panel":
            return self._send(200, panel(), "text/html; charset=utf-8")
        if url.path == "/detalle":
            out = detail(q.get("i", [""])[0], q.get("n", [""])[0])
            return self._send(200, out, "text/html; charset=utf-8") if out else self._send(404)
        self._send(404)


def main() -> None:
    global DB_PATH, TOKEN
    ap = argparse.ArgumentParser()
    ap.add_argument("--port", type=int, default=24681)
    ap.add_argument("--db", default="/opt/pokemon-pilot/partidas/partidas.db")
    args = ap.parse_args()
    DB_PATH = args.db
    os.makedirs(os.path.dirname(os.path.abspath(DB_PATH)), exist_ok=True)
    init_db()
    TOKEN = load_token(os.path.dirname(os.path.abspath(DB_PATH)))
    ThreadingHTTPServer(("127.0.0.1", args.port), Handler).serve_forever()


if __name__ == "__main__":
    main()
