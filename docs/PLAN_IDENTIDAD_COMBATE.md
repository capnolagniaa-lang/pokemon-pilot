# Plan de identidad de combate en tiempo real

> Plan **separado** del plan de etapas (`docs/PROGRESO.md`). Lo definió el usuario el 2026-10-21:
> la dirección del combate es que **cada Pokémon se sienta distinto de jugar**. Abajo está su documento
> de diseño tal cual; al final, la sección **"Integración con el proyecto"** (escrita por Claude) con el
> estado de avance, cómo encaja con lo ya construido y los puntos a decidir.

---

# ⚠️ ESTADO VIGENTE (v2, 2026-10-21) — LEER PRIMERO

El usuario **rediseñó el sistema** después de probar la versión de 5 ranuras. Lo de esta sección **manda** sobre
el documento original de abajo (que queda como referencia de ideas: estados, sinergias, fichas).

## Reglas vigentes
- **Sin energía.** Todo funciona con **recargas** por ataque.
- **4 ataques por Pokémon** + **esquive en Espacio** (igual para todos, recarga 0,9 s, invulnerable un instante).
- **Controles:** Clic izq. = ataque 1 · Clic der. = ataque 2 · Q = ataque 3 · R = ataque 4 (el de más recarga) ·
  Espacio = esquive. (Números 1-4 como alternativa.) `Controls.SLOT_ACTIONS` / `SLOT_KEYS`.
- **Estilos de pelea** (arquetipos) definidos por el kit: `data/kits/<pokémon>/kit.tres` → `Kit` con
  `archetype`, `preferred_range`, `signature` (opcional) y `moves` (4 `MoveData`).
- **Spawns durante la prueba del combate:** solo **Pidgey, Bellsprout, Rattata y Vulpix en todo el mapa**
  (`WildSpawner.TEST_POOL`, `use_test_pool = true`). Se extendió a todas las zonas porque las vecinas de Ruta 1
  (lago, humedal) se cargan al acercarse a sus bordes y metían Pokémon de agua. Los demás Pokémon no se borraron:
  con `use_test_pool = false` vuelven los spawns por zona/bioma (`BY_ZONE`, `BY_BIOME`).
- Stats oficiales, estados del plan (I-1), interacciones, resistencia a control, telegrafiado y recuperación:
  **siguen igual**.
- **Pantalla de inicio** (pedido del usuario): **Modo práctica** (por defecto activado: si tu Pokémon se debilita,
  vuelve a los 0,8 s con la vida al máximo) y **Dificultad de la IA**: Fácil / **Normal (por defecto)** / Difícil.
  Difícil = la IA original ("está MUY fuerte, hace todo bien"). Datos en `data/config/difficulty/*.tres`
  (`AiDifficulty`: intervalo entre ataques, error de puntería, probabilidad de esquivar, daño de los salvajes,
  ritmo de cambio de táctica). Estado en `GameState.practice_mode` / `GameState.difficulty`.
  Fácil: ataca ×2,2 más lento, erra ±28°, no esquiva, 60% de daño · Normal: ×1,5, ±15°, esquiva 12%, 80% ·
  Difícil: ×1, ±7°, esquiva 30%, 100%. Autotest: `--autotest-modes`.

## Estilos implementados
| Pokémon | Estilo | Clic izq. | Clic der. | Q | R | Mecánica |
|---|---|---|---|---|---|---|
| Charmander | **Bruiser** | Ascuas: abanico de 3 brasas, rango medio (1,4 s) | Arañazo: se lanza al punto apuntado (≤64 px); si conecta, 2 golpes (el 2º empuja) (1,1 s) | Giro Fuego: anillo que atrapa (7 s) | Embestida Ígnea: dash que golpea con leve empuje (90), invulnerable, deja estela de fuego (6 s) | **Calor** → Mar Llamas (el usuario lo aprobó) |
| Bellsprout | **Control** | Polvo Veneno: parche de esporas (máx. 3, 6 s) que ralentiza y suma veneno (1,3 s) | Látigo Cepa: agarra al primero que alcanza (72 px), lo enraíza y lo atrae (4 s) | Arraigo: se enraíza 3 s, recibe la mitad, se cura 3%/s, no lo empujan (10 s) | Somnífero: nube telegrafiada; quien se queda 1,5 s adentro se duerme (12 s) | (ninguna aún) |
| Bulbasaur | **Control** | Polvo Veneno | Látigo Cepa | Síntesis: se cura 5%/s 3 s, recibe ×0,75, más lento (12 s) | Somnífero | (ninguna aún) |
| Squirtle · Pikachu · Oddish · Paras · Psyduck · Poliwag · Growlithe · Eevee · Seel · Geodude | ver "v3" abajo | | | | | (en prueba) |
| Pidgey | **Hostigador** | Tornado: ráfaga que empuja (190) y **desvía proyectiles** enemigos (1,2 s) | Ataque Arena: 5 granos en abanico que **desorientan** (5 s) | Ataque Rápido: embestida (2,6 s) | Remolino: zona de viento 3,5 s que **echa a los enemigos** y desvía proyectiles (9 s) | **Vuelo** (barra de Aliento) |
| Rattata | **Asesino** | Mordisco: combo de 3 mordidas rápidas, 35% Herido (1 s) | Ataque Rápido: embestida de entrada (4 s) | Foco Energía: guarda un **crítico seguro** (×1,5) para el próximo golpe (9 s) | Hipercolmillo: mordida telegrafiada (0,22 s) que **ejecuta bajo el 25%** de vida (10 s) | **Instinto** |
| Vulpix | **Desgaste** | Ascuas: una brasa rápida, 20% quema (0,9 s) | Fuego Fatuo: llama lenta que **quema seguro** (5 s) | Rayo Confuso: **desorienta** (7 s) | Lanzallamas: cono canalizado 1 s (9 s) | **Rescoldo** |

Mecánicas de firma nuevas (`scripts/combat/signatures/`, números en `data/kits/<pokémon>/*.tres` → `params`):
- **Vuelo** (Pidgey, `flight_mechanic.gd`): Aliento 0-100. **Esquivar con ≥30 de Aliento lo eleva** (hasta 1,6 s,
  gasta 40/s): en el aire es **inmune a cuerpo a cuerpo, embestidas y látigos** (no a proyectiles ni zonas). El
  primer ataque desde el aire es un **Picado** (×1,4 daño) y aterriza. En el suelo recupera 30/s. Se ve elevado
  (la sombra queda en el piso: `CreatureSprite.lift`). Decisión de Claude (el plan decía "mecánica posible"):
  usa el esquive para no ocupar una 5ª tecla.
- **Instinto** (Rattata, `instinct_mechanic.gd`): **presa** = enemigo con <40% de vida o con cualquier estado
  (se marca con una mira roja). Contra presas ×1,3 daño y 25% de crítico (×1,5). Foco Energía = crítico seguro.
  **Rematar reinicia Ataque Rápido.** Sin barra: muestra "PRESA" / "CRÍTICO LISTO".
- **Rescoldo** (Vulpix, `embers_mechanic.gd`): golpes contra **quemados** ×1,35 y **renuevan la quemadura**.
  Sin barra: muestra cuántos enemigos cercanos están quemados.
- Ganchos genéricos nuevos en `SignatureMechanic`: `damage_mult_against(hit, objetivo)` (se evalúa al impactar)
  e `ignores_hit(hit)`. En `MoveData`: `execute_below` (ejecución) y `deflects_projectiles` (viento). Firma con
  `max_value = 0` = sin barra en la interfaz.

Los demás (Squirtle, Pikachu, etc.) **todavía usan sus 4 ataques sueltos** de `SpeciesData.moves` (mapeados a
las 4 teclas) hasta tener kit.

## Ajustes de estados y ataques (2026-10-24, pedido del usuario)
- **Paralizado "que paralice de verdad"**: ya no es por acumulación. Un golpe que paraliza lo deja 6 s a mitad de
  velocidad, con **tirones**: cada 1,5 s, 35% de quedar totalmente quieto 0,6 s ("¡Paralizado!"; no activa la
  resistencia a control). Data-driven: `StatusEffect.jolt_interval/jolt_chance/jolt_time`.
- **Escarcha de Seel**: congela con **5** cargas (antes 3: con el Rayo Aurora lo dejaba congelado casi sin parar).
- **Somnífero**: duerme a los **0,6 s** adentro de la nube (antes 1,5 s: "tarda mucho").
- **El daño de los estados (veneno, quemado) no despierta** al dormido; solo un golpe lo despierta.
- **Embestida Ígnea**: la estela pega como **un solo fuego** (una vez cada 0,5 s por rival) aunque el rival pise varios
  parches; antes cada parche pegaba por su cuenta ("pega mucho después del primer golpe").

## Rework de Empapado (2026-10-23, pedido del usuario)
Antes "dejaba inútil" al mojado: los disparos de agua mojaban todo el camino (charcos de 15 s), pararse en un
charco volvía a empapar cada medio segundo y la IA trataba lo mojado como peligroso y se pasaba la pelea
escapando. Ahora:
- **Moja al impactar**: todo ataque de tipo Agua empapa al que golpea (`ElementType.hit_status_id`, data-driven).
- **Empapado**: 4 s, −10% velocidad (se puede mover y pelear normal). Combos: Eléctrico → cortocircuito (×1,5 y
  aturde 0,9 s, lo consume) · Planta → alarga el Enraizado · **Fuego → pega un 30% menos y lo seca ("¡Vapor!")**.
  El agua sigue apagando el Quemado.
