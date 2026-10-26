# Propuesta — kits para los Pokémon que todavía no tienen estilo propio

> **Estado (2026-10-26)**: la **Tanda A está implementada** (Raichu jefe, Zubat, Ekans, Machop, Nidoran♀/♂, Horsea,
> Shellder, Tentacool, Voltorb): ver `PLAN_IDENTIDAD_COMBATE.md` "v6", con las simplificaciones anotadas ahí. Quedan
> las Tandas B y C.

Pedido del usuario (2026-10-25): "analizá los Pokémon implementados y, para los que no tienen un kit especializado,
pensá cómo deberían pelear según sus descripciones y cosas del anime". **Es una propuesta**: nada de esto está
implementado. Se decide con el usuario qué tanda se hace y qué se cambia antes de tocar `data/kits/`.

Mismo formato que el plan de identidad (v2 vigente): 4 ataques (Clic izq. · Clic der. · Q · R = el de más recarga) +
esquive igual para todos + mecánica de firma. Regla de oro: si le sacás la firma y se siente igual, el diseño falló.
Por eso cada firma de acá trata de **no repetir** las 30 que ya existen (Calor, Vuelo, Instinto, Rescoldo, Presión,
Estática, Esporas, Jaqueca, Deslizamiento, Rastreo, Adaptación, Escarcha, Impulso, Seda, Aguijón, Capullo, Furia,
Rabia, Velo Arena, Coloso, Núcleo, Mente Rápida, Ira de Dragón).

## 1. Qué hay en el juego hoy

Se contó todo lo que puede aparecer: tablas de salvajes (`data/world/encounters/`) y equipos de entrenadores
(`tools/build_story_npcs.py`, `data/trainers/`). Son **45 especies**.

| Situación | Especies |
|---|---|
| **Kit propio (23)** | Bulbasaur, Charmander, Squirtle, Pidgey, Rattata, Spearow, Pikachu, Caterpie, Metapod, Butterfree, Weedle, Kakuna, Beedrill, Sandshrew, Oddish, Mankey, Growlithe, Bellsprout, Geodude, Onix (jefe), Staryu, Starmie (jefa), Kadabra |
| **Heredan kit (6)** | Ivysaur, Charmeleon, Wartortle, Pidgeotto, Raticate → bien así · **Raichu → problema (ver 2)** |
| **Sin kit, usan su learnset (21)** | Zubat, Ekans, Machop, Nidoran♀, Nidoran♂, Horsea, Shellder, Tentacool, Voltorb, Abra, Clefairy, Goldeen, Jigglypuff, Magnemite, Meowth, Drowzee, Grimer, Koffing, Ponyta, Slowpoke, Magikarp |

(Psyduck, Poliwag, Seel, Paras, Vulpix y Eevee tienen kit pero hoy no salen en ningún mapa de la historia.)

**Prioridad sugerida** (por cuántas veces aparecen en el juego y por importancia):

- **Tanda A**: Raichu jefe (gimnasio), Zubat (7), Ekans (8), Machop (6), Nidoran♀ (6), Nidoran♂ (5), Horsea (5),
  Shellder (5), Tentacool (5) y Voltorb (4, también de Surge).
- **Tanda B**: Clefairy, Abra, Goldeen, Jigglypuff, Magnemite y Meowth (2-3 apariciones cada uno).
- **Tanda C**: Drowzee, Grimer, Koffing, Ponyta, Slowpoke y Magikarp (1 aparición cada uno; Magikarp es el de $500).

Al hacer un kit, sus evoluciones lo heredan solas (Golbat, Arbok, Machoke, Nidorina/Nidorino, Seadra, Tentacruel,
Electrode, Magneton, Persian, Hypno, Muk, Weezing, Rapidash, Slowbro...) con el criterio ya acordado: kit propio
solo si cambian mucho de forma de pelear.

---

## 2. Raichu — JEFE de Lt. Surge (urgente)

Hoy `raichu.tres` tiene `kit_inherited = true` con el kit de Pikachu: el jefe del capítulo 3 pelea igual que un
Pikachu salvaje. Onix y Starmie tienen kit de jefe, así que este es el más importante.

**Referencia**: en el anime, el Raichu de Surge evolucionó a la fuerza con la Piedra Trueno. Es **mucho más fuerte
pero más lento** que Pikachu, y Ash le gana en la revancha usando la velocidad. Según su descripción de la Pokédex,
cuando tiene los mofletes sobrecargados **planta la cola en el suelo** para descargar, y alrededor de su madriguera
quedan **zonas chamuscadas**.

