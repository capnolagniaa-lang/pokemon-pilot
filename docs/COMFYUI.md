# Crear gráficos con IA local (ComfyUI)

ComfyUI está instalado en `C:\Users\Gusti\ComfyUI\ComfyUI_windows_portable` (fuera del repo), con una RTX 5060 Ti de 16 GB.
Los workflows se abren desde el menú de workflows de ComfyUI (están en `ComfyUI/user/default/workflows/`).

## Modelos instalados
| Modelo | Para qué |
|---|---|
| `qwen-image-Q4_K_M.gguf` + LoRA `Qwen-Image-Lightning-8steps-V2.0` | crear imágenes desde texto (8 pasos) |
| `qwen-image-edit-2511-Q4_K_M.gguf` + LoRA `Qwen-Image-Edit-2511-Lightning-8steps` | editar/redibujar una imagen con una instrucción |
| `Wan2.2-I2V-A14B` (ruido alto + bajo, Q4) + LoRAs `lightx2v_4steps` | animar una imagen (video de 2 s) |
| LoRA `Qwen-Image-2512-Master-Pixel-Art-LoRA` (prithivMLmods, Apache-2.0) | pixel art con Qwen-Image (empezar el texto con "Pixel Art.") |
| LoRA `moss_pixelart_qwen_v2` (MOSS! Pixel Art Refiner, Civitai) | pixel art más nítido y fondo negro más limpio que el anterior, para efectos (a veces agrega un marco). En terreno mete matas de más |
| LoRA `pixel_4walk_32x48_qwen_image_edit_2511_v1` (svntax, Apache-2.0) | Qwen Edit: de un personaje de referencia a una hoja 32×48 en 4 direcciones (caminar, 2 de ataque, golpeado). Para entrenadores/NPC; todavía sin workflow |

## Workflows
| Workflow | Qué hace | Resultado probado |
|---|---|---|
| `mejorar_sprite_pokemon` | redibuja un sprite/retrato (Qwen Edit) y lo devuelve al mismo tamaño, con la transparencia original | **retratos: muy bien**; filas de animación: no mejora (a 32×40 no hay lugar, y aparece un borde) |
| `terreno_shaders` | repinta una captura del juego con iluminación (sol, atardecer, noche, lluvia) | **referencia visual excelente** (`docs/referencias/iluminacion/`); no se usa en el juego: ver `docs/PLAN_DIA_NOCHE.md` |
| `efecto_1_cuadro_clave` | texto → cuadro clave de un efecto de ataque en pixel art, fondo negro | bien; a veces agrega piso o un ícono (ver abajo) |
| `efecto_2_animar` | anima el cuadro clave con Wan 2.2 (33 cuadros) | bien: estalla y se desvanece |

`efecto_*` los arma `tools/comfy/build_workflows.py` (copia en `tools/comfy/workflows/`): para cambiarlos, editar
el script y correr `python -I -B tools/comfy/build_workflows.py <carpeta ComfyUI>`. Los otros dos se armaron una vez
y viven solo en ComfyUI.

## Flujo para un efecto de ataque
1. **Cuadro clave** (`efecto_1_cuadro_clave`): describir el efecto en inglés, empezando con "Pixel Art." y pidiendo
   fondo negro puro, sin piso, sin marco, sin íconos. Proyectiles: "flying to the right". Efectos oscuros
   (Fantasma, Siniestro): fondo blanco. Generar varias semillas y quedarse con una.
2. **Limpiar el fondo** (Qwen suele dibujar un piso casi negro y Wan después hace "caer" el efecto sobre él):
   ```
   python -I -B tools/fx_from_frames.py <ComfyUI>/output/efectos/clave_00001_.png --clean-key <ComfyUI>/input/efecto_clave.png
   ```
3. **Animar** (`efecto_2_animar`): cargar `efecto_clave.png`, describir el movimiento (estalla y se desvanece, cámara
   fija, fondo negro) y poner el nombre del efecto en el nodo "5) Cuadros".
4. **Pasar al juego**: elige cuadros (más al principio que al final), saca el fondo, recorta, achica, paleta común:
   ```
   python -I -B tools/fx_from_frames.py <ComfyUI>/output/efectos/cuadros/<nombre> --preview out/prueba.png --grow 1
   python -I -B tools/fx_from_frames.py <ComfyUI>/output/efectos/cuadros/<nombre> --out sprites/fx/types/fuego_impacto.png --size 32 --frames 7 --grow 1
   ```
   Impacto: `sprites/fx/types/<tipo>_impacto.png` o `sprites/fx/moves/<ataque>_impacto.png` (32 px, 7 cuadros).
   Proyectil: `sprites/fx/moves/<ataque>.png` (16 px, 4 cuadros, apuntando a la derecha). Ver CLAUDE.md, "Efectos de
   ataque con sprite". **Ojo**: `tools/make_vfx.py` pisa las hojas que genera; si reemplazás una, sacala de su tabla.
   El script necesita Pillow (el Python del sistema lo tiene; si no, el `python_embeded` de ComfyUI).

