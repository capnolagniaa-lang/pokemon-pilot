# Diccionario de prompts para Qwen (escenas, terreno, objetos y luz)

Lo que aprendimos generando gráficos para el juego con ComfyUI local (2026-10-28 a 2026-10-30). Complementa
`docs/COMFYUI.md` (instalación, workflows y efectos de ataque) y `docs/PLAN_TERRENO_PROPIO.md` (el plan de las skins).
**Antes de encolar algo nuevo, mirar acá**; si una prueba enseña algo, sumarlo a la tabla que corresponda.

## Modelo
| Funciona | No funciona |
|---|---|
| **Qwen-Image 2.1** (`qwen_image_2.1_int8_convrot`, 25 pasos, cfg 1): entiende la cámara "desde arriba con el frente de las paredes de cara", respeta la distribución al editar | Qwen-Image viejo (ago. 2025) + LoRAs de pixel art (Master, MOSS, Redmond): casi todo sale en **diagonal/isométrico** aunque se lo prohíba |
| Edición con una imagen de entrada (la maqueta del juego) para todo lo que tiene que calzar con el mapa | Solo texto para algo que tiene que calzar con celdas: inventa la distribución |
| **Qwen-Image 2.1 Turbo** (8 pasos, sigmas de la plantilla oficial): ~75 s por trozo contra ~250 s del normal, misma composición y casi el mismo detalle (el pasto un poco más liso). Por defecto en `repaint_zone.py`; `--quality` usa el normal | |
| Resolución 1536-1792 (sale ~2K): a 1920×1080 y zoom ×2,5 hace falta ~3 px de imagen por px del mundo | 1024: a 1080p se ve borroso |

## Cámara (va en todo prompt de escena u objeto)
**Funciona:**
```
Camera: the classic top-down 2D RPG map view. The ground is seen from directly above; buildings show their roof from above and their front wall facing the viewer straight on. Every edge is perfectly horizontal or vertical. Absolutely no isometric angle, no diagonal lines, no 3D perspective.
```
En edición, además: `The camera stays straight top-down with walls facing the viewer; no isometric angle, no perspective change, no zoom, no crop.`

## Escenas (repintar una zona desde su maqueta)
| Funciona | No funciona |
|---|---|
| `Keep EXACTLY the same layout and composition: every building, every tree, ... stays at exactly the same position, size and outline` → calza a 1-2 px | Pedir "fiel" sin más: sale FireRed en HD, conservador |
| **"Rico"**: `Make it look like a polished modern HD-2D game: much richer detail and texture everywhere, every surface hand painted with many small details, varied grass with darker and lighter patches, small stones, clover and wildflowers scattered in the grass, worn dirt at the doorsteps, weathered roofs with individual tiles, plants and small details around the houses, trees with depth and volume, gentle ambient occlusion at the base of walls and trees.` | Pasarle una imagen de estilo como segunda referencia: casi no influye |
| `Do not add anything that is not in the original image: no new houses, buildings, paths or objects` | Listar "every building, every tree..." en un trozo que es **solo bosque**: inventa casitas en la grilla de árboles |
| Para trozos de puro bosque, un prompt propio: `This area is only a dense forest... Only trees and grass: absolutely no houses, no roofs, no buildings, no paths, no fences, no objects.` | **Repintar sobre algo ya repintado** (la maqueta con la skin puesta): amplifica los errores en cada vuelta. La maqueta sale siempre de los tiles originales (`--clean`) |
| Luz pareja: `Neutral soft daylight from above, no strong cast shadows, no fog, no vignette.` (la luz de la hora va aparte) | |
| Paleta como frase de colores: `Use a natural, harmonious palette: deep natural greens for grass and trees, warm terracotta roofs, cream plaster walls.` | |

**Prompt según lo que tiene el trozo** (`day_prompt` en `tools/repaint_zone.py`, de las celdas: `<maqueta>.cells.json`):
| Trozo | Prompt | Por qué |
|---|---|---|
| Puro bosque (solo árboles y pasto liso) | `FOREST` | con el general inventa casitas en la grilla |
| Mayormente bosque (>60 %) sin edificios | `FOREST_MOSTLY` (+ lo que hay en la franja libre) | con el general raleaba el bosque en un claro y ponía casas |
| Sin edificios (rutas) | `KEEP_WILD` + `WILD_LEGEND` + `RICH_WILD` | `KEEP`/`RICH` nombran casas, techos, puertas → las inventa; sin leyenda, los salientes salen como **cercas** y el pasto alto como **cultivos** |
| Con edificios | `KEEP` + `RICH` | |

Regla general: **no nombrar en el prompt lo que no está en el trozo** (aunque sea para la lista de "mantener") y
**explicarle qué es cada forma de FireRed** que se puede leer mal (línea marrón = saliente, bloque oscuro = pasto alto).

