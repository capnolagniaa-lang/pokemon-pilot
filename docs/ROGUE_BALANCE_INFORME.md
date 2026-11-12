# Modo Desafío — informe de balance

Generado por `tools/rogue_balance.py` (no editar a mano: se pisa). Pasada del 2026-11-12, después de los ajustes.

Un bot juega partidas enteras: salas al azar, puertas, recompensas, Tienda y la pelea con Brock de verdad. El bot esquiva 70 % de los golpes que ve venir, tira ataques de daño al azar, toma la Poción bajo 45 % de vida y elige bendiciones y objetos al azar. **Juega peor que una persona atenta** (no arma combinaciones, no apunta con criterio, no guarda PP): sus números son un piso.

Números del piso al medir: EXP ×0.8, esbirros con 50 % de vida, 4 atacando a la vez, 4 Pociones, cura 35 % por sala.

## Lectura de los datos y ajustes hechos (a mano; el resto del informe se genera solo)

**Pasada del 2026-11-11/12.** 1.518 partidas en total: 321 de línea base y 663 aisladas antes de ajustar, 322 de línea
base y 212 aisladas después. Cada ajuste de abajo salió de un dato, no a ojo.

### Qué mostró la primera pasada
1. **El inicial pesa más que cualquier objeto.** Squirtle le ganaba a Brock 68 % de las partidas (84 % de las veces que
   llegaba: Agua contra Roca/Tierra), Bulbasaur 10 % y Charmander 0 %. Hasta la sala 3 los tres van iguales (mismo
   tiempo y misma vida); se separan en las salas 4-5 (élites) y en Brock.
2. **Ningún objeto ni bendición está roto por sí solo.** Con uno solo de entrada (común, Nv. 1), el que más empuja hace
   avanzar ~0,4 salas sobre 6. Lo que sí se mide bien es la **velocidad para limpiar las 3 primeras salas**: Casco
   Dentado −14 % de tiempo (z −4,3 con 30 partidas), Brasas Vivas −10 % (z −3,3), Ventisca y Carbón −8 % (z ~ −2).
3. **Los que más ayudan a sobrevivir son los que curan**: Restos y Campana Concha (+0,4 de avance, z 2,1).
4. **Varios no se notan**: Periscopio, Pañuelo Elegido, Roca del Rey, Baya Zidra (Δ ≤ 0 con 30 partidas).

### Ajustes (antes → después) y qué pasó al volver a medir
| Qué | Antes | Después | Dato que lo motivó | Resultado medido |
|---|---|---|---|---|
| Brock: mejora fija **Curtido** en sus dos Pokémon | — | recibe 30 % menos de lo súper efectivo (Nv. 2: 45 %) | Squirtle ganaba 84 % de las veces que llegaba | Squirtle: de 68 % a 55 % de victorias (73 % de las que llega); global de 26 % a 20 % |
| Casco Dentado | 0,5 de poder cada 2 s | 0,35 cada 2,5 s | limpiaba las salas 14 % más rápido | ahora 6 % más rápido (z −2,3): sigue siendo bueno, ya no se despega |
| Restos | 0,6 % de vida por segundo | 0,5 % | +0,37 de avance (z 2,1), el más alto | +0,46 (z 2,3): **no cambió** (la diferencia es azar); sigue siendo el mejor de supervivencia |
| Campana Concha | cura 6 % del daño | 5 % | +0,41 de avance (z 2,1) | −0,04: dentro del error; con 30 partidas no se distingue de no tener nada |
| Periscopio | 12 % de crítico | 18 % | sin efecto medible | sigue sin notarse (+0,09) |
| Pañuelo Elegido | +10 % de velocidad | +15 % | sin efecto medible | sigue sin notarse (el bot no aprovecha la velocidad: no es buen juez de esto) |
| Roca del Rey | 10 % de dejar sin actuar | 14 % | sin efecto medible | de −0,16 a +0,13 (dentro del error) |
| Baya Zidra | cura 15 % | 20 % | sin efecto medible | +0,16 (dentro del error) |

