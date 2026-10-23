# Plan: Captura, Mochila y Caja

> Plan **separado** pedido por el usuario el 2026-10-23, **antes** de seguir con los entrenadores vivos (E-1)
> porque los entrenadores van a capturar y usar objetos. Cubre la parte de captura de la **Etapa 6** de
> `PROGRESO.md` (IVs al azar al capturar). Decisiones confirmadas por el usuario (las recomendadas).

## Decisiones (2026-10-23)
1. **Captura lanzando la bola**: en el mundo o en combate, **E** lanza la Pokébola elegida hacia donde apunta
   el mouse, en arco y con alcance limitado (se puede errar). Si pega a un salvaje, entra en la bola, la bola
   **tiembla de 0 a 3 veces** y puede escaparse. Chance con la **fórmula oficial de la 3ª gen**: vida restante,
   tasa de captura de la especie, multiplicador de la bola y estado (Dormido/Congelado ×2; Paralizado,
   Envenenado, Quemado ×1,5).
2. **Equipo lleno → Caja**: lo atrapado con 6 en el equipo va a una **Caja** (como el PC), que se abre desde el
   menú: ver, pasar al equipo y dejar del equipo. Más adelante se ata a los Centros Pokémon.
3. **Mochila en combate = bolas + ranura rápida**: **E** lanza la bola elegida y **C** usa el objeto de la
   **ranura rápida** (ej. Poción) sobre tu Pokémon, con un instante de exposición. Elegir la bola y el objeto
   rápido, y usar cualquier otro objeto, desde **Esc → Mochila** (fuera de combate).
4. **Cómo se consiguen objetos** (sin tiendas ni dinero todavía): **mochila inicial**, **objetos tirados en el
   mapa** (un brillo que se recoge al pasar; vuelven a aparecer después de un rato) y **botín** de salvajes
   debilitados (a veces sueltan algo). Tiendas y dinero en otra etapa.
5. **IVs al azar** (ya decidido para la Etapa 6): los salvajes aparecen con IVs al azar 0-31 por stat (lo que
   atrapás conserva los suyos); uno perfecto (31 en todo) es rarísimo. Los iniciales siguen con IV 31.

## Objetos (oficiales, PokeAPI)
Datos de `tools/fetch_items.py` → `data/items/*.tres` (`ItemData`) + íconos en `sprites/items/`. Nombre y
descripción en español de PokeAPI; efecto adaptado al tiempo real (la vida del juego es ×3, así que las curas fijas
se multiplican por `CreatureInstance.HP_SCALE`).

| Bolsillo | Objetos |
|---|---|
| Pokéballs | Poké Ball (×1), Super Ball (×1,5), Ultra Ball (×2), Master Ball (atrapa siempre) |
| Objetos | Poción (20 PS), Superpoción (50), Hiperpoción (200), Poción Máxima (todo), Antídoto, Antiparalizador, Despertar, Antiquemar, Antihielo, Cura Total, Revivir (50%) |
| Objetos clave | (vacío por ahora) |

Mochila inicial: 10 Poké Ball, 3 Pociones, 1 Antídoto, 1 Antiparalizador.

## Fases (cada una deja el juego ejecutable, con autotest)
| Fase | Contenido | Autotest |
|---|---|---|
| **C-1** | `ItemData` + objetos oficiales; `GameState.bag` (id → cantidad), bola elegida y objeto rápido; mochila inicial; guardado (reemplaza `GameState.balls`) | `--autotest-bag` |
| **C-2** | Captura: `BallThrow` (arco, alcance, impacto), fórmula 3ª gen con temblores, animación (entra, tiembla, ¡atrapado! / se escapa), al equipo o a la Caja, Pokédex "atrapado"; IVs al azar en los salvajes | `--autotest-capture` |
| **C-3** | **Caja**: `GameState.box`, pantalla en Esc → Caja (pasar al equipo, dejar del equipo), guardado | en `--autotest-capture` |
| **C-4** | **Pantalla Mochila** (bolsillos, descripción, usar sobre un Pokémon del equipo, elegir bola y objeto rápido) + **ranura rápida (C)** en combate con exposición; HUD con bola y objeto rápido | en `--autotest-bag` |
| **C-5** | **Objetos en el mapa** (brillos que se recogen y reaparecen) + **botín** de salvajes debilitados | `--autotest-bag` |