**Idea**: un jefe pesado que pega como un camión y llena la arena de suelo electrificado. La lección del anime queda
como estrategia: si lo esquivás y aprovechás su lentitud, le ganás.

| | Ataque | Qué hace |
|---|---|---|
| Clic izq. | **Puño Trueno** | Combo de 2 golpes pesados; el 2º empuja fuerte y paraliza 25%. |
| Clic der. | **Impactrueno Triple** | Abanico de 3 rayos (como el Lanzarrocas de Onix). |
| Q | **Chispa** | Embestida eléctrica larga, telegrafiada 0,3 s; si choca contra una pared queda aturdido 0,8 s (la ventana para castigarlo). |
| R | **Trueno** | 3 rayos caen del cielo sobre el punto apuntado, con aviso (reusa `strike_count` de Tumba Rocas); paraliza al que pega. |

**Firma — Toma de Tierra**: barra que sube al pegar y al recibir. Llena → **planta la cola**: 1 s quieto (vulnerable,
telegrafiado) y suelta una descarga en anillo. Las celdas donde pega quedan **chamuscadas y electrificadas** 8 s:
dan un tirón de parálisis al que las pisa, y en los charcos de la arena eléctrica corre la corriente (ya existe en
el entorno reactivo). Cuerpo ×1,3 y empuje reducido, como los otros jefes. **A mitad de vida, Sobrecarga**: los
mofletes chisporrotean, +20% de daño, el Trueno cae doble y Chispa ya no lo aturde contra las paredes.

Pieza nueva: celdas "electrificadas" (un `EnvCellState` + `ReactionRule`, sin código central).

---

## 3. Tanda A

### Zubat — Hostigador vampiro
**Referencia**: los enjambres de Mt. Moon, que en el anime aparecen en cualquier cueva. **No tiene ojos** y se
orienta por ultrasonido (Supersónico). Su descripción dice que no aguanta la luz del sol.
- Clic izq. **Chupavidas**: mordida rápida que cura la mitad del daño (reusa `drain`).
- Clic der. **Supersónico**: onda en cono corto que desorienta.
- Q **Ataque Ala**: pasada en línea recta que **atraviesa** al rival y termina del otro lado.
- R **Rayo Confuso**: proyectil lento que desorienta seguro.
- **Firma — Ecolocalización**: es ciego, así que **Ataque Arena, Nube de Arena, Pantalla de Humo y Deslumbrar no le
  hacen nada**. Además, su Supersónico marca a los desorientados: contra ellos, Chupavidas cura el doble. Estilo de
  movimiento **volador**.
- *Por qué es distinto*: no es Pidgey (vuelo con barra) ni Spearow (furia). Sobrevive robando vida y es inmune a
  todo lo que ciega.

### Ekans — Emboscador que se enrosca
**Referencia**: Ekans es el Pokémon de Jessie. Su descripción dice que **se enrosca** para responder rápido a
cualquier amenaza, con una "feroz mirada" (**Deslumbrar**, que en el juego paraliza).
- Clic izq. **Picotazo Veneno**: mordida rápida, 30% veneno.
- Clic der. **Constricción**: agarre corto que enraíza 1,2 s y lastima mientras dura.
- Q **Ácido**: escupe un charco que deja **Expuesto** al que lo pisa.
- R **Deslumbrar**: cono corto telegrafiado 0,3 s; paraliza seguro.
- **Firma — Enroscarse**: si se queda quieto 0,8 s se enrosca (se ve el sprite enrollado). El próximo ataque sale
  como un **resorte**: alcance ×1,5, +40% de daño y un pequeño dash. Moverse lo desenrosca.
- *Por qué es distinto*: es el único que gana **quedándose quieto y esperando**. Dan ganas de acecharlo con cuidado.

### Machop — Luchador de agarres
**Referencia**: según su descripción, "no se agota por mucho esfuerzo que haga" y puede con cien adultos. Su ataque
clásico es **Sísmico**, donde agarra al rival y lo estrella contra el suelo.
- Clic izq. **Golpe Kárate**: combo de 3; el 3º tiene mucho crítico.
- Clic der. **Patada Baja**: barrida en arco que tambalea y ralentiza.
- Q **Foco Energía**: guarda un crítico seguro (reusa el de Rattata).
- R **Sísmico**: agarre corto. Si atrapa, lo levanta y lo **estrella detrás de Machop**: daño fijo según el nivel
  (como en el juego), cráter chico y temblor de pantalla.
