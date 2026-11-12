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