**Costura entre trozos**: mezclar el solapamiento deja objetos fantasma (un buzón doble); cortar derecho se nota. El
**corte de mínimo error** (`tools/repaint_zone.py`) busca el camino por donde los dos trozos más se parecen y rodea
casas y objetos. Solapamiento de 8 celdas.

## Skin pixel ("indie rico", elegida por el usuario 2026-10-30)
`--skin pixel` cambia `RICH`/`RICH_WILD` por `FINISH["pixel"]` (`Make it look like a lush modern indie pixel art game...
dense hand-placed pixel detail, rich color ramps, careful dithering...`). Lo aprendido en Pueblo Paleta, Ruta 1 y Ciudad Verde:
| Pasó | Arreglo (en `repaint_zone.py`) |
|---|---|
| El pasto de pueblo (casi blanco en FireRed) se llenaba de caminos y matas inventadas | `PLAIN_GRASS` ("the large plain pale green areas are open lawn..."), **solo si el trozo tiene >30 % de pasto liso**: en un trozo de bosque abría un claro |
| La plaza pavimentada de ciudad (gris casi blanco) salía como pasto claro | `PAVED_LEGEND` si >5 % de la maqueta es gris casi blanco (`paved_share`: no hay tag de celda que la distinga) |
| La meseta de roca escalonada salía como **techos de tejas**; sus paredes con rayas verticales, como **galpones** | `ROCK_LEGEND` si el trozo tiene celdas de roca (`cells.json` → "roca": categorías roca/pared/acantilado): meseta natural, acantilado con grietas, "not a row of roofs, sheds or greenhouses" |
| Filas de copas de árbol cortadas sobre la meseta (glitch del agrandado ×1,75) | En `ROCK_LEGEND`: son un error, sacarlas y llenar la meseta con rocas, matas secas y arbustos (pedido del usuario) |
| Aun con la leyenda, una semilla puede insistir (galpones en Ciudad Verde 3 y 6 con la 21) | Probar otra semilla en ese trozo (la 33 salió bien) y copiarla como `pintado_<i>.png` + `--only-stitch` |
| De noche, un trozo con 6 celdas de edificio en el borde inventaba casas prendidas (una en el estanque) | `lit(c)`: el prompt con ventanas solo con más de `LIT_MIN_CELLS` (20) celdas de edificio |
| De noche los caminos de tierra quedaban beige o gris lavanda clarito (aunque el prompt diga que no) | `darken_night_paths` después de coser la noche: la tierra de la pintura de día es la máscara (coinciden píxel a píxel) |
| De noche los techos verdes salían marrones (la paleta dice "terracotta roofs") | `Every roof keeps its original color (a green roof stays green), only darker.` en `NIGHT` |
| **Atardecer pintado** (`--dusk`, dos prompts, dos semillas): siempre un filtro amarillo-oliva parejo, pasto mostaza | Descartado: el atardecer lo hace Godot (Daylight + ventanas que se prenden; ver PLAN_TERRENO_PROPIO). `--dusk` queda en la herramienta |
| Ruta 22: las celdas de la meseta tienen el tag "arbol" (son sólidas) → el trozo contaba como bosque y salía bosque encima de la roca | `rock_share` (color rosado-marrón de la maqueta): con >12 % nunca los prompts de bosque, y la leyenda de roca solo por color (>10 %: un techo rosado da ~6 %; las celdas de "roca" también cuentan paredes de garitas, que hacían inventar mesetas en la Ruta 2) |
| Ruta 2: en trozos con garita, la grilla de copitas iguales salía como masa verde lisa o pradera; el pasto alto, como pasto liso | `TREES_LEGEND` (árboles > 30 % descontando la roca: "paint every tree crown individually... Blocks of tall grass are not trees") y `TALL_LEGEND` (pasto alto) en todo trozo que lo tenga |
| De noche, un trozo abierto sin casas usaba el prompt de bosque ("moonlight on the tree crowns") y pintaba árboles sobre el pasto alto | `NIGHT_WILD` (campo de noche, "tall grass stays tall grass"); `NIGHT_FOREST` solo con los prompts de bosque |
| Oscurecer de noche lo claro y sin color (para una franja de pasto claro que quedó gris lavanda) | Dejaba manchas oscuras sueltas: descartado (la franja clara se lee como sendero a la luz de la luna) |
| Subir a ComfyUI con nombre `rep_maqueta_6.png`: una tanda de otra zona pisaba la imagen antes de que corriera el trabajo encolado | El nombre lleva skin y zona |