- **Firma — Incansable**: cada golpe cuerpo a cuerpo que conecta baja 0,3 s todas sus recargas, y no lo pueden
  ralentizar.
- *Por qué es distinto*: Mankey se enoja y Machop no se cansa. Es el primer **lanzamiento** del juego, muy estilo
  Pokkén.
- Pieza nueva: **agarre y lanzamiento** (mover al rival a otro punto con un arco). Le sirve después a Machoke,
  Machamp y Hitmonlee.

### Nidoran♀ — Bruiser espinoso
**Referencia**: según su descripción, sus **púas segregan un veneno potente** y las desarrolló para protegerse,
porque es chiquita.
- Clic izq. **Arañazo**: combo de 2.
- Clic der. **Doble Patada**: 2 patadas; la 2ª empuja.
- Q **Mordisco**: pega +50% contra envenenados.
- R **Refuerzo**: 4 s recibe ×0,7 y sus púas se duplican.
- **Firma — Púas Venenosas**: cada vez que le pegan cuerpo a cuerpo, el atacante recibe 10% del daño de vuelta y
  suma veneno. Con Refuerzo activo, 20% del daño de vuelta y veneno seguro.
- *Por qué es distinta*: Kakuna envenena solo cuando está quieta y endurecida. Nidoran♀ castiga **todo** el cuerpo a
  cuerpo y puede pelear de frente.

### Nidoran♂ — Duelista de reflejos
**Referencia**: según su descripción, mueve las orejas para **captar hasta el sonido más leve**, y ataca con el
cuerno.
- Clic izq. **Picotazo**: combo de 2.
- Clic der. **Doble Patada**.
- Q **Foco Energía**.
- R **Cornada**: embestida con cuerno, telegrafiada; 30% veneno.
- **Firma — Oído Fino**: **esquive perfecto**. Si esquiva en los últimos 0,25 s antes de que le pegue, se recarga
  Cornada y su próximo golpe es crítico. Además, los ataques telegrafiados le muestran el aviso antes.
- *Por qué es distinto*: es el primero que premia el **timing** del esquive. Nidoran♀ aguanta y Nidoran♂ esquiva:
  pareja con estilos opuestos, como en el anime.
- Pieza nueva: detectar el esquive perfecto (`dodge` + golpe entrante en una ventana). Sirve para varios más.

### Horsea — Francotirador anclado
**Referencia**: es el Horsea de Misty, que tira **tinta (Pantalla de Humo)**. Según su descripción, **se ancla con
la cola** a rocas y corales para que la corriente no lo arrastre.
- Clic izq. **Burbuja**: ráfaga de 3 burbujas lentas.
- Clic der. **Pistola Agua**: disparo de largo alcance.
- Q **Pantalla de Humo**: nube de tinta. Los rivales adentro quedan desorientados y Horsea, adentro, recibe menos
  daño de proyectiles.
- R **Chorro a Presión**: carga 0,4 s y dispara un chorro que **atraviesa** a todos en línea.
- **Firma — Ancla**: quieto 0,5 s se ancla. Sus disparos ganan +30% de daño y alcance y no lo pueden empujar.
  Moverse lo suelta.
- *Por qué es distinto*: es el primer **espaciador** de verdad del juego (el arquetipo está en el plan y nadie lo
  usa). Gana con la distancia justa y sufre si se lo pegan encima.

### Shellder — Concha con lengua
**Referencia**: en el juego y en el anime, Shellder **muerde la cola de Slowpoke** y no la suelta (así nace
Slowbro). Su descripción dice que cierra la concha pero **deja la lengua afuera**.
- Clic izq. **Placaje**.
- Clic der. **Carámbano**: 3 carámbanos rápidos en línea; dejan escarcha (reusa el estado de Seel).
- Q **Refugio**: se cierra (recibe ×0,3, como el de Squirtle pero sin parry).
- R **Tenaza**: salta y **se prende del rival** 2,5 s. Lo muerde por tics y lo frena; el rival puede sacárselo
  esquivando.
- **Firma — Concha Bivalva**: **de frente** recibe −40% de daño y **de espaldas** +40% (la lengua). Hay que rodearlo.
- *Por qué es distinto*: es el único con **defensa por dirección**, que obliga a moverse alrededor de él, y el
  primero que se engancha al rival.
