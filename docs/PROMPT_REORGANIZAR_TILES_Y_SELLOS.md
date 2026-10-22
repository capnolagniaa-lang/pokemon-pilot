# Prompt: rehacer los sellos de edificios y reorganizar la paleta del editor de mapas

> Para el agente que hizo el editor de mapas. Pegalo en Claude Code abierto en `pokemon-tiempo-real`,
> o decile: "Leé `docs/PROMPT_REORGANIZAR_TILES_Y_SELLOS.md` y hacelo".

---

Hola Claude. Leé `CLAUDE.md`, la sección "Herramienta — Editor de mapas" de `docs/PROGRESO.md` y `docs/INSTRUCTIVO_EDITOR_DE_MAPAS.md`. Hablame en español rioplatense.

**El problema:** los **sellos de edificios están mal armados** y la **paleta no está organizada como corresponde**. Quiero que los rehagas tomando como referencia estas dos hojas de FireRed/LeafGreen de The Spriters Resource:

- **Edificios:** https://www.spriters-resource.com/game_boy_advance/pokemonfireredleafgreen/asset/3862/
- **Tiles del mundo:** https://www.spriters-resource.com/game_boy_advance/pokemonfireredleafgreen/asset/3863/

## 0. Conseguir las referencias

1. Probá bajar las dos imágenes (WebFetch, o el navegador si lo tenés). Ese sitio suele rechazar las descargas automáticas.
2. Si no podés, **pedime que las baje yo** y las guarde como:
   - `art_src/referencia/frlg_edificios.png` (la 3862)
   - `art_src/referencia/frlg_tiles_mundo.png` (la 3863)
3. **No sigas sin las referencias.** Agregá `art_src/referencia/` al `.gitignore` si te parece mejor no subirlas al repo (son de terceros), y decímelo.
4. Abrilas y miralas en detalle: recortes ampliados con Python y `Read` de los PNG.
   - Anotá cómo está organizada cada hoja: secciones, títulos, orden, separación entre piezas y color de fondo.
   - Contame qué hay en cada una antes de empezar a cambiar cosas.

## 1. Qué está mal hoy (ya lo revisé, confirmalo)

En `tools/pret_import.py → analyze()`, los sellos se arman así: desde cada celda con behavior de puerta (`0x69`) se hace un relleno por inundación de **celdas con colisión**. Se corta en lo "verdoso" (`_greenish`) y después **solo se guardan las piezas cuya categoría es `edificios`/`puertas`/`carteles`**. Eso produce:

- **Agujeros (`-1`) dentro de los edificios.** Por ejemplo, el Centro Pokémon de Azafrán tiene varios `-1`. Las piezas del techo, la chimenea, los aleros, las esquinas con pasto de fondo o las que no tienen colisión quedan afuera. Al pegarlo, en esas celdas queda lo que había abajo.
- **Edificios cortados o sin la fila de abajo:** la base de la puerta, el escalón o el frente caminable.
- **Pedazos sueltos tomados como edificios:** "Edificio 1" de 3×2, que en realidad es un cartel o un marco de puerta.
- **Varios edificios o paredes pegados en un solo sello:** por ejemplo, un "Edificio 2" de Azafrán de 12×3 que es un tramo de muro.
- **Nombres genéricos** ("Edificio 1, 2, 3…" por lugar) y **casi-duplicados**, porque solo se deduplica cuando son idénticos celda por celda.
- **Las categorías de la paleta salen de heurísticas** (`_greenish`, `_stony`, porcentaje de colisión, votos), así que hay tiles en el tipo equivocado. La paleta está ordenada por tileset e índice, no por lo que es cada cosa.

El render de los metatiles **está bien**: las paletas primaria/secundaria y la combinación de tiles de `general` con los del tileset secundario son correctas (lo verifiqué con `pallet_town_below.png`). **No toques eso.**

## 2. Lo que quiero

### A. Sellos de edificios fieles a la referencia (hoja 3862)
- **Un sello por cada edificio de la hoja de referencia**: casas de cada pueblo, Laboratorio de Oak, Centro Pokémon, Tienda Pokémon, cada gimnasio, edificios especiales de cada ciudad (Silph, Casino, Centro Comercial, torres, etc.), las variantes de color que existan, y lo que tenga la hoja.
- Cada sello es **el rectángulo completo del edificio**, con todas sus celdas:
  - techo, chimenea, aleros, paredes, ventanas, puerta, cartel pegado y base;
  - incluidas las piezas que tienen pasto de fondo o no tienen colisión.
  - **Sin agujeros dentro de la silueta.** Solo pueden quedar transparentes (`-1`) las celdas que en la referencia son fondo puro, fuera del contorno del edificio.
- **Cómo sacarlo bien** (no a ojo):
  1. Renderizá a PNG los mapas reales de FireRed (`art_src/pret/data/layouts/*/map.bin`), con su primario y secundario, como ya hace el importador.
  2. Segmentá la hoja de referencia en piezas, usando su color de fondo y la separación entre ellas.
  3. Para cada edificio de la referencia, **buscalo por coincidencia de píxeles** en los mapas renderizados, alineado a la grilla de 16 px. Así obtenés el mapa, la posición y el tamaño exactos, y tomás las celdas de `map.bin`: metatile y bits de colisión.
  4. Si algo de la referencia no aparece en ningún mapa (variante o recorte distinto), probá con tolerancia de color. Si sigue sin aparecer, listalo y **preguntame**.
