# Auditoría de la IA de entrenadores (Fase 0)

Pedido del usuario (2026-11-09): IA de entrenadores **difícil pero justa**: buenas decisiones, que se adapte a vos, que no
sea predecible y que no lea tus teclas. Este documento es la **Fase 0**: qué hay, qué falla (con archivo:línea), qué datos
tienen los ataques y un plan por fases. **No se tocó código.**

Resumen en una frase: **la mitad del pedido ya existe** (IA-1 a IA-7, H-1, S-0, S-1), pero está armada como reglas
sueltas con azar uniforme encima, decide con `argmax` + ruido, no tiene retraso de percepción, y **en Difícil es más
predecible que en Normal**. Recomiendo **construir encima** (reusar el cuerpo, la amenaza, el cálculo de daño y la
memoria) y reemplazar solo **la parte que decide** por un cerebro de utilidad nuevo, intercambiable con el actual.

---

## 1. Arquitectura actual

### Escenas y nodos
- `scenes/creatures/creature.tscn`: `Creature` (CharacterBody2D) con `StateMachine` y un nodo por estado
  (`scripts/creatures/states/`): `attack`, `cast`, `channel`, `step`, `lunge`, `dash`, `ride`, `recovery`, `stunned`,
  `chase`, `flee`, `watch`, `hunt`... + `Health`, `StatusEffects`, `MoveUser`, `Hurtbox`, `Hitbox`, `Telegraph`.
- `Creature.body` → `CombatBody` (`scripts/creatures/ai/combat_body.gd`) y `Creature.mind` → `TacticalMind`
  (`scripts/creatures/ai/tactical_mind.gd`), los dos `RefCounted` creados al vuelo (`creature.gd:123-132`).
- `TrainerBattle` (`scripts/world/trainer_battle.gd`, `world.arena`): la pelea de arena 1 contra 1 con cambios. El
  Pokémon rival es un `Creature` con `team = WILD`, `temperament = "entrenador"` y `trainer_style` (`trainer_battle.gd:266-276`).
- `SparringRecorder` (`world.sparring`): graba las peleas de arena a JSON (S-1).

### Recursos de datos
| Recurso | Dónde | Qué regula |
|---|---|---|
| `AiDifficulty` | `data/config/difficulty/{facil,normal,dificil}.tres` + "personalizado" (`GameState.custom_difficulty`) | ritmo, puntería, esquive, reacción, aviso, fintas, `smarts`, **`damage_mult`** |
| `TrainerStyle` | `data/ai/trainer_styles/*.tres` (impaciente, aguante, estratega, rocket, líder, élite), por título | `smarts_mult`, `pace`, `counter`, `switch_types`, `max_switches`, `patience`, `reads`, `knows_moves`, `retreat`, `smart_next`, `potions`, `low_hp` |
| `LeaderScript` + `LeaderMoment` | `data/ai/leader_scripts/*.tres` (9 líderes + Campeón) | momentos de guion (HP_BELOW, LAST_MON, FIRST_FAINT) |
| `Temperament` | `data/ai/temperaments/` | salvajes; "entrenador" para los de arena |

### Cómo percibe, decide y ejecuta
- **Percibe** (sin retraso): todo en el mismo cuadro. `TacticalMind.threat()` recorre los nodos hermanos (proyectiles,
  `SkyStrike`, `ChannelCone`, `GroundZone`) y el estado del rival (`cast` con su `Telegraph`, `step`/`lunge`)
  (`tactical_mind.gd:173-310`). `FoeMemory` escucha `dodged` y `move_released` del rival (`tactical_mind.gd:320-362`).
- **Decide** el Pokémon, en el estado `attack` (`creature_attack.gd:72-215`):
  1. aviso pendiente / finta (`:108-123`) → 2. `body.try_dodge()` (`:124`) → 3. paso al costado (`:126-130`) →
     4. salir de celda peligrosa (`:131-134`) → 5. espantado (`:135-138`) → 6. cada 0,4-0,9 s elige **modo**
     (`approach`/`retreat`/`strafe`/`hold`) con reglas en orden fijo (`:140-157`) → 7. cada 0,5-1,1 s **ataque** con
     `TacticalMind.pick` (`:159-172`, `:276-293`).
- **Decide** el entrenador: `TrainerBattle.think()` cada 0,4 s fijos (`trainer_battle.gd:362-365`): guion → retirar →
  cambio por tipos → Superpoción (`:375-383`).
- **Ejecuta**: `CombatBody.use(slot)` apunta con anticipación y error (`combat_body.gd:94-108`) y llama a
  `Creature.use_slot` — **el mismo camino que usa el jugador**, así que daño, tipos, recargas y hitboxes ya son los reales.

---

## 2. Punto por punto del pedido

Leyenda: ✅ hecho · 🟡 a medias · ❌ falta · ⚠️ choca con algo ya decidido.

### Fase 1 — Instrumentación
| Pedido | Estado | Dónde / qué falta |
|---|---|---|
| Logger de decisiones on/off | 🟡 | Solo `CombatBody.debug_threats` (`combat_body.gd:28`, `:146-148`), un `print` estático para tests. No registra modos, puntajes ni cambios. |
| Overlay de debug (situación, acción, top 3, predicción) | ❌ | No existe. La consola GM (`GmConsole`) es el lugar natural para prenderlo. |
| Métricas por pelea | 🟡 | `SparringRecorder` ya graba muestras a 10/s, `use/slot/hit/dodge/faint/send/wary` y marcas F8. **Falta el informe** (S-2, `tools/sparring_report.py`, pendiente) y las métricas de castigos hechos/perdidos y de si un cambio fue bueno. |