- Piezas nuevas: daño según el ángulo del golpe (gancho `damage_taken_mult` con dirección) y "pegarse al rival".

### Tentacool — Medusa de tentáculos
**Referencia**: el episodio de Tentacool y Tentacruel, en el que atacan la ciudad costera. Según su descripción,
está hecho casi todo de agua y **se seca fuera del mar**.
- Clic izq. **Picotazo Veneno**: latigazo de tentáculo de alcance medio, 30% veneno.
- Clic der. **Restricción**: látigo largo que ata (enraíza 1 s y lastima), sin atraer.
- Q **Ácido**: charco que deja Expuesto.
- R **Rayo Burbuja**: abanico de burbujas que ralentizan y empapan.
- **Firma — Cuerpo de Agua**: sobre agua o suelo mojado se cura 2%/s y sus tentáculos llegan +30% más lejos. En
  suelo seco, −10% de velocidad ("se seca"). Si lo empapan, le hace bien en vez de mal.
- *Por qué es distinto*: depende del **terreno**. En la arena de Misty o con lluvia es una amenaza, en seco es débil.

### Voltorb — Bomba rodante
**Referencia**: **se parece a una Poké Ball** (en el juego aparece camuflado como objeto en la Central Energía) y es
famoso por **Autodestrucción**. Velocidad base 100.
- Clic izq. **Rodar**: embestida que **rebota** en paredes y rocas.
- Clic der. **Chispa**: golpe corto, 30% parálisis.
- Q **Bomba Sónica**: onda en anillo alrededor.
- R **Autodestrucción**: parpadea 1,2 s (telegrafiado; se puede huir) y explota en un área grande. Lo deja con 1
  de vida y aturdido 2 s, así el jugador puede usarlo sin perder al Pokémon.
- **Firma — Camuflaje**: quieto 1,5 s se ve como una Poké Ball del mapa. Los salvajes lo ignoran y su próximo
  ataque desde el camuflaje es crítico. La IA de Surge lo usa para emboscar.
- *Por qué es distinto*: es el kamikaze rápido del juego. Pega y sale, y cada pelea tiene la amenaza de la
  explosión.
- Pieza nueva: rebote contra paredes (el rayo contra el mundo ya existe en `clear_shot`).

---

## 4. Tanda B

### Clefairy — Caótico lunar
**Referencia**: el episodio de Clefairy y la Piedra Lunar en Mt. Moon y su clásico **Metrónomo**. Según su
descripción, sale a jugar con la luna llena.
- Clic izq. **Doble Bofetón**: combo de 2 a 5 bofetadas, al azar.
- Clic der. **Canto**: anillo de notas que duerme al que se queda 0,6 s adentro (como Somnífero, pero centrado en
  Clefairy).
- Q **Reducción**: se achica 3 s (hurtbox chica, esquiva más seguido).
- R **Metrónomo**: lanza **un ataque al azar de cualquier kit del juego**: un Lanzallamas, una Tumba Rocas o una
  Salpicadura.
- **Firma — Luz de Luna**: cada Metrónomo carga la luna. Con 3 cargas, el próximo Metrónomo elige entre los 5
  ataques más fuertes. Cuando exista el ciclo día/noche (Etapa 5), de noche se cura sola.
- Pieza nueva: elegir un `MoveData` al azar de `DB` y usarlo. Es fácil y muy divertido de ver.

### Jigglypuff — Cantante inflable
**Referencia**: en el anime **canta, todos se duermen y, ofendido, les dibuja la cara con un marcador**. En el juego
usa Rodar y Rizo Defensa.
- Clic izq. **Destructor**: golpe con combo de 2.
- Clic der. **Rodar**: se infla y rueda (embestida que rebota, como la de Voltorb pero más lenta).
- Q **Rizo Defensa**.
- R **Canto**: canaliza 1,5 s y suelta un anillo **grande** que duerme a todos los que no salgan.
- **Firma — Inflado y Marcador**: cada golpe que recibe lo infla (hasta 3: más grande, más pesado, empuja al que lo
  toca). Rodar gasta el inflado para pegar más. Sus golpes contra dormidos dejan un **garabato** en la cara del
  rival (Expuesto 6 s, recibe +25%), como en el anime.
- *Diferencia con Clefairy*: Clefairy es azar, Jigglypuff es dormir y castigar.

