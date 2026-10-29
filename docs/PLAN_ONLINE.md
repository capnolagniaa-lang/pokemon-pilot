# Plan: multijugador online (fases O)

Pedido del usuario (2026-10-29): poder pelear online con amigos en una arena. Un edificio nuevo (hecho con Qwen) con su
interior: una enfermera que cura (como la del Centro Pokémon), una tienda y un NPC que muestra quién está conectado
para desafiarlo.

## Decisiones tomadas (no volver a preguntarlas)
| Tema | Decisión |
|---|---|
| Conexión | **Servidor propio**: el mismo juego corriendo en modo servidor (`-- --server`, headless) en una PC prendida o un servidor en la nube. Todos se conectan ahí. El servidor **simula la pelea** (nadie hace trampa y nadie tiene que abrir puertos, salvo el que hostea el servidor). |
| Sala | **Solo una lista en el NPC**: el edificio es un interior normal y el NPC abre una pantalla con los conectados. Ver a los otros caminando (como el Club Unión) queda para más adelante. |
| Equipos | **Nivel real** por ahora: cada uno pelea con su equipo tal cual lo tiene en su partida. |
| Recompensa | **Da experiencia como un combate en el mundo**, para cada uno de los dos jugadores (misma fórmula que contra un entrenador, repartida entre los que pelearon: `CombatDirector.exp_shares`). |
| Lugar | **Ciudad Verde**. Se llega enseguida en la historia. |

## Cómo funciona (arquitectura)
```
 Jugador A (su juego)            Servidor (mismo juego, --server)            Jugador B (su juego)
 ─ partida, mundo, equipo ─┐     ┌─ sala: nombres + equipos ─┐            ┌─ partida, mundo, equipo
   entra al edificio,      ├────►│  desafíos / aceptar       │◄───────────┤
   abre la lista (NPC)     │     │  ARENA: simula la pelea   │            │
   manda teclas ──────────►│     │  con los dos equipos      │◄────────── teclas
   ◄─── estado de la pelea │     │  (20-30 veces por segundo)│ estado ───►
   al terminar: EXP local  ┘     └─ resultado a los dos ─────┘            └ al terminar: EXP local
```
- **Red**: `ENetMultiplayerPeer` de Godot (UDP) + RPC. Un autoload nuevo, `Net` (`scripts/autoload/net.gd`), que
  conecta, manda y recibe. Igual que el resto de los sistemas, avisa todo por `Events` (`online_players_changed`,
  `online_challenge`, `online_battle_started`...).
- **La pelea la simula el servidor**: arma la arena (`TrainerBattle` / `ArenaData`) con los dos equipos que mandaron
  los jugadores. El código de combate ya separa quién da las órdenes (`CombatInput` del teclado, `BotCombatInput` de
  los tests). Se suma un `NetCombatInput`, que aplica las teclas que llegan por red: moverse, apuntar, los 4 ataques,
  esquivar y cambiar de Pokémon. Así se usa **el mismo combate que ya existe**, sin otro aparte.
- **Los jugadores ven la pelea**: el servidor manda 20-30 veces por segundo una foto del estado (posición, vida,
  animación, estados y recargas de cada criatura, y los proyectiles y áreas vivos). Los golpes, los números de daño y
  los efectos viajan como `Events` (el feedback ya escucha solo `Events`). Cada juego dibuja la pelea un poquito
  atrasada (~100 ms) e interpola entre fotos, así se ve suave.
- **Lag**: al principio tu Pokémon responde con el retraso de la conexión (con amigos en Argentina, 30-80 ms; se nota
  poco). Si molesta, se agrega **predicción** de tu propio movimiento (fase O-6).
- **Qué mandás al servidor**: tu nombre (el de la partida), la versión del juego y tu equipo (`CreatureInstance.to_dict`:
  especie, nivel, IVs, habilidad, ataques, vida). Entre amigos no se valida contra trampas, solo que los datos tengan
  sentido (especies y ataques que existen, niveles de 1 a 100).
