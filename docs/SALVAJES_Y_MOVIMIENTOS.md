# Salvajes, movimientos y kits: cómo funciona y cómo modificarlo

> Documentación de referencia (2026-10-23). El **listado actual** de qué aparece en cada zona, con niveles, kit,
> temperamento y movimientos de cada especie, está en [`SALVAJES_LISTADO.md`](SALVAJES_LISTADO.md) (generado:
> `godot --headless --path . --quit-after 5000 --script res://tools/build_wild_docs.gd`).

## 1. Cómo aparecen los salvajes (`WildSpawner`, `scripts/world/wild_spawner.gd`)

1. Cuando se **carga una zona** (el `ZoneStreamer` carga las cercanas al jugador), el spawner busca su **tabla de
   encuentros**: primero la propia de la zona (`data/world/encounters/<zona>.tres`) y, si no tiene, la de su
   **bioma** (`data/world/encounters/biomas/<bioma>.tres`; el bioma de cada zona está en `data/world/kanto.tres`).
   Sin tabla, en esa zona no aparece nada.
2. Pone enseguida hasta `max_alive` salvajes (3 por defecto) y después, cada `respawn_time` segundos (25 por
   defecto), repone los que faltan (debilitados, atrapados o que se fueron).
3. Para cada uno **primero elige la celda** entre todas las celdas de la zona que tienen alguno de los "dónde"
   de la tabla (tags de celda: `pasto_alto`, `agua`, `arena`, `flores`, `tierra`, `suelo`) y **después la fila**
   que vale en esa celda (`EncounterTable.pick_at`), por **peso**: la probabilidad es peso / suma de pesos de las
   filas de ese mismo "dónde". Así, en Ruta 1 Pidgey (35) y Rattata (35) salen el 35% de las veces en el pasto
   alto, Bellsprout (15) y Vulpix (15) el 15%.
