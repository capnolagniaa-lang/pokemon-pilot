# Progreso del proyecto

Bitácora viva. Se actualiza al cerrar cada etapa (y antes de que se termine el contexto de una sesión).

> **Plan paralelo:** la identidad del combate (arquetipos, mecánica de firma y kit por Pokémon) se sigue en
> [`PLAN_IDENTIDAD_COMBATE.md`](PLAN_IDENTIDAD_COMBATE.md), con su propia tabla de avance.

## 📍 Dónde estamos (actualizado 2026-10-22)
- **Etapa 3 hecha (entorno reactivo)** — ver "Etapa 3" más abajo. **Etapa 2c hecha** (título, guardado,
  equipo y movimientos).
- **Siguiente: Etapa 4 (IA salvaje con estados + spawns por bioma/hora)** — ver "Próximo paso concreto". El usuario aprobó los kits por ahora ("me gustan los de Charmander y
  Bulbasaur"); más adelante se harán **tests de balance** de los kits.
- v2 hecho: **sin energía** (solo recargas), **4 ataques + esquive en Espacio**, Charmander **bruiser** rearmado,
  Bellsprout/Bulbasaur **control**, y por ahora **todo el mapa** solo hace aparecer **Pidgey, Bellsprout,
  Rattata y Vulpix** (`WildSpawner.use_test_pool`; apagarlo devuelve los spawns por bioma).
- Pantalla de inicio con **Modo práctica** (por defecto on) y **Dificultad de la IA** (Fácil / Normal por
  defecto / Difícil = la IA original). Detalle en el plan de identidad.
- **Kits de Pidgey (hostigador, Vuelo), Rattata (asesino, Instinto) y Vulpix (desgaste, Rescoldo)** hechos
  (2026-10-22): los 4 de la zona de prueba tienen estilo propio. Detalle en el plan de identidad.
- Identidad pendiente: **Squirtle** (tanque/parry) y **Pikachu** (cargas). Propuestas en `PLAN_IDENTIDAD_COMBATE.md`.
- Lo de la sección "Combate (Etapa 2)" más abajo que hable de energía o de ataques 1-4 genéricos quedó
  superado por la v2 (ver el plan de identidad).

## Etapas

| # | Etapa | Estado |
|---|---|---|
| 1 | Refactor data-driven + mundo abierto con zonas | ✅ Hecha |
| 1b | Arte FireRed + efectos modernos | ✅ Hecha |
| 1c | Región grande (3×3 zonas, 9 biomas) | ✅ Hecha |
| 2 | Combate en tiempo real en el mapa + estados alterados | ✅ Hecha |
| 2b | Stats oficiales (PokeAPI), curvas de EXP, velocidad por stat, balance de energía, visual de fuego/estados | ✅ Hecha |
| 2c | Título, guardado, equipo (máx. 6) y movimientos por nivel (learnset + ficha) | ✅ Hecha |
| 3 | Entorno reactivo (fuego, agua, eléctrico) + puzzles | ✅ Hecha |
| 4 | IA salvaje con estados + spawns por bioma/hora | ⏭️ Siguiente |
| 5 | Ciclo día/noche, clima, NPCs con horarios | Pendiente |
| 6 | Captura, equipo y progresión (incluye **IVs al azar al capturar**, naturalezas, EVs) | Pendiente |
| 7 | Primer gimnasio (arena con transición) | Pendiente |
| 8 | Pulido (juice, audio, partículas) | Pendiente |

## Etapa 3 — Entorno reactivo (2026-10-22)
- **Estado por celda** (`EnvironmentGrid`, uno por zona, lo crea `ReactionSystem` al primer uso y se va con la
  zona): `data/environment/states/*.tres` (`EnvCellState`): **ardiendo** (4,5 s, se contagia a las vecinas 30%/s,
  quema a quien esté encima, después queda **quemado**), **quemado** (45 s, deja de ser inflamable/pasto alto),
  **mojado** (15 s, Empapa), **congelado** (10 s; sobre el agua saca el tile de agua = **puente de hielo**, no se
  derrite con alguien encima), **electrificado** (1,2 s, Paraliza; al terminar vuelve al estado anterior).
  Visual: llamas (partículas rojizas y luces suaves cada 3 celdas), hollín, charcos, hielo y chispas.
- **Reglas** (`data/environment/reactions/*.tres`, `ReactionRule`, por prioridad): agua apaga el fuego (vapor) ·
  fuego seca lo mojado (vapor) · fuego derrite el hielo · hielo congela agua y suelo mojado · eléctrico corre por
  el agua y lo mojado (propagación instantánea, hasta 80 celdas) · fuego prende lo inflamable (pasto alto,
  flores, árboles) · agua moja el suelo.
- `ReactionSystem` (en el mundo) escucha `Events.element_impact`. Los **proyectiles también tocan las celdas por
  las que pasan** (cada 14 px): las brasas prenden el pasto alto y el agua moja su camino.
- **Objetos**: lo inflamable (árbol cortable) se quema y desaparece; la **roca frágil** se rompe con una
  embestida (`Events.env_object_struck` desde los estados dash/lunge; `EnvObject.break_power` = 30 de potencia):
  Embestida Ígnea, Ataque Rápido, Arañazo... abren el rincón de Ruta 1.
- `World.tags_at()` ya devuelve los tags con el estado aplicado (el pasto alto quemado deja de serlo).
- Autotest `--autotest-env` (22 chequeos con el mapa real); vitrina `--showcase-env`.
- Pendiente: crecido (planta), viento que aviva el fuego, reflejar proyectiles, que la IA salvaje evite el fuego.

## Etapa 2c — Título, guardado, equipo y movimientos (2026-10-22)
Pedido del usuario en `docs/PROMPT_MENU_GUARDADO_EQUIPO.md`. Decisiones (todas las recomendadas):
**learnset = kit al inicio + extras** (los 4 del kit en Nv. 1, 1, 3 y 5; 2 extras por especie al nivel de
FRLG), **ranuras libres**, **guardado solo manual**, debug **F9 con `-- --debug`** (o desde el editor).
- **Título** (`scenes/ui/title_screen.tscn`, escena principal): Continuar (con resumen: retratos, nivel del
  líder, zona, tiempo y fecha), Nueva partida (confirma si ya hay guardado) y Salir. Esc en la elección de
  inicial vuelve al título.
- **Guardado** (`SaveManager`, autoload): un slot `user://saves/slot_1.json`, JSON con ids y `version`,
  escritura atómica (`.tmp` + renombrar), tolerante a JSON roto o especies/movimientos que ya no existen.
  Guarda equipo (especie, nivel, EXP, IV/EV, PS, movimientos equipados, apodo/naturaleza vacíos), activo,
  Pokébolas, opciones, tiempo jugado y **posición del entrenador** (World aparece ahí). No se guarda en combate.
- **Menú de pausa** (Esc, `PauseMenu`): Equipo, Guardar, Opciones (dificultad y modo práctica), Volver al
  título (pregunta si guardar) y Cerrar. Pausa el mundo; no se abre en combate.
- **Equipo** (`PartyScreen`): 6 casillas (vacías con "—"), activo marcado; acciones Ver ficha / Poner como
  activo / Mover arriba-abajo. `GameState.MAX_PARTY = 6`, `add_to_party()` (rechaza el 7°), `set_active()`
  (no a un debilitado), `move_in_party()`.
- **Ficha** (`SummaryScreen`, Tab cambia de pestaña): Estadísticas (estilo, mecánica de firma con descripción,
  PS, EXP, 6 stats con base/IV/EV y barra, velocidad en px/s) y Movimientos (4 ranuras + learnset completo,
  bloqueados con su nivel; equipar = Enter en movimiento y en ranura; Supr vacía; nunca sin movimientos ni
  repetidos). Los cambios re-sacan al activo (`Events.equipment_changed`).
- **Modelo**: `LearnsetEntry` + `SpeciesData.learnset` (generado por `tools/build_learnsets.gd`; sin learnset
  hay uno de compatibilidad), `CreatureInstance.equipped_moves` (+ `learned_moves`, `can_equip`, `equip`,
  `default_equipment`, `to_dict`/`from_dict`), `MoveUser.setup(instance)`, `DB.all_moves` / `move_key` /
  `move_by_id` (las claves de los kits son `<pokémon>/<archivo>` porque varios kits comparten ids).
  `GameState.grant_exp()` sube de nivel, aprende ("¡Aprendió X!", `Events.move_learned`) y equipa solo si
  hay ranura libre.
- **12 ataques oficiales nuevos** para los extras: Cuchillada, Ataque Ala, Persecución, Rayo Solar, Ácido
  (adaptación: envenena 30%), Rueda Fuego, Rayo, Hidrobomba, Derribo, Golpe Cuerpo, Rayo Hielo, Viento Hielo
  (adaptación: ralentiza siempre). El fetcher ahora también baja `learnset_frlg` de cada especie.
- Autotests: `--autotest-save` (17 chequeos), `--autotest-party` (12); vitrina `--showcase-menus`.

## Decisiones tomadas (no volver a preguntar)
- Generación: **solo primera generación (Kanto)**, nombres y sprites reales.
- Control: **entrenador + Pokémon**. Explorás con el entrenador (Red) y tu Pokémon te sigue.
- Mundo: **zonas conectadas sin corte** (streaming), región continua; solo el borde exterior tiene árboles.
- Arte: **pixel art GBA (FireRed, del decomp pret) + efectos modernos**; renderer **Forward+**
  (PCs con placa decente). Pokémon con sprites PMD (8 direcciones).
- Entrar en combate (Etapa 2): cuando un salvaje te detecta o lo atacás, **tomás control directo del
  Pokémon** (cámara se centra en él); al terminar o alejarte volvés al entrenador. También se puede sacar
  al Pokémon a pelear con una tecla.
- **Estados alterados** (quemado, paralizado, congelado...) entran en la **Etapa 2**.
- Subir a GitHub al cerrar cada etapa.
- **Stats oficiales** (2b): stats base, experiencia, curvas y tasa de captura de PokeAPI; fórmula oficial
  de stats y de daño; tabla de tipos oficial (se sumaron veneno, volador y siniestro).
- **Por ahora todos los Pokémon tienen stats máximos para su nivel** (IV 31, EV 0, naturaleza neutra).
  **Más adelante (Etapa 6)** cada Pokémon capturado tendrá IVs al azar según la suerte; uno con stats
  perfectos tiene que ser **sumamente difícil** de conseguir.
- Los Pokémon **se mueven según su stat de Velocidad** (sube con el nivel, con rendimiento decreciente).
- Los ataques **no deben salir tan seguido**: energía con regeneración lenta (12/s) y recargas que crecen
  con la potencia.
- El fuego tiene que verse **rojizo**, no amarillo ni demasiado luminoso; las luces dinámicas, suaves.

## Estado actual
- 9 zonas de 48×32 (`tools/build_world.gd` → `REGION`/`BIOMES`): Bosque Profundo, Bosque Verde,
  Lago Celeste / Pradera Florida, **Ruta 1 (inicio)**, Colinas Rocosas / Humedal, Pradera Sur, Arboleda.
- Ruta 1 tiene un rincón de flores cerrado por rocas con 2 rocas frágiles (puzzle para la Etapa 3).
  Bosque Verde tiene un arroyo con vados donde lo cruzan los caminos (candidato a puente de hielo).
- 14 especies (`data/species`; se sumaron Pikachu y Seel), 21 ataques (`data/moves`), 9 tipos
  (fuego, agua, planta, normal, eléctrico, hielo, veneno, volador, siniestro), 3 estados (`data/status`:
  quemado, paralizado, congelado).

### Stats oficiales (Etapa 2b)
- Datos en `data/source/official.json` (PokeAPI) → `tools/apply_official_data.gd` → `.tres`.
  Detalle de fórmulas y adaptaciones al tiempo real en `CLAUDE.md` ("Stats, daño y progresión").
- Ejemplos verificados por `--autotest-stats`: Pikachu Nv.50 = PS 110 / At 75 / Def 60 / AtEsp 70 /
  DefEsp 70 / Vel 110; curvas de EXP a Nv.100 (1.000.000 medium, 1.059.860 medium-slow, etc.).
- Velocidad de movimiento a Nv.5 entre ~68 px/s (Oddish) y ~80 (Pikachu/Poliwag); a Nv.50 ~114-141.
- Recargas: Ascuas 1,45 s / 16 EN, Lanzallamas 2,35 s, áreas 3-5,5 s, Protección 8 s.
- Visual: fuego rojizo (centro naranja), luces dinámicas suaves; quemado con llamitas que suben, luz
  parpadeante y tinte naranja; paralizado con chispas; congelado dentro de un bloque de hielo.

### Combate (Etapa 2)
- **Modo combate** (`scripts/combat/combat_director.gd`): un salvaje te detecta (o apretás **F**) → controlás
  al Pokémon (WASD, mouse, 1-4/clic, espacio esquiva), la cámara (`CameraRig`) lo sigue y el entrenador queda
  quieto. Termina si no quedan enemigos cerca por 1,5 s, si tu Pokémon se debilita o con F. Si lo sacaste con
  F sin enemigos, no termina solo.
- **Componentes de la criatura** (`scenes/creatures/creature.tscn`): `Health`, `StatusEffects`, `MoveUser`
  (recargas/energía), `Hurtbox` (capa 6 aliada / 7 salvaje), `DashHitbox`. Estados: idle, follow, controlled,
  cast, dash, stunned, fainted, wander, chase, attack, flee.
- **Ataques**: `Projectile` (choca con paredes, capa 1), `AreaEffect`, embestida (hitbox durante el dash),
  escudo. La carga (cast time) la interrumpe un golpe fuerte (knockback ≥ 200). Daño en `Damage` (escala 0.4).
- **Estados alterados**: quemado (daño por segundo, -25% ataque, lo cura el agua), paralizado (lento +
  inmovilizado al azar), congelado (no actúa, lo derrite el fuego).
- **Feedback** (`scripts/fx/combat_feedback.gd`): números de daño (súper eficaz en grande), hitstop, temblor,
  chispas, luces dinámicas en ataques de fuego/eléctrico/hielo, destello HDR al recibir golpes, estelas al esquivar.
- `Events.element_impact(element, pos, radius)` ya se emite en cada impacto: **es la entrada del sistema de
  entorno reactivo de la Etapa 3**.
- **Provisorio** (lo reemplazan etapas futuras): `WildSpawner` (salvajes en el pasto alto según bioma; Etapa 4)
  y regeneración fuera de combate de 2%/s con vuelta al 30% (Etapa 6: Centros Pokémon / objetos).

### Pruebas automáticas
`--autotest` (recorre las 9 zonas), `--autotest-combat` (3 peleas: Charmander/Bulbasaur, Pikachu/Squirtle,
Seel/Oddish), `--autotest-input` (simula teclas reales y verifica el spawner), `--autotest-stats` (stats y
EXP contra valores oficiales), `--showcase` (vitrina visual de los 3 estados, para renderizar). Correr siempre con
`--quit-after 60000` como límite por si algo se cuelga.

## Próximo paso concreto (Etapa 4: IA salvaje con estados + spawns por bioma/hora)
1. Que la IA use cada kit con criterio: defensivas (Arraigo, Síntesis, Foco Energía) en el momento justo, guardar
   la de más recarga, aprovechar la mecánica de firma (Vulpix busca quemados, Rattata remata presas, Pidgey sube
   al aire cuando lo encaran). Hoy elige al azar dentro del alcance.
2. Que la IA lea el entorno: no pararse en el fuego, salir del agua electrificada.
3. Comportamientos por especie (tímido/agresivo/territorial) y huida con poca vida.
4. Spawns por bioma y hora (volver a `WildSpawner.use_test_pool = false` cuando termine la prueba del combate).

## Pendientes de pulido (anotados)
- Esquinas interiores donde se cruzan caminos (quedan cuadradas).
- Lagos solo rectangulares (faltan esquinas interiores de agua).
- Bosques podrían ser más densos/variados (usar tileset viridian_forest ya exportado).
- Reflejos de personajes en el agua; sombras de árboles más elaboradas.
- Verificar visualmente el pasto alto tapando las piernas.