**Global: el bot que esquiva 70 % pasó de ganarle a Brock 26 % (84 de 321) a 20 % (65 de 322)**, y llega igual que antes
(43 % → 45 %). Queda dentro del objetivo de 15-25 % sin progreso permanente.

### Comprobación sobre las salas finales (2026-11-12, tercera línea base)
Después de estos ajustes la otra sesión rearmó otra vez las 36 salas (paso más ancho, paredes sólidas, orilla sin hilera
sólida). Se corrió otra línea base entera sobre esas salas, sin tocar ningún número: **324 partidas, llega a Brock 41 %
(132) y le gana 23 % (73)**; Squirtle 64 %, Bulbasaur 4 %, Charmander 0 %. Sigue dentro del objetivo de 15-25 %, así que
no se ajustó nada más. Las tres líneas base (26 % antes; 20 % y 23 % después) tienen un margen de ±5 puntos cada una: el
efecto de los ajustes es real pero chico, y la diferencia entre iniciales sigue siendo lo que más pesa. Al bot se le
trabó el camino 12 veces en 324 partidas (antes del primer arreglo de las salas eran ~85 en 657) y ninguna partida quedó
trabada en plena oleada.

### Criterio (bot contra persona)
El bot esquiva 70 % de lo que ve venir pero elige ataques al azar, no apunta, no guarda PP, no arma combinaciones de
bendiciones y gasta las Pociones apenas baja de 45 %. Una persona atenta juega mejor: mi estimación es que quien ya
conoce el juego le gane a Brock entre 30 y 45 % de las primeras partidas con Squirtle o Bulbasaur, y bastante menos con
Charmander. Si al jugarlo resulta fácil, lo primero a tocar es `boss.mod_level` y el valor de Curtido; si frustra antes
de llegar, `attackers` (4 → 3) y `minion_hp`.

### Lo que no se pudo medir o queda flojo
- **Charmander no le ganó nunca a Brock** (0 de 34 veces que llegó, sumando las dos pasadas) y llega poco (13-19 %).
  Parte es del bot (usa Arañazo y Garra Metal al azar y se mete entre los enemigos); parte es real (Fuego contra Roca).
  No se compensó facilitando las salas: es justo el caso que el progreso permanente debería resolver (una MT de entrada).
- **Combinaciones**: se midió cada cosa sola. No se midió qué pasa con dos o tres juntas (Garra Ardiente + Brasas
  Vivas + Combustión, por ejemplo), que es donde suele aparecer lo roto de verdad. La batería lo permite
  (`--give a,b,c`), falta correrlo.
- **Rareza y nivel**: todo se midió en común, Nv. 1. Una legendaria Nv. 3 multiplica sus números ×1,8 × 1,5.
- **Bendiciones atadas a una ranura** (Ventisca al Ataque 3, Estallido Ígneo al 4): si en esa ranura hay un ataque de
  estado no hacen nada. Ventisca salió floja por eso (−0,33). Es un problema de diseño, no de números.
- **Con 30 partidas por objeto, un efecto menor a ~0,4 salas no se distingue del azar.** Para afinar los flojos hacen
  falta ~100 partidas por objeto (unas 5 horas la tanda completa).
- **La muestra de "antes" quedó mezclada**: mientras corría, la otra sesión rearmó las 36 salas (menos densidad y
  colisión de piezas corregida). El "después" corrió entero sobre las salas nuevas.
- **Política "rareza"** (elegir siempre la mejor rareza) y simulaciones "con X de entrada": están hechas en la batería
  pero no se corrieron tandas largas.

## Línea base (sin nada de entrada)

|  | Partidas | Llega a Brock | Le gana | Avance medio (0-6) | Nivel al jefe | Daño recibido por sala | Trabadas |
|---|---|---|---|---|---|---|---|
| Todos | 322 | 45 % (144) | 20 % (65) | 4.44 | 14.0 | 95 | 2 |
| Charmander | 106 | 19 % (20) | 0 % (0) | 3.77 | 13.9 | 111 | 2 |
| Squirtle | 108 | 75 % (81) | 55 % (59) | 5.27 | 14.0 | 78 | 0 |
| Bulbasaur | 108 | 40 % (43) | 6 % (6) | 4.27 | 14.0 | 100 | 0 |

