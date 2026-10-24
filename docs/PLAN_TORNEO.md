# Plan: Torneo de entrenadores en Ciudad Plateada

> Idea del usuario (2026-10-23): un edificio de torneos en Ciudad Plateada (la ciudad del gimnasio de Brock). Pagás
> una entrada, jugás una liga de torneo con 3 o 6 Pokémon, y si ganás te llevás el premio en dinero; si perdés,
> perdés la entrada. Solo se pueden usar 6 Pociones, que vienen con la entrada. La arena tiene que ser **épica**
> (agua, rocas, etc.). Los **entrenadores con memoria (como Brock) participan con su equipo y aprenden de vos**.
> El **tope de nivel es para tu entrada, pero jugás con tu propio equipo** (no se nivela a nadie).
> **Estado (2026-10-23): T-0 a T-3 hechas** (dinero, edificio, torneo, estadio). Falta **T-4** (rivales que aprenden:
> depende de E-2 a E-4). Decisiones: el usuario dijo "mandale" → se tomaron las recomendadas de la sección 5.

## Cómo quedó (T-0 a T-3)
- **T-0 Dinero**: `GameState.money` (empieza en $3000, se guarda), `add_money`/`spend_money`, `Events.money_changed`.
  Ganarle a un entrenador da premio (`TrainerData.prize`; 0 = automático: nivel más alto de su equipo × 20, × 60 los
  líderes: Brock da $840). Se ve en la Mochila y en la Tarjeta. Perder no cuesta plata (por ahora).
- **T-1 Edificio**: la puerta del **anexo rosa del museo** de Plateada (39,4) lleva al **Torneo de Ciudad Plateada**
  (zona `ciudad_plateada_torneo`, interior estilo vestíbulo, en `kanto.tres`). Adentro: la recepcionista y gente que
  te cuenta las reglas.
- **T-2 Torneo** (`Tournament`, nodo del mundo, `world.tournament`; acción "torneo" de la recepcionista):
  - 6 copas (`TournamentCup`, `data/tournament/`): Nv. 15 / Nv. 30 / Libre, de 3 y de 6 Pokémon (entrada $500-$5000,
    premio $3000-$35000).
  - Se inscriben **los primeros 3 o 6 de tu equipo con nivel ≤ tope** (cambiás el orden en Esc → Equipo). Peleás con
    ellos tal cual.
  - Pagás, tu equipo y tu Mochila quedan guardados; adentro solo los inscriptos (curados al empezar) y **6 Pociones**.
    **No se cura entre rondas.** Si guardás en medio, se guarda tu equipo y Mochila de antes (el torneo se abandona).
  - Cuadro de 8, eliminación directa (cuartos, semi, final; las otras peleas se definen por fuerza + suerte). Cartel
    de cada ronda y locutor. Ganar la final: el premio y la bandera `campeon_<copa>`. Perder: afuera, sin devolución.
  - Rivales: **Brock** (desde que tenés la Medalla Roca; en el modo libre, siempre) con su equipo de roca que crece
    con la copa (Graveler desde Nv. 25, más Pokémon en la de 6), **Azul** (desde la Ruta 22) con su inicial, y
    entrenadores generados (clases y sprites de FireRed, Pokémon con kit).
- **T-3 Estadio** (`arena_torneo`, `tools/build_arenas.gd`): cancha de tierra, **dos lagunas** a los costados (agua de
  verdad: moja, frena, los de agua nadan), **pasto alto** en las esquinas (se prende fuego), rocas de cobertura y rocas
  que se rompen; **tribunas con público** que salta, **confeti**, braseros, rayos de luz y el emblema de una Poké Ball.
- Autotest `--autotest-tournament` (15 chequeos); vitrina `--showcase-tournament`.
- **Modo de prueba** (desde el título, "Probar el torneo"; `scripts/ui/tournament_test_setup.gd`): elegís hasta 6
  Pokémon (los que tienen kit), el nivel y la copa; aparecés en el vestíbulo y se juega la copa sin entrada. Brock y
  Azul siempre están en el cuadro. **No se guarda nada**. Al terminar: "Jugar otra vez" o "Volver al título".

## 1. Cómo se juega
1. **Edificio del Torneo** en Ciudad Plateada: recepcionista + cartel con las copas.
2. Elegís la copa:
   - **Copa 3**: inscribís 3 Pokémon de tu equipo.
   - **Copa 6**: inscribís 6 (más cara, mejor premio).
   - Cada copa tiene un **tope de nivel para inscribirse** (ej. Copa Nv. 15 / Nv. 30 / Libre): los Pokémon que
     inscribís no pueden pasar ese nivel. **Peleás con tu equipo tal cual** (sin nivelar).
