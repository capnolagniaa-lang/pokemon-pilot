# La historia: qué hay hoy y qué falta

> Guía para el jugador y el equipo (actualizada el 2026-10-23). El plan técnico, las fases y las decisiones están
> en [`PLAN_HISTORIA.md`](PLAN_HISTORIA.md). Este documento dice **qué se puede jugar hoy** y **qué todavía no**.

## En una línea
Hoy está hecha **la base** de la historia (personas que hablan, curar, entrenadores que te desafían y pelean en
arenas, Brock y la Medalla Roca), pero **todavía no hay ningún evento de la trama**: **no aparece el Profesor Oak**, no
se elige el inicial en el laboratorio, no está el rival ni el Paquete de Oak. Eso es la fase **H-1** en adelante.

## La historia que se va a contar (FireRed, de Pueblo Paleta a la Medalla Roca)
1. **Tu casa**: despertás; abajo está mamá.
2. **Pueblo Paleta**: al querer entrar al pasto alto de la Ruta 1, **Oak te frena** y te lleva al laboratorio.
3. **Laboratorio**: elegís tu inicial entre las 3 Pokébolas de la mesa; el rival (Azul) elige el de tipo ventajoso
   y te desafía (1ª pelea).
4. **Ruta 1**: un empleado de la Tienda te regala una Poción.
5. **Ciudad Verde**: en la Tienda te dan el **Paquete de Oak**; un viejo dormido tapa el camino al norte.
6. **Laboratorio**: le das el paquete a Oak; te da la **Pokédex** y 5 Pokébolas. Dalia (la hermana del rival) te da
   el Mapa. El viejo de Ciudad Verde se despierta y te enseña a atrapar.
7. **Ruta 22**: 2ª pelea contra el rival.
8. **Ruta 2 y Bosque Verde**: 5 Cazabichos te desafían.
9. **Ciudad Plateada**: el museo; un chico no te deja ir a la Ruta 3 sin medalla.
10. **Gimnasio de Plateada**: el Campista Liam y **Brock**, con su Onix como jefe. Ganás la **Medalla Roca**.

## Qué está hecho y cómo probarlo

| Qué | Estado | Cómo probarlo |
|---|---|---|
| **Personas que hablan** (67 de FireRed, en sus lugares reales, con sus sprites) | ✅ | Acercate a alguien y apretá **E**. Ej.: los vecinos de Pueblo Paleta, la gente del Centro Pokémon, el museo. |
| **Enfermeras y mamá curan** | ✅ | Centro Pokémon de Ciudad Verde o de Plateada (E frente a la enfermera, por arriba del mostrador) o mamá en tu casa. Ese lugar queda como "donde volvés si perdés". |
| **Regalo del empleado de la Tienda** (Ruta 1) | ✅ | E al empleado: te da una Poción una sola vez. |
| **Entrenadores que te desafían** (te ven, "¡!", se acercan) | ✅ | Bosque Verde: los 5 Cazabichos. Si pasás por delante de donde miran, te desafían solos. |
| **Combates en arena** (1 contra 1 con cambios) | ✅ | Al desafiarte, fundido y aparecés en una arena. Cambiás con **1-6**. Al terminar volvés donde estabas. |
| **Gimnasio de Plateada: Liam y Brock** | ✅ | Entrá al gimnasio: Liam te ve; a Brock le hablás con E. Arena de roca épica, Onix jefe. Ganarle da la **Medalla Roca** (por ahora es una marca interna: todavía no se muestra en ninguna pantalla). |
| **Perder** | ✅ | Si te quedás sin Pokémon, volvés al último lugar donde te curaron con el equipo curado. |
| **Banderas guardadas** | ✅ | Todo lo de arriba (a quién le ganaste, la medalla, la Poción) se guarda con la partida. |

## Qué NO está todavía (por eso no viste a Oak)

| Qué | Fase | Nota |
|---|---|---|
| **Profesor Oak** (te frena en el pasto, el laboratorio) | **H-1** (la siguiente) | Hoy el inicial se sigue eligiendo en la pantalla del principio. |
| **Elegir el inicial en el laboratorio** | H-1 | Decisión tomada: en la mesa del laboratorio, como en FireRed. |
| **Rival (Azul)**: 1ª pelea en el laboratorio y 2ª en la Ruta 22 | H-1 / H-3 | El sistema de pelea ya existe (E-1). |
| **Paquete de Oak**, Pokédex de regalo, Dalia y el Mapa | H-2 | Hoy la Pokédex está desde el principio. |
| **Viejo de Ciudad Verde** (tapa el camino y te enseña a atrapar) | H-2 | El sistema de bloqueos ya existe (H-0); falta ponerlo. |
| Objetos fijos del Bosque Verde | H-4 | Hoy hay 3-4 objetos al azar por ruta. |
| Chico que bloquea la Ruta 3, MT39, tarjeta de entrenador con medallas | H-5 | |
| Un bot que juegue el capítulo entero (prueba) | H-6 | |
| Mostrar la Medalla Roca en pantalla | H-5 | Hoy es solo una marca interna (`medalla_roca`). |

## Cómo está armada (para el equipo)
- **Banderas** (`GameState.story_flags`): la historia avanza poniendo banderas (`muestra_pocion`, `vencido_<id>`,
  `medalla_roca`...). Se guardan con la partida.
- **Personas** (`data/story/npcs/*.tres`): quién, dónde, qué dice (con condiciones por bandera) y si es entrenador.
  Las arma `tools/build_story_npcs.py` desde los NPC reales de FireRed; los textos son propios, en rioplatense.
- **Disparadores** (`data/story/triggers/*.tres`): pisar un lugar abre una conversación (ej. Oak frenándote).
  Todavía no hay ninguno puesto (llegan con H-1).
- **Bloqueos**: una persona con `hide_if` desaparece cuando se pone su bandera (ej. el viejo de Ciudad Verde).
- **Combates**: `TrainerBattle` lleva a la arena (`data/arenas/`); ver `PLAN_ENTRENADORES.md`, "E-1".
- Pruebas: `--autotest-story` (H-0) y `--autotest-arena` (E-1).
