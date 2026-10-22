# Instructivo — Editor de mapas de Pokémon Pilot

Herramienta para armar las zonas del juego pintando sobre un mapa con los gráficos de Pokémon FireRed. Lo que
guardás acá es exactamente lo que después se juega.

---

## 1. Abrirlo

Cualquiera de estas tres formas:

- **Ícono "Editor de mapas"** en la carpeta del proyecto (doble clic).
- **Acceso directo del escritorio** "Pokémon Pilot — Editor de mapas".
- Desde el juego: si lo arrancás con `-- --debug`, en la pantalla de título aparece el botón **Editor de mapas**.

Abre la zona donde empieza el juego (Ruta 1). Para cambiar de zona usá el desplegable **Zona** de arriba a la izquierda.

> Guarda directo en los archivos del proyecto. Si alguna vez dice *"No se puede escribir en res://"*, es que
> se está corriendo una versión exportada del juego: el editor necesita la carpeta del proyecto.

---

## 2. La pantalla

```
┌──────────────────────────────────────────────────────────────┬──────────────┐
│ Fila 1: Zona · Nueva zona · Guardar · Probar · Validar ·     │              │
│         Deshacer/Rehacer · Capas · Ver · (Guardado) · Salir  │              │
│ Fila 2: Herramientas · Tamaño 1-3 · Relleno · Capa activa    │              │
├──────────────────────────────────────────────────────────────┤   Panel de   │
│                                                              │   pestañas   │
│                 LIENZO (la zona que estás editando)           │              │
│        las zonas vecinas se ven atenuadas alrededor          │  Pinceles    │
│                                                              │  Sellos      │
│                                                              │  Tiles       │
│                                                              │  Tile        │
│                                                              │  Zona        │
├──────────────────────────────────────────────────────────────┴──────────────┤
│ Estado: celda bajo el mouse, qué hay, tags, herramienta, pincel, capa       │
│ Ayuda: atajos de teclado                                                     │
└──────────────────────────────────────────────────────────────────────────────┘
```

- Arriba a la derecha dice **Guardado** o **● Sin guardar**.
- La barra de abajo te dice siempre qué hay en la celda donde tenés el mouse: coordenadas, tipo, objeto y tags.
- Sobre el mapa vas a ver marcadores: **H** amarillo es la plaza (hub), los **▲ ▼ ◀ ▶** verdes son las salidas
  hacia las zonas vecinas, y la **S** celeste es donde empieza una partida nueva.

---

## 3. Moverse por el mapa

| Qué | Cómo |
|---|---|
| Acercar / alejar | Rueda del mouse (hace zoom hacia donde apuntás) |
| Mover el mapa | Clic del medio y arrastrar, o **Espacio + clic izquierdo** y arrastrar |

---

## 4. Las pestañas del panel derecho

### Pinceles (lo más común)
Pinceles que **ya saben las reglas del juego**: no tenés que pensar en capas.

- **Terreno**: Pasto, Pradera clara, Pasto alto, Flores, Arena, Tierra, Agua/laguna.
  - Arena, tierra, pradera clara y agua arman **solos los bordes y las esquinas**, tanto al pintar como al borrar.
  - Pasto alto y flores se ponen con pasto abajo. **En el pasto alto aparecen los Pokémon salvajes.**
  - El agua lleva pasto abajo y tiene colisión de agua (se puede congelar con hielo en el juego).
- **Árboles**: árbol de 2×2, con su copa que tapa al personaje y su sombra. Si ponés uno justo debajo de otro,
  usa solo la copa "apilada" como en FireRed. **Borde ↑ ↓ ← →** pone una hilera doble de árboles en ese lado de la zona.
- **Objetos**: Roca frágil (se rompe con una embestida), Roca pesada y Árbol cortable. Hay uno solo por celda.
  Cualquier objeto nuevo que se agregue a `scenes/world/objects/` aparece acá solo.
- **Borrar**: *Todo (deja pasto)* limpia la celda entera (tiles, árbol y objeto). *Solo capa activa* borra
  únicamente la capa elegida arriba.

### Sellos (edificios enteros)
Unos 70 edificios sacados de los mapas reales de FireRed: casas de cada pueblo, Centro Pokémon, Tienda,
edificios de las ciudades... El desplegable filtra por lugar.

1. Elegí un sello de la lista.
2. Hacé clic en el mapa: esa celda va a ser **la esquina de arriba a la izquierda** del edificio. Antes de hacer
   clic, la sombra celeste te muestra dónde va a quedar.

Pega el edificio con su techo y su colisión, y saca lo que hubiera debajo (árboles, agua, objetos).

### Tiles (la paleta: todos los gráficos sueltos)
Todos los gráficos de FireRed, de a uno, para casos que los pinceles no cubren: cercas, carteles, escaleras,
techos, rocas de cueva, muebles...

