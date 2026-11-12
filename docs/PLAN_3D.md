# Plan del port a 3D (Pokémon Pilot 3D)

Decisión del usuario (2026-11-12): hacer una versión 3D del juego con historia, en **Godot**, como **proyecto nuevo**
pensado en 3D, con modelos propios generados con IA local. Primer alcance: **de Pueblo Paleta a Ciudad Plateada**, con
los Pokémon que aparecen en ese tramo. El juego 2D sigue en `main`, jugable, sin tocarse.

## Qué se probó antes de decidir (rama `mundo3d`)

- **Vista 3D del juego 2D** (`--view3d`): el mismo juego dibujado en 3D con los tiles parados. Funciona pero se ve mal:
  descartado como camino. Dejó una certeza: la lógica (historia, combate, IA, guardado) no depende de cómo se dibuja.
- **Pipeline de modelos**: Qwen 2.1 (imagen de concepto) → TRELLIS.2 nativo de ComfyUI (malla con textura, `.glb`) →
  Godot. Probado con una casa, un árbol y Bulbasaur: la casa y el árbol salen muy bien; Bulbasaur se reconoce, con
  detalles a cuidar (ojos, pose). Entre 7 y 20 minutos por modelo en la RTX 5060 Ti.
- **Animación sin esqueleto**: Bulbasaur camina, embiste y recibe golpes animado por código (salto, estirar y aplastar,
  inclinarse). Alcanza para criaturas; para personas no.

Scripts: `tools/model3d/` de la rama `mundo3d` (`concepts.py`, `run_trellis.py`, `blender_views.py`).

## ESTADO VIGENTE (2026-11-12): en pausa hasta que el usuario avise

El usuario aprobó el enfoque y pidió dejarlo en espera: necesita la placa para otras cosas. **No correr nada que use la
placa (ComfyUI, renders de Godot) hasta que diga de retomar.** Orden acordado al retomar: **primero el mundo** (verlo
lindo y con colisiones), después los Pokémon.

**Hecho** (todo en la rama `mundo3d`, carpeta `../pokemon-tiempo-real-3d`):
- Modelos: `models3d/casa.glb`, `arbol.glb`, `bulbasaur.glb`. Conceptos sin convertir: `art_src/model3d/laboratorio.png`
  y `art_src/model3d/pokemon/` (Charmander, Squirtle, Caterpie).
- `tools/export_plan3d.gd`: saca el plano de una zona del mapa 2D (`data/plan3d/<zona>.json`: qué hay en cada celda,
  qué choca, puertas). Hecho para Pueblo Paleta.
- `scenes/proto3d/town3d.tscn` (`scripts/proto3d/town3d.gd`): arma la zona en 3D desde su plano: suelo con camino y
  bosque, agua, árboles (solo el borde del bosque), cercos, carteles, flores, casas en su lugar, colisión celda por
  celda y cámara en tercera persona con brazo que no atraviesa cosas. Corrió una vez: se ve el pueblo y la colisión
  frena al personaje.
- Instalado fuera del repo: Blender 4.5 en `tools/blender/`, modelos de TRELLIS.2 en ComfyUI.

**Lo primero al retomar** (etapa 3D-2, mundo):
1. Convertir el laboratorio a 3D (`run_trellis.py`, unos 20 minutos) y revisar Paleta completa: hoy el laboratorio es
   una caja blanca y el recorrido de demostración se traba contra un cartel.
2. Pulir Paleta hasta que se vea linda: escala de las casas, buzones, flores y carteles con modelo propio, borde del
   mundo, pasto con volumen, salientes con altura.
3. Sumar Ruta 1 (pasto alto, salientes) y Ciudad Verde, y la unión entre zonas.
4. Recién ahí, el proyecto nuevo (3D-0) y los Pokémon (3D-1).

## Qué se trae del juego 2D y qué se hace de nuevo

