# Plan: terreno propio hecho con IA (fases T)

> **Estado (2026-10-30)**: el enfoque de **piezas sueltas** (todo lo de abajo hasta "Alternativa") se probó y **se
> volvió atrás** a pedido del usuario: las piezas generadas por separado no combinan entre sí. El código de esa prueba
> está en los commits 4aebebbe..4f49b808 (StyleOverlay, `tools/style_pack.py`, zona de pruebas). Se conservó lo global:
> luz por hora (tinte de sombras, niebla, gradación en dos tonos, arco del sol), `camera_zoom` y el comando `ir`.
> **Próximo paso: "Alternativa: repintar la zona entera".**

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

## Render HD-2D (2026-10-30, segunda pasada)
Referencia: la captura del pueblo HD pasada por Qwen-Image 2.1 ("relight" a mediodía, mañana y atardecer; prompts en el
registro de la sesión). Lo que se reprodujo en Godot:
- **Suelos como "escena vacía"** (tanda 18): pedir "a screenshot of an HD-2D game looking straight down at an empty
  meadow/road/square/lake" da materiales con el mismo acabado que los objetos; `style_pack.py` recorta el centro
  (`SCENE_CROP`, evitando el muñequito del medio y los bordes) y corrige el tono (`TONE`: Qwen los saca claros y
  amarillos, y el día del juego los lava). Pedirlos como "seamless texture" daba moteado chico sin diseño.
- **Sombras de los objetos** (`SunShadow.offset_mode` + `soft`): silueta corrida hacia donde caen las sombras según
  la altura del sprite (`OFFSET_K`), apenas inclinada, dibujada 5 veces corrida (borrosa). Los personajes siguen con la
  acostada. Ojo: con `CanvasTexture` (relieve) la sombra salía clara: se usa `diffuse_texture`.
- **Sombra de contacto** al pie de cada objeto (mancha radial, `CONTACT_*`).
- **Relieve**: `<pieza>_n.png` (mapa de normales desde la silueta suavizada + brillo, `make_normal`) + un
  `DirectionalLight2D` (`StyleSun`, solo sobre `LIGHT_BIT`) que sigue al sol de DayNight. Es sutil; con mucha energía
  los sprites pasan de blanco y el glow (HDR) lava toda la pantalla: `SUN_ENERGY` 0,3 y `LIT_BASE` 0,72.
  `--sun-energy <x>` para calibrar en la vitrina.
- **Gradación en dos tonos** (`post_process.gdshader`, `split`): lo oscuro recibe el tinte opuesto al de la hora
  (sombras frías con luz cálida).
- **Corrección (misma tarde)**: la sombra "desplazada" estaba mal (corría la silueta entera a media altura: la copa
  del árbol flotaba al costado). Para una vista desde arriba lo correcto es la proyección "acostada" de los personajes
  (cada punto cae al piso según su altura), más larga (`flatten_k` 0,5) y borrosa (5 dibujos corridos). Y las sombras no
  se veían por el **y-sort de la zona**: el suelo (ColorRect) se agregaba después de las casas y las sombras estaban en
  (0,0); ahora el suelo va primero (`move_child`) y cada sombra/contacto se pone en la posición de su objeto, un pelo
  por encima. `--shadow-debug` las pinta de rojo opaco e imprime dónde caen.
- El arco del sol pasa un poco a la izquierda del centro (`sun_at`: 0,36) para que a mediodía las sombras caigan abajo
  a la derecha y no justo debajo (donde no se ven); `SHADOW_MIN` 1,0. Horas con más carácter en `KEYS` (7:30 fría,
  10 y 15 de día, 17 y 18:30 doradas) y `split` 0,9. El suelo lleva manchas grandes de luz y sombra (ruido en el shader).
- **Tercera pasada (más dramático, pedido del usuario)**: `KEYS` tiene dos columnas más: **tinte de las sombras**
  (lo oscuro en la gradación de dos tonos: frío a la mañana, violeta al atardecer) y **niebla** (post-procesado:
  niebla baja animada, fuerte a las 6-7:30 y al anochecer). Sombras de los objetos más largas (`flatten_k` 0,65), con
  alfa entero y hasta ×1,25 más densas con el sol bajo; sombra de contacto más ancha. Pasto calibrado midiendo el mismo
  pasto en el juego y en la referencia (scratchpad `calib2.py`: cajas verdes en los dos → proporción → `TONE`).
- Pendiente para acercarse más a la referencia: verdes más profundos y saturación por hora (hoy el tinte cálido de las
  8 y las 17 deja el pasto lima), empedrado con más variación de color, relieve más marcado (quizá pedirle a Qwen
  versiones iluminadas de izquierda/derecha de cada objeto), y los interiores.