### Fase 2 — Percepción y situación
| Pedido | Estado | Dónde / qué falta |
|---|---|---|
| Retraso de percepción 0,15-0,4 s | 🟡 | Solo hay **reacción** antes de actuar (`AiDifficulty.reaction`, `combat_body.gd:132`): Difícil 0,14 (debajo del rango pedido), Normal 0,22, Fácil 0,35. Pero lo que ve es **del cuadro actual**: la amenaza, tu posición, tu velocidad para anticipar (`combat_body.gd:102`), tu estado. |
| Clasificador táctico | 🟡 | Hay piezas sueltas, no un clasificador: `exposed()` (`tactical_mind.gd:498`), `window_open()` (`:423`), `threat()` (`:173`), `low_hp_plan()` (`:449`), `wary()` (`:143`), `_finisher` (`:595`). Falta "neutral por distancia" y un único lugar que diga *en qué situación estoy*. |
| Clasificador estratégico | 🟡 | `matchup()` (`:484`, por efectividad) y `matchup_score()` (`:791`, daño real con stats, IA-7) + el equipo en `TrainerBattle`. Falta juntarlo (recargas, equipo restante, si conviene cambiar) en una sola lectura. |

### Fase 3 — Utility AI en dos niveles
| Pedido | Estado | Dónde / qué falta |
|---|---|---|
| Nivel entrenador (mantener / cambiar / objeto) | 🟡 | `think()` existe pero es una **cadena de ifs** con orden fijo y `randf` de una sola tirada. Ver §3. |
| Nivel Pokémon (atacar, spacing, esquivar, esperar/amagar, reposicionarse) | 🟡 | Todas las **acciones** existen (S-0 sumó el paso al costado, H-1 el "esperar"), pero se eligen con reglas en orden, no comparando utilidades. El ataque sí tiene puntaje (`score`). |
| Softmax con temperatura | ❌ | Hoy: `argmax` de `score × U(0,85-1,15)` mezclado con azar uniforme por `smarts` (`tactical_mind.gd:521`, `:677-684`). |
| Timing con variación | 🟡 | Uniforme `randf_range(0.4, 0.9)` y `(0.5, 1.1)` (`creature_attack.gd:142`, `:164`): varía, pero sin ritmo (ráfagas/respiros). El aviso dura siempre lo mismo (`:287-291`). |
| Penalidad por repetir | 🟡 | Solo el **último** ataque ×0,7 (`tactical_mind.gd:564-565`). Nada para modos ni secuencias. |

### Fase 4 — Modelo del jugador
| Pedido | Estado | Dónde / qué falta |
|---|---|---|
| Hábitos por situación | ❌ | `FoeMemory` cuenta **sin situación**: lado de esquive, lejos/cerca, ataques vistos, el que repetís (`foe_memory.gd`). |
| Esquives y su dirección | ✅/🟡 | Lado del esquive (últimos 10) y lo usa para apuntar (`aim_read`, `tactical_mind.gd:393-400`). No sabe *cuándo* esquivás (al aviso, al disparo, tarde). |
| Cambios del jugador | 🟡 | Responde a tu cambio en 1,5 s (`trainer_battle.gd:30`, `:406-408`). No aprende *cuándo* cambiás. |
| N-gramas de 2-3 acciones | ❌ | No hay secuencias. |
| Predecir y castigar | 🟡 | Solo "repetís el mismo → esquiva antes" (`tactical_mind.gd:361-362`) y "esquivás a la derecha → tira a la derecha". |
| Memoria que decae, adaptación según dificultad | 🟡 | Ventana fija FIFO de 10/6 eventos (`foe_memory.gd:6-11`), sin decaimiento por tiempo. La dificultad no regula cuánto aprende (sí `TrainerStyle.reads`). |

### Fase 5 — Castigos, esquivas, lecturas
| Pedido | Estado | Dónde / qué falta |
|---|---|---|
| Tabla de castigos de los datos | ❌ | Castigo = "si estás expuesto, ×1,4 a lo que pegue" (`tactical_mind.gd:18`, `:541-542`). No mira si **le da el tiempo**: la ventana que dejás vs. el arranque de su ataque. |
| Esquivas por la animación visible, nunca por input | ✅ | S-0: reacciona a proyectiles, cargas (por su `Telegraph`), zonas, chorros y golpes que salen (`tactical_mind.gd:173-310`). **Nunca lee tu input**: confirmado, ningún script de la IA toca `Input` ni `CombatInput`. |
| Mezclar en las adivinanzas | 🟡 | Fintas (`creature_attack.gd:116-120`) y el lado al que se esquiva (`combat_body.gd:120`, 50/50). Sin mezcla deliberada por situación. |

