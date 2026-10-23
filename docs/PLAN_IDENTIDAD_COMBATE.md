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
| **Paralizado** | Acumula; al llenar la barra → aturdimiento corto | Pikachu, Oddish |
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
