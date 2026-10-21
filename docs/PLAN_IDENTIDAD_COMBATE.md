# Plan de identidad de combate en tiempo real

> Plan **separado** del plan de etapas (`docs/PROGRESO.md`). Lo definió el usuario el 2026-10-21:
> la dirección del combate es que **cada Pokémon se sienta distinto de jugar**. Abajo está su documento
> de diseño tal cual; al final, la sección **"Integración con el proyecto"** (escrita por Claude) con el
> estado de avance, cómo encaja con lo ya construido y los puntos a decidir.

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
| I-2 | Kit de 5 ranuras + controles nuevos; Charmander completo (Calor, Mar Llamas, Sobrecalentado) | Pendiente |
| I-3 | Pikachu (Estática, cargas, cancelación de combos) | Pendiente |
| I-4 | Squirtle (Refugio, parry, Presión, charcos) | Pendiente |
| I-5 | Bulbasaur (semillas en el suelo, Somnífero telegrafiado, Rayo Solar) | Pendiente |
| I-6 | Bellsprout (hitbox con zona de punta, Ritmo) | Pendiente |
| I-7 | Oddish (stacks de esporas en el enemigo, florecer, enterrarse) | Pendiente |
| I-8 | Rattata (Instinto por umbral de vida, Foco Energía, ejecución) | Pendiente |
| I-9 | Pidgey (estado aéreo, Aliento, viento que desvía proyectiles) | Pendiente |

## Decisiones del usuario (2026-10-21, no volver a preguntar)
- **Orden:** el plan de identidad va **ahora, antes de la Etapa 3** (entorno reactivo). Después la Etapa 3
  reutiliza charcos, semillas, estelas de fuego y viento de los kits.
- **Stats:** los **oficiales** siguen siendo la base numérica (vida, daño, velocidad por nivel). La tabla 1–5
  es **guía de diseño del kit** (alcance, control, dificultad), no reemplaza números.
- **Estados:** se usan **los del documento** (identidad): Quemado −15% daño físico, Paralizado por
  acumulación, Empapado, Enraizado, Envenenado con stacks, Dormido, Desorientado, Herido. **Congelado se
  mantiene** para el hielo.
- **Controles del kit (5 ranuras):** Clic izq. = básico · Clic der. = habilidad 1 · **Q** = habilidad 2 ·
  **Espacio** = movilidad propia (reemplaza el esquive genérico) · **R** = definitiva. (Tab queda para cambiar
  de Pokémon; F para sacar/guardar.)

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
