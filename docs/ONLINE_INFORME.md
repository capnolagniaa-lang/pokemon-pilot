# Informe del multijugador online (2026-11-08)

Revisión a fondo del online (`docs/PLAN_ONLINE.md`, fases O-0 a O-5 hechas): cómo funciona hoy, qué se encontró, qué se
arregló, qué queda y qué cubre la suite nueva `--autotest-online-sync`.

## 1. Cómo funciona hoy (mapa de una pelea)

```
 Jugador A                          Servidor (NetPeer, --server)                       Jugador B
 Net.go_online()  ──hello(versión, PROTOCOL, nombre, equipo)──►  _pending → _by_id      ◄── hello ──
                  ◄── welcome(id, nombre) / rejected(motivo) ──   (versión ≠ → echa)
                  ◄── player_list ───────── a todos cuando cambia algo ─────────────► player_list
 Sala (OnlineLobbyScreen)
   challenge(to, 1|3|6) ──►  _challenges[from]  ──► got_challenge(from, nombre, n) ──►  pregunta
                  ◄── got_answer ◄──────────── answer(from, sí/no) ◄────────────────────  Aceptar
   got_choose(mid, rival, n, 30 s) ◄── matches[mid] {a, b, count, teams} ──► got_choose
   choose_team(mid, [to_dict + hp_ratio]) ──► clean_battle_team ◄── choose_team
   got_ready(mid, rival, su equipo) ◄── los dos eligieron: status "peleando" ──► got_ready
 Pelea (NetMatch en el servidor; OnlineBattle en cada jugador)
   battle_event "start" {a, b, arena, countdown 3 s}  (reliable)
   battle_event "send" {side, index, p, hp}            → OnlineBattle._switch_own / _spawn_foe
   battle_input(mid, [mover, apuntar, punto, bits, esquives, toques]) ──► NetCombatInput  (unreliable_ordered, 60/s)
   battle_state {t, id: {p, f, hp, st, hs, bw, i, in}}  (unreliable_ordered, 30/s) → posiciones, vida, estados, teclas del rival
   battle_event "use" {side, m, aim, pt}  → el rival en tu pantalla: Creature.force_move (sin mirar recargas ni PP)
   battle_event "hit" {side, amount, hp, p, hs, kb}  → vida, stagger, empujón (salvo si tu pantalla ya lo adivinó)
   battle_event "faint" {side}  → apply_damage(todo) → CombatDirector reparte la EXP como en el mundo
   battle_switch(mid, index) ──► request_switch (1,5 s entre cambios) ──► "send"
   battle_event "end" {winner, reason, hp: {id: [proporciones]}}  → cartel, vida final, vuelta al Centro
 Desconexión: ENet 8 s sin respuesta → el servidor da la pelea al otro ("end" con motivo); el cliente queda "offline".
```

- **El servidor manda** (modelo de autoridad): simula la pelea entera con el combate del juego (`Creature`, ataques,
  daño, estados) en una copia de `arena_campo` por pelea, cada una a 4000 px de las demás. Los clientes **imitan**: tu
  Pokémon se mueve con tus teclas al instante (predicción de movimiento) y el rival con las teclas que vienen en la foto,
  pero acá los golpes no sacan vida (tu Pokémon no tiene hurtbox; la del rival solo sirve para que tu golpe se vea al
  instante: `_predict_hits`). La verdad llega en `hit`/`faint`/`end` y en las fotos (`_correct` acerca al rival rápido y al
  tuyo solo si se fue más de 28 px).
- **EXP**: el Pokémon del rival está en `CombatDirector.enemies`; cuando el servidor dice `faint`, tu pantalla lo debilita y
  `exp_shares` reparte como contra un entrenador. La vida con la que terminás la dice el `end` (proporción × tu vida máxima:
  cada partida puede tener otra escala).
- **Versión**: `Net.game_version()` = `PROTOCOL` + huella de ataques y especies. Otro zip no entra.

## 2. Bugs encontrados