- Cada sello guarda, además de las celdas:
  - la **colisión por celda tal como está en el mapa real**: el techo y las paredes no se pueden atravesar, y el frente de la puerta sí;
  - las celdas de **puerta** marcadas, para usarlas en el futuro como entradas a interiores (los warps **no** se implementan ahora);
  - la parte de arriba (`Overhead`), que sale como hoy de `above_used`.
- **Nombres claros en español** y un **grupo**: Casas, Centros y tiendas, Gimnasios, Edificios especiales, Puertas y entradas (cuevas, garitas…).
- **Lugar de origen** ("Pueblo Paleta", "Ciudad Plateada"…), para filtrar.
- **Sin duplicados.** Si dos edificios son iguales salvo por el color (variantes de techo por ciudad), dejalos como **variantes del mismo sello** (selector de variante), no como sellos separados.

### B. Sellos de piezas del mundo y paleta reorganizada (hoja 3863)
- Usá la hoja de tiles del mundo como **guía de organización de la paleta**: mismas secciones, en el mismo orden y con nombres en español. Por ejemplo (ajustalo a lo que realmente tenga la hoja):
  - pasto y suelos;
  - caminos de arena y tierra (con sus bordes);
  - agua, orillas y cascadas;
  - árboles y arbustos;
  - flores;
  - salientes (bordes que se saltan);
  - cercas y vallas;
  - rocas;
  - carteles y buzones;
  - escaleras y puentes;
  - entradas de cuevas;
  - adornos urbanos: faroles, fuentes, macetas, estatuas, bolardos.
- **Mapeá cada celda de 16×16 de la referencia a su metatile** del TileSet, por coincidencia de píxeles con los metatiles renderizados (`<tileset>_below.png` + `above`). Con eso:
  - el **orden y la categoría de la paleta** salen de la referencia, no de las heurísticas;
  - los tags y la colisión de cada categoría salen de `tile_roles.tres` / `CATEGORY_TAGS`;
  - lo que no aparezca en la referencia queda en **"Otros"**, separado por tileset, con la categoría heurística actual.
- Las **piezas de varias celdas** que estén armadas en la referencia (árboles grandes, fuentes, estatuas, carteles de 2 celdas, entradas de cueva, puentes, tramos de cerca con sus puntas, salientes con esquinas) van como **sellos**, en el mismo panel que los edificios, con su propio grupo.
- En la paleta, que se pueda ver **"como en la hoja"**: una grilla que respete la disposición de la referencia, con las piezas en el mismo lugar relativo. El filtro por tipo, tileset y tag sigue funcionando.

### C. Dónde vive esto (que se pueda regenerar)
- Pasá la definición de los sellos a **datos curados y versionados**, por ejemplo `data/world/stamps.json` o `.tres`. Cada uno con `id`, nombre, grupo, lugar, variantes, el **origen** (layout + rectángulo en el mapa real), celdas, colisión y puertas. Así, si se reimporta FireRed, los sellos se regeneran desde el origen y no dependen de heurísticas.
- Lo mismo para el orden y las secciones de la paleta: `data/world/palette_layout.json` (o similar).
- La herramienta que hace la coincidencia con la referencia es un script aparte (`tools/match_reference.py`, Python sin dependencias como el importador; si necesitás alguna, preguntame). Genera esos archivos. `pret_import.py` deja de inventar sellos y categorías por su cuenta y usa los datos curados cuando existen.
- **Mantené estables los ids globales de metatile** (`base` por `manifest.json → order`): las zonas guardadas dependen de eso.

## 3. Verificación (mostrame las imágenes)

- **Hoja de contacto de sellos:** cada sello renderizado (below + above) **al lado de su recorte de la referencia**, con el nombre, y la diferencia de píxeles. Tiene que dar 0, o explicarse. Revisala vos y mandámela.
- **Hoja de la paleta reorganizada**, al lado de `frlg_tiles_mundo.png`.
- **Prueba de colocación:** en una zona temporal, pegá todos los sellos en grilla y renderizá con `--write-movie`, y también con la superposición de colisión. Que no haya agujeros, que las paredes y techos sean sólidos y que se pueda caminar frente a las puertas.
- Ampliá `--autotest-map-editor` (o sumá `--autotest-stamps`):
  - ningún sello tiene `-1` dentro de su contorno;
  - cada sello coincide con su origen en el mapa real (metatiles y colisión);
  - no hay sellos duplicados;
  - todos los de la referencia están;
  - pegar y deshacer un sello deja la zona igual.
- **Todos los autotests existentes siguen en "OK"** y las 9 zonas actuales no cambian ni un tile: sus tags y colisión, verificados celda por celda como la última vez.

## 4. Preguntame antes (AskUserQuestion, con la opción recomendada primero)

1. Si la hoja de referencia tiene edificios que **no están en ningún mapa de FireRed** (cortes promocionales, beta, variantes): (a) recomendado: dejarlos afuera y listarlos; (b) armarlos a mano a partir de los metatiles.
2. **Variantes de color de un mismo edificio:** (a) recomendado: un sello con selector de variante; (b) un sello por variante.
3. **Los sellos viejos:** (a) recomendado: reemplazarlos por completo (las zonas guardan tiles, no sellos, así que no se rompe nada); (b) dejarlos en un grupo "Antiguos".
4. Si te surge otra decisión de diseño importante, preguntame igual.

## 5. Al terminar

- Actualizá `docs/INSTRUCTIVO_EDITOR_DE_MAPAS.md` (sellos, grupos, variantes y la vista "como en la hoja"), `CLAUDE.md` (pipeline: `match_reference.py` + datos curados) y `docs/PROGRESO.md`.
- Después, commit y push como dice `CLAUDE.md`.
- Contame qué cambió y cómo probarlo, con las hojas de contacto adjuntas.