3. Pagás la **entrada** y te dan **6 Pociones del torneo**. Mientras dura el torneo tu Mochila normal queda bloqueada
   (solo las 6 del torneo); al salir, las que sobraron se pierden.
4. **Eliminación directa** de 3 rondas (8 participantes): cuartos, semifinal y final. Cada pelea es en la **arena del
   torneo**, 1 contra 1 con cambios (como contra cualquier entrenador).
5. **Ganás la final** → premio en dinero (+ trofeo/registro). **Perdés una pelea** → quedás afuera y perdés la entrada.

## 2. Los rivales
- **Entrenadores con memoria** (los "entrenadores vivos" de `PLAN_ENTRENADORES.md`): **Brock**, **Azul** (rival) y los
  que se vayan sumando (Valeria, Tomás...) se anotan con **su equipo** y **recuerdan cómo peleás** (qué atacás, cómo
  esquivás, si peleás de lejos o de cerca). En la próxima pelea (en el torneo o fuera) ajustan su estrategia: el
  torneo es la forma de **enfrentarlos muchas veces** y verlos aprender.
- El resto del cuadro se completa con **entrenadores del torneo** generados (especies de la zona con kit, nivel
  cerca del tope de la copa), para que el cuadro cambie cada vez.
- **Dependencia importante**: la memoria y la estrategia que cambia son las fases **E-2 a E-4** del plan de
  entrenadores (IA con perillas, observador + memoria, planificador). Hoy Brock es un entrenador **fijo** (decisión
  del capítulo 1). Para que "aprenda de vos" hay que hacer E-2→E-4 y pasar a Brock y Azul al sistema con memoria
  **fuera de la historia** (en la historia siguen como en FireRed; en el torneo y revanchas, con memoria).

## 3. La arena del torneo (épica)
Un estadio grande (más que la arena común, como el gimnasio de roca) armado con tiles de FireRed + `ArenaDecor`, pero
**usando el entorno reactivo** que ya existe:
- **Agua**: un canal o estanque en la cancha (moja, Poliwag se desliza, los de agua nadan, el eléctrico la electrifica).
- **Rocas**: cobertura y **rocas que se rompen**.
- **Pasto** en los costados (se prende fuego).
- **Tribunas**, luces de estadio, cartel de **ronda** ("CUARTOS DE FINAL"), presentación de cada rival, y en la final
  un show más grande (temblor, luces, banner del campeón).
- La cancha puede **variar por ronda** (ej. la final con más agua y rocas).

## 4. Lo que hay que construir (fases)
| Fase | Contenido | Depende de |
|---|---|---|
| **T-0 Dinero** | `GameState.money` (se guarda), premio al ganarle a un entrenador, se muestra en el HUD / Tarjeta; Tienda que vende (opcional en T-0) | — |
| **T-1 Edificio** | Interior en Plateada (coordinar con el agente de mapas: un edificio existente o uno nuevo con su puerta), recepcionista con menú de copas | T-0 |
| **T-2 Torneo** | Inscripción (copa, 3/6 Pokémon, tope de nivel), entrada, 6 Pociones del torneo y Mochila bloqueada, cuadro de 8, rondas, premio | T-1, E-1 |
| **T-3 Arena** | Estadio épico con agua, rocas, pasto, tribunas, luces, carteles de ronda | T-2 |
| **T-4 Rivales con memoria** | Brock/Azul/vivos se anotan con su equipo y aprenden (usa E-2→E-4) | E-2, E-3, E-4 |

T-0 a T-3 se pueden hacer **antes** de la memoria (los rivales del torneo pelean como hoy); T-4 llega cuando estén
E-2→E-4 y ahí el torneo pasa a ser donde los entrenadores te estudian.

## 5. Decisiones (a confirmar)
1. **¿Se cura entre rondas?** (rec.) **No**: las 6 Pociones son para todo el torneo y hay que administrarlas. Alternativa:
   curar entre rondas y que las Pociones sean para dentro de cada pelea.
2. **Copas y topes**: (rec.) Copa Nv. 15, Copa Nv. 30 y Copa Libre, cada una en versión 3 y 6 Pokémon.
3. **Entradas y premios**: (rec.) entrada = 10% del premio aprox.; premios a balancear cuando exista el dinero
   (ej. Copa 3 Nv. 15: entrada 500, premio 3.000).
4. **Cada cuánto**: (rec.) cuando quieras (todavía no hay reloj); más adelante, una vez por día de juego.
5. **Brock en el torneo**: (rec.) con el mismo equipo del gimnasio pero que **crece** con el tiempo (sube de nivel y
   suma Pokémon de roca), así sigue siendo un rival en serio.