## Pueblo Paleta y Ruta 1 reales (2026-10-30, primera prueba del traductor)
- `StyleOverlay.REAL_ZONES`: zonas reales de Kanto que ya se dibujan con el paquete (sin tocar sus escenas). Traductor
  por **categoría del catálogo** (`CAT_MATERIAL`, `CAT_STRIP` cercas/salientes, `CAT_PIECE` carteles) + sellos
  (`STAMP_PIECES`: casa, laboratorio, fuente; `STAMP_TREES`: pinos en hilera) + metatiles sueltos que el catálogo no
  clasifica bien (`FENCE_METATILES`, `SIGN_METATILES`). `tools/style_audit.gd -- <zona>` lista qué usa una zona.
- Piezas nuevas (tanda 19-22): laboratorio, pino, cartel, buzón, saliente (tira; `CROP_X` se queda con la izquierda
  porque Qwen mete un muñequito en el medio), flores. Referencias de Qwen de las dos zonas (`v20_ref_*`).
- Ajuste de partida **`camera_zoom`** (campo de visión; por defecto 2,5, antes 3 fijo), pedido del usuario.
- **Resultado y duda del usuario**: funciona (colisión, puertas y todo igual), pero armar la zona con piezas generadas
  por separado da texturas de densidad y estilo distintos (suelo liso, carteles, salientes, pasto alto): "queda todo
  bastante raro". Ver "Alternativa: repintar la zona entera" abajo.

## Alternativa: repintar la zona entera (propuesta, 2026-10-30)
Las referencias que más gustaron (`v17_luz_*`, `v20_ref_*`) salen de darle a Qwen una escena entera: pinta todo junto,
con la misma mano, luz y densidad. En vez de componer piezas sueltas:
1. Render "maqueta" de la zona desde sus celdas (lo que ya hace StyleOverlay, o los tiles de FireRed tal cual) en trozos
   del tamaño de una pantalla con solapamiento.
2. Qwen-Image 2.1 edición repinta cada trozo ("misma distribución, HD-2D, luz neutra"), con la misma semilla y una
   imagen de estilo fija; se cosen los trozos mezclando el solapamiento.
3. La imagen de la zona es el suelo; lo que tapa al jugador (techos, copas) se recorta de la misma imagen con máscaras
   que salen de las celdas (sellos, árboles) y va como capa con y-sort. Sombras, luz y hora siguen siendo de Godot.
Riesgos a probar: que no corra el dibujo (colisiones alineadas), las costuras entre trozos y que un mismo edificio se
vea igual en dos pueblos. Cambiar un mapa = repintar sus trozos.

## Repintado: primera prueba (2026-10-30)
- **Maqueta limpia**: `-- --overview --overview-rect x,y,ancho,alto --clean` (en `autotest.gd`): un pedazo del mundo
  en celdas, sin personajes, sombras, luces, partículas ni hora. Trozo de 40×22 celdas a zoom 2 = 1280×720.
- **Repintado**: Qwen-Image 2.1 edición, la maqueta como imagen 1, resolución 1536 (sale 2048×1152, ~95 s por trozo).
  **2K hace falta**: a 1920×1080 y zoom ×2,5 cada píxel del mundo ocupa 3,75 px de pantalla; 2K da 3,2 px por píxel
  del mundo (1K daría 1,6: borroso).
- **Posición**: casas, laboratorio, cerca y flores quedan sobre los bordes de la maqueta con 1-2 px de diferencia
  (la colisión sirve). El medidor automático por bloques exagera porque compara las manchas del pasto.
- **Prompt que mejor anduvo** ("rico", semilla 21): "Repaint this top-down 2D RPG screenshot as a beautiful HD-2D game
  scene. Keep EXACTLY the same layout and composition [...] Make it look like a polished modern HD-2D game: much richer
  detail and texture everywhere [...] Neutral soft daylight from above, no strong cast shadows [...]" + paleta natural.
  Sale con tejas, pasto con matas y piedritas, caminitos de tierra en las puertas, plantas, árboles con volumen. El
  "fiel"/"natural" sin "rico" sale como FireRed en HD (conservador).
- **Costura**: mezclar el solapamiento deja objetos fantasma (buzón doble); cortar derecho se nota. **Corte de mínimo
  error** (programación dinámica dentro del solapamiento de 8 celdas, mezcla de 3 px): el corte rodea casas y objetos y
  pasa por el pasto; no se ve.
- Scripts (scratchpad de la sesión, pasar a `tools/` en la fase siguiente): `t21.py` (encola Qwen 2.1), `alinea.py`
  (bordes de la maqueta sobre el repintado), `cose_corte.py` (costura).
- Próximo: Pueblo Paleta entero (6 trozos) cosido y metido en el juego como capa de suelo, con techos y copas
  recortados por máscara para el y-sort; ver cómo se ve caminando, de día y de noche.

## Skins del mundo: Pueblo Paleta en el juego (2026-10-30)
- **Skins** (idea del usuario): `art/skins/<skin>/<zona>.png` + `skin.json` (nombre). Ajuste de partida `skin`
  ("clasico" = tiles de FireRed; por defecto "hd"), en Ajustes del juego → "Skin del mundo". `PaintedZone`
  (`scripts/world/painted_zone.gd`, World la agrega a cada zona): dibuja la imagen en lugar de Ground/Water/Foliage/
  TreeShadows/Overhead, y recorta techos y copas de la misma imagen en las celdas que tienen algo en `Overhead` (mismo z:
  te tapan al pasar por detrás). Cambiar de skin se ve al instante. Zona sin imagen en esa skin = tiles.
