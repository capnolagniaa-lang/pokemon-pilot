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
