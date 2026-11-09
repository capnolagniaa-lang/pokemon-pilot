class_name AiFightStats
extends RefCounted
## Métricas de una pelea de arena contra la IA (Fase 1 de docs/IA_AUDITORIA.md). Lógica pura: `AiDebug` le pasa lo que
## pasa (golpes, esquives, decisiones, cada cuadro si alguno está expuesto) y esto lo cuenta. "ia" = el Pokémon del
## entrenador; "vos" = el tuyo. Sale en el registro, el overlay y el JSON de sparring (`metrics`).
##
## **Castigos**: una *ventana* es un rato en que un lado quedó expuesto por algo que hizo él (cargando, canalizando,
## recuperándose de un ataque) o aturdido. El stagger de un golpe no cuenta (si no, cada combo serían castigos).
## Castigo hecho = el otro le pegó durante la ventana o hasta `PUNISH_GRACE` después. Perdido = la ventana duró por lo
## menos `PUNISH_MIN` y en algún momento el otro tenía con qué pegarle desde ahí (un ataque listo que llegaba), y no le pegó.

const PUNISH_MIN := 0.3
const PUNISH_GRACE := 0.15

## Daño en vidas enteras (1,0 = una vida del que lo recibe), golpes y ataques usados.
var damage := {"ia": 0.0, "vos": 0.0}
var hits := {"ia": 0, "vos": 0}
var uses := {"ia": 0, "vos": 0}
## Esquives (rodar) y pasos al costado de la IA; "útil" = había una amenaza que esquivar.
var ia_dodges := 0
var ia_dodges_useful := 0
var ia_reads := 0
var ia_steps := 0
var ia_feints := 0
var ia_saves := 0
var your_dodges := 0
## Castigos por lado: el que castiga ("ia" castigó tus ventanas).
var punished := {"ia": 0, "vos": 0}
var missed := {"ia": 0, "vos": 0}
## Cambios del entrenador: buenos = el que entra tiene mejor cruce contra el tuyo que el que sale.
var switches := 0
var switches_good := 0
var your_switches := 0
var retreats := 0
var potions := 0
## Ataques de la IA en orden (para medir cuánto repite) y cuánto tiempo pasó en cada modo.
var ia_moves: Array[String] = []
var mode_time := {}
var duration := 0.0

# Ventanas abiertas por lado expuesto: {"open": bool, "len": float, "hit": bool, "could": bool, "grace": float}
var _win := {"ia": {}, "vos": {}}
var _mode := ""


## Un cuadro de pelea. `ia_open`/`you_open` = ese lado está expuesto; `ia_can_hit`/`you_can_hit` = ese lado tiene un
## ataque listo que llega al otro desde donde está. `mode` = el modo de movimiento de la IA.
func tick(dt: float, ia_open: bool, you_open: bool, ia_can_hit: bool, you_can_hit: bool, mode: String = "") -> void:
	duration += dt
	_track("vos", you_open, ia_can_hit, dt)  # (tu ventana la castiga la IA)
	_track("ia", ia_open, you_can_hit, dt)
	if mode != "":
		mode_time[mode] = float(mode_time.get(mode, 0.0)) + dt


## `exposed` = el lado expuesto ("ia" o "vos"); el que castiga es el otro.
func _track(exposed: String, is_open: bool, other_can_hit: bool, dt: float) -> void:
	var w: Dictionary = _win[exposed]
	if is_open:
		if not w.get("open", false):
			w.clear()
			w.merge({"open": true, "len": 0.0, "hit": false, "could": false, "grace": 0.0})
		w["len"] += dt
		w["could"] = w["could"] or other_can_hit
		return
	if not w.get("open", false):
		return
	w["grace"] += dt
	if w["grace"] >= PUNISH_GRACE:
		_close(exposed)


func _close(exposed: String) -> void:
	var w: Dictionary = _win[exposed]
	if not w.get("open", false):
		return
	var punisher := "ia" if exposed == "vos" else "vos"
	if w["hit"]:
		punished[punisher] += 1
	elif w["len"] >= PUNISH_MIN and w["could"]:
		missed[punisher] += 1
	w.clear()


## `victim` recibió un golpe de `amount` vidas (0..1).
func on_hit(victim: String, amount: float) -> void:
	var attacker := "ia" if victim == "vos" else "vos"
	damage[attacker] += amount
	hits[attacker] += 1
	var w: Dictionary = _win[victim]
	if w.get("open", false):
		w["hit"] = true


