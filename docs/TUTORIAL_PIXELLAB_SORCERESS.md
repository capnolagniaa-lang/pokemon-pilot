# Tutorial: efectos y animaciones con PixelLab y Sorceress

Guía para generar con IA lo que **no viene en SpriteCollab**: efectos de ataques (llamarada, rayo, explosión,
impacto) y animaciones de Pokémon que falten, en pixel art que combine con los sprites PMD/GBA del juego, y
meterlo en el proyecto.

> Info buscada en la web el 2026-10-24. Los precios de estas herramientas cambian seguido: tomalos como
> referencia y mirá la página oficial antes de pagar.

---

## 1. Qué es cada uno

| | **PixelLab** (pixellab.ai) | **Sorceress** (sorceress.games) |
|---|---|---|
| Qué es | Suite de IA para pixel art: personajes, rotaciones, animación, mapas, tilesets, edición (inpaint). | Plataforma de herramientas para hacer juegos; **Quick Sprites** genera hojas de sprites animadas retro. |
| Para qué nos sirve | **Animaciones de Pokémon** (rotar a 8 direcciones, animar desde un cuadro de referencia) y retoques. | **Efectos de ataques** (modo VFX: fuego, explosiones, rayos, magia) en una hoja lista. |
| Dónde se usa | Web, **extensión de Aseprite**, Pixelorama en el navegador, API/MCP. | En el navegador. |
| Precio | Suscripción mensual con 3 niveles (≈ 9-12 USD, ≈ 24-30 USD y 50 USD por mes según la fuente) y prueba gratis sin tarjeta, con pocas generaciones. Los niveles pagos permiten uso comercial; prohíben usar lo generado para entrenar modelos. | Membresía Pro **de por vida a 49 USD** (pago único), pero **no incluye la IA**: cada generación gasta créditos aparte (un artículo de ellos habla de ~9 créditos por generación en Quick Sprites). Hay recarga automática de créditos opcional. |

Para el juego (proyecto personal, no se publica) cualquiera de los dos sirve. Si vas a usar uno solo:
**PixelLab** si querés animar Pokémon, **Sorceress** si querés efectos rápidos y baratos.

---

## 2. Qué tiene que tener el arte para que combine

Antes de generar, tené en cuenta el estilo del juego:

- **Sprites PMD** (los de SpriteCollab): cuadros de 24 a 96 px, contorno oscuro de 1 px, pocos colores,
  sombreado con 2-3 tonos. Los efectos tienen que ir en la misma escala: un efecto de **32×32 o 48×48** queda
  bien al lado de un Charmander (~24 px de cuerpo). Uno de 96×96 es para ataques grandes (explosión, Terremoto).
- **Pixeles enteros, sin antialias**: nada de bordes difusos ni degradés suaves. Si sale borroso, pedí
  "crisp pixel art, no anti-aliasing, hard edges" y bajale la resolución.
- **Fondo transparente**. Los dos lo dan por defecto (en PixelLab: "Remove background"/"No background").
- **Paleta**: los colores de cada tipo ya están en `data/types/*.tres` (`ElementType.color` y `core_color`; el
  fuego es rojizo/naranja, **no** amarillo ni blanco: el usuario se quejó de eso). Usá esos tonos en el prompt.
- El brillo "next gen" lo pone el juego (glow HDR del post-proceso + luces): el sprite del efecto no tiene que
  traer brillos exagerados.

### Prompts que funcionan para efectos

Escribilos en inglés (los modelos entienden mejor). Estructura: *qué es + forma + colores + estilo*.

- **Llamarada**: `fire burst flame explosion, red orange and dark red, small yellow core, retro pixel art, GBA style, crisp pixels, transparent background`
- **Rayo / Impactrueno**: `lightning bolt strike from above, electric yellow with white core and dark outline, jagged, GBA pokemon style pixel art`
- **Explosión**: `round explosion with smoke puffs, orange core, grey smoke, 8 frames, retro pixel art`
- **Impacto (golpe)**: `hit impact spark star burst, white and pale yellow, short punchy, pixel art`
- **Agua / Pistola Agua**: `water splash droplets, blue and light cyan, white highlights, pixel art`
- **Hoja / Hojas Navaja**: `spinning green leaf blade, two greens, dark outline, pixel art`