### Abra — El que no se deja atrapar
**Referencia**: según su descripción, **duerme 18 horas al día** y, cuando detecta un enemigo, se teletransporta.
En el juego es famoso porque se escapa antes de que lo atrapes. El Abra de Sabrina siempre duerme.
- Clic izq. **Destello Psíquico**: disparo débil.
- Clic der. **Teletransporte**: desplazamiento corto invulnerable.
- Q **Confusión**: 30% desorienta.
- R **Teletransporte Lejano**: desaparece y reaparece lejos. Un Abra salvaje lo usa para **escaparse de la pelea**.
- **Firma — Sueño Vigilante**: fuera de combate duerme y se cura. Si le pegan mientras duerme, se teletransporta
  solo (cada 6 s). Para capturarlo hay que dormirlo o paralizarlo primero.
- *Nota*: es el kit más "de salvaje" de todos. Lo importante es que atraparlo sea un desafío, como en el juego.
  Kadabra ya tiene kit propio.

### Goldeen — Anti-tanque con cuerno
**Referencia**: es el Goldeen de Misty, el chiste de que **fuera del agua solo aletea**. Según su descripción,
"en cualquier momento puede embestir con el cuerno".
- Clic izq. **Picotazo**: combo de 2.
- Clic der. **Supersónico**.
- Q **Hidrochorro**: moja el suelo alrededor (para nadar).
- R **Cornada**: embestida larga con el cuerno.
- **Firma — Cuerno Perforador**: sus golpes de cuerno **ignoran las defensas** (Fortaleza, Refugio, Rizo
  Defensa, Capullo, Concha) y en agua o suelo mojado se mueve ×1,3. En seco, cada tanto da un "aleteo" (pierde
  0,3 s), en guiño al anime.
- *Por qué es distinto*: es la respuesta a los tanques (Metapod, Squirtle, Geodude, Shellder).

### Magnemite — Torreta magnética
**Referencia**: imán flotante de Acero/Eléctrico. Según su descripción, **se engancha a las líneas de tensión**. En
el juego aprende **Fijar Blanco**.
- Clic izq. **Impactrueno**.
- Clic der. **Bomba Sónica**: onda en anillo.
- Q **Supersónico**.
- R **Fijar Blanco**: marca al rival 4 s y **todos sus disparos lo persiguen** (teledirigidos).
- **Firma — Magnetismo**: sus disparos atraen un poco al rival hacia él, y los rivales de tipo Acero o Eléctrico
  quedan medio "pegados" (−20% de velocidad cerca de él). Flota: no lo frenan los cráteres ni el pasto alto.
- Pieza nueva: proyectiles teledirigidos.

### Meowth — Ladrón de monedas
**Referencia**: es el Meowth del Team Rocket y su **Día de Pago**. Según su descripción, "adora las monedas
brillantes" y camina a hurtadillas.
- Clic izq. **Arañazo**: combo de 3 rápido.
- Clic der. **Mordisco**: 30% Herido.
- Q **Finta**: aparece detrás del rival y golpea; no se puede esquivar.
- R **Golpes Furia**: ráfaga de 2 a 5 zarpazos.
- **Firma — Día de Pago**: cada golpe hace saltar una moneda al piso. Si Meowth pasa por arriba, le baja 0,5 s las
  recargas. Al terminar la pelea, las monedas que quedaron se suman a **tu dinero** (`GameState.money` ya existe).
- *Por qué es distinto*: obliga a moverse por la cancha juntando monedas, y le da un uso concreto al sistema de
  dinero del Torneo.

---

## 5. Tanda C (1 aparición cada uno)