### Reglas del usuario
| Regla | Estado |
|---|---|
| IA nueva en paralelo, intercambiable | ❌ Hoy hay una sola. Propuesta en §6. |
| Nada de trampas | ⚠️ **Hay tres** (ver §3.4): leer tus recargas y PP exactos, `knows_moves` de líderes y élite (decisión tuya del 2026-11-05) y percepción instantánea. |
| Dificultad = mejores decisiones, no más daño | ⚠️ `AiDifficulty.damage_mult` (Fácil 0,6, Normal 0,85, Difícil 1,0) se aplica también a los Pokémon de entrenador, porque salen como `team = WILD` (`trainer_battle.gd:269` → `hit_info.gd:37-38`). Difícil no tiene ventaja, pero Fácil y Normal sí bajan el daño. |
| Parámetros en `.tres` (`AIProfile`) | 🟡 Ya está repartido en `AiDifficulty` + `TrainerStyle` + `LeaderScript`. Propuesta: `AIProfile` solo para lo nuevo (§6). |
| Tipado, señales, modular, comentado | ✅ El código actual lo cumple; lo nuevo sigue igual. |
| Rama nueva con commits por fase | ⚠️ El proyecto trabaja en `main` y **hay otras sesiones en el mismo checkout**: cambiar de rama acá les rompe el trabajo. Alternativas en §7. |
| Usar la lógica real, sin duplicar | ✅ Ya es así (`use_slot`, `Damage` vía `hit_share`, `MoveUser.can_use`). Lo nuevo reusa lo mismo. |

---

## 3. Por qué se siente predecible (con archivo:línea)

### 3.1 Decisiones casi deterministas
- **En Difícil piensa "perfecto" y por eso es más fácil de leer.** `smarts` = 1,0 → `lerpf(azar, puntaje, 1)` = el puntaje
  solo (`tactical_mind.gd:681`). Queda `argmax` con ±15 % de ruido (`:521`): si un ataque vale bastante más que el resto,
  sale **siempre ese**. Y `smarts_mult` de líder (1,3) y élite (1,5) **no hace nada** en Difícil porque se recorta a 1
  (`:661`): un Cazabichos y el Campeón eligen ataques igual de "bien".
- **Abre siempre igual**: si tiene embestida o salto y estás lejos, el primer ataque es ese (`creature_attack.gd:276-282`,
  `combat_body.gd:84-89`).
- **Modo de movimiento por reglas en orden fijo** (`creature_attack.gd:144-157`): ventana → bajo fuego → lejos → cerca
  → rodear. Mismo estado de la pelea = mismo modo; el único azar es invertir el lado del rodeo (20 %).
- **Cuerpo a cuerpo con ritmo de metrónomo**: entra 0,45 s antes de pegar, pega, sale 0,4-0,65 s, vuelve
  (`creature_attack.gd:33-34`, `:165-167`, `:230`). Se aprende en dos peleas.
- **Aviso de duración fija** por dificultad (`creature_attack.gd:287-291`, `telegraph` 0,12 / 0,22 / 0,35): el golpe
  sale siempre al mismo tiempo después del brillo, salvo la finta (20 % en Difícil, 5 % en Normal).
- **Esquiva una vez por amenaza con una tirada** (`combat_body.gd:131-135`): bien para no tener reflejos perfectos, pero
  el paso al costado sale siempre hacia el lado al que ya estaba corrido (`tactical_mind.gd:217`, `:281-282`).

### 3.2 Timers
- `TrainerBattle.think` cada **0,4 s fijos** (`trainer_battle.gd:364`).
- Pensar y atacar con `randf_range` **uniforme** (`creature_attack.gd:142`, `:164`): no hay ráfagas ni pausas largas
  (lo que planteaba H-2 y nunca se hizo).
- Retirar en < 25 % de vida, Superpoción en < 30 %: **umbrales fijos** (`trainer_battle.gd:21`, `:33`, `:432`). Si
  sabés que a 30 % se cura, la bajás de 35 a 0 de un saque.

### 3.3 Memoria del jugador corta y sin contexto
- `FoeMemory` = listas FIFO de 10 y 6 sin tiempo (`foe_memory.gd:6-11`, `:21-37`): no sabe si eso pasó hace 2 s o hace 2 min.
- Sin situación: no distingue "esquivás a la izquierda **cuando te dispara de cerca**" de "en general".
- Lee tu esquive para **apuntar**, pero al esquivar él mismo una costumbre tuya tira **50/50** el lado
  (`combat_body.gd:118-120`), sin usar lo que sabe.
- Los salvajes no leen nada (`reads()` = 0, `tactical_mind.gd:366-367`): está bien, no es el foco.

### 3.4 Trampas (lee lo que una persona no vería)
1. **Tus recargas y tus PP exactos**: `strong_on_cooldown()` mira `t.moves.can_use(slot)` de tus cuatro ranuras
   (`tactical_mind.gd:433-445`), y `can_use` incluye la recarga, la pausa y si te alcanzan los PP (`move_user.gd:204-207`).
   Ve la recarga de ataques **que nunca usaste** y tu barra de PP al punto. Lo usan `window_open`, `wary` y el modo
   `approach`. (H-3 proponía arreglarlo: "calcula tus PP con lo que te vio gastar".)
2. **`knows_moves`** en líder y élite (`trainer_style.gd`, `trainer_battle.gd:426-427`): conoce tus 4 ataques desde el
   principio para elegir cambios. Lo decidiste vos en la IA-7 ("te estudió"). Choca con "nada de trampas".
3. **Percepción instantánea**: tu posición y velocidad del mismo cuadro para la anticipación perfecta (`lead` 1,0 en
   Difícil, `combat_body.gd:102`), tu estado de máquina (`creature_attack.gd:144`), la amenaza apenas aparece.

