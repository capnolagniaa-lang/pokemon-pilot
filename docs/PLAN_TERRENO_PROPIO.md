# Plan: terreno propio hecho con IA (fases T)

Pedido del usuario (2026-10-30): dejar de depender de los tiles de FireRed y generar con Qwen (ComfyUI local) un terreno
**propio, con identidad**, sin copiar a Pokémon ni a otro juego: biomas, bosque, cuevas, edificios y pisos de pueblos y
ciudades. Este documento es el plan; las pruebas que lo respaldan están en "Pruebas" (abajo) y las decisiones que faltan,
en "Para decidir".

## Opinión corta
Sí, vale la pena, con una condición: **hacerlo todo junto con una identidad, no de a pedazos**. El 2026-10-28 se probó
cambiar solo el árbol y el pasto alto de FireRed por unos hechos con IA y no gustó (`docs/COMFYUI.md`): un árbol nuevo
entre tiles viejos choca. Un juego de piezas propio, con una paleta y una luz fijas, no tiene ese problema.

Lo que Qwen hace bien y lo que no (ver "Pruebas"):
- **Bien**: objetos enteros (casas, árboles, rocas, fuentes, cercas) sobre fondo blanco, escenas completas como
  referencia de estilo, texturas "de material" (pasto, tierra, empedrado, madera) a buena escala.
- **Mal**: tiles exactos de 16 px, que empalmen solos y que tengan las 9 o 47 piezas de borde. Eso lo hace el código.

Por eso la idea es **Qwen para la materia prima, código para el encastre**.

## Cómo se arma (la parte técnica)
### 1. Suelo = materiales, no 8.727 metatiles
FireRed tiene 8.727 metatiles usados (paredes, suelos, edificios, muebles...). No hay que redibujarlos: el suelo pasa a
ser un puñado de **materiales** por bioma (pasto, pasto corto, tierra, arena, empedrado, baldosa, madera, piso de
cueva, agua...), cada uno una textura que se repite sin costura (64-128 px, hecha con Qwen y "cerrada" con código).
Cada celda dice qué material tiene y un **shader de mezcla** dibuja los bordes entre materiales con un contorno
orgánico (ruido + máscara por celda), así no hace falta dibujar piezas de transición para cada par. El autotile
3×3 de hoy (`ZoneBuilder.autotile_piece`) queda para lo que tiene borde duro (acantilados, salientes, paredes de cueva).

### 2. Objetos = sprites enteros
Edificios, árboles, rocas, cercas, carteles, fuentes, faroles y muebles van como **sprites enteros** con su "pie"
(celdas sólidas, puerta), igual que `ExtraBuilding` hoy (`data/world/extra/buildings/`). Qwen los dibuja de a uno
sobre fondo blanco; `tools/prop_from_image.py` ya los recorta, achica y pasa a paleta. Nombres, tamaños y celdas los
decidimos nosotros (esa es la ventaja que decías: mapas más fáciles de dibujar, piezas con nombre).

### 3. Mapas: traducir los que ya están, no redibujar 234 zonas
Un **traductor** lee cada zona actual y la pasa al juego de piezas nuevo:
- celda → material, por la categoría y el rol de su metatile (`catalog.json`, `tile_roles.tres`: pasto, camino,
  arena, agua, árbol, piso de ciudad, piso de cueva...);
- edificio → sprite nuestro del mismo tamaño y con la puerta en el mismo lugar (los edificios ya se reconocen por sus
  celdas: `data/world/stamps.json`, 78 sellos);
- árboles, rocas, cercas → sus sprites; la colisión, los tags, las puertas, los salvajes y la historia **no cambian**.

Después se retoca a mano con el editor de mapas. Ojo: las zonas importadas las maneja otro agente; el traductor no las
pisa: arma una capa nueva aparte (o zonas nuevas) y se coordina antes de reemplazar nada.

### 4. Interruptor
Como el `TilePack` del 2026-10-28: un ajuste "Estilo del mundo: FireRed / propio" para comparar y volver atrás al
instante mientras se arma. El juego queda siempre jugable.

### 5. Que combine con los personajes
Los Pokémon (PMD) y las personas (FireRed) **se quedan**. La paleta y el contorno del terreno se eligen para que
combinen con ellos (se prueba poniendo los sprites encima de cada prueba). Escala: 1 px del dibujo = 1 px del juego,
celda de 16 px.