- Los disparos ya **no afectan las celdas por las que pasan**, solo donde impactan. Los **charcos** (suelo
  mojado) no empapan ni asustan a la IA: sirven para que corra la electricidad y para congelarlos.

## v3 — 10 kits nuevos (✅ implementados, en prueba, 2026-10-23)
Pedido del usuario: llegar a ~16 kits para el modo historia ("los vamos a ir trabajando a medida que testee").
Lista aprobada en `docs/SALVAJES_Y_MOVIMIENTOS.md` (sección 4). **Ya están en el juego** (16 especies con kit);
los números son iniciales y se van a ajustar a medida que el usuario los pruebe.
- Datos: `data/kits/<especie>/` (4 ataques + firma + `kit.tres`), estados nuevos en `data/status/` (refugio,
  esporas, rastreado, escarcha, rizo, descansando). Los generó `tools/build_kits_v3.py` (**correrlo de nuevo los
  pisa**: una vez que se retoquen en el inspector, no volver a correrlo).
- Mecánicas: `scripts/combat/signatures/` → shell (Squirtle), static (Pikachu), spores (Oddish), headache
  (Psyduck), slide (Poliwag), track (Growlithe), adapt (Eevee), frost (Seel), momentum (Geodude). Paras no tiene
  firma: su identidad son las esporas inflamables (`GroundZone.ignite`).
- Learnsets: los 4 del kit en Nv. 1/1/3/5 + extras (`EXTRAS` de `tools/build_learnsets.gd`).
- Autotest `--autotest-kits-v3` (37 chequeos: cada kit usa sus 4 ataques y su mecánica funciona).
- **Ajustes tras la primera prueba del usuario (2026-10-23)**: Rayo de Pikachu = golpe desde el cielo en área
  (`MoveData.zone_strike` + `strike_delay`, nodo `SkyStrike`); Burbuja de Poliwag = poco daño, sin empapar
  (`MoveData.skip_element_status`) y encierra en una burbuja (`data/status/burbuja.tres`, `StatusEffect.fx_bubble`).
  Growlithe, Pidgey, Bellsprout y Charmander: bien por ahora.

Diseño (números iniciales):

| Pokémon | Estilo | Clic izq. | Clic der. | Q | R | Mecánica de firma |
|---|---|---|---|---|---|---|
| Squirtle | Tanque | Placaje (combo 2, el 2º empuja fuerte) | Pistola Agua (empapa) | **Refugio**: se mete en el caparazón 1,5 s (recibe ×0,3, no lo empujan, no se mueve); si le pegan en los primeros 0,3 s = **parry** (anula y aturde al atacante) | Giro Rápido: rueda, limpia sus estados | **Presión**: el daño bloqueado y los parry cargan una barra; el próximo golpe la gasta y pega más |
| Pikachu | Velocista | Impactrueno (rápido) | Ataque Rápido | Onda Trueno (onda que suma parálisis) | Rayo: **cae del cielo** en un círculo chico donde apuntás (radio 30, como Giro Fuego), con aviso de 0,35 s; gasta las cargas (hasta ×2) | **Estática**: moverse y esquivar cargan (5 cargas); quieto las pierde; con 5, el próximo golpe es una **Descarga** que paraliza |
| Oddish | Desgaste | Absorber (cura la mitad del daño) | Polvo Veneno (parche) | Paralizador (parche de parálisis) | **Florecer**: hace florecer las esporas de los enemigos cercanos | **Esporas**: cada golpe deja una espora (máx. 5); al florecer: 1+ envenena, 3+ paraliza, 5 duerme, y Oddish se cura un poco por cada una |
| Paras | Control | Arañazo (combo 2) | Paralizador (parche) | Chupavidas (cura la mitad del daño) | **Espora**: nube que duerme si te quedás adentro | **Esporas inflamables** (idea del usuario): el fuego que toca un parche o nube de esporas la prende 3 s y quema a todos los que estén adentro |
| Psyduck | Caótico | Pistola Agua | Arañazo (combo 3 rápido) | Confusión (puede desorientar) | **Anulación**: si pega, el rival tarda 3 s más en recargar todo | **Jaqueca**: sube al recibir daño y con el tiempo en combate; al llenarse, estalla una Confusión en área que desorienta |
| Poliwag | Velocista acuático | Burbuja: una burbuja lenta que **saca poco, no empapa y encierra 0,9 s** al rival (estado "En burbuja", control) | Pistola Agua | Danza Lluvia: moja el piso alrededor y empapa | **Hipnosis**: proyectil lento y telegrafiado que duerme | **Deslizamiento**: sobre agua o suelo mojado se mueve ×1,4 y esquiva el doble de seguido |
| Growlithe | Perseguidor | Mordisco (combo 2) | Ascuas | Rugido: empuja muy fuerte y desorienta | Rueda Fuego (embestida que quema) | **Rastreo**: sus golpes marcan al rival 6 s; contra el marcado corre ×1,25 y pega ×1,25 |
| Eevee | Adaptativo | Placaje (combo 2) | Ataque Arena (desorienta) | Ataque Rápido | Derribo (embestida fuerte) | **Adaptación**: al recibir un golpe de un tipo, 8 s recibe ×0,7 de ese tipo |
| Seel | Tanque helado | Golpe Cabeza (empuja y tambalea) | Viento Hielo (3 ráfagas que ralentizan) | Rayo Aurora | **Descanso**: duerme 2 s y se cura | **Escarcha**: sus ataques de hielo dejan escarcha (máx. 3); con 3, el rival se congela |
| Geodude | Tanque de roca | Placaje (pesado) | **Rodar**: embestida que encadena | Lanzarrocas | Rizo Defensa: recibe la mitad 4 s | **Impulso**: cada Rodar dentro de 3 s del anterior pega +50% (hasta ×2); con Rizo Defensa activo, Rodar pega el doble |

Piezas nuevas del motor (genéricas, sin `if especie`): `MoveData.drain` (cura una fracción del daño),
`MoveData.cleanse_self` (limpia los estados propios al usarlo), `MoveData.cooldown_lock` (alarga las recargas del
golpeado), `MoveData.zone_flammable` (esporas que arden), ganchos `SignatureMechanic.damage_taken_mult` y
`dodge_cooldown_mult`, y estados nuevos (refugio, esporas, rastreado, escarcha, rizo, descansando).

- (Pidgey, Rattata y Vulpix: **implementados**, ver arriba.)