- **Misma versión**: el servidor rechaza un juego de otra versión y avisa que hay que bajarse el zip nuevo (si no, los
  ataques y los datos no coinciden).
- **Partida y guardado**: la pelea online no toca el archivo del otro. Al terminar, el servidor manda el resultado y
  **cada juego** aplica la EXP (y lo que se decida de la vida) a su propio equipo y guarda.

## El edificio y el interior
- **Exterior, con Qwen** (ComfyUI, `docs/COMFYUI.md`): Qwen-Image + LoRA de pixel art, con el estilo y la paleta de los
  edificios de FireRed (de referencia: el Centro y la Tienda de Ciudad Verde). Tamaño de un Centro Pokémon o un poco
  más grande (unos 5×4 metatiles, 80×64 px), con techo de otro color y algo que lo distinga (una antena). Después se
  limpia, se pasa a la paleta y se recorta con un script como `tools/prop_from_image.py`.
- **Cómo se pone en el mapa sin pisar las zonas**: los mapas los toca otro agente, así que
  `scenes/world/zones/ciudad_verde.tscn` y `kanto.tres` no se editan. El edificio va como **agregado**: un dato nuevo
  (`data/world/extra_buildings.json` o un `.tres`: zona, celda, sprite, celdas sólidas y celda de la puerta) que
  `World` pone al cargar la zona, con un sprite y su colisión. La puerta la registra el `WarpSystem` desde ese dato.
  **Hay que elegir el lugar** en Ciudad Verde, uno libre que no tape caminos (lo valida `MapRules`).
- **Interior**: una escena aparte como las arenas (no es una zona de `kanto.tres`), armada con los tiles de interior de
  FireRed (piso, mostradores y PC del Centro Pokémon) con el editor de mapas o con un script. Adentro hay tres personas:
  - **Enfermera**: cura al equipo, la misma acción que la del Centro (`StoryDirector.heal_party`). También marca el
    lugar al que volvés si perdés (`last_heal_position`).
  - **Vendedor**: una `ShopData` nueva (`data/shops/online.tres`, con la lista de Ciudad Verde) y la misma
    `ShopScreen`.
  - **Recepcionista online**: acción `online` (`StoryDirector.register_action`). Si no estás conectado, conecta al
    servidor y abre la **pantalla de la sala**.
- **Personas**: se agregan con `tools/build_story_npcs.py` (sprites de FireRed que ya están: enfermera, vendedor y una
  recepcionista).

## Pantalla de la sala (`OnlineLobbyScreen`)
- Lista de conectados: nombre, retratos de su equipo (los 6, con nivel) y si está **libre**, **eligiendo** o
  **peleando**.
- **Desafiar**: elegís a alguien y el formato (cuántos Pokémon: 1, 3 o 6; por defecto 3). El otro ve
  "¡X te desafía! (3 contra 3)" y puede aceptar o rechazar. Si acepta, los dos tienen 30 s para elegir cuáles llevan.
  Después, pantalla VS (`VsScreen`) y a la arena.
- Arriba se ve el estado de la conexión, el ping y cuántos hay conectados. Si se cae el servidor, se avisa y te deja
  en el edificio.

## La pelea online
- Mismas reglas que contra un entrenador en arena: 1 contra 1, con cambios (1-6). Gana el que debilita a todos los del
  otro. Para que todos vean lo mismo, la arena es fija: `arena_campo` o una nueva, "arena online".
- **Pausa**: no hay. El menú (Esc) se abre reducido (Mochila y Equipo) y la pelea sigue.
- **Objetos**: la C (objeto rápido) funciona igual. La Mochila que cuenta es la de cada jugador, que el servidor recibe
  al empezar.
- **Si alguien se desconecta**: el servidor espera 15 s. Si no vuelve, gana el otro y recibe su EXP.
- **Al terminar**: un cartel con el resultado. Cada jugador recibe EXP por cada Pokémon del rival que debilitó
  (fórmula del juego, `exp_mult` de **sus** Ajustes), y vuelve al edificio junto a la recepcionista.