---

## 3. Sorceress: efecto de ataque con Quick Sprites (modo VFX)

1. Entrá a **sorceress.games**, iniciá sesión y conseguí créditos (sin sesión no genera).
2. Abrí **Quick Sprites** y elegí el estilo **VFX Effects** (efectos cuadrados 1:1).
3. Elegí el tamaño: **24, 32, 48, 64, 80 o 96 px**. Recomendado:
   - 32×32 para impactos chicos y proyectiles (Ascuas, Impactrueno, Pistola Agua),
   - 48×48 para llamaradas y explosiones medianas,
   - 64-96 para ataques de área.
4. Escribí el prompt (sección 2). Opcional: subí una **imagen de referencia** (por ejemplo una captura de un
   ataque del juego, o un efecto del estilo que te guste) y poné una **semilla** (seed) si querés poder repetir
   el resultado.
5. Generá. Te devuelve **toda la animación en una sola hoja** (spritesheet PNG, fondo transparente). Mirala en
   el visor (lightbox) cuadro por cuadro; si no te gusta, cambiá el prompt o la semilla.
6. **Exportá en 1×** (spritesheet PNG). No uses 2×/4×/8× para el juego: el juego ya escala la cámara, y una
   hoja agrandada después no se puede achicar sin perder pixeles. El GIF sirve solo para mostrarlo.

---

## 4. PixelLab: animaciones de Pokémon y efectos

### Instalar la extensión de Aseprite (recomendado)

1. Necesitás **Aseprite 1.3.7 o más nuevo** (la versión de prueba de Aseprite no acepta extensiones).
2. En tu cuenta de pixellab.ai bajá la extensión.
3. En Aseprite: **Edit → Preferences → Extensions → Add Extension** y elegí el archivo (o doble clic al archivo).
4. Reiniciá Aseprite y aceptá los permisos que pide (acceso a internet por websocket; "full trust" si querés que
   se actualice sola).
5. Abrí el panel con **Edit → PixelLab → Open plugin** (o Ctrl + Espacio + P).

También podés usar todo desde la web (pixellab.ai) y bajar los PNG; los pasos son los mismos.

### Pasarle un cuadro del sprite como referencia y sacar 8 direcciones

Los sprites PMD vienen en **8 direcciones** (una fila por dirección, ver sección 6). Para una animación nueva
de un Pokémon:

1. Sacá el cuadro de referencia: abrí `sprites/pokemon/<N.º>/Idle-Anim.png` en Aseprite, y copiá el **primer
   cuadro de la primera fila** (mirando **abajo/sur**: PixelLab recomienda empezar del sur). El ancho de cada
   cuadro está en `AnimData.xml` (`FrameWidth`/`FrameHeight`).
2. Con la herramienta **Create 8-directional sprite (Pro)**, modo **Rotate character**: pasale ese cuadro y
   genera las otras 7 direcciones en una grilla de 3×3 (hasta 168×168 por cuadro). Alternativa: la herramienta
   **Rotate**, girando de a 45° tomando cada resultado como la nueva referencia (más preciso en giros chicos,
   pero los errores se acumulan).
3. Con la dirección lista, animala con **Animate with text** (le pasás el cuadro y la acción: `breathes fire`,
   `jumps back`, `spins`, `falls down fainted`; de 4 a 16 cuadros) o con **Animate with skeleton** (más control:
   poses con esqueleto). Tip de ellos: empezá con pocos cuadros (2) para encontrar una buena referencia y después
   generá más. Para un ataque con efecto grande, corré al Pokémon a un costado del lienzo así tiene lugar.
4. Repetí la animación para cada dirección (o generala en la dirección sur y usá la rotación de cada cuadro).
5. Si una dirección sale rara, retocala con **Inpaint** (pintás de negro la parte a rehacer en la capa de
   inpainting) o **Edit animation (Pro)** (aplica un mismo cambio a 2-16 cuadros).

### Efectos en PixelLab