## Fases
| Fase | Qué | Listo cuando |
|---|---|---|
| **T-0** | Identidad: elegir dirección de arte con pruebas (esta tanda) y fijar una **hoja de estilo**: paleta (32-48 colores), contorno, luz, escala, prompts base. | El usuario elige y quedan los prompts en `docs/COMFYUI.md` |
| **T-1** | Herramientas: `tools/terrain_material.py` (textura de Qwen → material sin costura, a escala y en paleta) y prompts/plantillas para objetos (`prop_from_image.py`). Hoja de contacto para revisar. | Pasto, tierra y empedrado sin costura a la vista |
| **T-2** | Bioma 1 **pradera y pueblo**: materiales (pasto, pasto alto, tierra, arena, agua, flores) + objetos (3-4 árboles, arbustos, cercas, rocas, casa chica, Centro, Tienda, faroles, cartel). | Hoja de contacto aprobada |
| **T-3** | Render por materiales (shader de mezcla) + traductor para **Pueblo Paleta, Ruta 1 y Ciudad Verde** + interruptor. | Se camina por las 3 con el estilo nuevo, mismas colisiones y puertas (autotest) |
| **T-4** | **Bosque**: suelo de bosque, árboles densos que encastran (borde de bosque), troncos, hongos, luz filtrada. Bosque Verde. | Bosque Verde traducido |
| **T-5** | **Cuevas**: piso, paredes y acantilados (autotile de borde duro), escaleras, cristales, charcos. Mt. Moon. | Mt. Moon traducida |
| **T-6** | **Ciudades e interiores**: pisos (baldosa, madera, alfombra), paredes, edificios grandes (gimnasios, edificios altos), muebles. | Una ciudad grande + sus interiores |
| **T-7** | El resto de Kanto con el traductor, revisando zona por zona. | Todo con el estilo nuevo |

## Pruebas (2026-10-30)
Scripts y registro de prompts en el scratchpad de la sesión (`t2i.py`, `edit.py`, `t21.py`, `boceto.py`, `prompts.md`);
pasarlos a `tools/comfy/` en la T-1.

| Tanda | Modelo | Resultado |
|---|---|---|
| 1-2 | Qwen-Image (ago. 2025, Q4) + LoRA pixel art (Master / MOSS / Redmond), solo texto | Lindo de estilo, pero **casi todo en diagonal (isométrico)** aunque se lo prohíba; los "pisos" salen como un cuadro con marco y cuadrícula; a veces mete caritas. Árboles sueltos sobre blanco: bien |
| 3 | Qwen Edit 2511 + boceto plano de colores | **Perspectiva correcta**, pero copia la pobreza del boceto y la línea de estilo pisa la escena (la cueva salía con casas) |
| 4 | **Qwen-Image 2.1** (sept. 2026, 7B, int8) edición: boceto + imagen de estilo + leyenda de colores | Perspectiva correcta, limpio, todo en su lugar, pero sobrio (la imagen de estilo casi no influye: A y C salen iguales) |
| 5 | **Qwen-Image 2.1 solo texto** con cámara y estilo descritos | **El mejor**: perspectiva correcta, hermoso y creativo (pueblo de campo con ceibos y jacarandás, pueblo de cuento, bosque, cueva, ciudad, interior). 44 s por imagen |