## Fases (tabla de avance)
| Fase | Qué | Cómo se prueba |
|---|---|---|
| **O-0** ✅ | Base de red: autoload `Net`, modo `--server` headless, conectar, nombre, chequeo de versión, lista de conectados, desconexiones. **Hecho 2026-10-29** (ver "Hecho: O-0"). | `--autotest-online`: servidor + 2 clientes **en el mismo proceso** (Godot permite una `MultiplayerAPI` por rama del árbol) por `127.0.0.1`. |
| **O-1** ✅ | El edificio (Qwen) en Ciudad Verde como agregado, la puerta y el interior con enfermera, tienda y recepcionista. | Autotest: entrar y salir por la puerta, curar, comprar, la recepcionista abre la sala. Vitrina con capturas. |
| **O-2** ✅ | Sala: pantalla de conectados, desafiar, aceptar o rechazar, elegir equipo. (La pantalla VS va con la pelea, O-3.) | Autotest con 2 clientes de prueba que se desafían. |
| **O-3** ✅ | Pelea online: el servidor simula, `NetCombatInput`, fotos del estado + `Events`, interpolación, fin de la pelea y desconexión. | Autotest: 2 clientes con bots (`BotCombatInput` del lado del cliente) pelean hasta que gana uno; los dos ven lo mismo. |
| **O-4** ✅ | Resultado: EXP para cada uno, vuelta al edificio (hecho junto con la O-3; se guarda como siempre, desde el menú). | Autotest: la EXP sube como en un combate en el mundo. |
| **O-5** | Poner el servidor: `build_portable.py --server` (un ejecutable de servidor), guía para correrlo en una PC (con el puerto abierto en el router) o en un servidor en la nube gratis (Oracle Cloud Always Free). Dirección del servidor en Opciones (con una por defecto). | Probarlo de verdad con un amigo. |
| O-6 (después) | Predicción del movimiento propio, ping en pantalla, chat rápido o emotes, sala compartida (verse caminando), nivel 50 opcional. | — |

## Hecho: O-0 (2026-10-29)
- `NetPeer` (`scripts/net/net_peer.gd`): el mismo script hace de servidor (`host`) o de cliente (`join`), cada uno con
  su `SceneMultiplayer` propia (`set_multiplayer` sobre su rama). Mensajes: `hello` (versión, `PROTOCOL`, nombre,
  equipo) → `welcome` / `rejected`; `player_list` a todos cuando algo cambia; `update_team`, `set_status`
  ("libre", "eligiendo", "peleando"). El servidor limpia el nombre (16 letras, sin repetir: "Ash (2)") y el equipo
  (especies que existen, nivel de 1 a 100), echa al que no se presenta en 10 s y rechaza otra versión o sala llena (32).
  El cliente queda "offline" con un mensaje si no encuentra el servidor (8 s) o si se corta (ENet, 8 s sin respuesta).
- **Versión** = `Net.game_version()`: `PROTOCOL` + huella de los ataques (forma, potencia, recarga, empuje) y de las
  especies. Cambia sola cuando cambian los datos: dos zips distintos no se mezclan.
- Autoload `Net` (`scripts/autoload/net.gd`): `go_online()` (nombre = `Net.player_name` o el de la partida; equipo =
  especie y nivel), `go_offline()`, `is_online()`, `players`; avisa por `Events.online_state_changed` y
  `online_players_changed`. Dirección, puerto y nombre en `user://online.cfg` (de la PC). Por defecto `127.0.0.1:24680`.
- **Servidor**: `godot --headless --path . -- --server [--port 24680]` (descarga la escena del título y solo atiende la
  sala; escribe en la consola quién entra y sale).
- Test `--autotest-online`: servidor + 4 clientes en el mismo proceso, el autoload Net y el modo `--server` en otro
  proceso.

