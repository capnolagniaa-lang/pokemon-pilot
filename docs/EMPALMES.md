# Empalmes entre zonas (revisión 2026-10-31)

Pedido del usuario: revisar todos los empalmes de las rutas (al agrandar los mapas de FireRed algunas zonas no
quedaban bien unidas) y las cercas y cosas de más que no deberían estar.

**Cómo se revisó.** `python -I -B tools/check_seams.py . [--png <carpeta>]` recorre cada borde entre dos zonas
exteriores: cuántas celdas se cruzan caminando, qué caminos dan contra algo sólido del otro lado, si el agua sigue, y
avisa si dos mapas que en FireRed están conectados no se tocan. Además se comparó cada una de las 42 zonas exteriores con
su mapa original de FireRed, una al lado del otro.

## Lo que estaba mal y se arregló (en `tools/import_frlg_maps.py`)

| Problema | Dónde | Arreglo |
|---|---|---|
| Cercas dobles, partidas en escalón o con huecos, y salientes apilados (dos o tres seguidos donde FireRed tiene uno). Las costuras que agrandan el mapa copiaban filas que pasaban por la cerca. | Casi todas: Ruta 1, Verde, Ruta 22, Ruta 2, Plateada, Ruta 3, Celeste, Fucsia, Ruta 15... (31 zonas) | `straighten_lines`: cada tramo de cerca o saliente del original queda en una sola fila (o columna); lo corrido vuelve a su línea y el hueco se tapa con el suelo de al lado; los huecos que abrió el ensanche se cierran, las entradas del original quedan abiertas. |
| Ciudad Fucsia y la Ruta 15 no se tocaban: la salida este de Fucsia daba al vacío, 52 filas más abajo que el camino de la Ruta 15. | Fucsia–Ruta 15 | `EXTEND`: la Ruta 15 se alarga 44 filas hacia abajo con bosque y un camino que baja desde su camino hasta la salida de Fucsia. |
| Una fila de vacío entre Pueblo Paleta y la Ruta 21 (la Ruta 21 Sur no podía crecer lo que le tocaba), y el canal de la Ruta 21 quedaba 20 columnas corrido del estanque de Paleta: no se podía salir surfeando al sur. | Paleta–Ruta 21 | Lo que no alcanza un mapa que cierra un círculo lo toma el otro (`FIT`); `REALIGN` alinea la Ruta 21 Norte con el estanque de Paleta (con la Ruta 21 Sur se toca en mar abierto). |
| Franjas verticales de borde de acantilado y columnas de puntitos en la roca. | Oeste de Ciudad Verde, arriba de la Ruta 22 | El relleno de los costados (`pad`) ya no repite lo que no es textura: ahí va roca lisa. |

Ninguna zona cambió de lugar salvo esas dos (Ruta 15 más larga, Ruta 21 Norte corrida); las puertas, las personas y los
edificios agregados quedan donde estaban (las personas de la Ruta 21 Norte se rearmaron con `build_story_npcs.py`).

## Lo que queda (no corta el paso)

- **Azafrán tiene dos garitas por entrada.** En FireRed el mapa de Ciudad Azafrán incluye las garitas de las rutas 5, 6,
  7 y 8 (las rutas se conectan con otra versión del mapa, sin ellas); acá se usó el mapa completo, así que cada ruta
  tiene su garita y la ciudad otra copia al lado. Se juega bien (entrás por la garita de la ruta y salís por la de la
  ciudad), pero se ven las dos. Arreglarlo bien es sacar la copia de la ciudad y abrir un camino entre el bosque desde
  la garita de cada ruta hasta la entrada (en la Ruta 6 son ~35 celdas): decisión del usuario.
- Bordes donde el agua da contra tierra sin orilla (Ruta 17–18, Ruta 21 Sur–Canela, Ruta 13–14) y cercas que no siguen
  la misma fila de un lado y del otro (Ruta 13–14): cosmético.
- Zonas con mucho espacio vacío por el ensanche (abajo a la derecha de Fucsia): cosmético.
