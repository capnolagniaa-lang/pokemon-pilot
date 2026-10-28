# Plan — El resto de Kanto: de Ciudad Carmín a la Liga Pokémon

Pedido del usuario (2026-10-28): "Continuá hasta donde puedas para terminar la historia" (a la sesión de mapas) y "sí,
dale" (a esta sesión: historia y mecánicas). Referencia: la guía de Pokémon Wiki (Rojo Fuego / Verde Hoja), secciones 8
a 20. La sesión de mapas importa los mapas (Rutas 7-21 y 23, Túnel Roca, Cueva Diglett, Lavanda, Azulona, Azafrán,
Fucsia, Canela, Calle Victoria, Meseta Añil); esta sesión hace las mecánicas que los mapas solos no resuelven y la
historia de cada tramo.

## Mecánicas nuevas (MO y objetos clave)

| Mecánica | Cómo funciona en el juego | Se consigue | Hace falta |
|---|---|---|---|
| **Surf** (MO03) | E frente al agua → "¿Usás Surf?": el entrenador navega sobre tu Pokémon (el agua deja de ser sólida para él); al pisar tierra baja solo. | Casa Secreta de la Zona Safari | Medalla Alma (Koga) |
| **Fuerza** (MO04) | E frente a una roca grande → "¿Usás Fuerza?"; después, caminando contra la roca la empujás una celda si del otro lado hay lugar. | El guarda de la Zona Safari (le devolvés los Dientes de Oro) | Medalla Arcoíris (Erika) |
| **Poké Flauta** | E frente al Snorlax dormido (Rutas 12 y 16) → lo despertás y pelea (salvaje Nv. 30, se puede atrapar). | Sr. Fuji, en la Torre Pokémon | — |
| **Té** | Los guardias de las garitas de Azafrán te dejan pasar si tenés el Té. | La abuela de la Mansión Azulona | — |
| **Silph Scope** | Sin él, los fantasmas de la Torre Pokémon no se pueden pelear (te frenan). | Giovanni, en el Escondite Rocket | — |
| Flash | Fuera de alcance: el Túnel Roca se ve igual (como con Flash). | — | — |

Todas usan las **interacciones con la E** (`StoryDirector.register_interaction`, como Corte) y banderas/objetos clave.

## Tramos de la historia (capítulos)

| Cap. | Tramo | Hitos |
|---|---|---|
| 4 | Carmín → Lavanda → Azulona | Cueva Diglett (opcional), Ruta 9-10, Túnel Roca, Lavanda (rival en la Torre), Ruta 8/7 (Azafrán cerrada), Azulona: Casino → **Escondite Rocket** (Giovanni, Silph Scope), Té, **Erika** (Medalla Arcoíris) |
| 5 | Torre Pokémon → Fucsia | Fantasmas + Marowak, **Sr. Fuji** (Poké Flauta), Snorlax, Rutas 12-15 (o 16-18), Zona Safari (Surf, Dientes de Oro → Fuerza), **Koga** (Medalla Alma) |
| 6 | Azafrán | Garitas con el Té, **Silph S.A.** (rival, Giovanni, Lapras de regalo), Dojo Karate (Hitmonlee/Hitmonchan), **Sabrina** (Medalla Pantano) |
| 7 | Islas Espuma → Canela | Surf por las Rutas 19-20, Islas Espuma, Canela: Mansión Pokémon (Llave Secreta), **Blaine** (Medalla Volcán) |
| 8 | Liga | **Giovanni** en el gimnasio de Ciudad Verde (Medalla Tierra), rival en la Ruta 22, Ruta 23 + Calle Victoria (Fuerza), **Alto Mando** (Lorelei, Bruno, Agatha, Lance) y el **rival campeón** |

## Cómo se arma
- **Entrenadores automáticos**: los ~150 entrenadores comunes salen de pret (`trainer_parties.h` + los scripts de cada
  mapa) con `tools/fetch_frlg_trainers.py` → `data/source/trainers_frlg.json`; `build_story_npcs.py` los toma para las
  zonas nuevas con frases por clase de entrenador (variantes en rioplatense). Los importantes (líderes, rival, Giovanni,
  Alto Mando, Sr. Fuji) tienen frases propias.
- **Arenas**: una por gimnasio y por miembro del Alto Mando (`tools/build_arenas.gd`).
- Cada capítulo: su test `--autotest-story-hN`, la Guía del menú y su fila en "Avance".

## Avance
| Parte | Estado |
|---|---|
| Mapas (sesión de mapas) | en curso (casi todo Kanto ya en frlg_maps.json) |
| Mecánicas | ✅ 2026-10-28: Surf, Fuerza, Poké Flauta, legendarios (Articuno, Zapdos), Té y guardias (`FieldMoves`, disparadores) |
| Entrenadores | ✅ 2026-10-28: 345 de pret (`tools/fetch_frlg_trainers.py` → `data/source/trainers_frlg.json`), automáticos en las zonas nuevas con frases por clase; líderes, rival (Torre, Silph, Ruta 22, Campeón), Giovanni ×3 y Alto Mando con frases propias |
| Capítulos 4-8 | ✅ 2026-10-28: todos los hitos (ver la tabla de tramos), Guía del menú con los capítulos 4-8 y objetivos del Mapa, tiendas de todas las ciudades, 9 arenas temáticas, ~870 personas (las sin charla propia: frase según cómo se ven y el lugar). Test `--autotest-story-h4` (39) y `--autotest-field` |
| Pendiente | Probarlo jugando entero; Flash (el Túnel Roca no se oscurece), puertas con Tarjeta Llave de Silph, el puzzle de los teletransportadores de Sabrina y las paredes invisibles de Koga (si los mapas no los traen), Mewtwo (Cueva Celeste), Moltres, intercambios, bicicleta, Casino (monedas) |