### 3.5 Ataques sin evaluar el riesgo
- `score` mira daño, tipos, PP, habilidad y entorno, pero **no el riesgo**: ni el `recovery` que le queda expuesto
  (216 de 349 ataques lo tienen), ni la carga (`cast_time`) en la que lo podés cortar con un golpe fuerte, ni si a esa
  distancia le contestás. Tira una carga larga con vos a 40 px igual que a 200 px.
- `fits()` es solo "llega / no llega" (`combat_body.gd:66-80`).

### 3.6 No castiga bien
- Castigo = ×1,4 a cualquier ataque con daño si estás expuesto (`tactical_mind.gd:541-542`). No compara **cuánto dura
  tu ventana** con **cuánto tarda su ataque en pegar**: elige una carga de 0,8 s contra una recuperación de 0,3 s.
- `window_open` lleva a "acercarse" (`creature_attack.gd:144-145`), pero el ataque lo decide el timer, que puede tener
  0,9 s por delante: la ventana se cierra antes.

### 3.7 Tipos
- Lo hace bien en el ataque (STAB, efectividad, inmunidades, habilidades: `tactical_mind.gd:533-540`, `:704-727`) y en
  los cambios (daño real, IA-7). Falta usarlo en el **movimiento** más allá de "cuidate/presiona" (`:484-494`).

### 3.8 Cambios de Pokémon
- **Decide una vez por combinación y nunca más**: la clave `[su Pokémon, el tuyo, tu costumbre]` se marca **antes** de la
  tirada `randf() >= style.switch_types` (`trainer_battle.gd:409-418`). Si la tirada sale mal, ese cruce perdido no
  se revisa en toda la pelea aunque esté perdiendo feo.
- **Cambiar no le cuesta nada**: `_withdraw` es instantáneo (`trainer_battle.gd:449-456`); vos tenés 1,5 s de recarga
  de cambio (`combat_director.gd:38`). Tampoco evalúa el riesgo de entrar comiendo un golpe.
- Sin `smart_next`, saca **el primero de la lista** (`trainer_battle.gd:259-262`).
- El retirar es "una vez por Pokémon" con una tirada (`:388-397`), independiente del cambio por tipos.
- Bien: responde a tu cambio con tiempo humano, el líder guarda a su último (`:466-467`), `SWITCH_GAP` evita el ping-pong.

---

## 4. Datos por ataque (`MoveData`, `scripts/resources/move_data.gd`)

| Pedido | ¿Está? | Campo(s) |
|---|---|---|
| Daño | ✅ | `power`, `power_mult`, `category`, `element`, golpes (`combo_steps`, `projectile_count`, `tick_interval`; `TacticalMind.hits_of`) + el cálculo real en `hit_share` |
| Tipo | ✅ | `element` |
| Rango | ✅ | `reach()` (`move_data.gd:185-200`) por forma |
| Arranque (startup) | 🟡 | `cast_time` (44 ataques); en la IA también `telegraph`. Para golpes y embestidas está **implícito** en los estados (`melee_step` + `creature_step`, `dash_time`, `lunge_speed`). |
| Activo | ❌ explícito | Se deduce: `dash_time`, `channel_time`, `zone_duration`, `lifetime`, `strike_delay`; el del golpe está en `MeleeSwing`. |
| Recuperación | ✅ | `recovery` (216 de 349 tienen) |
| Recarga | ✅ | `cooldown` + costo de PP (`MoveUser.pp_cost_of`) |
| Área | ✅ | `size`, `radius`, `zone_radius`, `cone_*`, `whip_*`, `swing_radius`, `spread_deg`, `beam_length` |
| Empuje / stagger | ✅ | `knockback` (≥ 200 = corta cargas), `final_knockback`; stagger por potencia (`creature.gd:23-27`) |
| Invulnerabilidad | 🟡 | `invulnerable_time` (embestidas); esquive `DODGE_TIME` 0,16 s (`creature.gd:14`) |

**Qué falta de verdad**: no hace falta tocar los 349 `.tres`. Propongo un ayudante **`MoveFrames.of(move)`** que calcule
arranque / activo / recuperación / alcance **desde los campos y las constantes de los estados** (una sola fuente; si
cambia un estado, cambia solo). Si alguna forma no se puede derivar bien, recién ahí se suma un `@export` opcional.

---

## 5. Lo que ya está bien y no hay que tirar
- **El cuerpo** (`CombatBody`): apuntar con error y anticipación, rodear obstáculos, camino por celdas, paso al costado.
- **La amenaza** (`threat()`, S-0): ya es "percepción por animación visible". Solo le falta el retraso.
- **El cálculo de daño** (`hit_share`, `matchup_score`, `ability_mult`, `env_mult`): el corazón de una buena utilidad.
- **H-1** (juntar PP), **IA-7** (cruces de verdad, `FoeMemory` compartida por el equipo), **guiones de líder**.
- **El grabador** (S-1): base directa de las métricas de la Fase 1.

Rehacer esto sería tirar dos semanas de trabajo que funciona y está testeado (`--autotest-ai-mind`, `-ai-threat`,
`-ai-pp`, `-ai-trainers`, `-ai-steer`).

**Lo que sí recomiendo rehacer**: la **parte que decide** (el `physics_update` de `creature_attack.gd` y `think()` de
`TrainerBattle`). Razón: hoy son reglas en orden de prioridad con azar uniforme repartido en muchos lugares; sumarle
softmax, situación, modelo del jugador y castigos con cronómetro a esa cadena de ifs la vuelve inmanejable. Un cerebro de
utilidad que **llama a las mismas piezas** es más chico y se puede apagar.