- **Filtros**, de arriba hacia abajo:
  1. **Grupo**: Exteriores, Interiores o Todos.
  2. **Tileset**: de dónde sale (General, Pueblo Paleta, Cuevas, Ciudad Azulona...).
  3. **Tipo**: terreno, pasto alto, arena, agua, hielo, árboles, rocas, edificios, puertas, escaleras, salientes,
     carteles, cercas, suelos especiales, interiores... Hay además filtros extra: con colisión, sin tags, animados
     y parte de arriba.
  4. **Tag**: por ejemplo `solido` o `agua`.
- Pasando el mouse sobre un gráfico ves su número, tileset, tipo, tags y colisión.
- Se pinta **en la capa activa** (fila 2, "Capa activa"). Si el gráfico tiene parte de arriba (un techo, la
  copa de un árbol), esa parte se pone sola en la capa de Copas.
- Con muchos resultados muestra los primeros 1500: elegí un tileset o un tipo para ver el resto.

### Tile (la ficha de un gráfico)
Muestra el gráfico elegido en la paleta, o el que tomaste con el gotero, y deja cambiar:

- **Tags** (escritos separados por coma, o tocando los botones de tags conocidos).
- **Tipo** (en qué grupo de la paleta aparece).
- **Colisión**: Ninguna, Sólida o Agua.
- **Sugerir**: si FireRed tiene un dato sobre ese gráfico (por ejemplo, que es pasto alto o agua), propone tags y colisión.

**Aplicar al TileSet…** pide confirmación, porque **cambia ese gráfico en todas las zonas**. Antes de guardar
hace una copia de seguridad del TileSet en `art/tiles/.backup/`.

### Zona
- **Nombre** y **Bioma** de la zona.
- **Mover plaza y salidas (H)**: arrastrá los marcadores sobre el mapa. Las salidas solo se mueven pegadas a su borde.
- **Salida arriba / abajo / izquierda / derecha**: activa o saca una salida.
- **Elegir inicio**: el próximo clic en el mapa marca dónde empieza una partida nueva.
- **Validar zona**: lista de problemas. Hacé clic en uno y el mapa va hasta esa celda.
- **Nueva zona…** (ver el punto 8).

---

## 5. Herramientas (fila 2)

| Herramienta | Tecla | Uso |
|---|---|---|
| Pincel | B | Pinta donde hacés clic y donde arrastrás. **Tamaño 1, 2 o 3** con los botones o con `[` `]` |
| Línea | L | Clic, arrastrás y soltás: pinta una línea recta. Con árboles, pone uno cada 2 celdas |
| Rectángulo | R | Clic, arrastrás y soltás. **Relleno** (o tecla F) elige entre relleno y solo el borde |
| Balde | G | Rellena toda la mancha igual que la celda donde hacés clic (por ejemplo, toda una zona de arena). No pone árboles |
| Selección | M | Marca un rectángulo para copiar (Ctrl+C) o borrar (Supr) |
| Gotero | I o **Alt+clic** | Toma el pincel de la celda: árbol, arena, objeto... En la pestaña Tiles toma el gráfico crudo |
| Plaza y salidas | H | Arrastrar los marcadores H y ▲▼◀▶ |

- **Clic derecho = borrar** con cualquier herramienta: borra todo lo de la celda. Si estás pintando un gráfico de
  la paleta, borra solo la capa activa.
- **Pegar**: Ctrl+V. Aparece un recuadro que sigue al mouse; un clic pega y Esc o clic derecho cancela. Copiar y
  pegar sirve también entre zonas distintas.
- **Esc** cancela lo que estés haciendo (pegar, seleccionar, mover marcadores).

### Capa activa (1 a 5)
Solo importa para la paleta Tiles, el borrado por capa y el balde:

| Tecla | Capa | Qué va ahí |
|---|---|---|
| 1 | Suelo (Ground) | Pasto, caminos, edificios, árboles |
| 2 | Agua (Water) | Agua (tiene colisión de agua) |
| 3 | Follaje (Foliage) | Pasto alto y flores (se mueven con el viento) |
| 4 | Copas (Overhead) | Lo que tapa al personaje: copas de árboles, techos |
| 5 | Objetos | Rocas, árbol cortable |

---

## 6. Ver y capas (menús de la fila 1)

- **Capas ▾**: mostrar u ocultar cada capa. "Solo capa activa" deja ver una sola.
- **Ver ▾**:
  - **Grilla** (F2).
  - **Colisión** (F3): rojo es sólido (no se pasa) y azul es agua.
  - **Celdas sin tags** (F4): en magenta, lo que no tiene ningún tag.
  - **Resaltar tag**: pinta de amarillo las celdas con ese tag. Por ejemplo `pasto_alto` muestra dónde aparecen salvajes.
  - Plaza y salidas, Inicio del juego, Zonas vecinas.

---

## 7. Guardar, deshacer y probar

- **Deshacer / Rehacer**: Ctrl+Z / Ctrl+Y (o Ctrl+Shift+Z). Vale para todo: tiles, árboles, objetos, sellos, plaza y salidas.
- **Guardar**: Ctrl+S o el botón.
  - Antes de guardar valida la zona. Los **avisos** no frenan el guardado; los **errores** que romperían el juego sí
    (por ejemplo, dos zonas encimadas o un id repetido).
  - Antes de pisar el archivo hace una **copia de seguridad** en `scenes/world/zones/.backup/` y conserva las últimas 5.
  - Si cambiaste plaza, salidas, nombre o inicio, guarda también la región (`data/world/kanto.tres`).
  - Si cambiás de zona o cerrás con cambios sin guardar, te pregunta: Guardar, Descartar o Cancelar.
