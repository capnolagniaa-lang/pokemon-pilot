# Plan — Capítulo 2: de Ciudad Plateada al Gimnasio de Ciudad Celeste

Pedido del usuario (2026-10-24): "Sigan implementando hasta el Gimnasio Pokémon de Ciudad Celeste", con la guía de
Pokémon Wiki (Rojo Fuego / Verde Hoja) como referencia, y permiso para decidir ("te doy permiso para lo que se te
ocurra"). Sigue el mismo estilo del capítulo 1 (`docs/PLAN_HISTORIA.md`): mapas reales de FireRed, entrenadores con
los equipos de FireRed (pret: `trainer_parties.h`), frases propias en rioplatense, banderas de historia y autotests.

## 1. Recorrido (como en FireRed)

| # | Lugar | Qué pasa |
|---|---|---|
| 1 | Ruta 3 (se abre con la Medalla Roca) | 8 entrenadores (Cazabichos, Chicas, Jóvenes; Nv. 9-14). Salvajes: Pidgey, Spearow, Nidoran♀/♂, Jigglypuff, Mankey. |
| 2 | Ruta 4 (oeste) | **Centro Pokémon de la Ruta 4** (el vendedor de Magikarp: $500, Nv. 5). Salvajes: Rattata, Spearow, Mankey, Ekans, Sandshrew. |
| 3 | Mt. Moon (P1, S1, S2) | Cueva con Zubat, Paras, Geodude y Clefairy (raro). Entrenadores (Cazabichos, Chicas, Supernecios, Montañero, Joven). **Team Rocket** (4 soldados) y el **Supernecio Miguel**: al ganarle elegís **Fósil Hélix o Fósil Domo**. Objetos: Piedra Lunar, Caramelo Raro, Cuerda Huida, MT09... |
| 4 | Ruta 4 (este) | Bajada hacia Ciudad Celeste (salientes: no se vuelve). Ekans/Sandshrew. |
| 5 | Ciudad Celeste | Centro, **Tienda** (Poké Ball, Superpoción, Poción, Antídoto, Antiparalizador, Despertar, Antiquemar), casa robada con guardia (bloquea), Slowbro que tapa el árbol. **3ª pelea con el rival** al ir al Puente Pepita (Pidgeotto 17, Abra 16, Rattata 15, inicial 18). |
| 6 | Ruta 24 (Puente Pepita) | 5 entrenadores en fila (Nv. 10-18) + premio (Pepita) + **soldado Rocket** (Ekans 15, Zubat 15). |
| 7 | Ruta 25 → Casa de Bill | Entrenadores; **Bill convertido en Clefairy** (el gag del Separador): te da el Ticket del barco (objeto clave, para más adelante). |
| 8 | **Gimnasio de Ciudad Celeste** | Nadador (Horsea 16, Shellder 16) y Dominguera (Goldeen 19); **Misty**: Staryu 18 + **Starmie 21 (jefa)**. Medalla Cascada (`medalla_cascada`) + MT03 Hidropulso. Fin del capítulo. |

Fuera de alcance por ahora: Ruta 5 en adelante, la casa robada por dentro (MT28 Excavar) y Corte.

## 2. Quién hace qué (sesiones en paralelo)

| Parte | Sesión | Qué entrega |
|---|---|---|
| **M — Mapas** | "Editor de mapas interactivo" (su área: zonas, importación FRLG, encuentros) | Importar con el pipeline de FireRed: Ruta 3, Ruta 4, Mt. Moon (1F, B1F, B2F), Ciudad Celeste + interiores (Centro, Tienda, Gimnasio, casas, casa robada), Centro de la Ruta 4, Ruta 24, Ruta 25 y Casa de Bill; conexiones y puertas; tablas de salvajes de FireRed. Sin pisar lo que ya está editado. |
| **K — Kits y estilos** | "Codigo de kits" | `FightStyle` (`build_fight_styles.py`) para los Pokémon nuevos del capítulo y **kit de jefa para Starmie** (como Onix con Brock) + Staryu. |
| **H — Historia y entrenadores** | esta sesión ("Animaciones extra…") | Entrenadores y diálogos (`build_story_npcs.py`), Team Rocket, fósiles, rival 3, Bill, guardias/bloqueos, Tienda de Celeste y Centro de la Ruta 4 (`data/shops`), **arena de agua de Misty** (`build_arenas.gd`), objetos nuevos (Fósiles, Pepita, Piedra Lunar, Caramelo Raro, Superpoción ya existe), medalla y autotest del capítulo. |

Orden: M primero (la historia ubica a las personas en los mapas importados); H arranca en paralelo con lo que no
depende de los mapas (arena de Misty, objetos, equipos y textos) y se engancha a los mapas cuando estén. K en
paralelo.

## 3. Fases de H

| Fase | Contenido |
|---|---|
| **H-7** | Datos sin mapa: objetos nuevos, Tienda de Celeste, arena de agua de Misty, equipos de FireRed y frases. |
| **H-8** | Ruta 3 + Ruta 4 + Mt. Moon: entrenadores, Team Rocket, fósil a elección, objetos fijos. |
| **H-9** | Ciudad Celeste: rival 3, Puente Pepita (5 + Rocket), Bill. |
| **H-10** | Gimnasio de Celeste: Nadador, Dominguera, **Misty con Starmie jefa**, Medalla Cascada. |
| **H-11** | Autotest del capítulo (`--autotest-story-h2`) y guía del menú actualizada. |

### Avance
| Fase | Estado |
|---|---|
| H-7 | ✅ 2026-10-24: objetos (Caramelo Raro sube un nivel, Piedra Lunar, Trozo Estrella, Pepita, fósiles, Ticket), Tienda de Celeste, arena de agua de Misty (`build_arenas.gd -- --only arena_gimnasio_agua`), equipos y frases |
| H-8 | ✅ 2026-10-24: Ruta 3 (8), Mt. Moon (7 + 4 Rocket + Miguel), fósil a elección (`fosil_elegido`), objetos fijos de la cueva, Centro de la Ruta 4 con el Magikarp de $500 (`Mart.sell_magikarp`) |
| H-9 | ✅ 2026-10-24: rival en el norte de Celeste (disparador `rival_celeste`), Puente Pepita (5 + Rocket: la Pepita es el premio de ganarle), Ruta 25 (9), Bill-Clefairy → Ticket |
| H-10 | ✅ 2026-10-24: Nadador Luis, Dominguera Diana y Misty (Staryu 18 + Starmie 21 jefa) en la arena de agua; Medalla Cascada |
| H-11 | ✅ 2026-10-24: `--autotest-story-h2` (21 chequeos) y la Guía del menú con el capítulo 2. Falta: probarlo caminando entero (H-6 del capítulo 1, el bot) |
| M | ✅ 2026-10-24 (sesión de mapas, commit 50f8bd05): Ruta 3, Ruta 4 + Centro, Mt. Moon (3 plantas), Ciudad Celeste + interiores, Ruta 24, Ruta 25 y Casa de Bill, con puertas y salvajes de FireRed (`import_frlg_maps.gd -- --only-new`); `--autotest` camina hasta el Gimnasio de Celeste |
| K | ✅ 2026-10-24: kits de Staryu y **Starmie jefa** (`build_kits_v5.py`, firma Núcleo, `--autotest-kits-v5`) y `FightStyle` de 33 Pokémon del capítulo (`build_fight_styles.py`). Los demás Pokémon nuevos todavía sin kit propio |
