# Plan: Entrenadores vivos (memoria de combate, rutinas y equipos que evolucionan)

> Plan **separado** del de etapas (`PROGRESO.md`) y del de identidad de combate (`PLAN_IDENTIDAD_COMBATE.md`).
> Propuesto el 2026-10-22 a partir de una idea del usuario. **Estado**: decisiones confirmadas por el usuario el
> 2026-10-23 (las recomendadas de la sección 8; IA en la sección 1b). **E-0 hecha** (ver "Avance").
> Todo el sistema se prende y apaga con el interruptor **"Entrenadores vivos (en prueba)"**, como el modo práctica.

---

## 1. Opinión (Claude)

Es la mejor idea que hay sobre la mesa para que el juego tenga identidad propia, y encaja con lo que ya
construimos: el combate es en tiempo real y **cada Pokémon tiene un estilo** (bruiser, control, asesino...).
Eso hace que "cómo peleás" sea observable y rico. En Pokémon por turnos la IA solo puede recordar *qué*
usaste; acá puede recordar *cómo* lo usaste (distancia, esquives, cuándo rematás). Ese es el diferencial.

Lo que mantendría de la propuesta, y lo que cambiaría:

- **Coincido**: pocos entrenadores con identidad, memoria limitada a lo que vieron, aprendizaje gradual,
  personalidades que reaccionan distinto, contramedidas imperfectas, sin modelos de lenguaje (todo
  determinista y data-driven), y prototipo con 3 entrenadores.
- **La adaptación tiene que hablar el idioma de los kits.** No "la IA es más difícil", sino cambios que se
  entiendan con los estilos que ya existen: "si te alejás, Bellsprout te tira el Látigo Cepa para atraerte";
  "el Charmander del rival guarda la Embestida Ígnea para cuando esquivás"; "ahora trae a su Pidgey para
  desviar tus proyectiles". Técnicamente: la IA tiene **perillas** (rango preferido, agresión, a qué lado
  anticipa tu esquive, qué ataques prioriza, qué Pokémon saca primero) y la memoria solo gira perillas.
  Nada de código por entrenador.