**Antes de los ajustes** (misma batería, datos de `bal_v1`):

|  | Partidas | Llega a Brock | Le gana | Avance medio (0-6) | Nivel al jefe | Daño recibido por sala | Trabadas |
|---|---|---|---|---|---|---|---|
| Todos | 321 | 43 % (139) | 26 % (84) | 4.49 | 14.0 | 94 | 3 |
| Charmander | 108 | 13 % (14) | 0 % (0) | 3.74 | 14.0 | 112 | 0 |
| Squirtle | 108 | 81 % (87) | 68 % (73) | 5.48 | 14.0 | 75 | 0 |
| Bulbasaur | 105 | 36 % (38) | 10 % (11) | 4.25 | 14.0 | 102 | 3 |

**Dónde termina la partida**: Brock: 25 % · Ganó: 20 % · Sala 3: 2 % · Sala 4: 17 % · Sala 5: 36 % · Sala 6: 0 %

**Recompensas que tocaron** (por sala limpiada): bendicion 45 % · objeto 17 % · mt 10 % · centro 6 % · dinero 6 % · proteina 6 % · caramelo 5 % · bola 4 % · tienda 2 %

**Al bot se le trabó el camino** (más de 25 s para llegar a una puerta o al paso; se lo llevó ahí y la partida siguió): sala_bosque_p2:puerta ×4, sala_bosque_p5:puerta ×4, sala_cueva_p1:eleccion ×3, sala_cueva_p5:eleccion ×2, sala_volcan_p5:eleccion ×2, sala_cueva_p1:puerta ×2, sala_volcan_p4:eleccion ×2, sala_cueva_p3:eleccion ×1, sala_hielo_p2:eleccion ×1, sala_cueva_p2:eleccion ×1, sala_hielo_p6:puerta ×1, sala_bosque_p4:puerta ×1, sala_volcan_p4:puerta ×1, sala_cementerio_p5:eleccion ×1, sala_hielo_p2:puerta ×1, sala_bosque_p1:puerta ×1

**Partidas trabadas** (nadie pega por 45 s; no cuentan): 2 — sala_volcan_p4:oleada ×2

## Cada objeto y cada bendición, sola (arrancando la partida con esa sola, común, Nv. 1)

Así se ve cuánto empuja cada una sin el sesgo de "la tenía porque llegó lejos". **Avance** = salas limpiadas + 1 si le ganó a Brock (0 a 6). **Δ** = cuánto más avanza que la línea base (del mismo inicial en los potenciadores de tipo). **z** = Δ en errores estándar (|z| < 2 = puede ser azar). Media de los Δ: +0.17; desvío: 0.20. **ROTO** = Δ más de 1,5 desvíos por encima de la media y z ≥ 2. **Flojo** = Δ ≤ 0 (no se nota que ayude).

| | Clase | Partidas | Avance | Δ | z | Llega a Brock | Le gana | Daño recibido por sala | Daño hecho por sala | |
|---|---|---|---|---|---|---|---|---|---|---|
| Restos | objeto | 30 | 4.90 | +0.46 | +2.3 | 67 % | 37 % | 100 | 353 | fuerte |
| Casco Dentado | objeto | 30 | 4.87 | +0.43 | +2.2 | 57 % | 37 % | 86 | 330 | fuerte |
| Baya Zidra | objeto | 30 | 4.60 | +0.16 | +0.9 | 50 % | 20 % | 105 | 350 |  |
| Roca del Rey | objeto | 30 | 4.57 | +0.13 | +0.8 | 47 % | 17 % | 97 | 344 |  |
| Periscopio | objeto | 30 | 4.53 | +0.09 | +0.4 | 53 % | 23 % | 90 | 327 |  |
| Pañuelo Elegido | objeto | 30 | 4.40 | -0.04 | -0.2 | 43 % | 20 % | 95 | 340 | flojo |
| Campana Concha | objeto | 30 | 4.40 | -0.04 | -0.2 | 40 % | 20 % | 107 | 354 | flojo |