## Noche (lo que funciona, 2026-10-30)
Pintarla **desde la maqueta en una sola pasada** con el prompt de escena + `It is night: a calm dark blue moonlit night.
Every house window glows warm yellow and casts a soft pool of warm light on the ground right in front of it; doors stay
closed. Cool blue moonlight from above, deep but readable shadows... No street lamps, no fireflies, no stars, no fog, no
sparkles, nothing added.` En trozos de puro bosque, el de noche sin ventanas (`NIGHT_FOREST`).

## Luz por momento del día (re-iluminar lo ya pintado)
> **2026-10-30: re-iluminar los trozos ya repintados de Pueblo Paleta salió mal en todos los casos** (mañana y
> atardecer, cancelado): el pasto y los árboles se deshicieron en puntitos de colores, con y sin palabras "dibujables".
> Lo que sí había funcionado (las referencias `v17_luz_*`) fue re-iluminar una captura **menos detallada a 1024**; a
> ~2K y sobre una pintura muy densa (grilla de árboles, pasto lleno de matas), Qwen-Image 2.1 edición rompe la textura.
> Opciones a probar: pintar cada momento directo desde la maqueta (una sola pasada con la luz en el prompt) o hacer la
> luz por hora en Godot sobre la imagen del mediodía (gradación por hora solo en la capa pintada).

| Funciona | No funciona |
|---|---|
| Hablar **solo de luz, color de la luz y sombras**: dirección del sol, largo de las sombras, color de lo iluminado y de la sombra | Cualquier cosa que se pueda dibujar: **"dew sparkles", "mist", "fog", "fireflies", "glow in the air", "particles"** → Qwen las pinta como puntitos de colores sobre toda la textura (la mañana salió como un campo de flores) |
| `Do not add anything: no new flowers, plants, particles, sparkles or details. Only change the lighting, the color of the light and the shadows:` | |
| Atardecer: `deep orange sun from the left casting long soft shadows to the right, warm rim light on roofs and treetops, purple shade, soft contact shadows and ambient occlusion` (salió muy bien en las referencias) | |
| Noche **pintada desde la maqueta** (una pasada), nunca re-iluminando la pintura de día | Noche con "every house window glows" en un trozo **de puro bosque**: inventa casitas con la ventana prendida entre los árboles → prompt de noche de bosque sin ventanas ni luces |
| Noche: `dark blue moonlit scene, every house window glowing warm yellow and casting a soft pool of light on the ground below it` + `No street lamps added, no fireflies, no stars.` | |

## Objetos sueltos (un sprite por imagen)
| Funciona | No funciona |
|---|---|
| `Exactly one object and nothing else: no other buildings, no scenery, no ground patch under it, no shadow. Isolated in the center of a plain pure white background.` | Objetos "en una escena": salen con suelo, sombra y vecinos |
| El material de la pieza va **en su descripción** ("whitewashed adobe walls, terracotta tile roof") | Una línea de estilo con **cosas** ("village, houses, roofs"): se mete en todas las piezas (la fuente salía como una plaza, la roca como una isla con casas) |
| Estilo = solo colores y técnica: `Color palette: warm sunlit earth tones, terracotta red, ...` | |
| "No flowers" + describir la pieza sin flores ("a leafy green bush made only of leaves") | Solo "No flowers" con una paleta cálida: el arbusto florece igual |
| Tiras que se repiten (salientes): recortar después un pedazo sin "muñequito" | Qwen pone un muñequito en el medio de casi toda tira u objeto chico, aunque diga "no characters" |
| Lo oscuro sobre fondo blanco y aclarar después (el siniestro sale casi negro) | |

## Suelos sueltos (si alguna vez hacen falta)
| Funciona | No funciona |
|---|---|
| Pedirlos como **escena vacía**: `A screenshot of a beautiful HD-2D top-down adventure game, the camera looking straight down at the ground. The view shows only an empty stretch of ground that continues beyond every edge of the image...` y recortar el centro | `A seamless tileable texture ...`: moteado chico sin diseño, a veces con marco o cuadrícula |
| | `magnified tiny pixel art tile, 64 pixels wide`: sale pobre |
| | Suelos generados aparte y objetos aparte: no combinan entre sí (por eso se pasó a repintar la zona entera) |

## Palabras que se dibujan aunque se nieguen
Nombrar algo lo invoca: "no rocket" dibuja un cohete, "no face" caras, "toxic" una calavera, "projectile" balas,
"jet" aviones, Pokémon o juegos por nombre los dibuja. Describir **lo que sí va** y dejar las negaciones genéricas
("no text, no characters, no animals") al final; aun así a veces aparece un bichito (se saca después: `keep_main`).

## Tiempos (RTX 5060 Ti)
Qwen-Image 2.1 a 1792: ~95 s por trozo de 40×34 celdas. Pueblo Paleta: 3 trozos + 9 re-iluminaciones ≈ 20 min.