func on_use(who: String, move_name: String) -> void:
	uses[who] += 1
	if who == "ia":
		ia_moves.append(move_name)


func on_your_dodge() -> void:
	your_dodges += 1


## Una decisión de la IA (Events.ai_decided).
func on_decision(what: String, data: Dictionary) -> void:
	match what:
		"esquive":
			ia_dodges += 1
			if str(data.get("amenaza", "")) != "":
				ia_dodges_useful += 1
		"lectura":
			ia_dodges += 1
			ia_reads += 1
		"paso":
			ia_steps += 1
		"finta":
			ia_feints += 1
		"juntar":
			ia_saves += 1
		"cambio":
			switches += 1
			if float(data.get("nuevo", 0.0)) > float(data.get("cruce", 0.0)):
				switches_good += 1
		"retira":
			retreats += 1
		"pocion":
			potions += 1


func on_your_switch() -> void:
	your_switches += 1


## Cuánto repite sus ataques: la parte del más usado, la racha más larga del mismo, la parte del par seguido más
## repetido y la variedad (entropía normalizada: 0 = siempre el mismo, 1 = todos por igual).
func repetition() -> Dictionary:
	var n := ia_moves.size()
	var out := {"ataques": n, "mas_usado": 0.0, "racha": 0, "par_repetido": 0.0, "variedad": 0.0}
	if n == 0:
		return out
	var counts := {}
	var run := 0
	var best_run := 0
	for i in n:
		counts[ia_moves[i]] = int(counts.get(ia_moves[i], 0)) + 1
		run = run + 1 if i > 0 and ia_moves[i] == ia_moves[i - 1] else 1
		best_run = maxi(best_run, run)
	var top := 0
	var entropy := 0.0
	for k in counts:
		top = maxi(top, counts[k])
		var p := float(counts[k]) / n
		entropy -= p * log(p)
	out["mas_usado"] = snappedf(float(top) / n, 0.01)
	out["racha"] = best_run
	out["variedad"] = snappedf(entropy / log(float(counts.size())), 0.01) if counts.size() > 1 else 0.0
	if n >= 3:
		var pairs := {}
		for i in range(1, n):
			var key: String = ia_moves[i - 1] + ">" + ia_moves[i]
			pairs[key] = int(pairs.get(key, 0)) + 1
		var top_pair := 0
		for k in pairs:
			top_pair = maxi(top_pair, pairs[k])
		out["par_repetido"] = snappedf(float(top_pair) / (n - 1), 0.01)
	return out


## Todo junto (para el JSON y el registro). Cierra las ventanas que quedaron abiertas.
func to_dict() -> Dictionary:
	_close("ia")
	_close("vos")
	var modes := {}
	for k in mode_time:
		modes[k] = snappedf(mode_time[k] / maxf(duration, 0.001), 0.01)
	return {
		"duracion": snappedf(duration, 0.1),
		"dano_hecho_ia": snappedf(damage["ia"], 0.01), "dano_hecho_vos": snappedf(damage["vos"], 0.01),
		"golpes_ia": hits["ia"], "golpes_vos": hits["vos"], "ataques_ia": uses["ia"], "ataques_vos": uses["vos"],
		"esquives_ia": ia_dodges, "esquives_ia_utiles": ia_dodges_useful, "lecturas_ia": ia_reads, "pasos_ia": ia_steps,
		"fintas_ia": ia_feints, "juntar_pp_ia": ia_saves, "esquives_vos": your_dodges,
		"castigos_ia": punished["ia"], "castigos_perdidos_ia": missed["ia"],
		"castigos_vos": punished["vos"], "castigos_perdidos_vos": missed["vos"],
		"cambios_ia": switches, "cambios_ia_buenos": switches_good, "cambios_vos": your_switches,
		"retiros_ia": retreats, "pociones_ia": potions,
		"repeticion_ia": repetition(), "modos_ia": modes,
	}


## Resumen en pocas líneas (registro y overlay).
func summary() -> String:
	var rep := repetition()
	return "daño %.2f/%.2f · castigos %d (perdió %d) · esquives %d (%d útiles) · pasos %d · cambios %d (%d buenos) · más usado %d%%" % [
		damage["ia"], damage["vos"], punished["ia"], missed["ia"], ia_dodges, ia_dodges_useful, ia_steps,
		switches, switches_good, roundi(float(rep["mas_usado"]) * 100.0)]