- **Si el jugador no lo nota, no existe.** El mayor riesgo no es técnico: es que la adaptación sea invisible.
  Propongo tres señales: (1) una **frase antes del combate** que delata lo que cree saber ("Esta vez no me vas a
  tener a la distancia"); (2) una **libreta de entrenadores** (pestaña en la Pokédex) con el récord y *lo que
  ese entrenador cree de vos*, así podés engañarlo a propósito; (3) un **overlay de debug** (F10) con sus
  creencias y perillas, para probar.
- **El cuello de botella real es el combate entre entrenadores**, no la memoria. Hoy no existe: hace falta
  desafío, equipos, **cambio de Pokémon (Tab)**, fin de combate y recompensa. Es la base de todo y conviene
  hacerla bien primero.
- **La IA táctica se superpone con la Etapa 4** ("IA salvaje con estados"). Propongo hacerla una sola vez: la IA
  con perillas que use el entrenador la usan también los salvajes (con perillas fijas por especie). Así este
  plan adelanta y absorbe la mitad de la Etapa 4.
- **La vida propia, simple y por horas, no por minutos.** Fuera de pantalla el entrenador no camina: cambia de
  "bloque de rutina" cuando pasa la hora del juego y, al cargarse la zona donde está, aparece ahí. Necesita un
  **reloj del juego** mínimo (sin día/noche visual todavía, eso es la Etapa 5).
- **Equipos que evolucionan, pero lento.** Cambiar el equipo una vez por "semana" de juego como mucho, y solo
  dentro de su pool (especies de las zonas que recorre + preferencias). Nunca aparece "el counter perfecto".
- **Sobre la pregunta de la relación (respeto, rivalidad, miedo, amistad)**: sí, pero en chico. Un solo eje
  (rivalidad ↔ respeto) calculado de los resultados alcanza para cambiar saludos y si te busca o te evita.
  Diálogos ramificados, más adelante.

## 1b. IA de salvajes vs. IA de entrenadores (definido con el usuario el 2026-10-23)

Son **dos IAs distintas** sobre una **capa compartida**:

- **Cuerpo (compartido)** — `CombatBody`: *cómo* se ejecuta: moverse, apuntar, usar bien cada forma de ataque
  (alcance, punto para zonas y embestidas), esquivar, recargas. **La dificultad (Fácil/Normal/Difícil) actúa
  solo acá** (puntería, reflejos, cuánto esquiva), para salvajes y entrenadores por igual.
- **Mente de salvaje = instinto, sin memoria.** Temperamento por especie (datos, `Temperament`):
  **agresivo** (te ataca apenas te ve), **territorial** (solo si entrás a su zona; te persigue poco), **tímido**
  (huye; pelea si lo acorralás o le pegás), **curioso** (se acerca a mirarte). Patrón reconocible: abre siempre
  igual (si estás lejos, con su ataque de acercamiento) y rota sus ataques en orden, sin azar: **el que aprende
  es el jugador**. Reacciona al momento: huye con poca vida, se espanta con un golpe fuerte, sale de lo
  electrificado. Avisos visibles (¡!, ?, gota). **En grupo** (si atacás a uno vienen los demás): más adelante.
- **Mente de entrenador = órdenes + memoria** (este plan, fases E): decide con perillas que ajusta su memoria;
  **grita la orden** ("¡Látigo Cepa!") un instante antes de que su Pokémon la ejecute (personalidad,
  telegrafiado y adaptación visible). La memoria no depende de la dificultad, solo de su personalidad.
- **Orden**: primero cuerpo + salvajes (etapa W), después E-0 en adelante.
- ✅ **Etapa W hecha (2026-10-23)** = Etapa 4a de `PROGRESO.md`: `CombatBody` + temperamentos. Falta "en grupo".

## 2. El interruptor "Entrenadores vivos (en prueba)"

- `GameState.living_trainers: bool` (se guarda en la partida). **Apagado por defecto** mientras se prueba.
- Checkbox en la **elección de inicial** y en **Esc → Opciones**, igual que el modo práctica. El HUD lo muestra
  junto a la dificultad ("IA: Normal · Modo práctica · Entrenadores vivos").
- **Apagado**: no aparecen entrenadores, no se registra memoria, no corre la simulación. El juego queda
  exactamente como hoy (los autotests actuales no cambian).
- **Prendido**: aparecen los 3 entrenadores del prototipo con su rutina y memoria.
- Herramientas de prueba (solo con `-- --debug`): **F10** overlay de memoria/perillas, **F11** adelantar el
  reloj 1 hora, y en Opciones "Borrar memoria de los entrenadores".

## 3. Arquitectura (respeta la del proyecto: data-driven, sistemas por `Events`)

```
TrainerData (.tres, a mano)          TrainerState (en el guardado JSON)
  nombre, sprite, personalidad   →     equipo actual, memoria, relación,
  equipo inicial, pool, rutina          bloque de rutina actual, récord
            │                                       ▲
            ▼                                       │
   LifeSim (reloj + rutinas)   ──►  TrainerNPC en el mundo (si su zona está cargada)
                                            │ te ve / lo encarás
                                            ▼
                         Desafío → TrainerBattle (CombatDirector, equipos, Tab)
                                            │
            TacticalAI (perillas) ◄─────────┤ CombatObserver (registra cómo peleás)
                    ▲                       ▼
            StrategyPlanner  ◄──────  TrainerMemory (creencias con confianza)
```

**Datos** (`data/trainers/<id>/`):
- `TrainerData`: id, nombre, sprite, frases, `PersonalityData`, equipo inicial (especie + nivel + movimientos),
  pool de especies (por zona o lista), rutina (`RoutineBlock`: hora inicio/fin → zona + punto + actividad).
- `PersonalityData`: **velocidad de aprendizaje** (encuentros necesarios para creer algo), **techo de
  inteligencia** (1 memoria · 2 adaptación · 3 planificación), **orgullo** (cuánto resiste cambiar de equipo),
  **agresión base**, **curiosidad** (cuánto captura y prueba especies), **probabilidad de malinterpretar**.

**Sistemas** (cada uno se prueba por separado):
1. **CombatObserver** (solo en combates contra entrenadores): escucha `Events` y muestrea cada 0,25 s. Arma un
   `BattleRecord`: distancia media y % del tiempo lejos/cerca, dirección de esquive *relativa al atacante*
   (atrás / izquierda / derecha), ataques usados (por forma, elemento y ranura), uso de la mecánica de firma,
   si rematás después de un aturdimiento, si cambiás con poca vida, daño por Pokémon, resultado.
2. **TrainerMemory**: junta los `BattleRecord` con olvido gradual (lo viejo pesa menos) y saca **creencias**
   con confianza 0-1: "mantiene distancia 0,7", "esquiva a la derecha 0,6", "depende del fuego 0,8", "remata
   aturdidos 0,4". Solo lo observado: nunca sabe de un Pokémon tuyo que no vio pelear.
3. **StrategyPlanner** (entre combates, nunca durante): convierte creencias + personalidad en un
   `TacticProfile` (las perillas). Respeta las reglas anti-frustración (sección 5).
4. **TacticalAI**: reemplaza la elección al azar de `creature_attack.gd` por una **IA de utilidad** que puntúa
   cada acción (atacar con la ranura X, acercarse, alejarse, esquivar hacia Y) con las perillas. Los salvajes la
   usan con perillas fijas por especie (esto cubre la Etapa 4).
5. **LifeSim**: `GameClock` (hora del juego) + `TrainerScheduler`: en qué bloque está cada entrenador, y efectos
   abstractos por bloque (entrenar = EXP, explorar = chance de capturar del pool de la zona, curarse después de
   perder, buscar rival si la rivalidad es alta y el equipo está listo). Al cargar la zona, aparece el
   `TrainerNPC` en su punto; al descargarla, desaparece (el estado sigue en `TrainerState`).

**Combate contra entrenador** (lo nuevo más grande):
- El NPC te ve (radio + línea de visión), dice su frase y te desafía. Formato propuesto: **hasta 3 Pokémon por
  lado, uno a la vez**; cuando uno se debilita sale el siguiente.
- **Cambio de Pokémon con Tab** (para vos y para él), con una pequeña demora para que no sea gratis.
- Fin: gana quien deja al otro sin Pokémon. Recompensa: EXP (y más adelante dinero/objetos). Con modo práctica,
  perder no tiene castigo.

## 4. Los 3 entrenadores del prototipo (Ruta 1 y alrededores)

| Entrenador | Personalidad | Aprende | Equipo y evolución | Rutina (horas de juego) |
|---|---|---|---|---|
| **Rival** (impulsivo) | Agresión alta, orgullo alto, techo 2 | Rápido, pero cambia poco (orgulloso: sigue con sus Pokémon) | Charmander + Rattata; prefiere rápidos y de daño | 8-12 entrena en Ruta 1 · 14-19 busca combates (te persigue si la rivalidad es alta) |
| **Estratega** (táctica) | Agresión baja, techo 3, malinterpreta poco | Lento al principio, muy preciso | Bellsprout + Pidgey; busca sinergias (control + desvío) | 9-13 estudia en la plaza · 15-18 practica en el Bosque Verde |
| **Explorador** (adaptativo) | Curiosidad alta, orgullo bajo, techo 2 | Medio; cambia el equipo según dónde anduvo | Vulpix + lo que capture en las zonas que recorre | Recorre zonas distintas cada día; descansa de noche |

Ejemplo de adaptación concreta (lo que el prototipo tiene que demostrar): le ganás al Rival dos veces
manteniendo distancia con Ascuas. Para la 3ª pelea creyó "mantiene distancia" con confianza alta: su Charmander
abre con Arañazo (se lanza al punto), guarda Embestida Ígnea para tu esquive y su Rattata sale primero para
cerrarte. Dice: "¡Esta vez no me vas a tener a la distancia!". Si en la 3ª pelea cambiás a pelear de cerca, lo
agarraste desprevenido.

## 5. Reglas anti-frustración (con números iniciales)

1. **Información limitada**: solo creencias sobre lo que vio en combate contra él. Nada de leer tu equipo
   entero ni tu Pokédex.
2. **Gradual**: una creencia necesita confianza ≥ 0,6 para usarse (según la velocidad de aprendizaje: el Rival
   la alcanza en ~2 peleas, el Estratega en ~3). **Máximo 1 ajuste de perillas por revancha** (2 con techo 3).
3. **Personalidad**: el orgulloso no cambia de equipo aunque pierda; el curioso cambia aunque gane.
4. **Imperfecta**: 15-25% de malinterpretar una creencia (ajusta la perilla equivocada); las contramedidas solo
   salen de su pool; las creencias se olvidan (cada combate y cada día de juego pesan menos las viejas).
5. **Revancha con tiempo**: no te vuelve a desafiar hasta que pase al menos un bloque de rutina (o un día).
6. **El jugador puede engañarlo**: como olvida de a poco y necesita confianza, acostumbrarlo a una táctica y
   cambiar funciona, y la libreta te deja ver qué cree.

## 6. Fases (cada una deja el juego ejecutable, con su autotest)

| Fase | Contenido | Se prueba con |
|---|---|---|
| **E-0** | Interruptor (GameState, inicio, Opciones, HUD, guardado). `TrainerData`/`PersonalityData`/`TrainerState`. Los 3 NPC quietos en Ruta 1 cuando está prendido | `--autotest-trainers`: apagado = no hay NPC; prendido = aparecen; se guarda |
| **E-1** | **Combate contra entrenador**: visión y desafío, equipos de hasta 3, salida del siguiente, **cambio con Tab** (vos y él), fin y EXP | Bot del autotest gana y pierde un combate de 2 contra 2; Tab cambia |
| **E-2** | **TacticalAI con perillas** (reemplaza el azar; los salvajes también la usan) | Mismo rival con perillas distintas se comporta distinto (rango medio, ataques usados) |
| **E-3** | **CombatObserver + TrainerMemory** + guardado + overlay F10 | Bot que siempre se aleja y esquiva a la derecha → creencias correctas tras 2 peleas; sobrevive a guardar/cargar |
| **E-4** | **StrategyPlanner** (creencias → perillas) + frases previas + libreta en la Pokédex | **Criterio del prototipo**: 3 peleas con el mismo bot; la 3ª es distinta sin haberla programado (rango y aperturas cambian) |
| **E-5** | **Reloj + rutinas + simulación fuera de pantalla** (F11 adelanta horas) | Al adelantar el reloj el NPC aparece en otro lugar; si lo ves, está donde dice su rutina |
| **E-6** | **Equipos que evolucionan**: capturas simuladas del pool de la zona, sustitución por rol, entrenar sube niveles | Tras N días simulados el Explorador tiene una especie de las zonas que visitó; el Rival no cambia |
| **E-7** | **Relación** (si se aprueba): eje rivalidad ↔ respeto → saludo y si te busca o te evita | Ganarle seguido sube la rivalidad y lo hace buscarte en su bloque "busca combates" |

Orden sugerido respecto del plan de etapas: **E-0 a E-4 reemplazan la parte de IA de la Etapa 4** (después la
Etapa 4 queda en spawns por bioma/hora). **E-5** adelanta el reloj de la Etapa 5 (sin lo visual). **E-6** usa
una captura simulada; cuando exista la captura real (Etapa 6) la comparten.

## 6b. Avance

| Fase | Estado | Notas |
|---|---|---|
| W (cuerpo + salvajes) | ✅ 2026-10-23 | `CombatBody` + temperamentos (Etapa 4a de PROGRESO) |
| E-0 | ✅ 2026-10-23 | Ver abajo |
| E-1 | ⏭️ Siguiente | Combate contra entrenador (desafío, equipos, cambio con Tab, fin, EXP) |

**E-0 (cómo quedó):**
- Interruptor `GameState.living_trainers` (apagado por defecto; `set_living_trainers` emite
  `Events.living_trainers_changed`): casilla en la elección de inicial y en Esc → Opciones, aviso en el HUD, se
  guarda con la partida.
- Datos (`scripts/resources/`): `TrainerData` (nombre, título, sprite, personalidad, equipo inicial, pool, rutina,
  frases), `PersonalityData`, `TrainerMon`, `RoutineBlock`. Los 3 del prototipo en `data/trainers/*.tres`, armados
  por `tools/build_trainers.gd` (correrlo los pisa; se pueden ajustar en el inspector).
- **Azul (Rival)**: Charmander 8 + Rattata 7, orgullo 0,85, agresión 0,85. **Valeria (Estratega)**: Bellsprout 8 +
  Pidgey 8, inteligencia 3, malinterpreta 10%. **Tomás (Explorador)**: Vulpix 8, curiosidad 0,85. Rutinas
  cargadas para E-5 (en E-0 aparecen en el lugar de su primer bloque, en Ruta 1, cerca de la plaza).
- `TrainerState` (equipo actual, victorias/derrotas, memoria, rivalidad) en `GameState.trainers`, guardado como
  diccionario con ids. `TrainerDirector` (nodo del mundo) saca o guarda los `TrainerNPC` según el interruptor y si
  su zona está cargada; el estado sobrevive a que el NPC desaparezca.
- `TrainerNPC` (`scenes/characters/trainer_npc.tscn`): sprite de FireRed (Blue, Cooltrainer, Camper; bajados del
  decomp y exportados con `pret_import.py`), bloquea el paso, te mira y muestra su nombre cuando te acercás.
- Autotest `--autotest-trainers` (10 chequeos); vitrina `--showcase-trainers`.

## 7. Cómo probarlo (prendido el interruptor)

1. Inicio → marcar "Entrenadores vivos (en prueba)" (o Esc → Opciones en una partida).
2. Con `-- --debug`: F10 muestra lo que cada entrenador cree de vos y sus perillas; F11 adelanta el reloj.
3. Pelear 3 veces seguidas contra el Rival con la misma táctica y mirar cómo cambia (frase previa + F10).
4. Opciones → "Borrar memoria de los entrenadores" para empezar de cero.

## 8. Decisiones a confirmar (con la opción recomendada)

1. **Relación con el jugador**: (a) **Recomendado**: un eje simple rivalidad ↔ respeto en la fase E-7, que cambia
   saludos y si te busca. (b) Nada por ahora, solo memoria de combate. (c) Relación completa con diálogos.
2. **Formato del combate contra entrenadores**: (a) **Recomendado**: hasta 3 Pokémon por lado, uno a la vez,
   con cambio (Tab). (b) 1 contra 1 para el prototipo (más rápido, pero no permite "saca primero a su Rattata").
3. **Interruptor**: (a) **Recomendado**: apagado por defecto mientras se prueba. (b) Prendido por defecto.
4. **Duración del día de juego** (para las rutinas): (a) **Recomendado**: 1 día = 24 minutos reales (1 hora = 1
   minuto), compatible con la Etapa 5. (b) 1 día = 48 minutos.
5. **Orden**: (a) **Recomendado**: E-0 a E-4 ahora (absorben la IA de la Etapa 4), después E-5 a E-7. (b) Primero
   terminar la Etapa 4 tal como estaba y después este plan.