### Arreglados en esta pasada
| # | Dónde | Qué pasaba | Arreglo |
|---|---|---|---|
| 1 | `OnlineBattle.run` | **Si se cortaba la conexión en plena pelea, el jugador quedaba trabado para siempre en la arena**: esperaba un `end` que nunca llegaba (el servidor se lo manda al otro, no al que se fue), con el entrenador `locked`. | `_on_net_state`: al pasar a offline cierra la pelea ("Se cortó la conexión con el servidor.", cuenta como perdida) y vuelve al Centro. Test: "se cae el servidor en plena pelea". |
| 2 | `NetCombatInput` / `battle_input` | **Un toque de un solo cuadro se perdía** si el paquete que llevaba el bit se perdía (van sin garantía). Tu pantalla mostraba el ataque y el servidor no lo hacía (desincronización real, no solo visual). | Contadores de toques por ranura en el paquete (como ya tenía el esquive): el servidor toma el toque aunque solo llegue el contador. `PROTOCOL` 7. Test con 35 % de pérdida: 12 de 12. |
| 3 | `CombatWeather` | **El clima era global en el servidor**: la Danza Lluvia de una pelea subía el daño de Agua en todas las peleas a la vez (y el granizo lastimaba a todos). | Un clima por ámbito (`scope_of`: la `NetMatch` que lo contiene, o 0 = el juego del jugador). `Damage`, `hurts`, las habilidades (Clorofila, Cura Lluvia) y la IA leen el de su criatura. Al terminar la pelea se borra. |
| 4 | `NetPeer._start_battle` | Las arenas del servidor iban en `id % 16` lugares: **la pelea 1 y la 17 se encimaban** si la primera seguía (5 min de tope): los Pokémon de una podían pegarle a los de la otra. | Primer lugar libre entre las peleas vivas (`_free_arena_slot`). |
| 5 | `NetCombatInput.set_packet` | Un paquete con basura (NaN, infinitos, vectores enormes, textos) entraba tal cual: un cliente roto podía mandar el Pokémon al infinito o romper la física del servidor. | Se valida cada campo (tipo, finito, largo máximo); lo inválido se ignora y queda lo de antes. |
| 6 | `NetPeer.host` | `SceneMultiplayer.server_relay` venía prendido: un cliente podía mandar RPC a otros clientes a través del servidor (no hacían nada, por `authority`, pero gastan ancho de banda y son un vector de abuso). | `server_relay = false`. |
| 7 | `clean_battle_team` | Se aceptaba una **habilidad ajena** a la especie (por ejemplo Levitación en un Pikachu) y apodos largos o con caracteres raros. Nivel, IV, vida y ataques ya se limpiaban (`from_dict` solo deja ataques que la especie aprende). | Habilidad de su especie o la primera; apodo limpio y de hasta 12 letras. |
| 8 | `OnlineBattle._sync_statuses` | **Parpadeo de estados**: una mejora propia (Danza Espada) o un estado que le pegaste al rival se ponía al instante en tu pantalla y la foto siguiente del servidor (de hace una ida y vuelta) todavía no lo tenía, así que se curaba y a los 100 ms se volvía a poner: texto y partículas dos veces. | Gracia de 0,6 s: un estado al que le queda casi toda su duración no se borra por una foto. |
| 9 | `OnlineBattle` "hit" | Un golpe fuerte del servidor cortaba la carga, el canalizado o la ola de Surf **en el servidor pero no en la copia**: en tu pantalla el rival seguía cargando y soltaba un ataque que no existió. | Con `kb` ≥ `STAGGER_KNOCKBACK` y la copia en `cast`/`channel`/`ride`, `stun(0.25)` como hace `Creature._on_hit`. |
| 10 | `NetMatch._send` | El que **vuelve a salir** aparecía en tu pantalla con la vida de cuando eligió el equipo hasta la primera foto (33 ms, un salto en la barra). | El aviso `send` trae la vida de ahora. |
| 11 | `Creature.force_move` | La copia del rival ponía su barra de PP en "al menos el costo", pero la barra tiene tope (100 + 4·nivel): **un Pokémon de nivel bajo con un ataque caro (Lanzallamas a Nv. 3) no se veía atacar nunca** en la pantalla del otro (`consume` fallaba por PP). Encontrado por la suite. | `MoveUser.force_next`: el ataque forzado sale sin mirar recarga, pausa ni PP de la copia (sus PP no se muestran a nadie). |