| Pokémon | Estilo | Clic izq. · Clic der. · Q · R | Firma | Referencia |
|---|---|---|---|---|
| **Drowzee** | Control de sueño | Destructor · Confusión · Anulación (reusa la de Psyduck) · **Comesueños** (×2 contra dormidos y cura la mitad) | **Hipnosis acumulable**: sus ataques psíquicos suman Somnolencia (como la Escarcha de Seel): con 4, duerme | Según su descripción, **come sueños** por la nariz; en el anime, Hypno duerme a la gente con el péndulo |
| **Grimer** | Tanque de lodo | Destructor (abrazo pegajoso que ralentiza) · Residuos (bola que deja charco tóxico) · Armadura Ácida (recibe ×0,6) · **Derretirse** (1 s hecho charco: invulnerable a proyectiles, se desliza rápido) | **Rastro de Lodo**: al moverse deja lodo que ralentiza y envenena (como la estela de Embestida Ígnea); no lo pueden ralentizar | Según su descripción, su **cuerpo de lodo se cuela** por cualquier hueco; en el anime, el Muk de Ash abraza a Oak |
| **Koffing** | Trampero | Placaje · Gas Venenoso (nube) · Pantalla de Humo (nube que desorienta) · **Detonar** (hace explotar todas sus nubes a la vez) | **Gas Inflamable**: sus nubes explotan con fuego o con Detonar (empujan y pegan); como las esporas de Paras, pero las prende él | Es el Koffing de James. Según su descripción, **se hincha hasta explotar** |
| **Ponyta** | Velocista de carrera | Pisotón (tambalea) · Ascuas · Giro Fuego · **Derribo** (embestida que usa el galope) | **Galope**: correr en línea recta acumula velocidad (hasta ×1,4) y deja estela de fuego; girar fuerte la pierde | El episodio de la **carrera de Ponyta**; según su descripción, se hace fuerte de tanto caerse |
| **Slowpoke** | Tanque despistado | Golpe Cabeza · Pistola Agua · **Pesca con Cola** (látigo largo que atrae, como el Látigo Cepa) · **Bostezo** (a los 2 s el rival se duerme si no lo golpearon ni esquivó) | **Reacción Tardía**: el daño que recibe le llega repartido en 3 s, y si en ese tiempo pega, se "olvida" de un 30% | En el anime, **reacciona varios segundos tarde**; según su descripción, **pesca con la cola** |
| **Magikarp** | Chiste | Salpicadura (salta: esquive que no hace nada) · Placaje · Azote (más daño cuanto menos vida) · Salpicadura Alta | **Determinación**: cada pelea en la que participa y sobrevive suma algo de EXP extra (para llegar a Gyarados) | El triste ejemplo de un Pokémon que "solo salta y salpica". El chiste es que no sirva... hasta que evoluciona |

---

## 6. Piezas nuevas del motor que harían falta

Todas genéricas, por datos, **sin `if especie`**:

| Pieza | La usan | Esfuerzo |
|---|---|---|
| Celdas electrificadas (`EnvCellState` + `ReactionRule`) | Raichu | bajo (solo datos) |
| Agarre y lanzamiento (mover al rival con un arco) | Machop (y Machoke/Machamp) | medio |
| Esquive perfecto (ventana antes del golpe) | Nidoran♂, después otros | medio |
| Daño según la dirección del golpe | Shellder | bajo |
| Engancharse al rival (seguirlo pegado) | Shellder (Tenaza) | medio |
| Rebote contra paredes en embestidas | Voltorb, Jigglypuff | medio |
| Autodestrucción (área grande + queda en 1 de vida) | Voltorb | bajo |
| Camuflaje (sprite de Poké Ball, la IA lo ignora) | Voltorb | bajo |
| Inmunidad a estados por firma | Zubat, Grimer, Machop | bajo |
| Ataque al azar de `DB` | Clefairy | bajo |
| Proyectiles teledirigidos | Magnemite | medio |
| Monedas recogibles + dinero al final | Meowth | medio |
| Detonar las nubes propias | Koffing | bajo (reusa `ignite` de Paras) |
| Velocidad por distancia recorrida en línea recta | Ponyta | bajo |
| Daño diferido | Slowpoke | bajo |
| Estado con demora (Bostezo) | Slowpoke | bajo |
| Inflarse durante la pelea (`body_scale` dinámico) | Jigglypuff | bajo (`body_scale` existe) |

Lo demás reusa piezas existentes: `drain`, combos de golpes, abanicos, `zone_strike`/`strike_count`, látigos que
atraen o atan, parches, estados (Expuesto, Desorientado, Escarcha, Foco Energía, Refugio, Rizo).

## 7. Preguntas para el usuario

1. ¿Arrancamos por la **Tanda A** con **Raichu jefe primero**?
2. ¿Autodestrucción deja a Voltorb en 1 de vida (propuesta) o lo debilita como en el juego?
3. ¿Querés el **Metrónomo** de Clefairy con cualquier ataque del juego, o solo de una lista curada?
4. ¿Meowth suma monedas a tu dinero real, o es solo un efecto de la pelea?
5. ¿Hay algún Pokémon que imagines distinto? (por ejemplo, Zubat más molesto y menos vampiro)
