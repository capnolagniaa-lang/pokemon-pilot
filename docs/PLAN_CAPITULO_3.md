# Plan — Capítulo 3: de Ciudad Celeste al Gimnasio de Ciudad Carmín

Pedido del usuario (2026-10-25): "arrancá la historia del capítulo 3 hasta el gimnasio de Lt. Surge (entrenadores de
FireRed, rival en el S.S. Anne, Corte del capitán, puzzle de los basureros y Surge)". Referencia: la guía de Pokémon
Wiki (Rojo Fuego / Verde Hoja), secciones 7.4 a 8.2. Mismo estilo que los capítulos 1 y 2.

## Recorrido

| # | Lugar | Qué pasa |
|---|---|---|
| 1 | Ciudad Celeste | Con la Medalla Cascada el policía deja la puerta de la casa robada; atrás está el **Rocket ladrón** (Machop 17, Drowzee 17): le ganás y te da la **MT28 Excavar**. |
| 2 | Ruta 5 → Vía Subterránea → Ruta 6 | Azafrán sigue cerrada (garitas). Ruta 6: 6 entrenadores (Nv. 16-20). Guardería "en mudanza". |
| 3 | Ciudad Carmín | Centro, **Tienda** (Antihielo), Club de Fans, casas. El marinero del muelle **pide el Ticket** de Bill. El árbol fino tapa el gimnasio. |
| 4 | S.S. Anne | 16 entrenadores (marineros, caballeros, pescadores, chicas) en los camarotes y la cubierta. **El rival** te frena en el pasillo del 2º piso (Pidgeotto 19, Raticate 16, Kadabra 18 y su inicial evolucionado Nv. 20). **El capitán** mareado: le frotás la espalda y te da la **MO01 Corte**. |
| 5 | Corte | Con la MO01 y la Medalla Cascada, **E frente a un árbol fino** (EnvObject "cortable") → "¿Usás Corte?" → se corta (vuelve a crecer al recargar la zona). |
| 6 | Gimnasio de Carmín | **Puzzle de los basureros**: 15 basureros (5×3); un interruptor al azar y el segundo en uno vecino; si le errás al segundo se reinician. Con los dos se apaga la barrera eléctrica. Caballero Tucker, Marinero Dwayne, Mecánico Benito y **Lt. Surge** (Voltorb 21, Pikachu 18, **Raichu 24 jefe**) en la **arena eléctrica**. Medalla Trueno. Fin del capítulo. |

Fuera de alcance: el barco zarpando (sigue amarrado), Bono Bici/Club de Fans, Caña Vieja, intercambios, la Cueva
Diglett y Azafrán.

## Cómo está hecho
- Entrenadores, diálogos y disparadores (Ticket en el muelle, rival en el barco): `tools/build_story_npcs.py` (bloque
  "Capítulo 3"). Equipos de pret (`trainer_parties.h`).
- **Interacciones con la E** (`StoryDirector.register_interaction`): lo que hay adelante del entrenador. Las usan
  `FieldMoves` (Corte) y `VermilionGymPuzzle` (basureros y barrera; bandera `surge_puerta_abierta`).
- Arena eléctrica: `tools/build_arenas.gd -- --only arena_gimnasio_electrico`.
- Objetos: MO01 Corte (`fetch_items.py`), MT28 Excavar (`data/items/mt28.tres`), Tienda `data/shops/ciudad_carmin.tres`.
- Guía del menú: capítulo 3 (`StoryGuide.STEPS`, `CHAPTERS`).
- Test `--autotest-story-h3` (28 chequeos), vitrina `--showcase-surge`.

## Avance
| Parte | Estado |
|---|---|
| Mapas (sesión de mapas) | ✅ 2026-10-25, commit 0e8da6c2 |
| Historia, Corte, puzzle, Surge (esta sesión) | ✅ 2026-10-25 |
| Kits de los Pokémon nuevos (Tentacool, Machop, Horsea, Voltorb, Raichu…) | heredan o usan su learnset; kit propio pendiente (sesión de kits) |