## Avance
| Fase | Estado |
|---|---|
| C-1 a C-5 | ✅ Hechas (2026-10-23) |

## Cómo quedó implementado
- **Objetos** (`ItemData`, `scripts/resources/item_data.gd`): 15 objetos en `data/items/*.tres` generados por
  `tools/fetch_items.py` (PokeAPI: nombre y descripción en español + ícono en `sprites/items/`); el efecto
  (bola, cura, estados que sana, revivir, si se usa en combate y cuánto te expone) está en `ITEMS` del script.
  "Cura Total" sana los problemas de estado (`ItemData.BAD_STATUSES`), no las mejoras propias (Arraigo...).
- **Mochila** (`GameState.bag` id → cantidad, `selected_ball`, `quick_item`; `add_item`, `remove_item`,
  `pocket_items`, `use_item_on`). Inicial: `GameConfig.starting_bag`. Se guarda; las partidas viejas pasan su
  contador `balls` a Poké Balls (`GameState.balls` quedó como atajo a la cantidad de Poké Ball).
- **Captura**: `PlayerItems` (nodo del mundo) → **E** lanza `BallThrow` desde el entrenador hacia el mouse
  (alcance 160 px, recarga 1,2 s; la bola se gasta al lanzarla). La bola vuela en arco; si al bajar toca a un
  salvaje lo mete adentro (`Creature.set_captured`: invisible, quieto, sin golpes), tiembla según
  `Capture.roll` (fórmula oficial 3ª gen) y lo atrapa (`GameState.add_caught` → equipo o Caja, Pokédex
  "atrapado", `Events.pokemon_caught`) o lo deja escapar. `BallThrow.finished(result)`.
- **IVs al azar**: `CreatureInstance.roll_ivs()` en `WildSpawner.spawn` (los iniciales y los de entrenadores
  siguen con 31).
- **Caja**: `GameState.box` (sin límite), `box_to_party`, `party_to_box` (nunca el último); pantalla
  `BoxScreen` (Esc → Caja). Se guarda.
- **Ranura rápida**: **C** usa `quick_item` sobre tu Pokémon activo; en combate queda en "recovery" `use_time`
  segundos (expuesto). HUD: panel abajo a la derecha con la bola de E y el objeto de C (íconos y cantidades).
- **Pantalla Mochila** (`BagScreen`, Esc → Mochila): bolsillos Objetos / Pokéballs / Objetos clave (Tab), lista con
  cantidades y marcas [E]/[C], descripción oficial, Usar (elegir Pokémon del equipo), "Lanzar esta con E",
  "Poner en la ranura rápida (C)".
- **Objetos en el mapa**: `FieldItemSpawner` pone 3 por zona (`FieldItem`: Pokéball en el suelo con destello) en
  lugares fijos por zona (semilla = id de la zona) con `data/items/loot/campo.tres`; se recogen pasando por
  encima; `GameState.field_picked` ("zona:x,y" → tiempo jugado) y vuelven a los 15 min de juego.
  **Botín**: un salvaje debilitado suelta algo con `data/items/loot/salvajes.tres` (15%), dura 60 s.
- **Pokédex**: atrapados con una Pokéball en la casilla y "Atrapado" en la ficha; contador de atrapados. Lo que
  está en tu equipo cuenta como atrapado.
- Autotests: `--autotest-capture` (14 chequeos), `--autotest-bag` (17); vitrina `--showcase-capture`.