4. **Áreas pintadas** (`EncounterArea`, se pintan en el editor de mapas): un grupo de celdas con ajustes que
   **pisan** la fila de la misma especie y "dónde", o **suman** filas nuevas (ej. "en el claro del bosque aparece
   Pikachu con más frecuencia").
5. El nivel sale al azar entre `min_level` y `max_level` de la fila. No aparece a menos de 120 px del
   entrenador (para que no salga encima tuyo).
6. Los que aparecen en el agua **nadan** (`Creature.swims`: no chocan con el agua).
7. Cada salvaje nace con **IVs al azar** (0-31 por stat; `CreatureInstance.roll_ivs`): lo que atrapás conserva
   los suyos. Su **temperamento** sale de la especie (ver 3).
8. Al descargar la zona, los salvajes que no están peleando se van.

**Opción "Salvajes de prueba"** (Esc → Opciones, se guarda en la partida): ignora las tablas y pone solo Pidgey,
Bellsprout, Rattata y Vulpix en el pasto alto de todo el mapa, al nivel de tu Pokémon (−2 a +1), 3 por zona.

### Cómo cambiar qué aparece
- **Editor de mapas → pestaña Salvajes** (recomendado): elegís la zona, agregás/quitás filas (especie, dónde,
  peso, niveles), cambiás máximo vivos y tiempo, pintás áreas. Se guarda en `data/world/encounters/`.
  Plantillas de FireRed: botón de plantillas (sale de `encounters/plantillas_frlg.json`).
- A mano: abrir el `.tres` de la tabla en el inspector de Godot (`entries`, `areas`, `max_alive`, `respawn_time`).
- Después correr `tools/build_wild_docs.gd` para actualizar `SALVAJES_LISTADO.md`.
- `EncounterEntry.time` (día/noche) está reservado para la Etapa 5 (todavía no hace nada).

## 2. Movimientos: de dónde salen y cómo cambiarlos

**Cadena**: `SpeciesData.learnset` (qué aprende y a qué nivel) → `CreatureInstance.equipped_moves` (las 4
ranuras: Clic, Clic der., Q, R) → `MoveUser.setup` (lo que usa en combate).

- **Salvajes**: aparecen con los **4 primeros movimientos que aprendieron a su nivel**, en el orden del learnset
  (`CreatureInstance.default_equipment`). Si a su nivel aprendió menos de 4, tienen huecos.
- **Tus Pokémon**: lo mismo al atraparlos; después los cambiás en la **ficha** (Esc → Equipo → Ver ficha →
  Movimientos). Al subir de nivel aprenden lo nuevo (si hay ranura libre, se equipa solo).
- Las especies con **kit** aprenden sus 4 ataques de kit en los niveles **1, 1, 3 y 5** (decisión del usuario:
  el estilo está desde el principio), así que un salvaje de Nv. 2 tiene solo los dos primeros. Más 2 "extras" a
  niveles más altos.
- Las otras **8 especies que ya existían antes de las 386** (Squirtle, Pikachu, Oddish, Psyduck, Growlithe,
  Poliwag, Seel, Eevee) todavía usan sus **4 ataques sueltos de antes** (`SpeciesData.moves`) en Nv. 1, 1, 3 y 5 +
  2 extras, no el learnset oficial completo. Las otras **372** usan el **learnset oficial de FireRed/LeafGreen**.

### Cómo cambiar los movimientos de una especie
| Caso | Dónde se cambia | Después |
|---|---|---|
| Especie **con kit** (sus 4 ataques de estilo) | `data/kits/<especie>/kit.tres` (array `moves`, en orden Clic/Clic der./Q/R) y cada ataque en `data/kits/<especie>/*.tres` | `tools/build_learnsets.gd` |
| Extras de las 14 especies "viejas" | tabla `EXTRAS` de `tools/build_learnsets.gd` (`[nivel, id de data/moves]`) | `tools/build_learnsets.gd` |
| Las 4 sueltas de las 8 especies sin kit "viejas" | `SpeciesData.moves` en `data/species/<especie>.tres` (inspector) | `tools/build_learnsets.gd` |
| Learnset de cualquier especie (a mano, puntual) | `SpeciesData.learnset` en `data/species/<especie>.tres` (inspector: nivel + ataque por fila) | nada (ojo: `build_learnsets.gd` lo pisa) |
| Learnset oficial de las 372 | sale de PokeAPI (`data/source/official.json`) | `fetch_official_data.py` → apply → `build_learnsets.gd` |
| **Cómo se comporta** un ataque (forma, alcance, recarga, estados) | `data/moves/<id>.tres` (inspector) o `data/kits/...` | nada |

Comandos (desde la carpeta del proyecto, `G` = Godot de consola):
```
$G --headless --path . --quit-after 3000 --script res://tools/build_learnsets.gd
$G --headless --path . --quit-after 5000 --script res://tools/build_wild_docs.gd
```
Ataques automáticos (los ~300 que no se hicieron a mano): su forma sale de `_shape()` en
`tools/apply_official_data.gd`; rearmarlos todos con `apply_official_data.gd -- --regen-auto`. Si se toca uno a
mano en el inspector, no volver a correr `--regen-auto` (lo pisa).

## 3. Temperamentos de los salvajes (IA sin memoria)

Cada especie tiene uno (`SpeciesData.temperament`, asignado por `tools/assign_temperaments.gd`: heurística por stats
+ ajustes a mano en `OVERRIDES`). Datos de cada temperamento en `data/ai/temperaments/*.tres` (distancia a la que
te nota, correa, radio de territorio, vida a la que huye, chance de espantarse).

| Temperamento | Qué hace | Ejemplos |
|---|---|---|
| Agresivo | Te ataca apenas te ve (110 px) y te persigue lejos | Rattata, Spearow, Zubat, Mankey |
| Territorial | Te mira ("...") y solo ataca si entrás a su zona (70 px de su lugar); te suelta si salís **sin pelear** | Bellsprout, Bulbasaur, Squirtle, Growlithe, legendarios |
| Tímido | Huye sin pelear; si lo acorralás o le pegás, pelea; huye con poca vida (30%) | Pidgey, Oddish, Poliwag, Abra |
| Curioso | Se acerca a mirarte (~55 px); si te le venís encima ataca o huye | Vulpix, Pikachu, Psyduck, Eevee |

**Arreglo del 2026-10-23 ("Bellsprout corta la batalla")**: el territorial soltaba la pelea apenas tu Pokémon
salía de su zona aunque estuvieran peleando, y te volvía a agarrar enseguida (detecta también al entrenador), así
que el combate se cortaba y volvía a empezar. Ahora: mientras hay intercambio de golpes (últimos 5 s,
`Creature.engaged`) no suelta por salir de la zona (solo si lo arrastrás muy lejos de su lugar), y después de
soltar una pelea se queda tranquilo 6 s (`Creature.calm_until`). El tímido huye con 30% de vida (antes 50%).
Cambiar cualquier temperamento de una especie: `OVERRIDES` en `tools/assign_temperaments.gd` y correrlo
(`--script res://tools/assign_temperaments.gd`), o a mano en el inspector de la especie.

## 4. Kits (estilos de pelea)

Un kit (`data/kits/<especie>/kit.tres`, ver `docs/PLAN_IDENTIDAD_COMBATE.md`) define el **estilo** (arquetipo),
el **rango preferido** (lo usa la IA), la **mecánica de firma** opcional y los **4 ataques** hechos a mano.

**Con kit hoy (6)**: Charmander (bruiser, Calor) · Bulbasaur (control) · Bellsprout (control) · Pidgey (hostigador,
Vuelo) · Rattata (asesino, Instinto) · Vulpix (desgaste, Rescoldo). El resto (380) pelea con sus movimientos
oficiales de forma automática.

### Propuesta: llegar a ~16 kits para el modo historia (a confirmar con el usuario)
Criterio: los que **ya aparecen en el mapa** sin kit (así todo lo que te cruzás tiene estilo propio) + dos para
la historia temprana. Cada uno con un arquetipo que no pise a los otros.

| # | Pokémon | Estilo propuesto | Idea de mecánica | Por qué |
|---|---|---|---|---|
| 7 | Squirtle | Tanque / contraataque | Refugio (bloqueo y parry), Presión | Inicial; propuesta ya escrita en el plan de identidad |
| 8 | Pikachu | Velocista de cargas | Estática (moverse carga, descargar) | Aparece en 3 zonas; propuesta ya escrita |
| 9 | Oddish | Desgaste de esporas | Esporas que se acumulan y "florecen" | Aparece en 6 zonas; ficha en el plan original |
| 10 | Paras | Control de esporas | **Espora** en el piso que arde con fuego (idea del usuario) | Trae la interacción esporas + fuego |
| 11 | Psyduck | Caótico / control | Jaqueca: recibir daño la carga y libera Confusión en área | Aparece en 2 zonas |
| 12 | Poliwag | Velocista acuático | Hipnosis + se desliza más rápido en el agua y lo mojado | Aparece en 2 zonas; usa el entorno |
| 13 | Growlithe | Perseguidor / guardián | Rastro: marca a un objetivo y lo persigue más rápido | Aparece en 2 zonas |
| 14 | Eevee | Adaptativo | Adaptación: cambia de tipo según el último golpe que recibe | Aparece en 3 zonas; base de sus evoluciones |
| 15 | Seel | Tanque helado | Se desliza en el hielo; Viento Hielo congela el agua | Aparece en el lago; usa el puente de hielo |
| 16 | Geodude | Tanque de roca | Rizo Defensa + Desenrollar que gana velocidad | Primer gimnasio (Plateada) |

Alternativas si se prefiere otra cosa: Caterpie/Weedle (bichos del Bosque Verde), Spearow, Nidoran ♀/♂,
Machop, Abra.