## Árboles y pasto alto del juego: probado y descartado (2026-10-28)
Se probó reemplazar el árbol y el pasto alto de FireRed por unos redibujados con Qwen (estilo HeartGold/SoulSilver),
con un interruptor en Ajustes. Al usuario no le gustaron y se sacaron. Todo (`TilePack`, `tools/tile_pack.py`, el árbol
de 32×48) está en el commit d34b20ba. Lo aprendido: el árbol de FireRed son 2×3 metatiles encadenables (copa 14/15,
cuerpo 30/31 y 28/29, base 36-39, unión de bosque 20-23; 42/43 son techo, no árbol), y otros tilesets tienen sus propios
árboles.

## Lecciones (pruebas del 2026-10-28)
- **Caras**: no nombrar lo que no se quiere ("no face", "no rocket": lo dibuja igual, y peor) ni Pokémon/ataques/juegos
  ("shadow ball", "sludge", "Mystery Dungeon": dibuja a Gastly, Grimer o Geodude con cara). Describir solo energía, luz,
  partículas y formas. "Toxic" dibuja una calavera. Con eso (reglas fijas de `efecto_1_cuadro_clave`), 0 caras.
- **Tamaño**: la IA rinde en efectos de 32-48 px (impactos, Trueno, Giro Fuego, Psíquico). A 16 px (proyectiles) queda
  una mancha: los hechos por código se leen mejor.
- **Efectos oscuros** (Bola Sombra): sobre fondo negro el centro oscuro se vuelve transparente y queda un anillo.
  Para esos, fondo blanco (cambiar las Reglas) y `--bg white`.
- **Wan** a veces cambia el efecto a mitad del video (Giro Fuego termina en fogata): usar `--end N` para quedarse con
  la primera parte.
- **Terreno**: Qwen Edit sin LoRA (estilo "HeartGold/SoulSilver") da los árboles y el pasto alto más prolijos, pero
  dibuja la sombra pegada al árbol (sacarla: el juego ya tiene sombras por hora).
- **Proyectiles**: la palabra "projectile" dibuja balas y cohetes, y "jet" aviones; describir solo la energía ("a ball
  of X moving fast to the right and leaving a short glowing trail..."). Para estos efectos, el LoRA **MOSS** (1,0) va
  mejor que el anterior. Wan a veces deforma el bucle (Lanzarrocas se deshace, Hoja Mágica cambia de forma): ahí,
  cuadro clave quieto (`--frames 1`). Lo oscuro (una roca, Bola Sombra) va sobre fondo blanco y `--bg white`; y para
  que el recorte no salga enorme, pedirlo "compact" (sin chispas desparramadas). `fx_from_frames.py --loop` (cuadros parejos), `--flip` si la estela quedó del otro lado,
  `--end 5` para quedarse con el principio. Tamaño: `max(16, min(32, size·4))` px.
- **Objetos del mapa** (poste, antorcha, cristales): las mismas Reglas pero "a single game prop sprite for a top-down 2D
  RPG ... 3/4 top-down view ... plain pure white #FFFFFF background", LoRA MOSS 1,0; después
  `tools/prop_from_image.py <png> sprites/props/<x>.png --height <px>`. "Mounted on a wall" dibuja la pared entera:
  pedir objetos parados.
- **Retratos VS** (2026-10-28): las ilustraciones de batalla de FireRed (`art_src/vs/`) con el workflow de redibujo
  (Qwen Edit 2511) e instrucción "same character, face, hair, expression and eyes...". ~4 min cada uno. Cambia
  colores de pelo a veces (Misty y Agatha salieron rubias: se corrigió con un cambio de tono en la zona de la
  cabeza). Al juego: `prop_from_image.py <png> sprites/vs/<gfx>.png --height 210 --colors 48 --outer-bg`.
- ComfyUI se puede colgar al alternar Wan (2 × 9,6 GB) y Qwen (13 GB) con 32 GB de RAM: si pasa, reiniciarlo y volver
  a encolar lo que faltó.

## Tiempos (RTX 5060 Ti)
Cuadro clave ~1 min (la primera vez más, carga el modelo) · animación ~4-6 min · redibujo de sprite ~1 min.

## Prueba: animaciones con Qwen-Image 2.1 (2026-11-01)
Qwen-Image 2.1 Turbo (`qwen_image_2.1_turbo_int8_convrot` + `qwen3vl_8b_int8_convrot`, nodo `TextEncodeQwenImage21`
con la imagen de referencia, 8 pasos con `ManualSigmas` de la plantilla, cfg 1) arma **una hoja entera de animación en
una sola imagen** y en ~6-12 s:
- **Sprite de Pokémon**: se le pasa la fila de Idle de PMD agrandada ×8 (fondo blanco) y se le pide "redibujala como una
  animación de N cuadros de <ataque> en la misma fila". Mantiene personaje, dirección y estilo (Charmander: llamarada de
  frente y arañazo de perfil salieron bien). Para bajar a 32×40 conviene mapear a la **paleta del sprite original**; sin
  eso queda borroso. Pendiente: sacar el fondo antes de achicar (si no, deja un borde claro) y ajustar el tamaño (lo dibuja
  un poco más grande que el original).