## Hecho: O-3 (2026-10-29)
- **Servidor** (`NetMatch`, `scripts/net/net_match.gd`; lo arma `NetPeer._start_battle` cuando los dos eligieron, con
  `host_battles`): la arena `arena_campo` (solo sus tiles, sin el mundo: las criaturas y los ataques no lo necesitan) y
  el Pokémon de cada uno, en estado "controlled", movidos por `NetCombatInput` (las teclas que llegan: mover, apuntar,
  punto, bits de los 4 ataques y un contador de esquives). Lado A = el que desafió (abajo), B = el que aceptó (arriba).
  Cuenta regresiva de 3 s; cambios 1-6 con 1,5 s de espera; al debilitarse sale el siguiente en pie a los 1,2 s; sin
  ninguno, gana el otro. Tope 5 min (gana el que tiene más vida en proporción). Si alguien se desconecta, gana el otro.
  Manda una foto 20 veces por segundo (`battle_state`: posición relativa a la arena, mirada, vida en proporción,
  estados, stagger, quién está afuera y sus teclas) y los hechos (`battle_event`: start, hit, faint, send, end con la
  vida final de cada equipo). Cada pelea va lejos de las otras (`-60000 + id·4000`).
- **Jugador** (`OnlineBattle`, `world.online.battle`; la arranca `OnlineDesk` al cerrar la sala): fundido, arena (lejos de
  la de los entrenadores), tu Pokémon = el compañero de siempre manejado con el teclado (CombatDirector, `arena_lock`) y el
  del rival imitado con sus teclas. **Se imita la pelea con el mismo combate del juego** (se ven igual los ataques y los
  efectos), pero acá los golpes no pegan (sin hurtbox): vida, estados, debilitados y cambios los dice el servidor; las
  posiciones se corrigen con sus fotos (el rival se acerca rápido; el tuyo solo si se fue más de 28 px, así no tironea).
  El Pokémon del rival está en los enemigos de CombatDirector: cuando se debilita, **la EXP se reparte como en un combate
  en el mundo** (entre los que pelearon contra él). El daño queda (como en el mundo; la enfermera está al lado). Sin
  pausa (el menú no abre), sin E ni C (objetos) en la pelea. 1-6 pide el cambio al servidor (`intercepts_switch`). Al
  terminar: cartel "¡GANASTE!" / "Perdiste...", y de vuelta frente a la recepcionista.
- `PROTOCOL` 3 (la vida va como proporción, `hp_ratio`: cada partida puede tener otra escala de vida).
- Tests: `--autotest-online` (pelea en el servidor: cuenta regresiva, golpes, cambio, debilitados, fin, desconexión) y
  `--autotest-online-building` (la pelea con el mundo: arena, rival en tus enemigos, sin pausa, gana y suma EXP, vuelve
  al edificio).

## Hecho: O-2 (2026-10-29)
- **Servidor del juego fijo** (`Net.OFFICIAL_SERVER`): nadie tiene que escribir una dirección. Mientras no haya un
  servidor de verdad prendido (O-5) es esta misma PC; cuando esté, va ahí su dirección fija (IP de la nube o un nombre
  tipo DuckDNS si corre en una PC de casa) y sale en los zips. Opciones → Online → "Servidor" queda como **avanzado**
  (vacío = el del juego; `Net.server_override`, `user://online.cfg`).
- **Protocolo** (`NetPeer`, `PROTOCOL` 2): `challenge(a quién, formato 1/3/6)` → al otro `got_challenge`; `answer`
  (aceptar/rechazar) o `withdraw` (retirar); sin contestar en 20 s se cae. Aceptado: `got_choose` a los dos (contra
  quién, formato, 30 s); `choose_team` manda los `CreatureInstance.to_dict` elegidos (el servidor saca los
  debilitados y lo que pasa del formato: `clean_battle_team`); con los dos, `got_ready` (con qué viene el otro) y
  `match_started` en el servidor. **Hasta la O-3 nadie escucha `match_started`: la partida termina ahí y vuelven a estar
  libres** (`end_match`). Si no eligen a tiempo (30 + 5 s) o alguien se desconecta, `got_cancelled` al otro. Estados en
  la lista: libre → eligiendo → peleando. No se puede desafiar a uno mismo, a alguien ocupado, ni con un desafío
  pendiente.