### Pendientes (no se tocaron: son decisiones de diseño o trabajo más grande)
| Prioridad | Qué | Detalle |
|---|---|---|
| Alta | **Tus propios ataques pueden diferir del servidor** | Tu copia dispara con tus teclas y el servidor con las que le llegan. Si la recarga o los PP difieren (otra escala de vida, un `hit` que te frenó antes en el servidor), uno ataca y el otro no. El aviso `use` de tu lado hoy se ignora. Propuesta: usarlo para **reconciliar** (si el servidor usó y tu copia no, hacerlo con `force_move`; si tu copia usó y el servidor no avisó en ~250 ms, cancelar el efecto visual). |
| Media | **Transformación, Metrónomo, Espejo, Ayuda** | El servidor cambia los ataques (`fight_moves_changed`) o tira uno al azar; la copia del rival no sabe cuál: `force_move` de un ataque que no está en sus ranuras devuelve `false` y no se ve nada. Propuesta: que el `use` lleve también el ataque real tirado (`cast_other`) y que la copia lo haga con `cast_other`. |
| Media | **Sustituto, cambios de tipo/stats de la pelea** | `sub_hp`, `fight_types`, `fight_stats` no viajan: la barra y "No le afecta" pueden no coincidir. Propuesta: sumar `sub` y `types` a la foto. |
| Media | **Choque de proyectiles** (recién agregado) | Pasa en el servidor y también en cada pantalla (los dos proyectiles existen en las dos). El resultado del servidor es el que vale para el daño; el de tu pantalla es visual y puede diferir (otro momento, otro ángulo). Nada roto hoy, pero si se agrega un efecto fuerte (anillo, sacudida) conviene que viaje como hecho (`clash`) y que las copias no choquen solas. |
| Media | **Orden entre canales** | Las fotos van sin garantía y los hechos con garantía: un `send` puede llegar después de una foto que ya trae el índice nuevo (se le aplica una vida al Pokémon viejo por un cuadro). Propuesta: que la foto lleve un número de secuencia y que `_on_state` ignore fotos de un índice que todavía no salió. |
| Media | **Rendimiento del servidor** | Cada pelea instancia la arena entera (tiles y colisión). Medido en el test: ver la línea `[online-sync] N peleas a la vez` (en esta PC, 6 peleas con bots quedan muy por debajo del presupuesto de 16 ms). El VPS tiene 1 vCPU: para más de ~10 peleas a la vez habría que compartir una sola arena con offsets o bajar las fotos a 20/s. |
| Baja | **Lista de la sala** | `_broadcast_players` manda toda la lista a todos ante cualquier cambio (incluye el equipo de cada uno): con 32 jugadores y `refresh_team` por cada cambio de equipo es ruido. Propuesta: mandar diffs o limitar a 1 por segundo. |
| Baja | **Seguridad entre amigos** | No hay límite de mensajes por segundo (un cliente puede inundar `challenge`/`update_team`), `set_status` deja fingir "peleando", y `choose_team` acepta diccionarios grandes. Suficiente para amigos; si el servidor queda público, poner tope por peer. |
| Baja | **`Events.party_changed` durante la pelea** | La EXP de cada debilitado dispara `refresh_team` (un `update_team` + `player_list` a todos) en plena pelea. Inofensivo; se podría postergar al final. |

### Reconexión con gracia (hecha el 2026-11-08, decisión del usuario)
Antes: 8 s sin paquetes (un microcorte de wifi) = pelea perdida al instante. Ahora:
- **Token de sesión**: el `welcome` trae un token al azar (`NetPeer.session_token`); el cliente lo vuelve a presentar en el
  `hello` al reconectar. `PROTOCOL` 8.
- **Servidor** (`NetPeer._absent`, `RECONNECT_GRACE` 15 s): si uno se desconecta en plena pelea, en vez de darle la pelea
  al otro la **congela** (`NetMatch.hold`: `process_mode` apagado, no corre ni el tiempo ni los Pokémon) y manda `hold`
  al que quedó. Si el que se fue vuelve con su token, su lugar pasa al id de red nuevo (`NetMatch.rebind`, con alias para
  lo que quedó atado al viejo: timers, señales de las criaturas), los dos reciben `resume` (id nuevo, id viejo y cómo
  está cada lado: quién está afuera, dónde y con cuánta vida) y sigue. Si no vuelve en 15 s, gana el otro con el motivo
  de siempre ("se desconectó"). Si se caen los dos, termina al toque. Si vuelve antes de que el servidor note el corte
  (la conexión vieja sigue abierta), se corta la vieja y se retoma igual. Un token vencido entra como jugador nuevo.