- **Efectos**: solo texto, "sprite sheet de 6 cuadros, fondo negro" (impacto de fuego y de hielo): coherentes de un cuadro
  al otro, mejor y mucho más rápido que el cuadro clave + Wan 2.2.
- El modelo completo (no turbo, 30 pasos, ~18 s) no fue mejor que el Turbo.

### Prompts que funcionan (afinado el 2026-11-01)
Herramientas: `tools/comfy/qwen21_prep.py <n.º> <fila> <nombre>` (fila de Idle de PMD ×8 con fondo blanco; fila 0 = de
frente, 1 abajo-derecha, 2 derecha, 3 arriba-derecha, 4 de espaldas), `tools/comfy/qwen21_run.py <nombre> <ancho> <alto>
"<prompt>" <imagen>` (ancho/alto = los de la tira; `SEED`, `MODEL`, `LORA`, `OUT`) y `tools/comfy/qwen21_down.py
<ia.png> <nombre>_orig.png 4 <salida>` (a tamaño real: saca el fondo y las líneas de grilla en grande, escala para que el
último cuadro, la pose de reposo, mida como el original, pasa a la paleta del original y le pone el contorno oscuro; los
efectos claros quedan sin contorno). Plantilla que mejor anduvo:

> This image is a pixel art sprite sheet: 4 animation frames of **{Especie (descripción corta: "a round grey boulder
> with two big muscular rock arms, no legs")}** side by side in one row, **{vista}**, on a plain white background. Redraw
> it as a 4-frame **{ataque}** animation, keeping exactly 4 cells of equal width in one row: **frame 1 … frame 2 …
> frame 3 … frame 4 …** Use exaggerated, readable key poses with strong anticipation and follow-through, so the
> silhouette clearly changes from frame to frame. Keep the identical character design, colors, proportions and facing
> direction from the input. Each cell is a tiny low-resolution game sprite enlarged 8 times: big square pixels on a
> strict grid, a 1-pixel dark outline, flat colors, no gradients, no anti-aliasing, no blur. Same character size in every
> cell. Plain pure white background everywhere, no floor, no ground line, no shadow, no text.

Lo aprendido:
- **Describir la especie** entre paréntesis: sin eso Geodude salió sin brazos (no lo reconoció en 32×24).
- "Exaggerated key poses / anticipation / follow-through" = poses con más fuerza (sin eso se mueve poco).
- No decir "ground line" (dibuja una línea de suelo); decir "no floor, no ground line".
- Vistas: "facing down toward the viewer", "in three-quarter view facing down-right", "seen from the side facing right",
  "in three-quarter back view facing up-right", "seen from behind, facing away from the viewer". Una corrida por
  dirección (5) y las 3 de la izquierda espejadas: así salen las 8 de PMD. **Pedir la hoja entera de 8 filas de una vez
  no sirve** (pierde direcciones o el golpe sale solo en algunas filas).
- Algunas semillas dibujan una grilla o dan vuelta un cuadro: probar 2 semillas y quedarse con la mejor (~10 s cada una).
- **LoRAs de pixel art** (Redmond, Master Pixel Art, moss): son del Qwen-Image viejo; en 2.1 casi no cargan ("lora key
  not loaded") y no cambian nada. Con Qwen-Image-Edit 2511 (`tools/comfy/qwen_edit2511_run.py`) sí cargan, pero sale peor
  (pixeles rotos, sombra; el `pixel_4walk` lo pone de frente) y tarda ~90 s. **Quedarse con 2.1 Turbo sin LoRA.**
- Uso posible en el juego: solo 48 de 386 especies tienen `Strike` y 94 `LeapForth` (las demás caen a `Attack`).

### Golpes en el juego: 5 especies de prueba (2026-11-01)
`tools/comfy/strike_sheet.py` hace todo el camino para una especie sin `Strike` propio:
- `gen <n.º> "<especie (descripción)>" "<acción con {dir}>" <carpeta> [semillas]`: 5 corridas por semilla (una por
  dirección, sobre su fila de Idle) y `elegir.png` (cada dirección con cada semilla, ya a 32 px). Lo generado no se
  repite; `ROWS=4` genera solo esa fila (para probar más semillas en una dirección que salió mal).
- `build <n.º> <carpeta> <semilla por fila, 5>`: arma `sprites/pokemon/<n.º>/Strike-Anim.png` (8 filas: las 3 de la
  izquierda espejadas; celda = la del Idle + 12 px por lado, el golpe se corre hacia adelante sin cortarse), lo anota en
  su `AnimData.xml` (pisa el `CopyOf Attack`) y en `sprite_data.gd`. Una semilla con `i` (ej. `777i`) = el último cuadro
  salió mal: se mide con el primero y el último pasa a ser el Idle original. Después `--import`.
- Hechos: Bulbasaur, Squirtle, Pidgey, Rattata y Geodude (test `--autotest-anims`, vitrina `--showcase-strike`: arriba el
  golpe nuevo, abajo el Attack de antes, por las 8 direcciones).
- Lo que se aprendió: sin colores de efectos en la paleta (el gris y el celeste se comían el verde de Bulbasaur); de
  frente y de espaldas la IA tiende a girarlo de costado (Squirtle de espaldas necesitó 4 semillas; Pidgey de frente
  estira el cuello para arriba); "floating" hace que Geodude salga como plato volador con rayas (no usar la palabra), y
  Geodude sale más liso que su sprite original (se nota al volver al Idle).

### Animaciones por ataque: familias de movimiento (2026-11-01, para revisar; todavía no entran al juego)
Decisión del usuario: en vez de una animación por ataque y especie (decenas de miles), cada ataque cae en una **familia
de movimiento** (`tools/comfy/move_families.py`: embestida, morder, arañar, puño, patada, picotazo, ala, cabezazo,
cola/látigo, cuerno, pisotón, lanzar, soplar por la boca, descarga, mirada/mental, grito, sacudirse, potenciarse; por
nombre en inglés y, si no está en la tabla, por categoría/tipo/objetivo) y por especie se genera solo la familia de cada
ataque que aprende por nivel en FRLG (~5 por especie). El **efecto va aparte, encima** (VfxSprite): los prompts piden
la pose sola, sin fuego ni agua.
- `python -I -B tools/comfy/family_anims.py 1-151` (o `25`, `1,4,7`; `--only boca,morder`, `--seeds`): una semilla por
  dirección (~40 s por familia), todo en `out/animaciones/<n.º>_<nombre>/<familia>/` (no se sube): lo de la IA, la hoja
  de 8 filas a 32 px y un GIF con las 8 direcciones (Idle en el centro). Lo ya hecho no se repite. Descripciones para el
  prompt: `tools/comfy/species_desc.json` (Kanto; las de Johto y Hoenn, a sumar).
- Revisión: `out/animaciones/revision.html` (lo rehace `review_page.py` después de cada especie): Bien / Rehacer / No va
  + nota por familia, guardado en el navegador, "Copiar revisión" arma el texto para pasárselo a Claude.
- El último cuadro se reemplaza solo por el Idle si sale con otra forma (el "plato volador" de Geodude).
- **Más parecidos al sprite (2026-11-01, "algunos están feos, como Bulbasaur")**: (1) el paso a 32 px igualaba mal los
  colores (la IA pinta con los del arte oficial, Bulbasaur turquesa, y el sprite de PMD es pálido) y promediar dejaba
  puntitos: ahora se iguala media y desvío de cada canal al sprite original, cada pixel va al color de paleta más
  parecido (pesa la luz) y cada pixel chico es el color con más votos de su bloque (`strike_sheet.convert`). (2) El
  prompt manda como **imagen 2 la animación Attack de PMD** de esa dirección ("dibujá en exactamente ese estilo") y pide
  copiar colores, sombreado, proporciones y tamaño de pixel; sin líneas de velocidad (quedaban rayitas sueltas).
  Comparado en Bulbasaur, Pidgey y Geodude contra el prompt anterior. Lo hecho con el prompt viejo quedó en
  `out/animaciones_v1/`.