---

## 6. Plan propuesto

### Arquitectura
```
Creature
 ├─ body: CombatBody            (igual: cómo se ejecuta)
 ├─ mind: TacticalMind          (igual: evaluadores — daño, tipos, amenaza, PP)
 └─ estado "attack" ──► brain: FighterBrain (interfaz)
                          ├─ ClassicBrain   = la lógica de hoy, movida tal cual (por defecto)
                          └─ UtilityBrain   = la nueva
TrainerBattle ──► coach: TrainerCoach (interfaz)
                    ├─ ClassicCoach  = think() de hoy
                    └─ UtilityCoach  = la nueva
```
- **Elegirla**: ajuste de partida `ai_brain` ("clásica" / "nueva", en Ajustes del juego → Combate) y, por encima, un
  campo `brain` en `AIProfile` para forzarla por entrenador desde el inspector. Por defecto, la clásica hasta que la
  nueva gane en las pruebas. Salvajes: **siempre la clásica** (temperamentos), igual que se decidió para S-3.
- **`AIProfile`** (`scripts/resources/ai_profile.gd`, `data/ai/profiles/{facil,normal,dificil}.tres`): solo lo nuevo —
  `perception_delay`, `temperature`, `repeat_penalty`, `adapt_rate`, `memory_half_life`, `punish_skill`, `mixup`,
  `commit_time`, ritmos de ráfaga/respiro. Lo referencia `AiDifficulty.profile`; un `TrainerStyle` o un `LeaderScript`
  puede traer su propio `AIProfile` o multiplicadores. No duplica lo que ya está en `AiDifficulty`/`TrainerStyle`.
- **Online y la batería de balance**: el online no usa IA; la batería (`--autotest-balance`) gana un `--brain` para
  medir las dos.

### Fases (estimación en sesiones de trabajo como las de estos días, ~3-4 h cada una)

| Fase | Qué | Reusa | Prueba | Estimación |
|---|---|---|---|---|
| **1. Instrumentación** | `AiTrace` (señal `decided(actor, situacion, opciones, elegida)`; log a archivo prendido con GM `ia log`); **overlay** `AiDebugOverlay` (CanvasLayer, GM `ia ver`, no en la portable): situación, acción, top 3 con puntaje, predicción sobre vos; **métricas** = S-2 (`tools/sparring_report.py`) + castigos hechos/perdidos, cambios buenos/malos por cruce, repetición. Mover la lógica de hoy a `ClassicBrain`/`ClassicCoach` **sin cambiar comportamiento**. | `SparringRecorder`, `GmConsole` | todos los `--autotest-ai-*` siguen OK; `--autotest-ai-trace` | 1-1,5 |
| **2. Percepción + situación** | `Perception`: buffer de fotos del rival (posición, velocidad, estado visible, amenazas) leído con `perception_delay` (Fácil 0,4, Normal 0,25, Difícil 0,15 ±jitter). `threat()` y la anticipación leen de ahí. **Sacar las trampas**: tus recargas y PP se **estiman** con lo que te vio usar (H-3). `Situation`: táctica (neutral cerca/media/lejos, ventana de castigo, ataque entrante, acorralado, poca vida, rematar) + estratégica (cruce, equipo, recargas estimadas, conviene cambiar). | `threat()`, `matchup_score`, `exposed` | `--autotest-ai-perception`: con retraso X no reacciona antes de X; nunca lee `can_use` del rival | 1-1,5 |
| **3. Utility AI** | `UtilityBrain`: acciones (atacar ranura N, acercarse, alejarse, rodear izq/der, mantener distancia, paso al costado, esquivar, esperar/juntar, amagar, reposicionarse); cada una con utilidad = consideraciones (curvas) × situación; **softmax con temperatura**; **intención con compromiso** de `commit_time` (H-2: presionar / juntar / castigar / rematar); ritmo con ráfagas y respiros (no uniforme); penalidad por repetir con decaimiento. `UtilityCoach`: mantener / cambiar / objeto evaluado cada 0,5-1 s con jitter + eventos (cayó uno, cambiaste, golpe fuerte), con histéresis y **costo de cambiar** (sin la tirada única que hoy bloquea el cruce para siempre). | `score`/`move_value`, `CombatBody`, `matchup_score` | `--autotest-ai-utility` (situaciones armadas: elige lo razonable, no siempre lo mismo: entropía mínima); batería clásica vs nueva | 2-3 |
| **4. Modelo del jugador** | Ampliar `FoeMemory` → `PlayerModel`: conteos **por situación** con decaimiento por tiempo (`memory_half_life`), cuándo y hacia dónde esquivás, cuándo cambiás, n-gramas de 2-3 acciones tuyas; predicción con confianza; `adapt_rate` por dificultad. La utilidad suma "castigar lo que viene" cuando la confianza pasa un umbral. Se sigue compartiendo en el equipo. | `FoeMemory`, `dodged`, `move_released` | bot con patrón fijo → la IA lo predice en N repeticiones; bot que cambia de patrón → lo olvida | 1-1,5 |
| **5. Castigos, esquivas, lecturas** | `MoveFrames.of(m)` (§4) y **tabla de castigos** por pelea: para cada ataque tuyo que vio, cuánto te deja expuesto, y qué ataque suyo entra en ese tiempo desde cada distancia. Esquivas siguen siendo por animación (ya es así) con el retraso de la Fase 2. **Mezclas**: en situaciones de adivinanza (vos cargando, cuerpo a cuerpo en rango) reparte entre opciones según lo que predice de vos y una cuota de azar (`mixup`). Lo que sigue del pedido (cortado) se suma acá. | `threat()`, fintas, `exposed` | casos armados: castiga solo con lo que llega a tiempo; jugarlo | 1,5-2 |