- **Cliente** (`OnlineBattle`): al perder la conexión (`NetPeer.lost`) congela tu pantalla (`_set_held`: tu Pokémon, el
  del rival y los disparos en el aire con `process_mode` apagado), muestra "reconectando..." y `Net.reconnect(20 s)`
  reintenta cada 1,5 s; con `welcome.resumed` espera el `resume`, que acomoda cada lado y descongela. Si no se pudo
  volver, o el servidor ya no tenía la pelea, se da por perdida y se cierra la arena como antes. El que se queda ve
  "se lo espera hasta 15 s" y la pelea congelada; con el `resume` el id del rival pasa a ser el nuevo.
- Tests: parte `reconexion` de la suite y dos escenarios en `mundo` (se te corta a vos; se cae el rival y no vuelve).

## 3. Propuestas de mejora (por impacto)
1. **Reconciliar tus ataques con el `use` del servidor** (ver pendientes). Es el desvío más visible que queda.
2. **Secuencia en las fotos** y descartar las viejas; con eso también se puede interpolar entre dos fotos en vez de
   acercarse con `lerp` (movimiento del rival más suave con 100 ms de ping).
3. **`use` con el ataque real** (Metrónomo, Transformación, Espejo) y `sub`/tipos en la foto.
4. **Tope de mensajes por peer** y lista de la sala con diffs (si el servidor se abre a más gente).
5. **Nivel 50 opcional y lo de la O-6** (chat rápido, verse en la sala) quedan como estaban en el plan.

## 4. Qué cubre la suite nueva (`--autotest-online-sync`)
- **Paquetes**: toque de un cuadro que llega solo con el contador; mismo contador no vale dos veces; contadores que suben
  al apretar y no al mantener, con vuelta a los 256; basura (NaN, infinitos, textos, vectores enormes, paquete corto).
- **Equipo trucho**: nivel 999, habilidad ajena, ataques que no aprende, IV fuera de rango, vida > 100 %, apodo largo;
  y que un equipo sano pase entero.
- **Cada forma de ataque en el servidor, con su aviso `use`, el golpe en el rival y la copia del rival con `force_move`**:
  disparo (Impactrueno), cuerpo a cuerpo (Agarre), Surf montado en la ola (con `pt`), Rayo del cielo, canalizado
  (Lanzallamas), clima (Danza Lluvia, por pelea), mejora propia (Danza Espada, en la foto), Excavar en dos tiempos. La copia
  no ataca sola con sus teclas, y un golpe fuerte le corta la carga. Reglas del cambio de Pokémon.
- **Red con 120 ms de demora y 35 % de pérdida** (`NetPeer.sim_latency_ms` / `sim_loss`, solo tests): 12 toques de un
  cuadro llegan; las fotos llegan en orden; los hechos también.
- **6 peleas a la vez**: lugares distintos, clima por pelea (la lluvia de una no moja a la otra ni al juego del jugador),
  todas terminan con su `end`, tiempo de física por cuadro del servidor (umbral 12 ms), y una pelea nueva toma el primer
  lugar libre.
- **Con el mundo**: `send` con la vida de ahora, gracia de los estados, golpe fuerte que corta el canalizado de la copia,
  y **se cae el servidor en plena pelea → la pelea se cierra sola y se puede caminar** (el bug 1).
- Siguen los de antes: `--autotest-online` (sala, protocolo, pelea en el servidor, desconexión, Excavar),
  `--autotest-online-building` (el Centro, la sala en pantalla, una pelea entera con EXP y vuelta, la ruleta),
  `--autotest-burrow` (Excavar online) y `--autotest-save-sync` (partidas en el servidor).

## 5. Para publicar
`PROTOCOL` pasó a 8 (7: paquete de teclas con contadores, `send` con vida; 8: token de sesión en `hello`/`welcome`, avisos
`hold` y `resume`): hay que sacar zip nuevo y subirlo al servidor
(`build_portable.py` + `subir_servidor.bat`), si no los clientes viejos no entran ("otra versión"). No se desplegó nada.