## v4 — kits de Kanto hasta Ciudad Plateada (✅ implementados, en prueba, 2026-10-23)
Pedido del usuario: kits para lo que aparece en los mapas de FireRed (Pueblo Paleta → Ciudad Plateada) según sus
movimientos, y **Onix como JEFE** (el de Brock: "bastante poderoso, con mucho sentido, referencia el anime, buenas
animaciones, que se sienta como un BOSS"). Ya son **24 Pokémon con kit**.
- Datos generados por `tools/build_kits_v4.py` (reusa el formato del v3; **correrlo de nuevo pisa los ajustes**).
  También engancha el kit en la especie. Después `tools/build_learnsets.gd` (extras de Spearow, Mankey,
  Sandshrew y Onix en `EXTRAS`). Estados nuevos: seda, fortaleza, intimidado, expuesto, enfurecido, furia_roca.
- Autotest `--autotest-kits-v4` (35 chequeos); vitrina del jefe `--showcase-onix`.

| Pokémon | Estilo | Clic izq. | Clic der. | Q | R | Mecánica de firma |
|---|---|---|---|---|---|---|
| Caterpie | Control | Placaje | Disparo Demora (ralentiza + seda) | Telaraña (parche que ralentiza + seda) | Fortaleza (recibe ×0,6 3 s) | **Seda**: 3 de seda → el rival queda enredado (enraizado) |
| Weedle | Asesino | Picotazo Veneno (rápido, 30% veneno) | Disparo Demora | Doble Ataque (se lanza y pega 2 veces) | Pin Misil (abanico de 5) | **Aguijón Venenoso**: +10% de daño por stack de veneno del rival (hasta +50%) |
| Metapod | Tanque | Placaje | Disparo Demora | Fortaleza | Derribo (embestida fuerte) | **Capullo**: quieto se endurece (hasta la mitad de daño); moverse lo ablanda |
| Kakuna | Tanque | Picotazo Veneno | Disparo Demora | Fortaleza | Derribo | **Capullo Venenoso**: como Metapod y, endurecido, envenena al que le pega cuerpo a cuerpo (50%) |
| Spearow | Asesino | Picotazo (combo 3) | Gruñido (Intimidado: −20% daño físico) | Ataque Furia (combo de 5 rápido) | Persecución (se lanza lejos, 2 golpes) | **Furia**: golpes seguidos al mismo rival +10% cada uno (hasta 5); se pierde a los 2 s o al cambiar de rival |
| Mankey | Bruiser | Arañazo (combo 3) | Malicioso (Expuesto: recibe +25%) | Patada Baja (ralentiza) | Golpe Kárate (se lanza, 2º golpe fuerte) | **Rabia**: recibir golpes la llena; llena → Enfurecido 5 s (+30% daño, +15% velocidad) |
| Sandshrew | Control | Arañazo (combo 2) | Ataque Arena (cono que desorienta) | Picotazo Veneno | Rizo Defensa | **Velo Arena**: al esquivar deja una nube de arena que desorienta (cada 4 s) |
| **Onix (jefe)** | Tanque | **Atadura**: látigo largo que atrapa, tira hacia él y ralentiza | **Lanzarrocas**: 3 rocas en abanico | **Excavar**: se mete bajo tierra (invisible e invulnerable, el suelo se agrieta donde va a salir) y a 1 s sale debajo del rival con un golpe en área que empuja fuerte y hace temblar la pantalla | **Tumba Rocas**: 3 piedras caen del cielo alrededor del punto (ralentizan) | **Coloso**: cuerpo ×1,4, no lo empujan ni lo tambalean, recibe −25% de daño físico, +30% contra lo ralentizado; **a mitad de vida ruge** (onda que empuja y deja Expuesto, temblor fuerte) y entra en **Furia de Roca** (+25% daño, +20% velocidad) hasta el final |

Piezas nuevas del motor (genéricas): `MoveData.strike_count`/`strike_spread` (varios golpes desde el cielo) y
`strike_burrow` (Excavar: el usuario se esconde y sale donde cae); ganchos `SignatureMechanic.knockback_taken_mult`
(empuje y tambaleo) y `body_scale` (jefes más grandes, sprite y hurtbox). La Pokédex muestra el estilo, la firma y
los 4 ataques del kit apenas viste al Pokémon.

## v5 — capítulo 2: Staryu, Starmie jefa y evoluciones que cambian de forma de pelear (✅ en prueba, 2026-10-24/25)
Pedido del usuario: "sigan implementando hasta el Gimnasio de Ciudad Celeste" (`docs/PLAN_CAPITULO_2.md`, parte K).
**Starmie es la jefa de Misty** (Staryu 18 + Starmie 21), como Onix con Brock.
**Evoluciones** (criterio del usuario 2026-10-25): *siguen con el mismo kit de su preevolución a menos que cambie mucho
su forma de pelear*. La herencia la hace `tools/apply_evolutions.gd` (sesión de evoluciones); las que cambian mucho
tienen kit propio acá: **Butterfree, Beedrill, Kadabra y Gyarados** (pendientes con el mismo criterio: Charizard,
Vaporeon, Jolteon, Flareon). Son **30 especies con kit propio** (más las que heredan).
- `tools/build_kits_v5.py` (mismo formato y aviso que el v4; reusa `write_kit`/`hook_species` del v4). Estados
  nuevos: `nucleo_brillante` (+20% daño y velocidad) y `recuperando` (cura 8%/s 2,5 s, va a mitad de velocidad).
- Firma `core_mechanic.gd` (**Núcleo**), genérica por parámetros: girando con el ataque `spin_move` desvía proyectiles
  (`Projectile.deflect_around`), +X% contra lo Empapado, barra (sube al pegar y al recibir) llena → cura y vuelve
  a 0; con `phase_at` > 0 es jefa (escala, empuje reducido, pulso + estado de fase a mitad de vida).
- Firma nueva `blink_mechanic.gd` (**Mente Rápida**, Kadabra): después de Teletransporte el próximo golpe pega +50% y
  desorienta seguro. Las otras reusan firmas por parámetros (vuelo de Pidgey, aguijón de Weedle, rabia de Mankey).
  Estado nuevo `agilidad` (+40% velocidad 4 s).
- Autotest `--autotest-kits-v5` (34 chequeos).
- Los demás Pokémon nuevos del capítulo (Nidoran, Zubat, Clefairy, Ekans, Abra, Magnemite...) **no tienen kit todavía**:
  usan los ataques automáticos de su learnset. Sí tienen `FightStyle` (estilo de movimiento y salto; sin combos
  porque los combos están apagados).

| Pokémon | Estilo | Clic izq. | Clic der. | Q | R | Mecánica de firma |
|---|---|---|---|---|---|---|
| Staryu | Velocista | Placaje (combo 2) | Pistola Agua (Empapado) | Giro Rápido (embestida girando: desvía proyectiles) | Fortaleza | **Núcleo**: +20% a lo Empapado; barra llena → cura 10% |
| Butterfree | Control | Confusión (30% desorienta) | Tornado (desvía proyectiles) | Paralizador (parche) | Somnífero (zona: quedarse 0,6 s duerme) | **Alas de Polvo**: vuela como Pidgey (esquivar con Aliento → en el aire, inmune a lo cuerpo a cuerpo; picada) |
| Beedrill | Asesino | Ataque Furia (combo de 5, 20% veneno) | Doble Ataque (se lanza, 2 golpes, 50% veneno) | Pin Misil (abanico de 5) | Agilidad (+40% velocidad 4 s) | **Aguijón Letal**: +12% por stack de veneno del rival (hasta +60%) |
| Kadabra | Control | Confusión | Psicorrayo (rayo largo canalizado) | Kinético (onda que desorienta) | Teletransporte (desplazamiento invulnerable) | **Mente Rápida**: tras Teletransporte, Golpe Mental (+50%, desorienta) |
| Gyarados | Bruiser | Mordisco (combo 2, 30% herido) | Furia Dragón (bola grande) | Ciclón (área que empuja, 20% desorienta) | Hidrobomba (110, carga 0,5 s, empuja muchísimo y moja) | **Ira de Dragón**: sube al recibir golpes; llena → Enfurecido 5 s |
| **Starmie (jefa)** | Control | **Hidropulso**: disparo grande, Empapado y 20% desorienta | **Rapidez**: abanico de 5 estrellas | **Giro Rápido**: embestida fuerte que desvía proyectiles | **Recuperación**: se cura 20% en 2,5 s (va lenta) | **Núcleo Prisma**: cuerpo ×1,3, empuje ×0,35, +25% a lo Empapado, barra llena cura 8%; **a mitad de vida el núcleo brilla**: onda que empuja, moja y deja Expuesto, y queda con Núcleo Brillante hasta el final |

## Sinergia con todo lo que aprenden (2026-10-26, pedido del usuario)
"Todos los movimientos que aparecen en la wiki de cada personaje tienen que poder ser elegidos y hacer sinergia con el
kit". Lo que se hizo:
- **Learnset completo**: los Pokémon con kit aprenden el kit (Nv. 1/1/3/5) **y todo su learnset de FRLG** (antes solo 2
  extras, y los de las Tandas A y B ninguno). `build_learnsets.gd`. Las partidas viejas los ven solos (lo aprendido
  sale del nivel). Las MT ya se suman con `taught_moves`; la compatibilidad por especie con cada MT queda pendiente.
- **Equipamiento inicial = el kit** (`CreatureInstance.default_equipment`): un ataque de FRLG del mismo nivel (Gruñido
  de Charmander) no desplaza a uno del kit.
- **Ataques oficiales con la forma de su versión de kit** (`tools/link_official_moves.py`): los automáticos con un
  ataque de kit del mismo nombre toman su forma (el Gas Venenoso oficial es la nube detonable de Koffing, Refugio
  activa el parry de Squirtle, Foco Energía guarda el crítico de Rattata...), sin el costo de recurso de firma. Los
  de mejora propia sin versión de kit tienen un efecto genérico: subir ataque → `potenciado` (+25% 6 s), defensa →
  Fortaleza, evasión → Agilidad, curarse → Recuperación, Protección/Detección → Refugio. Quedan sin efecto los raros
  (climas, Sustituto, Salpicadura...: lista `NO_EFFECT_OK` del test).
- **Firmas por tipo** (`SignatureData.params.element_marks`, en `SignatureMechanic`): un golpe de ese tipo le pone su
  estado al rival aunque el ataque no sea del kit — Seel hielo → escarcha, Caterpie bicho → seda, Oddish planta/veneno
  → esporas, Growlithe fuego/siniestro/normal → rastreado, Drowzee psíquico → somnolencia. Impulso de Geodude cuenta
  cualquier Rodar. Las demás firmas ya reaccionaban a cualquier ataque (golpes, daño, estados, tipo).
- Test: `--autotest-kits-v8 --only sinergia`.

## v8 — Tanda C de la propuesta (✅ en prueba, 2026-10-26)
Drowzee, Grimer, Koffing, Ponyta, Slowpoke y Magikarp (`tools/build_kits_v8.py`); heredan Hypno, Muk, Weezing, Rapidash,
Slowbro y Slowking. Firmas nuevas: `gas_mechanic.gd`, `gallop_mechanic.gd`, `slow_mechanic.gd`, `flail_mechanic.gd`
(Drowzee reusa `stack`, Grimer `body_trait`). Estados nuevos: `somnolencia`, `bostezo`, `potenciado`.

| Pokémon | Estilo | Clic izq. | Clic der. | Q | R | Firma |
|---|---|---|---|---|---|---|
| Drowzee | Control | Destructor | Confusión | Anulación | Comesueños (roba vida) | **Hipnosis Acumulable**: cualquier ataque psíquico suma Somnolencia; con 4, duerme |
| Grimer | Tanque | Destructor (ralentiza) | Residuos (veneno) | Armadura Ácida (Fortaleza) | Derretirse (charco invulnerable que deja lodo tóxico) | **Cuerpo de Lodo**: no lo ralentizan ni envenenan; al que le pega cuerpo a cuerpo lo pegotea |
| Koffing | Control | Placaje | Gas Venenoso (nube inflamable) | Pantalla de Humo (nube inflamable) | Detonar | **Gas Inflamable**: sus nubes se prenden con cualquier fuego; Detonar las explota todas |
| Ponyta | Velocista | Pisotón | Ascuas | Giro Fuego | Derribo | **Galope**: correr derecho → hasta ×1,4 de velocidad, estela de fuego (prende el pasto) y embestidas +40%; girar fuerte lo pierde |
| Slowpoke | Tanque | Golpe Cabeza | Pistola Agua | Pesca con Cola (atrae) | Bostezo | **Reacción Tardía**: 30% del daño le llega 2 s tarde (se olvida si conecta un golpe); Bostezo duerme a los 2 s |
| Magikarp | Caótico | Salpicadura (salto) | Placaje | Azote (hasta ×3 con poca vida) | Salpicadura Alta | **Determinación**: +20 EXP por cada rival que derriba y sigue en pie |

## v7 — Tanda B de la propuesta de kits pendientes (✅ en prueba, 2026-10-26)
Clefairy, Jigglypuff, Abra, Goldeen, Magnemite y Meowth (`tools/build_kits_v7.py`); heredan Clefable, Wigglytuff,
Seaking, Magneton y Persian. Decisiones (con lo que recomendaba la propuesta): el **Metrónomo elige entre los ataques
de todos los kits** (no los que lanza una firma, ni Autodestrucción) y **las monedas de tu Meowth suman a tu dinero**.
Firmas nuevas: `metronome_mechanic.gd`, `puff_mechanic.gd`, `wary_mechanic.gd`, `payday_mechanic.gd`; Goldeen y
Magnemite reusan `body_trait` (parámetros nuevos `wet_speed`, `pierce_*`). Estados nuevos: `inflado`, `reducido`.
Simplificaciones: Doble Bofetón es un combo de 4 (no al azar); Canto se centra en el que canta; el inflado de
Jigglypuff no lo agranda (le baja el empuje); el Abra salvaje no huye de la pelea con Teletransporte Lejano (la IA no lo
sabe usar para escapar); Fijar Blanco no hace teledirigidos (marca con Expuesto); Meowth suma las monedas al pegar,
sin recogerlas del piso. Autotest `--autotest-kits-v7` (`--only <especie>`).

| Pokémon | Estilo | Clic izq. | Clic der. | Q | R | Firma |
|---|---|---|---|---|---|---|
| Clefairy | Caótico | Doble Bofetón (combo 4) | Canto (anillo: quedarse 0,6 s duerme) | Reducción (recibe ×0,75, más rápido) | **Metrónomo** (un ataque al azar de cualquier kit) | **Luz de Luna**: cada Metrónomo carga la luna; llena, el próximo sale de los 5 más fuertes |
| Jigglypuff | Control | Destructor | Rodar | Rizo Defensa | Canto (grande, carga 0,6 s) | **Inflado y Marcador**: los golpes que recibe lo inflan (menos empuje); Rodar gasta el inflado (+25% c/u); a un dormido le deja un garabato (Expuesto) |
| Abra | Velocista | Destello Psíquico | Teletransporte | Confusión | Teletransporte Lejano | **Sueño Vigilante**: al recibir un golpe se teletransporta solo (cada 6 s); dormido o paralizado no |
| Goldeen | Perseguidor | Picotazo | Supersónico | Hidrochorro (moja alrededor) | Cornada | **Cuerno Perforador**: el cuerno pega ×1,6 a quien tiene una defensa puesta; mojado ×1,3 de velocidad, en seco aletea (×0,85) |
| Magnemite | Espaciador | Impactrueno (atrae) | Bomba Sónica | Supersónico | Fijar Blanco (atrae y marca: Expuesto) | **Magnetismo**: flota (no lo ralentizan ni enraízan); +25% a lo marcado |
| Meowth | Asesino | Arañazo (combo 3) | Mordisco | Finta (se lanza rápido) | Golpes Furia (combo 5) | **Día de Pago**: cada golpe suma $5 a tu dinero (si es tuyo); cada 4 golpes baja 0,5 s las recargas |

## v6 — Tanda A de la propuesta de kits pendientes (✅ en prueba, 2026-10-26)
Pedido del usuario: "leé la propuesta de kits pendientes y empezá a implementar" (`docs/PROPUESTA_KITS_PENDIENTES.md`,
Tanda A completa). Decisiones tomadas con lo que recomendaba la propuesta: **Raichu jefe primero** y
**Autodestrucción deja a Voltorb en 1 de vida** (no lo debilita). `tools/build_kits_v6.py`; las evoluciones heredan
(Golbat, Arbok, Machoke/Machamp, Nidorina/Nidoqueen, Nidorino/Nidoking, Seadra/Kingdra, Cloyster, Tentacruel,
Electrode, Crobat). Raichu deja de heredar el de Pikachu.
- Firmas nuevas, **genéricas por parámetros**: `grounding_mechanic.gd` (Toma de Tierra), `still_mechanic.gd` (quieto =
  postura: Enroscarse, Ancla, Camuflaje + Autodestrucción) y `body_trait_mechanic.gd` (inmunidades, drenaje extra,
  púas, recargas por golpe, defensa por dirección, cuerpo de agua, esquive perfecto).
- Gancho nuevo `SignatureMechanic.blocks_status` (por defecto la lista `immune` de los parámetros): lo consulta
  `StatusEffects.apply`.
- Estados nuevos: `plantado`, `sobrecarga`, `refuerzo`; estado de celda `chamuscado_electrico` (8 s, paraliza).
- Simplificaciones respecto de la propuesta (se pueden sumar después): Chispa de Raichu no se aturde contra paredes
  (tiene recuperación larga, que es la ventana); Machop no agarra ni lanza (Sísmico = embestida pesada con cráter) y
  usa Malicioso en vez de Foco Energía; Tenaza de Shellder frena pero no se engancha; Ataque Ala no atraviesa; el
  Chorro a Presión de Horsea no atraviesa; Voltorb camuflado se vuelve casi invisible (no se ve como Poké Ball).
- Autotest `--autotest-kits-v6`.

| Pokémon | Estilo | Clic izq. | Clic der. | Q | R | Firma |
|---|---|---|---|---|---|---|
| **Raichu (jefe)** | Bruiser, pesado | Puño Trueno (combo 2, paraliza 25%) | Impactrueno Triple (abanico) | Chispa (embestida telegrafiada, recuperación larga) | Trueno (3 rayos del cielo, paralizan) | **Toma de Tierra**: barra llena → planta la cola 1 s (quieto) y descarga en anillo; el suelo queda chamuscado y electrificado 8 s. ×1,3, empuje ×0,35; a mitad de vida, **Sobrecarga** (+20%) |
| Zubat | Hostigador | Chupavidas (cura la mitad) | Supersónico (cono que desorienta) | Ataque Ala | Rayo Confuso (lento, desorienta seguro) | **Ecolocalización**: no lo desorientan; Chupavidas cura el doble a un desorientado |
| Ekans | Control | Picotazo Veneno | Constricción (látigo corto que enraíza) | Ácido (charco: Expuesto) | Deslumbrar (cono que paraliza) | **Enroscarse**: quieto 0,8 s → el próximo golpe +40% y envión |
| Machop | Bruiser | Golpe Kárate (combo 3) | Patada Baja (ralentiza) | Malicioso (Expuesto) | Sísmico (embestida pesada, cráter) | **Incansable**: cada golpe cuerpo a cuerpo −0,3 s a todas las recargas; no lo ralentizan |
| Nidoran♀ | Bruiser | Arañazo | Doble Patada | Mordisco (×1,5 a lo envenenado) | Refuerzo (recibe ×0,7 4 s) | **Púas Venenosas**: devuelve 10% del daño cuerpo a cuerpo (+veneno 50%); con Refuerzo 20% y veneno seguro |
| Nidoran♂ | Asesino | Picotazo | Doble Patada | Malicioso | Cornada (embestida, 30% veneno) | **Oído Fino**: esquive perfecto → recarga Cornada y próximo golpe crítico |
| Horsea | Espaciador | Burbuja (3, empapan) | Pistola Agua (largo alcance) | Pantalla de Humo (nube que desorienta) | Chorro a Presión (carga 0,4 s, fuerte) | **Ancla**: quieto 0,5 s → disparos +30% y no lo empujan |
| Shellder | Tanque | Placaje | Carámbano (3, escarcha) | Refugio | Tenaza (se lanza y frena) | **Concha Bivalva**: de frente ×0,6, de espaldas ×1,4 |
| Tentacool | Control | Picotazo Veneno (latigazo) | Restricción (látigo largo que enraíza) | Ácido | Rayo Burbuja (ralentiza y empapa) | **Cuerpo de Agua**: mojado/en el agua se cura 2%/s; en seco −10% de velocidad |
| Voltorb | Hostigador | Rodar | Chispa (30% parálisis) | Bomba Sónica (anillo) | Autodestrucción (1,2 s de aviso, área grande; queda en 1 de vida y aturdido 2 s) | **Camuflaje**: quieto 1,5 s casi invisible → próximo golpe crítico |

## Combate de arena (2026-10-24, inspirado en Pokémon Arena 2D / Pokkén; ✅ implementado)
Pedido del usuario tras ver Pokémon Arena 2D: terreno que se deforma, superficies, combos y estilo de movimiento por
Pokémon (sin peleas de varios a la vez). **Por ahora rige solo en las peleas de arena** (torneo, gimnasio,
entrenadores); `GameConfig.arena_rules_everywhere = true` lo lleva al mundo abierto cuando se ajuste.
- **Estilos de movimiento** (`FightStyle.move_style`, `data/estilos/<especie>.tres` de `tools/build_fight_styles.py`):
  **ágil** (arranca y frena al instante, esquiva 25% más seguido: Pikachu, Poliwag, Rattata, Weedle, Eevee, Growlithe,
  Mankey) · **pesado** (inercia: acelera y frena de a poco, recibe 40% menos empuje: Geodude, Onix, Metapod, Kakuna,
  Seel) · **volador** (el terreno no lo frena: Pidgey, Spearow) · **normal** (el resto).
- **Combos — DESACTIVADOS (2026-10-24, decisión del usuario: "por ahora sacá los combos")**: interruptor
  `GameConfig.combos_enabled` (apagado); no prenderlo ni seguir con la v2 sin preguntar. Lo que hacían: cadena de
  golpes seguidos al mismo rival (+5% por golpe, hasta +25%; "COMBO ×N" desde el 3º) y **un
  combo con nombre por Pokémon** (`ComboData`: si conectás `first` y antes de 1,6 s `second`, pega más, empuja más y
  aplica un estado). Ej.: Charmander Arañazo → Ascuas = **Garra Ardiente** (×1,4 y quema); Pikachu Ataque Rápido →
  Impactrueno = **Descarga Relámpago** (paraliza); Onix Atadura → Tumba Rocas = **Sepultura**; Mankey Patada Baja →
  Golpe Kárate = **Golpe Bajo y Alto**. Lista completa en `tools/build_fight_styles.py`.
- **Terreno que se deforma**: `MoveData.crater_radius` (Excavar 34, Tumba Rocas 16, Lanzarrocas 8, Terremoto 40,
  Magnitud 30) → `Events.ground_impact` → estado de celda **cráter** (`data/environment/states/crater.tres`, 25 s) que
  se dibuja como pozo y **frena** (×0,65). Las arenas se registran en el `ReactionSystem` (`register_zone`), así el
  entorno reactivo también funciona adentro (agua de las lagunas, pasto que se prende).
- **Superficies** (`Creature.SURFACES`): cráter ×0,65, pasto alto ×0,85, arena ×0,85, mojado ×0,92 (los voladores y
  los que nadan no lo sienten).
- **Salto de cráter** (pedido del usuario): con el esquive (Espacio), si hay un cráter justo adelante (hasta 32 px) en
  la dirección en que **apuntás** o, si ahí no hay, hacia donde **caminás** (WASD; arreglo 2026-10-24: con el mouse
  en el rival no saltaba), los que tienen patas **saltan por el aire hasta la otra punta** (cruzan todos los cráteres
  seguidos, hasta 160 px; invulnerables; si del otro lado hay roca, pared o agua, es un esquive común).
  `FightStyle.can_jump`: Charmander, Squirtle, Bulbasaur, Pikachu, Rattata, Vulpix, Growlithe, Eevee, Mankey,
  Sandshrew, Psyduck, Poliwag, Paras, Oddish y Bellsprout. No saltan los bichos sin patas, Geodude, Onix ni Seel
  (Pidgey y Spearow vuelan por arriba). `Creature.crater_jump_target` / `_jump_to`.
- **Ataques de varios golpes cuentan una vez** (pedido del usuario: "se desbalancea mucho"): para la cadena y los
  combos solo vale el **primer golpe** de cada ataque; los demás (abanico de proyectiles, ticks de zonas y canalizados,
  varias piedras, pasos seguidos de un golpe con combo, el 2º golpe de una embestida) no suman cadena, no arman combo
  ni aplican el estado del combo (`Creature.is_same_attack`).
- **Tope de cráteres** (pedido del usuario): cada ataque de cada Pokémon deja como mucho `MoveData.crater_max` cráteres
  vivos (Excavar 2, Tumba Rocas 3, Lanzarrocas 4, Terremoto/Magnitud 1; al dejar uno más se borra el más viejo) y la
  cancha tiene un tope total de 40 celdas (`ReactionSystem.CRATER_CELLS_MAX`). `Events.ground_impact` lleva la fuente.
- **Combos v2**: propuesta en `docs/PROPUESTA_COMBOS.md` (2-3 por Pokémon con roles, efectos distintos, combos de 3
  golpes, descubrirlos, que los use la IA), a decidir con el usuario.
- **Sprite del cráter**: pedido al agente de mapas (un sprite de pozo estilo FireRed, con piezas para cráteres
  grandes); hoy se dibuja a mano en `EnvironmentGrid._draw_ground` (rama CRATER).
- Autotest `--autotest-arena-rules` (18 chequeos); vitrina `--showcase-arena-rules` (Geodude contra el Onix de Brock).

## Próximo paso sugerido
1. Que el usuario pruebe Charmander y Bellsprout en Ruta 1 y dé su opinión (sensación, recargas, rangos).
2. ✅ Kits de **Pidgey, Rattata y Vulpix** hechos (2026-10-22): todo lo que aparece en la zona de prueba tiene
   estilo propio. Falta que el usuario los pruebe (sensación del Vuelo, umbral de presa, ejecución).
3. Después Squirtle (tanque/parry) y Pikachu (cargas), que necesitan mecánicas nuevas (bloqueo mantenido, cargas).
4. Pendientes técnicos: mecánica de firma para el estilo control (ej. Siembra/Punta del documento original);
   la IA salvaje todavía elige ataques al azar dentro del alcance (falta que use las defensivas con criterio).

---

# Sistema de Estilos de Pelea — Combate Pokémon en Tiempo Real

> Documento de diseño para modelar a los Pokémon jugables. Objetivo: que cada uno **se sienta distinto de jugar**, no solo que tenga números distintos.
> Es agnóstico del motor: adaptá la estructura de datos a lo que ya existe en el proyecto.

---

## 1. Principio central

Cada Pokémon tiene identidad en **tres capas**:

1. **Arquetipo** → cómo quiere pelear (distancia, ritmo, rol).
2. **Mecánica de firma** → un recurso o regla propia que solo él tiene y que define sus decisiones.
3. **Kit** → los movimientos concretos, diseñados para alimentar la mecánica de firma.

Regla de oro: si a un Pokémon le sacás la mecánica de firma y se siente igual, el diseño falló.

---

## 2. Arquetipos

| Arquetipo | Rango ideal | Fantasía | Debilidad |
|---|---|---|---|
| **Bruiser** | Corto-medio | Entra, aguanta y gana peleas largas | Lo kitean |
| **Tanque** | Corto | Absorbe, bloquea, castiga errores | Poco daño, lento |
| **Control** | Medio | Domina el espacio, decide dónde se pelea | Frágil si lo alcanzan |
| **Velocista / Combo** | Variable | Movilidad alta, encadena y sale | Castigado si falla |
| **Hostigador aéreo** | Medio | Golpea y se va, imposible de atrapar | Poco daño sostenido |
| **Desgaste (DoT)** | Medio-largo | Gana por acumulación de estados | Débil al burst |
| **Espaciador** | Medio (preciso) | Premia la distancia exacta | Malo si lo pegan encima |
| **Asesino** | Corto | Remata, explota errores | Muy frágil |

---

## 3. Estados compartidos (la base para combos)

Los estados son el idioma común entre Pokémon. Varios interactúan entre sí, lo que genera sinergias y contra-juego.

| Estado | Efecto | Lo aplica |
|---|---|---|
| **Quemado** | Daño por tiempo, −15% daño físico del afectado | Charmander |
| **Empapado** | −10% velocidad. **Eléctrico contra empapado = aturdimiento** | Squirtle |
| **Enraizado** | No puede moverse, sí atacar | Bulbasaur, Bellsprout |
| **Paralizado** | (2026-10-24) De un golpe: 6 s a mitad de velocidad y **tirones al azar** (cada 1,5 s, 35%: queda totalmente quieto 0,6 s), como en los juegos. Antes acumulaba una barra | Pikachu, Oddish |
| **Envenenado** | DoT que escala con stacks (máx. 5) | Oddish, Bellsprout |
| **Dormido** | Inmóvil hasta recibir daño (con resistencia posterior) | Bulbasaur, Oddish |
| **Desorientado** | Controles/apuntado imprecisos, precisión reducida | Pidgey |
| **Herido** | −curación recibida, Rattata hace más daño | Rattata |

**Interacciones de tipo (prioritarias para la identidad):**
- Agua apaga Quemado (Squirtle puede limpiarse/limpiar aliados).
- Viento sobre Quemado → el fuego se propaga a enemigos cercanos.
- Eléctrico sobre Empapado → aturdimiento + daño extra.
- Planta sobre Empapado → enraizado dura más.
- Fuego sobre Enraizado → rompe la raíz y quema.

**Resistencia a control (CC):** tras recibir un aturdimiento/sueño, ventana de 2–3 s de inmunidad parcial para evitar cadenas infinitas.

---

## 4. Fichas de Pokémon

Escala de stats 1–5 (relativa entre ellos).

---

### 🔥 Charmander — Bruiser de rango medio
**Fantasía:** se calienta peleando. Cuanto más dura la pelea, más peligroso.

| Vida | Daño | Velocidad | Alcance | Control | Dificultad |
|---|---|---|---|---|---|
| 3 | 4 | 3 | 3 | 1 | 2 |

**Mecánica de firma — Calor (0–100)**
- Sube al pegar y al recibir daño. Baja lento fuera de combate.
- 50+: los ataques aplican Quemado.
- 100: entra en **Mar Llamas** (6 s): +daño, ataques con área, regeneración pequeña. Al terminar → **Sobrecalentado** (3 s, más lento).
- Decisión clave: ¿gastar el calor ahora o aguantar para la definitiva?

**Kit**
- **Básico — Arañazo:** combo de 3 golpes; el 3º empuja.
- **Ascuas:** proyectil de 3 brasas en abanico (herramienta de rango medio).
- **Giro Fuego:** anillo de fuego alrededor del objetivo que lo atrapa si intenta cruzar.
- **Movilidad — Embestida Ígnea:** dash corto que deja estela de fuego.
- **Definitiva — Lanzallamas:** canalizado en cono; consume Calor y escala con él.

**Juega bien contra:** Bulbasaur, Oddish, Bellsprout. **Sufre contra:** Squirtle, kiteo de Pidgey.

---

### 💧 Squirtle — Tanque medio / contraataque
**Fantasía:** se mete en el caparazón, aguanta y castiga.

| Vida | Daño | Velocidad | Alcance | Control | Dificultad |
|---|---|---|---|---|---|
| 4 | 2 | 2 | 2 | 3 | 3 |

**Mecánica de firma — Caparazón**
- **Refugio** (mantener botón): reduce 70% el daño frontal, no se mueve.
- Bloquear justo en el momento del impacto = **parry** → contragolpe garantizado.
- El daño bloqueado carga la **barra de Presión**, que potencia la siguiente habilidad.
- Deja **charcos** al usar habilidades: él se mueve más rápido sobre ellos y empapan a los enemigos.

**Kit**
- **Básico — Placaje:** golpes cortos y pesados.
- **Pistola Agua:** chorro que empuja y aplica Empapado.
- **Giro Rápido:** se mete al caparazón y rueda; limpia estados propios, choca y desplaza.
- **Utilidad — Refugio:** bloqueo/parry (mecánica de firma).
- **Definitiva — Hidrobomba:** consume Presión; gran empuje y charco grande.

**Juega bien contra:** Charmander, Rattata. **Sufre contra:** Bulbasaur, Pikachu (empapado propio = riesgo).

---

### 🌱 Bulbasaur — Control de zona
**Fantasía:** jardinero táctico. Decide dónde y cuándo se pelea.

| Vida | Daño | Velocidad | Alcance | Control | Dificultad |
|---|---|---|---|---|---|
| 3 | 2 | 2 | 4 | 5 | 4 |

**Mecánica de firma — Siembra**
- Ciertas habilidades plantan **semillas** en el suelo (máx. 4).
- Las semillas son trampas/zonas: se activan solas o manualmente (“florecer”).
- Cuantas más semillas activas, más fuerte la definitiva.
- Gana preparando terreno; pierde si lo sacan de su zona.

**Kit**
- **Básico — Látigo Cepa:** golpe de medio alcance con dos látigos.
- **Drenadoras:** marca al enemigo; drena vida mientras esté en rango.
- **Somnífero:** nube que duerme tras 1,5 s dentro (telegrafiado, esquivable).
- **Semilla Trampa:** planta semilla que enraiza al pisarla.
- **Definitiva — Rayo Solar:** carga larga, rayo enorme; cada semilla activa reduce la carga.

**Juega bien contra:** Squirtle, Rattata, Pikachu (si lo atrapa). **Sufre contra:** Charmander, Pidgey.

---

### ⚡ Pikachu — Velocista de combos
**Fantasía:** nunca se queda quieto; la velocidad se convierte en electricidad.

| Vida | Daño | Velocidad | Alcance | Control | Dificultad |
|---|---|---|---|---|---|
| 2 | 4 | 5 | 3 | 3 | 5 |

**Mecánica de firma — Estática**
- Moverse y esquivar generan **cargas** (máx. 5). Quedarse quieto las pierde.
- Las habilidades consumen cargas para potenciarse.
- Golpear con 5 cargas → **Descarga**: paraliza y rebota a un enemigo cercano.
- **Cancel de combos:** habilidades encadenables (Ataque Rápido → Impactrueno → Ataque Rápido) si se hacen en ritmo.

**Kit**
- **Básico — Golpe Rápido:** combo veloz de 4 golpes.
- **Ataque Rápido:** dash que atraviesa; con cargas, puede usarse 2 veces seguidas.
- **Impactrueno:** proyectil rápido; contra Empapado → aturdimiento.
- **Onda Trueno:** onda corta que aplica Paralizado fuerte.
- **Definitiva — Rayo:** varios rayos caen sobre área; daño escala con cargas.

**Juega bien contra:** Squirtle, Pidgey. **Sufre contra:** Bulbasaur (zonas), Oddish (DoT lo desgasta), errores propios.

---

### 🐦 Pidgey — Hostigador aéreo
**Fantasía:** golpea, se eleva, reposiciona. Molesto e inalcanzable.

| Vida | Daño | Velocidad | Alcance | Control | Dificultad |
|---|---|---|---|---|---|
| 2 | 2 | 4 | 3 | 3 | 3 |

**Mecánica de firma — Vuelo**
- Puede **elevarse** (estado aéreo): inmune a ataques terrestres cortos, pero no puede atacar cuerpo a cuerpo.
- Mientras vuela gasta **Aliento**; al aterrizar se recupera.
- Atacar en picada desde el aire hace daño extra (**Picado**).
- El viento manipula el campo: empuja enemigos y **proyectiles**.

**Kit**
- **Básico — Picotazo:** golpes rápidos.
- **Tornado:** ráfaga que empuja; desvía proyectiles; propaga Quemado.
- **Ataque Arena:** aplica Desorientado.
- **Remolino:** zona de viento que separa enemigos de sus aliados/zonas.
- **Definitiva — Pájaro Osado:** picada devastadora desde el aire; recibe parte de retroceso.

**Juega bien contra:** Bulbasaur, Bellsprout, Charmander (kitea). **Sufre contra:** Pikachu, Rattata si lo atrapa en tierra.

---

### 🍃 Oddish — Desgaste y estados
**Fantasía:** no te mata de golpe; te enferma de a poco.

| Vida | Daño | Velocidad | Alcance | Control | Dificultad |
|---|---|---|---|---|---|
| 3 | 2 | 2 | 3 | 4 | 3 |

**Mecánica de firma — Esporas**
- Cada habilidad deja **stacks de Esporas** en el enemigo (máx. 5).
- Oddish puede **florecer** las esporas: según el stack, aplica Veneno fuerte, Parálisis o Sueño.
- Se cura por cada stack que florece (sustain de desgaste).
- **Enterrarse:** puede meterse bajo tierra (inmóvil, se regenera, invulnerable un instante).

**Kit**
- **Básico — Absorber:** golpe corto que cura poco.
- **Polvo Veneno:** nube que aplica Envenenado + esporas.
- **Paralizador:** cono que aplica Paralizado + esporas.
- **Ácido:** proyectil que reduce defensa.
- **Definitiva — Danza Pétalo:** gira avanzando, aplica esporas rápido; al terminar queda confuso.

**Juega bien contra:** Squirtle, Pikachu, Rattata. **Sufre contra:** Charmander, Pidgey.

---

### 🌿 Bellsprout — Espaciador de látigo
**Fantasía:** maestro de la distancia exacta. La punta del látigo es letal.

| Vida | Daño | Velocidad | Alcance | Control | Dificultad |
|---|---|---|---|---|---|
| 2 | 4 | 3 | 4 | 3 | 4 |

**Mecánica de firma — Punta (sweet spot)**
- Sus ataques tienen **zona de punta**: golpear con el extremo hace +60% daño y aplica efecto.
- Golpear de cerca hace poco daño: premia el *spacing*.
- Cadena de puntas acertadas → **Ritmo**, reduce enfriamientos.
- Cuerpo flexible: esquiva hacia atrás con un pequeño salto (retroceso rápido).

**Kit**
- **Básico — Latigazo:** golpe largo con sweet spot.
- **Látigo Cepa:** golpe de gancho que atrae al enemigo hacia la zona de punta.
- **Constricción:** atrapa y enraiza; daño por tiempo.
- **Ácido:** escupitajo que envenena.
- **Definitiva — Hoja Afilada:** lluvia de hojas en línea, todas cuentan como “punta”.

**Juega bien contra:** Squirtle, Rattata, Pikachu (si espacia bien). **Sufre contra:** Charmander, Pidgey.

---

### 🐭 Rattata — Asesino oportunista
**Fantasía:** pequeño, nervioso, letal si te ve débil.

| Vida | Daño | Velocidad | Alcance | Control | Dificultad |
|---|---|---|---|---|---|
| 2 | 5 | 4 | 1 | 1 | 3 |

**Mecánica de firma — Instinto**
- Detecta enemigos con poca vida (marcados visualmente).
- Contra enemigos con menos del 40% de vida o con cualquier estado: +daño y críticos.
- **Foco Energía:** acumula y garantiza un crítico.
- Rematar a un enemigo reinicia su habilidad de movilidad.

**Kit**
- **Básico — Mordisco:** combo rapidísimo de golpes cortos.
- **Ataque Rápido:** dash de entrada.
- **Persecución:** salto a un enemigo que esté huyendo (+daño si le da la espalda).
- **Foco Energía:** carga crítico.
- **Definitiva — Hipercolmillo:** mordida de ejecución; mata si el enemigo está bajo un umbral.

**Juega bien contra:** Pikachu, Oddish, Pidgey en tierra. **Sufre contra:** Squirtle (parry), Bulbasaur (control).

---

## 5. Mapa de identidad (para validar que no se pisen)

| Pokémon | Rango | Ritmo | Gana por | Pregunta que se hace el jugador |
|---|---|---|---|---|
| Charmander | Medio | Crece en la pelea | Sostener presión | ¿Gasto el Calor ya? |
| Squirtle | Corto | Reactivo | Castigar errores | ¿Bloqueo o hago parry? |
| Bulbasaur | Medio-largo | Preparatorio | Controlar terreno | ¿Dónde planto? |
| Pikachu | Variable | Muy rápido | Combos | ¿Tengo cargas para el combo? |
| Pidgey | Aire | Golpe y fuga | Molestar | ¿Subo o ataco? |
| Oddish | Medio | Lento y constante | Acumular estados | ¿Florezco ahora? |
| Bellsprout | Medio exacto | Preciso | Distancia | ¿Estoy en la punta? |
| Rattata | Corto | Explosivo | Rematar | ¿Está lo bastante débil? |

**Sinergias de equipo sugeridas (si hay 2v2 o equipos):**
- Squirtle + Pikachu → empapar + aturdir.
- Bulbasaur + Charmander → enraizar + quemar.
- Pidgey + Charmander → viento que propaga fuego.
- Oddish + Rattata → estados que activan el Instinto.
- Bellsprout + Bulbasaur → atraer hacia trampas.

---

## 6. Estructura de datos sugerida

Todo data-driven para poder balancear sin tocar lógica:

```ts
type Arquetipo = "bruiser" | "tanque" | "control" | "velocista"
  | "hostigador" | "desgaste" | "espaciador" | "asesino";

interface PokemonDef {
  id: string;
  nombre: string;
  tipos: string[];
  arquetipo: Arquetipo;
  stats: {
    vida: number;
    velocidadMovimiento: number;
    defensa: number;
    // ...
  };
  mecanicaFirma: MecanicaFirmaDef; // recurso propio
  kit: {
    basico: HabilidadDef;
    habilidad1: HabilidadDef;
    habilidad2: HabilidadDef;
    movilidad: HabilidadDef;
    definitiva: HabilidadDef;
  };
}

interface MecanicaFirmaDef {
  id: string;            // "calor", "estatica", "siembra"...
  recursoMax: number;
  ganancia: Record<string, number>; // evento -> cantidad (ej. "alGolpear": 8)
  decaimientoPorSegundo: number;
  umbrales: { valor: number; efecto: string }[];
}

interface HabilidadDef {
  id: string;
  nombre: string;
  tipo: string;
  enfriamiento: number;
  tiempoCasteo: number;   // anticipación (telegrafiado)
  recuperacion: number;   // ventana de castigo
  hitbox: HitboxDef;      // forma, alcance, zona de punta opcional
  dano: number;
  estados?: { estado: string; duracion: number; stacks?: number }[];
  costeRecurso?: number;
  escalaConRecurso?: number;
  cancelableEn?: string[]; // para combos (Pikachu)
}
```

**Sistema de eventos:** la mecánica de firma escucha eventos de combate (`alGolpear`, `alRecibirDano`, `alMoverse`, `alBloquear`, `alRematar`, `alAplicarEstado`). Así cada Pokémon reacciona a su manera sin `if` por Pokémon en el código central.

---

## 7. Reglas de balance

- **Todo gran efecto se telegrafía.** Sueño, definitivas y control fuerte necesitan anticipación visible.
- **La recuperación (recovery) es la ventana de castigo.** Los ataques fuertes deben dejar abierto al atacante.
- **Presupuesto de poder:** más alcance/control → menos vida o daño. Usar la tabla de stats como guía: la suma de stats ronda 14–15.
- **Resistencia a control** tras CC para evitar bloqueos totales.
- **Cada Pokémon tiene al menos un mal matchup claro**, para que la elección importe.

---

## 8. Instrucciones para Claude (cómo empezar)

1. Revisá el código existente del combate y adaptá la estructura de la sección 6 al motor y convenciones del proyecto (no la copies a ciegas).
2. Implementá primero la **base compartida**: sistema de estados, eventos de combate y resistencia a control.
3. Implementá **un Pokémon completo** como prueba de la arquitectura — sugerido **Charmander** (mecánica de recurso simple) y después **Pikachu** (prueba combos y cancelaciones).
4. Definí los datos de cada Pokémon en archivos de configuración separados (JSON/ScriptableObject/Resource según el motor), no hardcodeados.
5. Después agregá el resto en este orden: Squirtle (bloqueo/parry), Bulbasaur (objetos en el suelo), Bellsprout (hitbox con zona de punta), Oddish (stacks en el enemigo), Rattata (umbral de vida), Pidgey (estado aéreo, el más complejo).
6. Dejá los números como valores iniciales a ajustar; priorizá que la **sensación** de cada estilo sea clara antes que el balance fino.
7. Si algo del diseño choca con lo ya construido, proponé la alternativa antes de reescribir sistemas existentes.

---
---

# Integración con el proyecto (Claude)

## Estado de avance

| Paso | Contenido | Estado |
|---|---|---|
| I-0 | Plan guardado; análisis de choques con lo construido; decisiones abiertas | ✅ Hecho |
| I-1 | Base compartida: estados nuevos (empapado, enraizado, envenenado con stacks, dormido, desorientado, herido; parálisis por acumulación), eventos de combate, resistencia a control, telegrafiado y recuperación | ✅ Hecho |
| I-2 | Kit de 5 ranuras + controles nuevos; Charmander completo (Calor, Mar Llamas, Sobrecalentado) | ✅ Hecho (reemplazado por v2) |
| v2 | **Rediseño del usuario:** sin energía, 4 ataques + esquive, Charmander bruiser rearmado, Bellsprout/Bulbasaur control, spawns de Ruta 1 | ✅ Hecho |
| I-3 | Pikachu (Estática, cargas, cancelación de combos) | Pendiente |
| I-4 | Squirtle (Refugio, parry, Presión, charcos) | Pendiente |
| I-5 | Bulbasaur (semillas en el suelo, Somnífero telegrafiado, Rayo Solar) | Pendiente |
| I-6 | Bellsprout (hitbox con zona de punta, Ritmo) | Pendiente |
| I-7 | Oddish (stacks de esporas en el enemigo, florecer, enterrarse) | Pendiente |
| I-8 | Rattata (Instinto por umbral de vida, Foco Energía, ejecución) | ✅ Hecho |
| I-8b | Vulpix (desgaste de quemaduras, Rescoldo) — no estaba en el documento original | ✅ Hecho |
| I-9 | Pidgey (estado aéreo, Aliento, viento que desvía proyectiles) | ✅ Hecho (v2: Vuelo con el esquive) |

## Decisiones del usuario (2026-10-21, no volver a preguntar)
- **Orden:** el plan de identidad va **ahora, antes de la Etapa 3** (entorno reactivo). Después la Etapa 3
  reutiliza charcos, semillas, estelas de fuego y viento de los kits.
- **Stats:** los **oficiales** siguen siendo la base numérica (vida, daño, velocidad por nivel). La tabla 1–5
  es **guía de diseño del kit** (alcance, control, dificultad), no reemplaza números.
- **Estados:** se usan **los del documento** (identidad): Quemado −15% daño físico, Paralizado por
  acumulación, Empapado, Enraizado, Envenenado con stacks, Dormido, Desorientado, Herido. **Congelado se
  mantiene** para el hielo.
- ~~Controles del kit (5 ranuras con movilidad propia en Espacio)~~ → **reemplazado en v2**: 4 ataques
  (Clic izq., Clic der., Q, R), **sin energía**, esquive genérico en Espacio. (Tab = cambiar de Pokémon;
  F = sacar/guardar.)

## Cómo quedó implementado (I-1)
- **Estados** (`scripts/resources/status_effect.gd`, datos en `data/status/*.tres`): además de duración,
  daño por segundo y multiplicadores, ahora tienen `can_move` (Enraizado), `max_stacks` (Envenenado ×5),
  barra de acumulación `buildup` (Paralizado: cada aplicación suma 0,4; al llenarse aturde 0,9 s),
  `wake_on_damage` (Dormido), `aim_jitter_deg` (Desorientado), `heal_mult` (Herido 0,5), `is_cc`.
  Valores: Quemado 5 s, 3%/s, −15% daño físico · Empapado 5 s, −10% velocidad · Enraizado 2 s ·
  Envenenado 6 s, 1,2%/s por stack · Dormido 3 s · Desorientado 3 s, ±28° · Herido 6 s · Congelado 2,2 s.
- **Interacciones** (`StatusInteraction`, `data/status/interactions/*.tres`): elemento × estado →
  consumir, multiplicar daño, aturdir, aplicar otro estado, extender duración, contagiar en radio.
  Las 6 del documento: agua apaga Quemado · fuego derrite Congelado · viento (volador) contagia Quemado
  a compañeros a 48 px · eléctrico sobre Empapado ×1,5 daño + aturde 0,9 s · planta sobre Empapado
  alarga Enraizado ×1,5 · fuego sobre Enraizado rompe la raíz y quema. Texto flotante al dispararse.
- **Eventos de combate por criatura** (señales en `Creature`): `hit_dealt`, `damage_received`, `moved`,
  `dodged`, `killed`, `status_inflicted`, `move_released`. Las mecánicas de firma se conectan a estas.
- **Resistencia a control:** al terminar un control (`stun(..., cc=true)`), 2,5 s en los que otro control
  dura 30%. Aro blanco tenue a los pies mientras dura.
- **Telegrafiado:** nodo `Telegraph` en cada criatura: círculo (áreas) o línea (proyectiles/embestidas) en
  el suelo, que se llena durante la carga.
- **Recuperación:** `MoveData.recovery` → estado `recovery` (no ataca ni esquiva, se mueve al 35%).
- Visual: raíces a los pies (Enraizado), "z" (Dormido), barra de parálisis, puntitos por stack de veneno.
- Autotest: `--autotest-identity` verifica cada regla (14 chequeos).

## Cómo quedó implementado (v2, vigente)
- `Kit` = `archetype` + `preferred_range` + `signature` opcional + `moves` (4). `MoveUser` sin energía: 4 ranuras
  con recarga (combos opcionales) + `dodge_cooldown`. Pokémon sin kit: sus `SpeciesData.moves` a las 4 teclas.
- Tipos de ataque nuevos en `MoveData.Kind`: `LUNGE` (estado `lunge`: se lanza al punto; si el contacto pega,
  `followup_delay` y 2º golpe con `followup_knockback`), `WHIP` (`WhipLash`: agarra al primero), `SELF_BUFF`
  (aplica `self_status`). `ZONE` con `zone_traps=false` = `GroundZone` (parche/nube: `zone_tick`,
  `zone_max_count`, `dwell_time`/`dwell_status`). `statuses_on_hit` = estados que aplica siempre.
- Estados nuevos: `ralentizado` (×0,6 velocidad), `arraigado` (Arraigo), `sintesis` (Síntesis); campos nuevos
  en `StatusEffect`: `damage_taken_mult`, `heal_per_second`, `knockback_mult`.
- Golpes de daño 0 (esporas) ya no hacen destello ni empuje: solo aplican estados.
- Autotests: `--autotest-kit` (Charmander, Bellsprout, Pidgey, Rattata y Vulpix: 38 chequeos), vitrina
  `--showcase-kit` (los 5 kits; grabar con `--quit-after 2400`).

## Cómo quedó implementado (I-2: kit + Charmander) — HISTÓRICO, reemplazado por v2
- **Datos** (todo editable en el inspector): `Kit` (`scripts/resources/kit.gd`): arquetipo, rango preferido
  (IA), mecánica de firma y 5 ranuras. `SignatureData`: recurso máximo, `gains` por evento, decaimiento en/fuera
  de combate, umbrales (marcas de la barra), `params` y el script de comportamiento. Las habilidades son
  `MoveData` con tipos nuevos: `MELEE` (combo), `ZONE` (zona que atrapa), `CHANNEL` (cono canalizado), además de
  abanico de proyectiles, estela de la movilidad, costo/escalado de recurso. `SpeciesData.kit` lo conecta.
- **Kit de Charmander** en `data/kits/charmander/`: Arañazo (combo ×3, el 3º empuja 260), Ascuas (3 brasas en
  abanico de 24°), Giro Fuego (zona de 30 px que atrapa, carga 0,25 s), Embestida Ígnea (dash invulnerable que
  deja fuego en el suelo 2,5 s), Lanzallamas (canalizado 1,3 s en cono de 40°, consume todo el Calor y hace
  hasta ×2 de daño).
- **Calor** (`scripts/combat/signatures/heat_mechanic.gd`): +7 al pegar, +5 al recibir daño, −6/s fuera de
  combate. ≥50: los golpes queman. 100: Mar Llamas 6 s (×1,25 daño, áreas ×1,6, regenera 1,5%/s, aura de fuego).
  Después: Sobrecalentado 3 s (×0,7 velocidad).
- **Mecánica de firma genérica** (`SignatureMechanic`): escucha las señales de su criatura y expone ganchos
  (`modify_hit`, `speed_mult`, `state_label`, `consume`). Mientras canaliza una habilidad que gastó recurso,
  no gana recurso.
- **Pokémon sin kit**: sus 4 ataques se mapean solos (1-3 en básico/hab.1/hab.2, el 4º como definitiva) y la
  movilidad es el esquive genérico.
- **IA**: usa el rango preferido del kit, guarda la definitiva para cuando tiene ≥60% de recurso y esquiva con la
  movilidad propia.
- **Interfaz**: 5 ranuras con su tecla, pasos del combo, ícono de carga y de costo de recurso; barra de la mecánica
  de firma con marcas en los umbrales y estado ("MAR LLAMAS", "SOBRECALENTADO", "QUEMA"); arquetipo en el panel.
- Autotests: `--autotest-kit` (13 chequeos del kit de Charmander); vitrina visual `--showcase-kit`.

## Qué ya existe y se reutiliza
- **Estados como Resources** (`StatusEffect` + `StatusEffects`): duración, daño por tiempo, multiplicadores,
  curación por elemento (`cured_by`: agua apaga quemado, fuego derrite congelado), partículas y tinte.
- **Bus de eventos** (`Events`): `move_used`, `creature_damaged`, `status_applied`, `creature_fainted`,
  `element_impact`. Base para los eventos de la mecánica de firma.
- **Ataques data-driven** (`MoveData`): proyectil, embestida, área, escudo; carga (cast time) interrumpible.
- **Hitbox/Hurtbox**, `HitInfo` + `Damage`, IA salvaje con máquina de estados, `CombatInput`/bot.

## Choques con lo construido y propuestas (a decidir con el usuario)
1. **Stats 1–5 vs. stats oficiales.** Hoy los stats salen de la fórmula oficial (pedido del usuario en la
   Etapa 2b). Propuesta: los stats oficiales siguen siendo la base numérica (vida, daño, velocidad), y la
   tabla 1–5 se usa como **guía de diseño del kit** (alcance, control, dificultad), no como stats.
2. **Estados del documento vs. versión actual.** Quemado (−15% físico vs. ×0,5 oficial), Paralizado
   (barra que acumula vs. probabilidad por segundo). Congelado no está en la tabla pero ya existe (hielo).
   Propuesta: adoptar las versiones del documento (identidad) y mantener Congelado para hielo.
3. **Kit de 5 ranuras vs. 4 ataques + esquive.** Propuesta de controles: clic izq. = básico,
   clic der. = habilidad 1, Q = habilidad 2, Espacio = movilidad propia (reemplaza el esquive genérico),
   R = definitiva.
4. **Kits a mano vs. ataques oficiales.** Los kits incluyen ataques que no están cargados (Drenadoras,
   Somnífero, Rayo Solar, Onda Trueno, Rayo, Giro Rápido, Hidrobomba, Picotazo, Ataque Arena, Remolino,
   Pájaro Osado, Absorber, Polvo Veneno, Paralizador, Ácido, Constricción, Persecución, Foco Energía,
   Hipercolmillo, Latigazo). Propuesta: el comportamiento lo define el kit; la **potencia base** sale del
   ataque oficial (PokeAPI), con un multiplicador por habilidad para ajustar.
5. **Salvajes.** La IA tiene que saber usar cada kit (y la mecánica de firma). Propuesta: cada kit declara
   "intenciones" para la IA (rango ideal, cuándo usar cada habilidad), así la IA genérica las aprovecha.
6. **Especies sin ficha** (Vulpix, Psyduck, Growlithe, Poliwag, Seel, Eevee): quedan con el sistema actual
   hasta tener su ficha; o se les asigna un arquetipo con kit simple.
7. **Relación con la Etapa 3 (entorno reactivo).** Charcos de Squirtle, semillas de Bulbasaur, estela de
   fuego de Charmander y viento de Pidgey son objetos/efectos en el suelo: conviene que usen el mismo
   sistema de celdas del entorno reactivo, para que el fuego queme el pasto y el agua deje el suelo mojado.
