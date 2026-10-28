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
  cuadro clave quieto. `fx_from_frames.py --loop` (cuadros parejos), `--flip` si la estela quedó del otro lado,
  `--end 5` para quedarse con el principio. Tamaño: `max(16, min(32, size·4))` px.
- ComfyUI se puede colgar al alternar Wan (2 × 9,6 GB) y Qwen (13 GB) con 32 GB de RAM: si pasa, reiniciarlo y volver
  a encolar lo que faltó.

## Tiempos (RTX 5060 Ti)
Cuadro clave ~1 min (la primera vez más, carga el modelo) · animación ~4-6 min · redibujo de sprite ~1 min.
