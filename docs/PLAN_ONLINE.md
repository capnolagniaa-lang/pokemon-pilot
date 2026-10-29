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
| **O-0** | Base de red: autoload `Net`, modo `--server` headless, conectar, nombre, chequeo de versión, lista de conectados, desconexiones. | `--autotest-online`: servidor + 2 clientes **en el mismo proceso** (Godot permite una `MultiplayerAPI` por rama del árbol) por `127.0.0.1`. |
| **O-1** | El edificio (Qwen) en Ciudad Verde como agregado, la puerta y el interior con enfermera, tienda y recepcionista. | Autotest: entrar y salir por la puerta, curar, comprar, la recepcionista abre la sala. Vitrina con capturas. |
| **O-2** | Sala: pantalla de conectados, desafiar, aceptar o rechazar, elegir equipo, VS. | Autotest con 2 clientes de prueba que se desafían. |
| **O-3** | Pelea online: el servidor simula, `NetCombatInput`, fotos del estado + `Events`, interpolación, fin de la pelea y desconexión. | Autotest: 2 clientes con bots (`BotCombatInput` del lado del cliente) pelean hasta que gana uno; los dos ven lo mismo. |
| **O-4** | Resultado: EXP para cada uno, vuelta al edificio, guardado. | Autotest: la EXP sube como en un combate en el mundo. |
| **O-5** | Poner el servidor: `build_portable.py --server` (un ejecutable de servidor), guía para correrlo en una PC (con el puerto abierto en el router) o en un servidor en la nube gratis (Oracle Cloud Always Free). Dirección del servidor en Opciones (con una por defecto). | Probarlo de verdad con un amigo. |
| O-6 (después) | Predicción del movimiento propio, ping en pantalla, chat rápido o emotes, sala compartida (verse caminando), nivel 50 opcional. | — |

## Preguntas abiertas (para cuando lleguemos)
- **Vida después de la pelea**: ¿el daño queda como en el mundo (te curás con la enfermera de al lado) o se vuelve como
  estaba? Recomendación: queda, como en el mundo, para que sea igual que un combate normal.
- **Dinero**: ¿el que gana se lleva un premio como contra un entrenador? Por ahora no.
- **Dónde corre el servidor**: ¿en tu PC (hay que abrir un puerto en el router) o en un servidor en la nube gratis?
  Para probar, primero en tu PC.
- **El lugar exacto** del edificio en Ciudad Verde.