| Se trae tal cual | Se reescribe para 3D |
|---|---|
| Datos: especies, ataques, tipos, objetos, encuentros, entrenadores, habilidades | Movimiento y colisiones |
| Fórmulas de stats, daño, EXP y captura | Formas de los ataques en el espacio (disparo, zona, golpe, embestida) |
| Diálogos, banderas y disparadores de la historia | IA de posición (la que decide qué ataque usar se adapta) |
| Guardado (`GameState`) | Mundo, cámara, efectos, día y noche |
| Mapas de FireRed como plano (dónde hay piso, agua, pared, puerta) | Menús y HUD (se rehacen con el mismo estilo) |

## Alcance del primer tramo

**Zonas**: Pueblo Paleta, Ruta 1, Ciudad Verde, Ruta 22, Ruta 2, Bosque Verde, Ciudad Plateada, y sus interiores
(casas, laboratorio de Oak, Centros Pokémon, Tiendas, gimnasio de Brock).

**Pokémon (19)**: Bulbasaur, Charmander, Squirtle (iniciales); Pidgey, Rattata, Spearow, Mankey, Psyduck, Tentacool,
Caterpie, Metapod, Weedle, Kakuna, Pikachu (salvajes); Butterfree, Beedrill (evoluciones a mano); Geodude, Onix,
Sandshrew (gimnasio de Brock).

## Etapas

| Etapa | Qué | Se ve cuando termina |
|---|---|---|
| **3D-0** | Proyecto nuevo, datos copiados, base (`DB`, `GameState`, `Events`), tests | Arranca y carga las 386 especies |
| **3D-1** | Modelos: los 19 Pokémon y el kit de piezas del mundo (casas, laboratorio, Centro, Tienda, gimnasio, árboles, cercos, carteles, pasto alto, rocas) | Vitrina con todos los modelos |
| **3D-2** | Mundo: las zonas construidas desde los mapas, con terreno, agua, salientes, colisión, carga por zonas y puertas | Se camina de Paleta a Plateada |
| **3D-3** | Entrenador con esqueleto y cámara en tercera persona con colisión; teclado, mouse y joystick | Se recorre con el personaje definitivo |
| **3D-4** | Pokémon en el mundo: el tuyo te sigue, salvajes con su IA, animación por código | Hay Pokémon vivos en las rutas |
| **3D-5** | Combate en tiempo real 3D: ataques, daño, estados, esquive, HUD | Se pelea contra salvajes |
| **3D-6** | Captura, Mochila, equipo, menús, guardado | Se atrapa, se cura, se guarda |
| **3D-7** | Historia hasta Brock: personas, diálogos, entrenadores, gimnasio | Se juega de tu cuarto a la Medalla Roca |
| **3D-8** | Pulido: día y noche, sonido, efectos, versión para los amigos | Se puede mostrar |

Cada etapa termina con test automático, capturas y commit.

## Decisiones de diseño pendientes (del usuario)

1. **Estilo visual**: el de la prueba (juguete estilizado, colores planos) u otro.
2. **Kanto**: fiel al trazado de FireRed (mismos caminos, agrandado) o rediseñado con más libertad.
3. **Interiores**: en 3D completo con la misma cámara, o con cámara fija por cuarto.
4. **Cámara de combate**: detrás de tu Pokémon (como la prueba) o más alejada, tipo arena.
5. **El entrenador**: cómo se ve y de dónde sale su modelo y sus animaciones.

## Riesgos

- **Personas**: un humano necesita esqueleto y animaciones de verdad. Es lo menos probado del pipeline.
- **Tiempo de máquina**: 10 a 20 minutos por modelo. El primer tramo son unas horas; los 386 Pokémon, varias noches.
- **Consistencia**: cada modelo sale de una imagen distinta; hay que cuidar que parezcan del mismo juego (mismo texto de
  estilo, misma luz, revisión de cada uno).
- **Animación por código**: sirve para caminar, embestir y recibir golpes. Disparar, volar, dormir o debilitarse van a
  pedir más trucos, o esqueleto en los Pokémon importantes.
- **Rendimiento**: 30.000 caras por Pokémon está bien para pocos en pantalla; con muchos hay que bajar caras o usar
  versiones livianas a distancia.