- **Probar ▶ (F5)**: guarda y abre el juego **en esa zona**, con el entrenador **en la celda donde tenés el mouse**
  (si ahí no se puede caminar, aparece en la plaza).
  - Usa tu equipo guardado.
  - Si guardás partida mientras probás, va a otro archivo: **no pisa tu partida real**.
  - El editor sigue abierto: cerrás el juego y seguís editando.

Si una partida guardada quedó parada en un lugar que ahora es sólido (porque pusiste un árbol o un edificio), al
cargarla el entrenador aparece en la celda libre más cercana.

---

## 8. Crear una zona nueva

1. **Nueva zona…** (arriba o en la pestaña Zona).
2. Completá:
   - **Id**: el nombre del archivo, sin espacios ni acentos (por ejemplo `ruta_2`).
   - **Nombre**: el que se muestra en el juego.
   - **Bioma**: pradera, bosque, lago, rocoso, humedal...
   - **Lugar**: solo ofrece lugares libres pegados a la región.
   - **Tamaño**: 48×32 por defecto.
3. **Generar con el bioma**: la arma automáticamente (caminos, pasto alto, árboles...). Si lo destildás, arranca toda de pasto.
4. **Salidas hacia las vecinas**: crea las salidas de los dos lados. **Ojo**: en la zona vecina, ese borde
   probablemente tiene árboles. Abrila y pintale el camino hasta la salida nueva (Validar te lo avisa).
5. **Guardá** la zona nueva: recién ahí queda en la región.

---

## 9. Validaciones (qué revisa)

- Que cada salida se pueda caminar (no sea sólido ni agua).
- Que cada salida empalme con la de la zona vecina.
- Que haya un camino caminable desde la plaza hasta cada salida.
- Que el inicio del juego no caiga en algo sólido o en el agua.
- Que haya pasto alto (si no, avisa que no van a aparecer salvajes).
- Que no haya tiles ni objetos afuera del tamaño de la zona.
- Errores que bloquean el guardado: id vacío o repetido, zonas encimadas.

---

## 10. Recetas rápidas

- **Un camino**: Pinceles → Arena (o Tierra) → Rectángulo (R) → arrastrar. Los bordes salen solos.
- **Un lago**: Pinceles → Agua → Rectángulo relleno. Para achicarlo, clic derecho sobre el borde.
- **Una zona de salvajes**: Pinceles → Pasto alto → Pincel tamaño 3 → pintar. Comprobalo con Ver → Resaltar tag → `pasto_alto`.
- **Un pueblo**: Sellos → elegí el lugar (por ejemplo Pueblo Paleta) → clic para cada casa. Completá con caminos de
  arena y con cercas o carteles desde Tiles → Tipo "Cercas y obstáculos" o "Carteles".
- **Un bosque**: Pinceles → Árbol → Rectángulo relleno (pone árboles cada 2 celdas). Los bordes de la zona, con Borde ↑ ↓ ← →.
- **Copiar un pedazo de otra zona**: Selección (M) → Ctrl+C → cambiás de zona → Ctrl+V → clic.
- **Un gráfico que no tiene colisión y debería**: Gotero (Alt+clic) sobre él → pestaña Tile → Colisión "Sólida" →
  Aplicar. Con F3 lo ves en rojo.

---

## 11. Cosas para saber

- **Lo que editás está protegido**: las zonas guardadas con el editor quedan marcadas. Si alguien regenera el
  mundo con `tools/build_world.gd -- --force`, esas zonas no se pisan (solo con `--force-all`).
- Los **tipos** de la paleta (edificio, roca, árbol...) se calcularon automáticamente con los mapas de FireRed y a
  veces se equivocan. Corregilos en la pestaña Tile: lo que corregís no se pierde aunque se vuelvan a importar los gráficos.
- Las animaciones propias de algunos tilesets (fuentes, luces) todavía se ven quietas. El agua y las flores sí se mueven.
- También se puede seguir retocando una zona en el editor de Godot: usa el mismo TileSet, pero ese editor no
  conoce estas reglas (bordes automáticos, árboles con sombra, etc.).

## 12. Si algo sale mal

- **Me equivoqué**: Ctrl+Z, tantas veces como haga falta.
- **Guardé algo que no quería**: en `scenes/world/zones/.backup/` están las últimas 5 versiones de cada zona
  (`<zona>_<fecha>.tscn`). Copiá la que quieras sobre `scenes/world/zones/<zona>.tscn`.
- **Rompí un gráfico en la pestaña Tile**: hay copias del TileSet en `art/tiles/.backup/`.
- **El ícono no abre nada**: si moviste la carpeta del proyecto o la de Godot, hay que volver a crear el ícono y
  el acceso directo (pedíselo a Claude).