## En las partidas de la línea base: qué se llevó y cómo le fue

Ojo: acá hay sesgo (cuanto más lejos llega una partida, más cosas junta). Sirve para ver **qué aparece y cuánto**, no para decidir nerfeos; para eso está la tabla de arriba.

| | Clase | La tuvo | Avance con ella | Avance sin ella | Le gana a Brock con ella |
|---|---|---|---|---|---|
| Toque Gélido | bendición | 13 % (43) | 4.49 | 4.43 | 23 % |
| Rayo Celeste | bendición | 13 % (42) | 4.67 | 4.41 | 21 % |
| Garra Ardiente | bendición | 12 % (39) | 4.46 | 4.44 | 23 % |
| Estallido Ígneo | bendición | 12 % (38) | 4.71 | 4.40 | 32 % |
| Estela de Fuego | bendición | 11 % (36) | 4.64 | 4.42 | 17 % |
| Rayo en Cadena | bendición | 11 % (35) | 4.51 | 4.43 | 17 % |
| Pila Cargada | bendición | 11 % (34) | 4.35 | 4.45 | 24 % |
| Combustión | bendición | 11 % (34) | 4.35 | 4.45 | 9 % |
| Aliento Polar | bendición | 11 % (34) | 4.59 | 4.42 | 26 % |
| Coraza de Escarcha | bendición | 10 % (33) | 4.67 | 4.42 | 33 % |
| Hielo Quebradizo | bendición | 10 % (33) | 5.00 | 4.38 | 30 % |
| Golpe Estático | bendición | 10 % (33) | 4.67 | 4.42 | 33 % |
| Sobrecarga | bendición | 10 % (32) | 4.56 | 4.43 | 25 % |
| Paso de Trueno | bendición | 10 % (31) | 4.55 | 4.43 | 19 % |
| Estela Helada | bendición | 9 % (30) | 4.43 | 4.44 | 20 % |
| Ventisca | bendición | 9 % (28) | 4.75 | 4.41 | 29 % |
| Pañuelo Elegido | objeto | 8 % (27) | 4.96 | 4.39 | 41 % |
| Ave Fénix | bendición | 8 % (26) | 4.46 | 4.44 | 15 % |
| Cinta Focus | objeto | 8 % (26) | 4.58 | 4.43 | 23 % |
| Brasas Vivas | bendición | 8 % (26) | 4.73 | 4.42 | 35 % |
| Pañuelo Seda | objeto | 6 % (20) | 4.70 | 4.42 | 15 % |
| Campana Concha | objeto | 6 % (20) | 5.20 | 4.39 | 40 % |
| Periscopio | objeto | 5 % (17) | 4.71 | 4.43 | 24 % |
| Garra Rápida | objeto | 5 % (17) | 4.82 | 4.42 | 29 % |
| Baya Zidra | objeto | 5 % (15) | 4.47 | 4.44 | 13 % |
| Huevo Suerte | objeto | 4 % (14) | 4.43 | 4.44 | 21 % |
| Casco Dentado | objeto | 4 % (13) | 5.08 | 4.41 | 46 % |
| Restos | objeto | 4 % (12) | 4.83 | 4.43 | 25 % |
| Roca del Rey | objeto | 3 % (10) | 5.00 | 4.42 | 20 % |
| Moneda Amuleto | objeto | 3 % (10) | 4.20 | 4.45 | 10 % |
| Agua Mística | objeto | 3 % (9) | 5.22 | 4.42 | 44 % |
| Semilla Milagro | objeto | 2 % (6) | 4.17 | 4.45 | 0 % |
| Carbón | objeto | 2 % (5) | 4.20 | 4.44 | 0 % |
| Revestimiento Metálico | objeto | 1 % (3) | 4.67 | 4.44 | 0 % |
| Cinturón Negro | objeto | 0 % (1) | 4.00 | 4.44 | 0 % |

