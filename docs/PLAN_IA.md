# Plan: IA de los Pokémon (fases IA)

Pedido del usuario (2026-10-30): mejorar la IA con todas las ideas de la lista (elegir ataque por situación, tipos,
habilidades, entorno, memoria corta, salvajes vivos, entrenadores con cabeza y que se sienta justo).

**Base que ya existe** (no se reescribe): el **cuerpo** `CombatBody` (alcance, apuntar con anticipación, esquivar,
peligros, rodear obstáculos, camino por celdas) y la dificultad `AiDifficulty`, que actúa solo ahí. La **mente** es el
estado `attack` (`creature_attack.gd`) + el `Temperament` del salvaje. Las peleas de entrenador (arena) usan el mismo
estado (`Creature.ai_fighter`), así que todo lo de la mente sirve para los dos.

**Arquitectura nueva**: `TacticalMind` (`scripts/creatures/ai/tactical_mind.gd`, `Creature.mind`, una por criatura)
= *qué* hacer: puntúa los ataques, lee los tipos, la habilidad y el entorno, y (fase 2) recuerda lo que hiciste. El
cuerpo sigue siendo el *cómo*. Nada de `if especie == ...`: todo sale de datos (ataques, tipos, habilidad,
temperamento, dificultad).

**Regla de justicia** (vale para todas las fases): la IA puede ser más lista, pero **siempre se puede leer**: los
ataques fuertes avisan antes, reacciona con tiempo humano y la dificultad regula cuánto piensa.

## Fases

| Fase | Qué | Cómo se prueba |
|---|---|---|
| **IA-1** | **Mente táctica + justicia**: elige el ataque por situación (potencia, STAB, efectividad contra tu Pokémon, si estás en stagger/cargando/recuperándote, no repetir siempre el mismo); lee los tipos para posicionarse (si tu Pokémon le pega súper efectivo se cuida: más distancia y ataca menos seguido; si él te pega súper efectivo, presiona); **tiempo de reacción** humano antes de esquivar; **aviso** (brillo + pausa corta) antes de los ataques fuertes sin carga. Dificultad: `smarts` (cuánto piensa vs. azar), `reaction`, `telegraph`. | `--autotest-ai-mind` |
| IA-2 | **Memoria corta** (la pelea actual, ~10 eventos): hacia dónde esquivás, con qué abrís, tus recargas (castiga la ventana), cambio de plan con poca vida según temperamento (valiente se juega todo, tímido huye, astuto se cubre/cura), **fintas** en Difícil. | bot que siempre esquiva a la derecha → la IA lo anticipa |
| IA-3 | **Habilidad y entorno**: la mente lee los parámetros de la habilidad (contacto, Intimidación...) y el `ReactionSystem` (descarga eléctrica si estás en el agua, prende el pasto alto entre los dos, evita las celdas que le hacen mal y te empuja a ellas). | casos armados en `--autotest-ai-mind` |
| IA-4 | **Entrenadores con cabeza**: cambian de Pokémon con criterio (tipos, vida), usan objetos (líderes: 1-2 Superpociones), **personalidad por clase** (perillas en datos), **líderes con guion** (2-3 momentos por líder, en datos). | peleas de arena con bot |
| IA-5 | **Salvajes vivos**: rutinas de día/noche (nocturnos duermen de día), **manadas** (se coordinan, defienden a las crías), presas y depredadores, **huyen de un Pokémon mucho más fuerte**, curiosidad (Pokébola, objetos). | `--autotest-wild-ai` ampliado + vitrina |
| IA-6 | **Ajuste fino**: dificultad dinámica opcional (si perdés seguido contra el mismo líder, baja un poco su reacción; ajuste de partida), batería de balance IA contra IA para que nada quede injusto. | `--autotest-balance` |

## Avance

| Fase | Estado | Notas |
|---|---|---|
| IA-1 | ✅ Hecha (2026-10-30) | `TacticalMind`, `AiDifficulty.smarts/reaction/telegraph`, aviso `CreatureSprite.tell_left` |
| IA-2 | ✅ Hecha (2026-10-30) | memoria en `TacticalMind`, `Temperament.low_hp`, `AiDifficulty.feint_chance` |
| IA-3 | ⏭️ Siguiente | |
| IA-4 a IA-6 | Pendientes | |

## Detalle IA-1

- **Puntaje de un ataque** (`TacticalMind.score`): solo los que llegan (`CombatBody.fits` + tiro limpio). Base =
  potencia × STAB × efectividad contra los tipos de tu Pokémon (inmune = 0). Los de estado/mejora: valor fijo (si
  `fits` los deja, son buena idea). Si estás **vulnerable** (stagger, cargando, recuperándote, dormido/paralizado)
  ×1,4 a los que pegan fuerte. Repetir el último ×0,7 (para que no sea siempre lo mismo, pero se lea). Azar ±15 %.
  Con `smarts` bajo (Fácil) el puntaje se mezcla con azar: elige más "tonto".
- **La apertura** del temperamento sigue igual (el de acercamiento si está lejos): eso es instinto, se lee.
- **Tipos y posición** (`TacticalMind.matchup`): ventaja = mejor efectividad de sus ataques contra vos; peligro = la
  mejor de los tuyos contra él. Peligro ≥ 2 y ventaja < 2 → cauteloso (distancia ×1,25, ataca ×1,2 más lento); ventaja ≥ 2
  y peligro < 2 → presiona (ataca ×0,85).
- **Reacción** (`CombatBody.try_dodge`): ve el disparo desde más lejos, decide si esquiva (dodge_chance) y lo hace
  recién pasado `reaction` (±30 %), si sigue viniendo. Fácil 0,35 s · Normal 0,22 s · Difícil 0,14 s.
- **Aviso** (estado `attack`): un ataque de potencia ≥ 60 sin carga (los con carga ya se marcan en el suelo) se
  anuncia: brilla anaranjado y se frena `telegraph` s (Fácil 0,35 · Normal 0,22 · Difícil 0,12); apunta al soltarlo.

## Detalle IA-2

- **Memoria** (`TacticalMind`, de la pelea actual; `observe()` cada cuadro: si cambia el rival, `forget()`): los últimos
  10 esquives (de qué lado de la línea entre los dos, con `Creature.last_dodge_dir`) y las formas de tus últimos 10
  ataques (`move_released`).
- **Te lee el esquive**: con 3+ esquives y 75 % al mismo lado, sus disparos y zonas se corren 42 px hacia ese lado
  (`aim_read`, en `CombatBody.use`) con probabilidad 0,6 × confianza × `smarts`. Si no esquivás, ese tiro te pasa al
  costado: se le puede ganar cambiando de lado.
- **Tu estilo**: si 70 % de tus ataques son de lejos, esquiva más (+0,15 × smarts; en Fácil nunca); si son de cerca, los
  de distancia te mantienen más lejos (×1,2).
- **Ventana**: si tenés todos tus ataques fuertes (≥ 60) en recarga o te estás recuperando, se te viene encima y ataca
  ×0,75 más seguido.
- **Poca vida** (< 35 % o el `flee_below` del temperamento; `Temperament.low_hp`): tímido y curioso **huyen** (como antes),
  agresivo **se juega todo** ("!", no huye, ataca ×0,7), territorial y los de entrenador **se cubren** (más lejos, ataca
  ×1,25 más lento, escudos y curas valen ×2,5).
- **Fintas** (`AiDifficulty.feint_chance`: Fácil 0, Normal 0,05, Difícil 0,2): el ataque avisado no sale y ataca 0,25 s
  después (castiga si esquivaste al aviso).