Prompt de cámara que funciona con 2.1 (va en todos):
```
Camera: the classic top-down 2D RPG map view. The ground is seen from directly above; buildings show their roof from above and their front wall facing the viewer straight on. Every edge is perfectly horizontal or vertical. Absolutely no isometric angle, no diagonal lines, no 3D perspective.
```
Prompt de estilo base:
```
Beautiful hand-crafted pixel art with crisp hard-edged pixels, rich but harmonious palette, clean dark outlines, soft shading, lots of charming small details and texture variation, warm afternoon light. No text, no characters, no animals, no faces, no UI.
```
Lecciones:
- **Qwen-Image 2.1 > Qwen-Image viejo + LoRAs** para esto: entiende la cámara. Los LoRAs de pixel art viejos empujan a lo isométrico.
- **Escala**: en una escena entera las casas salen de ~20 "píxeles" de ancho (muy chicas para el juego). Para el juego: **un objeto por imagen** (sale grande y con detalle; achicado a su tamaño en celdas queda bien al lado de los personajes: maqueta con Red y Charmander) y **materiales** recortados o pedidos aparte. Las escenas enteras sirven de referencia de estilo y de "lámina" para elegir.
- El boceto sirve cuando hace falta una forma exacta (una casa de 5×4 con la puerta en el medio); dibujarlo con proporciones lindas (techo más bajo, alero, jardín) porque las copia.
- Modelos bajados (ComfyUI): `qwen_image_2.1_int8_convrot`, `qwen_image_2.1_turbo_int8_convrot`, `qwen3vl_8b_int8_convrot` y `_w4a8`, `qwen_image_2.1_vae_bf16`, `qwen_image_2.1_fun_controlnet_union_int8_convrot` (de Comfy-Org/Qwen-Image-2.1) y el LoRA PixelArt Redmond (artificialguybr, Apache-2.0). Workflows oficiales en las plantillas de ComfyUI (`image_qwen_image_2_1_*`).

## Primera prueba en el juego (T-3 en la zona de pruebas, 2026-10-30)
- **Zona de pruebas** (`pruebas_pueblo`, `pruebas_bosque`, `pruebas_cueva`; la armó la sesión del editor de mapas con
  `tools/build_test_zone.gd`): se llega con `ir pruebas` en la consola de GM (Ctrl+Shift+G).
- **`StyleOverlay`** (`scripts/world/style_overlay.gd`): dibuja una zona de pruebas con un paquete leyendo sus celdas
  (rol/tags → material; sellos `PalletTown_5_3` → casa/almacén y `VermilionCity_25_32` → fuente; `tree_cells` → árboles;
  metatiles 214/215 → cercas; pasto alto; boca de cueva sobre la puerta a una cueva). Esconde las capas de tiles; la
  colisión, las puertas y los tags siguen siendo los de la zona. Suelo: `shaders/style_ground*.gdshader` (cuerpo en
  `style_ground.gdshaderinc`): textura por material + borde orgánico con ruido + borde oscurecido.
- **Paquetes** en `art/estilos/<paquete>/`, los arma `tools/style_pack.py` desde las salidas de ComfyUI (tabla `PACKS`:
  pieza → imagen). `campo`, `cuento`, `siniestro` (pixel art, 16 px por celda, en paleta) y **`*_hd`** (4 veces más
  píxeles por celda, sin paleta; se dibujan a 1/4 de escala y con filtro suave). Comando de GM `estilo <paquete|fire>`.
- **Decisión (usuario, 2026-10-30): el objetivo es 2D-HD**, no pixel art de 16 px: achicar las imágenes de Qwen 6-8
  veces perdía justo el detalle que las hacía lindas ("no se ven en HD"). Con los paquetes `_hd` se ve el detalle real.
  La idea a futuro: redibujar todo el mundo de FireRed así, zona por zona, con el mismo traductor.
- Test `--autotest-style`, vitrina `--showcase-style` (cada paquete en el pueblo, el bosque y la cueva).
- Lecciones de prompts: el estilo describe **solo colores y técnica** (si dice "pueblo, techos de tejas" mete casas en
  todo: la fuente salía como una plaza, la roca como una isla con casas); el material va en la descripción de cada pieza;
  "exactly one object, no ground patch"; los suelos "only the ground surface, nothing standing on it". "No animals" a veces
  se ignora (un bichito al lado de la casa: `style_pack.py` se queda con la mancha más grande). El blanco encerrado
  (entre ramas) se saca en una segunda pasada. El siniestro sale casi negro: `GAMMA` 0,7 en sus objetos.
- Falta: pasto mejor (pruebas "en bloques" en curso), agua y roca de verdad (corregidos en cola), sombras de FireRed que
  todavía se ven debajo de las casas, interiores de las casas, y personajes HD (más adelante).

## Para decidir
- **Identidad**: "campo sudamericano" (terracota, encalado, ceibos, jacarandás), "cuento" (cabañas con techo de musgo,
  arroyos, faroles) o una mezcla (cada región/bioma con su carácter).
- Si el estilo nuevo reemplaza a FireRed en todo Kanto o solo en zonas nuevas.
