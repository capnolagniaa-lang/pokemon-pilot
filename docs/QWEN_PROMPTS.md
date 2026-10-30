# Diccionario de prompts para Qwen (escenas, terreno, objetos y luz)

Lo que aprendimos generando gráficos para el juego con ComfyUI local (2026-10-28 a 2026-10-30). Complementa
`docs/COMFYUI.md` (instalación, workflows y efectos de ataque) y `docs/PLAN_TERRENO_PROPIO.md` (el plan de las skins).
**Antes de encolar algo nuevo, mirar acá**; si una prueba enseña algo, sumarlo a la tabla que corresponda.

## Modelo
| Funciona | No funciona |
|---|---|
| **Qwen-Image 2.1** (`qwen_image_2.1_int8_convrot`, 25 pasos, cfg 1): entiende la cámara "desde arriba con el frente de las paredes de cara", respeta la distribución al editar | Qwen-Image viejo (ago. 2025) + LoRAs de pixel art (Master, MOSS, Redmond): casi todo sale en **diagonal/isométrico** aunque se lo prohíba |
| Edición con una imagen de entrada (la maqueta del juego) para todo lo que tiene que calzar con el mapa | Solo texto para algo que tiene que calzar con celdas: inventa la distribución |
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

**Costura entre trozos**: mezclar el solapamiento deja objetos fantasma (un buzón doble); cortar derecho se nota. El
**corte de mínimo error** (`tools/repaint_zone.py`) busca el camino por donde los dos trozos más se parecen y rodea
casas y objetos. Solapamiento de 8 celdas.

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