**Total**: ~7-9 sesiones. Cada fase: autotests de IA en verde, batería de balance en segundo plano (~30 min por 2000
peleas) comparando clásica vs nueva, `docs/PLAN_IA.md` y `PROGRESO.md` actualizados, commit.

### Cómo se relaciona con lo que estaba pendiente
- **S-2** (informe de sparring) = parte de la Fase 1.
- **H-2** (plan de varios segundos) = la intención con compromiso de la Fase 3.
- **H-3** (leer tu barra) = sacar la trampa de recargas/PP en la Fase 2.
- **H-4** (ánimo y errores creíbles) = perillas de `AIProfile` (temperatura según cómo viene la pelea) en la Fase 3.
- **S-3** (política imitada de tus peleas) sigue posible después: la tabla de S-3 puede entrar como una consideración
  más de la utilidad ("qué haría el jugador acá").

---

## Avance

| Fase | Estado | Notas |
|---|---|---|
| 0. Auditoría | ✅ 2026-11-09 | este documento |
| 1. Instrumentación | ✅ 2026-11-09 | ver abajo |
| 2. Percepción + situación | ✅ 2026-11-09 | ver abajo |
| 3. Utility AI | ✅ 2026-11-09 | ver abajo; falta jugarla |
| 4. Modelo del jugador | próxima | |
| 5. Castigos, esquivas, lecturas | — | falta el resto del texto del pedido |

### Fase 1, cómo quedó
- **`AiTrace`** (`scripts/creatures/ai/ai_trace.gd`): `AiTrace.note(actor, qué, datos)` → `Events.ai_decided`. Lo llaman el estado
  `attack` ("modo" con el porqué, "ataque" con `por` = apertura / elige / remate / tras el aviso y el **top 3** de puntajes,
  "aviso", "finta", "juntar"), `CombatBody` ("ve" = vio una amenaza y qué decidió, "paso", "esquive", "lectura") y
  `TrainerBattle` ("saca" con el cruce, "cambio" y **"no cambia" con el motivo** = no tiene otro / ninguno mucho mejor /
  tirada, "retira" / "no retira", "pocion", "momento"). Solo trabaja con `AiTrace.enabled()` (registro, overlay o una pelea
  de arena midiéndose) y **no gasta números al azar**: la IA decide igual con todo prendido. `TacticalMind.last_scores` y
  `last_reason` guardan la última elección.
- **`AiDebug`** (`world.ai_debug`): el **registro** (`ia log` en la consola GM → `user://ia_log/<fecha>.log`, una línea por
  decisión con el reloj de la pelea, y al final el resumen y las métricas en JSON), el **overlay** (`ia ver`; a la derecha,
  debajo del cartel del rival: situación, amenaza, top 3, lo que te lee, la pelea y las últimas decisiones; `ia eco` las
  imprime también en la consola) y las **métricas** de cada pelea de arena (siempre).
- **`AiFightStats`**: daño hecho por lado (en vidas), golpes, ataques, esquives de la IA (útiles = había amenaza), lecturas,
  pasos, fintas, veces que juntó PP, tus esquives, **castigos** hechos y perdidos de los dos lados (ventana = cargando,
  canalizando, recuperándose o aturdido, no el stagger; perdido = duró ≥ 0,3 s y el otro tenía un ataque listo que
  llegaba), **cambios** del entrenador y cuántos fueron buenos (el que entra tiene mejor cruce que el que sale), tus cambios,
  **repetición** (el ataque más usado, la racha más larga, el par seguido más repetido, la variedad) y la parte del tiempo
  en cada modo.
- **Sparring** (JSON versión 2): `metrics` + hechos `ia`. **Informe S-2**: `tools/sparring_report.py`.
- **Lo que se cambió del plan**: no se movió la lógica de hoy a `ClassicBrain`/`ClassicCoach` en esta fase. El estado
  `attack` y `TrainerBattle.think` ya *son* la IA clásica; separarlos ahora era mover 300 líneas sin ganar nada. El punto
  donde se elige el cerebro entra en la Fase 3, cuando exista el nuevo.
- Test `--autotest-ai-trace` (métricas con números armados, consola, overlay, registro, pelea grabada, cambio forzado);
  vitrina `--showcase-ai-overlay`. Los tests de IA de antes siguen OK (`ai-mind`, `ai-threat`, `ai-pp`, `ai-trainers`,
  `ai-steer`, `sparring`, `gm`, `wild-ai`). `ai-trainers` fallaba a veces al azar (con 20 % de vida a veces retiraba al
  Pokémon en vez de usar la Superpoción): arreglado en el test.