Para un efecto suelto: **Create S-XL image (Pro)** o **Create image (pixflux)** con el prompt de la sección 2 y
fondo transparente, y después **Animate with text** sobre ese cuadro ("expanding explosion", "flickering
flame"). Sorceress es más directo para efectos; PixelLab conviene cuando querés que el efecto salga del mismo
estilo que un sprite que ya tenés (pasale el sprite como referencia de estilo).

---

## 5. Retocar en Aseprite

Lo generado casi siempre necesita una pasada a mano:

1. **Abrir la hoja como animación**: File → Import Sprite Sheet → tipo *By Rows*, con el tamaño de cuadro.
2. **Limpiar**: borrar pixeles sueltos, cerrar el contorno de 1 px, sacar semitransparencias (Sprite → Color
   Mode → Indexed y volver a RGB fuerza colores planos; o Edit → Replace Color).
3. **Paleta**: cargá la paleta del sprite original (Palette → Load from sprite) y repintá con esos colores para
   que el Pokémon no cambie de tono entre animaciones.
4. **Tiempos**: en la línea de tiempo ajustá la duración de cada cuadro. El juego usa los tiempos de PMD en
   "ticks" de 1/60 s (un cuadro de 2 ticks = 33 ms); para el `AnimData.xml` pasá ms → ticks dividiendo por 16,7.
5. **Exportar**: File → Export Sprite Sheet → *By Rows*, sin padding ni recorte (Trim desactivado), PNG.
   - Animación de Pokémon: **8 filas** (una por dirección, en el orden de la sección 6), cuadros hacia la derecha.
   - Efecto: **1 fila** (todos los cuadros seguidos).

---

## 6. Meterlo en el proyecto

### a) Animación nueva de un Pokémon

El juego lee las animaciones con el formato de SpriteCollab:

- Carpeta: `sprites/pokemon/<N.º con 4 cifras>/` (ej. `0004` = Charmander).
- Hoja: `<Nombre>-Anim.png`, cuadros del mismo tamaño, **8 filas** en este orden: abajo, abajo-derecha,
  derecha, arriba-derecha, arriba, arriba-izquierda, izquierda, abajo-izquierda (es el que usa
  `CreatureSprite._row`). Los pies del Pokémon, cerca del centro del cuadro (como en las hojas PMD).
- Datos: en el `AnimData.xml` de esa carpeta agregá (o editá) un `<Anim>`:

  ```xml
  <Anim>
    <Name>Shoot</Name>
    <Index>9</Index>
    <FrameWidth>48</FrameWidth>
    <FrameHeight>48</FrameHeight>
    <Durations><Duration>4</Duration><Duration>2</Duration><Duration>6</Duration></Durations>
  </Anim>
  ```

  Si la especie tenía esa animación como `<CopyOf>`, sacale el `CopyOf` y poné los datos de la tuya.
- Rearmá los datos y reimportá (no vuelve a bajar lo que ya está, así que respeta tu PNG y tu XML):

  ```bash
  python -I -B tools/download_sprites.py .
  ```

  ```bash
  C:/Users/Gusti/Documents/claude/tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --import
  ```

- El nombre tiene que estar en `ANIMS` de `tools/download_sprites.py`. Qué animación usa cada acción lo decide
  `CreatureSprite.CHAINS` (`scripts/creatures/creature_sprite.gd`): disparo → Shoot, carga → Charge, golpes →
  QuickStrike/Strike/Swing/Double, embestida → LeapForth, esquive → Hop/Rotate/Tumble, debilitado →
  Faint/HitGround/LostBalance, dormido → Sleep. Si inventás una animación nueva (ej. `Breath` para Lanzallamas),
  sumala a `ANIMS` y a la cadena que corresponda.
- Probá con `--autotest-anims` y mirándola en el juego.

> Ojo: si **borrás** el `AnimData.xml`, `download_sprites.py` lo vuelve a bajar de SpriteCollab y pisa el tuyo.
> Guardá una copia de lo hecho a mano (git ya lo versiona).

### b) Efecto de ataque

Hoy los efectos de los ataques **se dibujan por código** (círculos, partículas y luces con los colores del
tipo): `scripts/combat/projectile.gd` (`_draw` y `_trail`), `area_effect.gd`, `melee_swing.gd`,
`channel_cone.gd`, `whip_lash.gd`, y los genéricos en `scripts/fx/fx.gd`. **Todavía no hay un lugar para
hojas de efectos**: el primer efecto con sprite necesita ese enganche (una tarea chica). La forma prevista,
respetando la arquitectura data-driven:

1. Guardá la hoja en `sprites/fx/<nombre>.png` (ej. `sprites/fx/llamarada_48.png`, 1 fila de cuadros).
   Godot la importa sola al abrir el editor (o con `--import`). En el import dejá el filtro en *Nearest* (el
   proyecto ya usa filtro nearest por defecto para el pixel art).
2. En Godot creá un recurso **SpriteFrames** (`data/fx/<nombre>.tres`): Add frames from sprite sheet → elegí la
   hoja, poné las columnas/filas, velocidad (FPS) y sin loop si es una explosión/impacto.
3. Enganche en código (a hacer): un campo `@export var vfx: SpriteFrames` en `MoveData` (por ataque) o en
   `ElementType` (por tipo); `Projectile`/`AreaEffect`/`MeleeSwing` crean un `AnimatedSprite2D` hijo con esas
   frames, rotado según la dirección (`velocity.angle()`), y siguen dibujando el halo y la luz de ahora debajo
   (así conserva el glow). Para impactos, un efecto al pegar: escuchar `Events.creature_damaged` en
   `scripts/fx/combat_feedback.gd` y poner el `AnimatedSprite2D` en la posición del golpe, que se borre al
   terminar (`animation_finished`).
4. Asignale el `.tres` al ataque en el inspector (`data/moves/<ataque>.tres`) y probalo con la vitrina de kits:

   ```bash
   C:/Users/Gusti/Documents/claude/tools/godot/Godot_v4.7.2-stable_win64.exe --path . --quit-after 2400 --write-movie out/f.png --fixed-fps 30 -- --showcase-kit
   ```

Pedile a Claude "enganchá los efectos con sprite (vfx) a los ataques" cuando tengas la primera hoja lista.

---

## 7. Resumen rápido

1. **Efecto** → Sorceress Quick Sprites, VFX, 32-48 px, prompt con los colores del tipo, exportar 1× PNG.
2. **Animación de Pokémon** → PixelLab: cuadro sur del `Idle-Anim.png` como referencia → 8 direcciones →
   Animate with text → retocar en Aseprite con la paleta del original.
3. **Exportar** por filas (8 para Pokémon, 1 para efectos), sin padding.
4. **Pokémon**: PNG + `AnimData.xml` en `sprites/pokemon/<N.º>/` → `download_sprites.py` → `--import`.
   **Efecto**: `sprites/fx/` + `SpriteFrames` en `data/fx/` (el enganche a los ataques está por hacer).

## Fuentes

- PixelLab: [herramientas y extensión de Aseprite](https://www.pixellab.ai/llms-full.txt) ·
  [Create 8-directional sprite (Pro)](https://www.pixellab.ai/docs/tools/create-8-rotations-pro) ·
  [Rotar un personaje](https://pixellab.ai/docs/guides/rotating-a-character) ·
  [Formas de usar PixelLab](https://www.pixellab.ai/docs/ways-to-use-pixellab) ·
  precios: [Cutout.pro](https://www.cutout.pro/learn/pixellab/), [G2](https://ai.g2.com/marketplace/tools/pixellab),
  [Ludo](https://ludo.ai/compare/ludo-vs-pixellab), [AlternativeTo](https://alternativeto.net/software/pixellab/about)
- Sorceress: [Quick Sprites (wiki)](https://sorceress.games/wiki/sorceress/quick-sprites) ·
  [Planes y créditos](https://sorceress.games/wiki/sorceress/plans-credits-billing) ·
  [Generador de sprites y VFX (blog)](https://sorceress.games/blog/ai-sprite-generator-pixel-walk-cycles-idles-and-vfx)