- **Pantalla** `OnlineLobbyScreen` (la abre la recepcionista; `OnlineDesk.open_lobby`): sala (conectados con retratos y
  nivel, estado, formato, Desafiar / Retirar, desafío entrante con Aceptar / Rechazar), elegir (tu equipo, contador; al
  llegar a 0 van los primeros en pie) y lista. Esc o Salir cierra (retira o rechaza lo pendiente). Conectado y con la sala
  cerrada, un desafío te llega como pregunta de la recepcionista (si estás en una charla, pelea o menú, se rechaza solo).
  La sala ve tu equipo al día (`Net.refresh_team` al cambiar o curar el equipo).
- Tests: `--autotest-online` (protocolo) y `--autotest-online-building` (pantalla, con un jugador de prueba); vitrina
  `--showcase-online-building` (la sala con dos amigos de prueba y la elección de equipo).

## Hecho: O-1 (2026-10-29)
- **Edificios y zonas agregados** (`ExtraContent`, `scripts/world/extra_content.gd`): `data/world/extra/zones/*.tres`
  (ZoneEntry) y `data/world/extra/buildings/*.tres` (`ExtraBuilding`: zona, celda, tamaño, sprite, puerta, destino).
  `DB` los suma a la región al arrancar (zona nueva + puerta en la zona de afuera, marcada `"extra": true`); `World` pone
  el sprite, la colisión (`Body`) y las celdas sólidas (meta `extra_solid`, la lee `MapRules.cell_physics`) al cargar la
  zona. El editor de mapas guarda la región con `ExtraContent.without_extras` (kanto.tres queda igual). **No se tocó
  ninguna zona importada.**
- **El edificio**: `sprites/props/centro_online.png` (80×64, Qwen Edit 2511 a partir del Centro Pokémon de Ciudad
  Verde, lo hizo la sesión de ComfyUI; variantes en su carpeta). En Ciudad Verde, celdas (64, 43) a (68, 46), a la
  derecha del Centro; puerta (66, 46).
- **El interior** `centro_online` ("Centro de Combate Online"): por ahora una copia del Centro Pokémon de Ciudad Verde
  (`scenes/world/extra/centro_online.tscn`), debajo de todo el mundo (origen 0, 3300). Se puede retocar con el editor
  de mapas. Personas (`data/story/npcs/centro_online_*.tres`, escritas a mano: no salen de `build_story_npcs.py`):
  enfermera (cura y marca adónde volvés si perdés), vendedor (`data/shops/online.tres`, la lista de Ciudad Verde) y la
  recepcionista del Club de Cable (acción `online`: `OnlineDesk`, `world.online`; conecta, dice cuántos hay, "Ver quién
  está" con sus equipos, "Desconectarme").
- **Opciones → Online**: tu nombre y el servidor (`host` o `host:puerto`; `Net.set_server`), en `user://online.cfg`.
- Test `--autotest-online-building`; vitrina `--showcase-online-building`.

## Preguntas abiertas (para cuando lleguemos)
- **Vida después de la pelea**: ¿el daño queda como en el mundo (te curás con la enfermera de al lado) o se vuelve como
  estaba? Recomendación: queda, como en el mundo, para que sea igual que un combate normal.
- **Dinero**: ¿el que gana se lleva un premio como contra un entrenador? Por ahora no.
- **Dónde corre el servidor**: ¿en tu PC (hay que abrir un puerto en el router) o en un servidor en la nube gratis?
  Para probar, primero en tu PC.
- **El lugar exacto** del edificio en Ciudad Verde.