### Fase 2, cómo quedó
- **`AIProfile`** (`scripts/resources/ai_profile.gd`, `data/ai/profiles/{facil,normal,dificil}.tres`, `DB.ai_profiles` por id
  de la dificultad; la "personalizada" usa el de Normal; un `TrainerStyle.profile` lo pisa para esa clase): por ahora el
  **retraso de percepción** (Fácil 0,4 s · Normal 0,25 · Difícil 0,15, siempre entre 0,15 y 0,4) y su variación (± 0,06 /
  0,04 / 0,03, cambia cada 0,5 s). Las fases que siguen le suman sus perillas.
- **`Perception`** (`Creature.perception`, `scripts/creatures/ai/perception.gd`): cada cuadro guarda una foto de lo que se
  ve del rival (posición, velocidad, hacia dónde mira, estado, barra de vida, si tambalea, si puede actuar, si está bajo
  tierra, qué ataque está tirando y la amenaza que viene) y la IA lee la de hace `delay()`. `threat()` = la amenaza vista,
  con el tiempo que pasó descontado; `predicted_pos(ahead)` = dónde cree que vas a estar; `foe_exposed()`.
  **Sin trampas**: tus recargas y tus PP se **estiman** con lo que te vio tirar (`move_released`, recién pasado el retraso)
  y las reglas del juego (`rule_cooldown`, costo de PP, barra = 100 + 4 × nivel, recarga de la barra en pelea):
  `est_ready_in(m)`, `est_pp()`, `strong_down_est()`, `window_est()`. Lo que no te vio usar lo supone listo. El test
  revisa que el código de `Perception` y `Situation` no toque `Input`, tu `input_source`, tus `cooldowns`, `has_pp` ni tu
  `moves`.
- **`Situation`** (`scripts/creatures/ai/situation.gd`, `Situation.read(actor, perception, banco)`): táctica = neutral
  cerca (≤ 60 px) / media / lejos (más allá del alcance de sus ataques, mínimo 160 px), **castigar** (te ve expuesto y tiene
  algo listo que llega), **le viene un ataque** (≤ 0,6 s), **acorralado** (3 de 8 direcciones tapadas a 28 px), **poca vida**
  (< 35 %), **rematar** (un ataque listo te saca lo que te queda × 1,1). Mandan en ese orden: entrante > rematar > castigar >
  acorralado > poca vida > la banda neutral. Estratégica = cruce (`matchup_score` con lo que te vio, **sin
  `knows_moves`**), el mejor del banco y si conviene cambiar (los criterios de `TrainerBattle`), sus ataques listos, tus PP
  estimados. `to_text()` / `to_dict()`.
- **Overlay y registro**: con `ia ver`, el rival que se mira percibe y lee su situación como lo va a hacer el cerebro nuevo
  (línea "IA nueva (ve hace X s)") y cada cambio de táctica se anota ("situacion"). **La IA de hoy no usa nada de esto**:
  sigue peleando igual hasta que exista el cerebro nuevo (Fase 3), y ahí se elige con el ajuste `ai_brain`.
- Test `--autotest-ai-perception` (perfiles, retraso medido en las tres dificultades, el disparo visto con retraso, que no
  espía tus recargas aunque cambien, cada situación armada, el cambio sugerido y el overlay).

### Fase 3, cómo quedó
- **Cómo se elige**: ajuste de partida **"IA nueva de entrenadores (en prueba)"** (`ai_brain_new`, Esc → Opciones → Ajustes del
  juego → IA de entrenadores; apagado por defecto). `AIProfile.brain` ("ajuste" / "nueva" / "clasica") lo pisa por perfil;
  `Creature.brain_override` lo fuerza (batería, tests). Solo los Pokémon de entrenador (`Creature.uses_new_brain`): los
  salvajes siempre con la clásica. Con el ajuste apagado no se crea nada nuevo y la clásica pelea igual que antes.
- **Pokémon — `UtilityBrain`** (`Creature.brain`; lo llama el estado `attack` en lugar de su lógica): cada vez que piensa lee la
  `Situation` y puntúa **atacar con cada ranura** (valor de `TacticalMind.move_value` en modo `perceived`, normalizado contra
  su mejor ataque; × `punish_skill` si te ve expuesto, más a los rápidos; + remate con el más barato; − riesgo = carga +
  recuperación si tenés con qué castigar; × 0,5 si le viene un ataque; ahorro de PP; aguante/contragolpe de su clase; ritmo
  `attack_gap`), **juntar PP**, **acercarse** (lejos, entrar a pegar si es cuerpo a cuerpo, tu ventana, una pared en el
  medio; menos bajo fuego, con un ataque encima, con poca vida o saliendo de pegar), **alejarse**, **rodear** por cada lado
  (no contra una pared), **mantener la distancia** y **salir del rincón**. A cada opción le descuenta lo que repitió hace poco
  (`repeat_penalty`, con vida media `repeat_half_life`) y elige con **softmax** (`temperature` ÷ `smarts_mult` de su clase).
  Si elige atacar, igual elige con qué moverse. Piensa cada `think_mean` × lognormal(`think_sigma`) × su `pace` × la fase de
  **ráfaga o respiro** (`tempo_swing`, cambia cada 1,5-3,5 s), o enseguida si le pegan, te ve expuesto o cambia la situación.
  **Reacciona** a lo que ve venir (`Perception.threat`, ya con retraso): decide una vez por amenaza (`evade_skill`, + 0,15
  si es fuerte); paso al costado si hay tiempo, rueda si es fuerte o no llega caminando, recién al final. **Apunta** adonde
  cree que vas a estar (`Perception.predicted_pos`, también al soltar una carga: `creature_cast`), con el error de puntería
  de la dificultad. Los fuertes sin carga se siguen avisando y pueden ser finta (`AiDifficulty.telegraph`, `feint_chance`).
  Bajo fuego (2 golpes viniendo de frente en 3 s) deja de venir de frente 2-4 s. Las celdas peligrosas son solo las que se
  ven (no supone lo que le harías con tus ataques, como la clásica).