- **`tools/repaint_zone.py <proyecto> <zona> [--skin hd] [--forest 0] [--redo 0] [--seed 21]`**: la zona en una fila de
  trozos de 40 celdas × el alto entero (solape 8), maqueta limpia de cada uno con Godot (`--overview --overview-rect
  --clean`, que usa la skin clásica: si no, se repinta sobre el repintado anterior), Qwen-Image 2.1 a `--size 1792`,
  costura de mínimo error. Trabajo en `out/repintado/<zona>/` (ignorado por git y por Godot). Pueblo Paleta: 3 trozos,
  ~8 min, 4685×1659 (3 px de imagen por px del mundo).
- **Trozos de puro bosque** (`--forest`): con el prompt general Qwen inventa casitas en una grilla de árboles; el
  prompt de bosque ("only trees and grass: absolutely no houses...") lo arregla.
- **Luces y sombras**: siguen siendo de Godot (hora, niebla, gradación, ventanas, faroles, sombras de personajes) y
  calzan porque salen de las celdas. La pintura trae su oclusión suave; por eso las sombras del mapa en zonas con skin
  van más claras y con el borde suavizado (`ZoneShadows.PAINTED_ALPHA` 0,6, `soften` 5 px en `sun_shadows.gdshader`).
- Test `--autotest-repaint`, vitrina `--showcase-repaint`.
- Próximo: Ruta 1, interiores (otra cámara: paredes), agua animada sobre la pintura, pasto alto (recortar el pedazo
  de la pintura para tapar las piernas).

## Workflow vigente (acordado con el usuario 2026-10-30)
**Escena pintada de fondo + capa de sprites encima.** El mapa de celdas (zonas de FireRed) es la fuente de la verdad;
la pintura es un resultado que se regenera, nunca se retoca a mano.
1. **Pintado (fondo, por zona)**: suelo, caminos, casas, edificios, cercas, carteles fijos, árboles que no se cortan.
   `tools/repaint_zone.py <proyecto> <zona> [--forest i] [--redo i]`: maqueta limpia de cada trozo (tiles originales, sin
   personajes ni objetos interactivos) → Qwen-Image 2.1 → costura de mínimo error → `art/skins/<skin>/<zona>.png` + .json
   con la receta (prompt, semilla). Revisar cada trozo apenas sale y rehacer los que fallan con `--redo`.
2. **Capa de arriba**: lo que se mueve o se usa. Agua y pasto alto = la pintura con un **shader encima** solo en sus
   celdas (ondas, vaivén) + el frente del pasto que tapa las piernas recortado de la pintura. Árboles de Corte, rocas de
   Fuerza, barreras, Pokébolas, personas = sprites sueltos (más adelante, generados con la pintura de la zona como
   referencia de estilo). Fuentes, cascadas: animación chica aparte.
3. **Luz**: gradación de Godot (la de la hora) sobre la pintura del día + una **versión de noche pintada desde la
   maqueta** (ventanas prendidas) que se funde al oscurecer. Re-iluminar la pintura con Qwen no funciona (rompe la
   textura). Con skin no se dibujan las sombras del mapa, las ventanas ni los faroles calculados; sí las de personajes.
4. **Editar un mapa** = repintar los trozos que cambiaron (huella de la maqueta, a automatizar).
**Hecho en Pueblo Paleta (2026-10-30)**: noche pintada desde la maqueta (`--night`; bosque con su propio prompt sin
ventanas, detectado solo con `--forest auto`), agua con ondas sobre la pintura, luz de la hora del Daylight sobre la
pintura de día y la de noche fundida al oscurecer (`PaintedZone.night_weight`; el shader divide la noche por el color del
Daylight). Sin nubes, sombras del mapa, ventanas ni faroles calculados en zonas con skin. `repaint_zone.py` corta en
grilla (`--width 40 --height 36`, costura en los dos sentidos) y usa **Qwen-Image 2.1 Turbo** por defecto (~75 s por
trozo; `--quality` = el normal, 3× más lento). Trampas: en `painted_zone.gdshader` TEXTURE solo se lee dentro de
`fragment()` y `COLOR` ya trae la textura (el modulate va por un varying del vertex); en CanvasLayer propia la pintura
salía oscura y saturada con HDR 2D (va dentro de la zona).
5. Próximos: Pueblo Paleta completo (agua, noche, luz) → Ruta 1 y Ciudad Verde (variedad y tiempos) → compresión de las
   imágenes para el zip → interiores (otro prompt).

## Para decidir
- **Identidad**: "campo sudamericano" (terracota, encalado, ceibos, jacarandás), "cuento" (cabañas con techo de musgo,
  arroyos, faroles) o una mezcla (cada región/bioma con su carácter).
- Si el estilo nuevo reemplaza a FireRed en todo Kanto o solo en zonas nuevas.