- **Entrenador — `UtilityCoach`** (`TrainerBattle.coach`; con la IA nueva `think` solo corre el guion del líder): cada 0,5-1 s
  (o enseguida si cambiaste o a su Pokémon le sacaron más de 20 %) puntúa **mantener** (+ histéresis, según el cruce),
  **cambiar** a cada uno del banco (cuánto mejora el cruce con lo que te vio, × `switch_types`; + salvar al golpeado; +
  responder a tu cambio; casi nada si ya gana) y **Superpoción** (con menos de 45 %; arriesgada con vos encima). Softmax
  más frío (× 0,6). Cambiar tiene costo: no en plena carga, golpe o recuperación, `SWITCH_GAP` entre cambios, el líder
  guarda a su último. **Sin `knows_moves`** (también al elegir quién sale).
- **`AIProfile`** suma `brain`, `temperature` (Fácil 0,4 · Normal 0,2 · Difícil 0,1), `repeat_penalty` (0,2 / 0,35 / 0,45),
  `repeat_half_life` 3 s, `think_mean` (0,6 / 0,45 / 0,35 s) y `think_sigma`, `attack_gap` (0,85 / 0,6 / 0,45 s),
  `tempo_swing`, `evade_skill` (0,3 / 0,6 / 0,85) y `punish_skill` (1,1 / 1,3 / 1,5). **Valores a ojo**: se ajustan jugando y
  con la batería.
- **Overlay y registro**: "Cerebro nuevo: eligió X · top 3 con utilidad y probabilidad · T" y "Entrenador: ..."; se anotan
  "decide", "entrenador", "bajo fuego" y los "ve"/"paso"/"esquive" del cerebro nuevo.
- **Batería**: `--autotest-balance --brain duelo` = tu bando con la nueva contra la clásica (cada especie pelea con las dos);
  `--brain nueva` = las dos con la nueva.
- **Primer duelo** (2026-11-09, `--brain duelo --fights 400 --seed 5`, Difícil, nivel 40, 11 min): la nueva ganó **183**, la
  clásica **196**, 21 empates (5 %, contra ~2 % de la batería normal): **parejas** (48 % de las que se definen; la diferencia
  está dentro del azar con 379 peleas). Ojo: la clásica juega con ventajas que la nueva no tiene (te ve sin retraso, sabe tus
  recargas). Queda en la clásica por defecto hasta que la nueva gane jugando y en la batería (ajustar perillas, Fases 4-5).
- Test `--autotest-ai-utility`: ajuste y perfiles, softmax frío/tibio, penalidad que se olvida, ritmo variable, que no lea
  nada prohibido, decisiones por situación (lejos → acercarse; te ve recuperándote al lado → pegarte; a pocos PP → juntar;
  acorralado → salir), que reaccione a un disparo (3 de 3 con `evade_skill` 1), el entrenador (cambia a Oddish, se queda con
  el cruce a favor, Superpoción con vos lejos) y una pelea viva contra un bot (decide seguido, ataca, varía).

## 7. Decisiones

**Respondidas por el usuario (2026-11-09)**: plan aprobado · IA nueva **en paralelo** (ajuste `ai_brain`, la clásica
por defecto) · se trabaja en **`main`** con commits por fase · las trampas (recargas y PP exactos, `knows_moves`,
`damage_mult` en entrenadores) **se sacan en la IA nueva**; la clásica queda igual. Falta: el texto del pedido desde la Fase 5.

Lo que se preguntó:

1. **¿Aprobás el plan?** (construir encima: el cerebro nuevo reusa cuerpo, amenaza y daño; se rehace solo la parte que decide).
2. **¿Paralelo o reemplazo?** Recomiendo **en paralelo** con el ajuste `ai_brain` (como pediste): la clásica queda por
   defecto hasta que la nueva gane en la batería y jugando; después se cambia el valor por defecto. Reemplazar por partes
   es más rápido pero no deja comparar.
3. **¿Rama nueva?** Otras sesiones trabajan en este mismo checkout: cambiar de rama acá les rompe el trabajo.
   Recomiendo **seguir en `main` con commits chicos por fase** (la IA nueva va apagada por defecto, el juego sigue
   ejecutable). Si querés rama igual, va en una **carpeta aparte** (`git worktree`, como `hd2d`): `../pokemon-tiempo-real-ia`.
4. **Trampas y daño que ya existen** (choque con "nada de trampas" y "no más daño"):
   - leer tus recargas y PP exactos → recomiendo sacarlo (estimarlo con lo que te vio);
   - `knows_moves` de líderes y élite (decisión tuya del 2026-11-05) → recomiendo sacarlo en la IA nueva y dejarlo en la clásica;
   - `damage_mult` por dificultad (Fácil 0,6, Normal 0,85) también a los entrenadores → recomiendo dejarlo solo para
     salvajes y que en los entrenadores la dificultad salga de cómo piensan.
5. **El resto del texto** del pedido (desde la Fase 5): se cortó en "mezclar las opciones en las situaciones de adivinanza".
