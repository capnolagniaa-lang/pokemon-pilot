# Progreso del proyecto

Bitácora viva. Se actualiza al cerrar cada etapa (y antes de que se termine el contexto de una sesión).

> **Plan paralelo:** la identidad del combate (arquetipos, mecánica de firma y kit por Pokémon) se sigue en
> [`PLAN_IDENTIDAD_COMBATE.md`](PLAN_IDENTIDAD_COMBATE.md), con su propia tabla de avance.

## 📍 Dónde estamos (actualizado 2026-10-23)
- **Día y noche, parte A (2026-10-28, pedido del usuario)**: plan y reparto en `docs/PLAN_DIA_NOCHE.md` (A y B:
  sesión de gráficos; C ventanas/faroles: sesión de mapas; D luces de ataques: sesión de kits), con las referencias que
  pintó Qwen en `docs/referencias/iluminacion/`. Hecho: `DayNight` (nodo del mundo): la hora del juego corre (un día =
  24 min reales), se guarda con la partida y avisa por `Events.time_changed(hora, fase)`. Pinta el Daylight, la
  gradación, una luz de esquina con rayos (post-procesado), las nubes y las luciérnagas de noche. Interiores y arenas
  van con luz pareja. "Hora fija" en Ajustes del juego. Por ahora solo visual (decisión del usuario). **Parte B (sombras largas)**:
  casas, árboles y cercas (`ZoneShadows`, máscara de las celdas sólidas + shader) y personajes y Pokémon (`SunShadow`,
  su propio cuadro acostado), según la hora. Test `--autotest-daynight` (23), vitrina `--showcase-daynight`.
- **Creación de gráficos con IA local (2026-10-28)**: ComfyUI con Qwen-Image, Qwen Edit, Wan 2.2 y LoRAs de pixel art.
  Flujo de efectos de ataque (cuadro clave → animación → `tools/fx_from_frames.py` → `sprites/fx/`). Guía:
  `docs/COMFYUI.md`.
- **Capítulo 3 de la historia (2026-10-25, pedido del usuario: "hasta el gimnasio de Lt. Surge")**: plan en
  `docs/PLAN_CAPITULO_3.md` (mapas de la sesión de mapas, 0e8da6c2). Hecho: 29 entrenadores con los equipos de FireRed
  (Ruta 6, S.S. Anne, gimnasio), el Rocket de la casa robada (MT28 Excavar), el Ticket en el muelle, el rival en el
  S.S. Anne, el capitán y **Corte** (E frente a un árbol fino), el **puzzle de los basureros** con la barrera eléctrica,
  **Lt. Surge** (Raichu jefe) en la arena eléctrica, Medalla Trueno, Tienda de Carmín y la Guía del capítulo 3.
  Arreglado: un entrenador que te veía y se descargaba su zona a mitad de camino dejaba la historia trabada.
  Test `--autotest-story-h3` (28), vitrina `--showcase-surge`.
- **Evoluciones (2026-10-25, pedido del usuario)**: las 172 especies que evolucionan (PokeAPI) lo hacen por nivel o con
  piedra (Lunar, Fuego, Agua, Trueno, Hoja, Solar); intercambio y amistad quedan para cuando exista ese sistema
  (Kadabra, Graveler, Golbat... por ahora no evolucionan). Pantalla clásica con parpadeo, Esc la frena (con piedra no),
  espera a que termine el combate. Conserva nivel, daño y movimientos; aprende lo de su nivel. **Kits**: la evolución
  pelea con el kit de su preevolución (28 heredan: Charmeleon, Pidgeotto, Raticate...) salvo las que cambian mucho
  (Butterfree, Beedrill, Gyarados, Kadabra: ya tienen kit propio, de la sesión de kits; Charizard y
  Vaporeon/Jolteon/Flareon todavía no y pelean con su learnset de FireRed). La ficha y la Pokédex muestran a qué evolucionan.
  Test `--autotest-evolution` (20), vitrina `--showcase-evolution`.
- **Capítulo 2 de la historia (2026-10-24, pedido del usuario: "hasta el gimnasio de Ciudad Celeste")**: plan y reparto en
  `docs/PLAN_CAPITULO_2.md` (mapas: sesión de mapas; estilos y kit de Starmie: sesión de kits; historia: esta). Hecho
  en la historia: 45 entrenadores con los equipos de FireRed (Ruta 3, Mt. Moon, Rocket, Puente Pepita, Ruta 25, gimnasio),
  Miguel y el fósil a elección, el rival en Celeste (Pidgeotto/Abra/Rattata/inicial), el Rocket del puente (Pepita),
  Bill-Clefairy (Ticket del barco), Magikarp de $500 en el Centro de la Ruta 4, Tienda de Celeste, **arena de agua de
  Misty** (piletas reales), Medalla Cascada, Caramelo Raro que sube de nivel, la Guía del capítulo 2. Test
  `--autotest-story-h2` (21 chequeos), vitrina `--showcase-misty`.
- **Más salvajes en el Bosque Verde (2026-10-24, pedido del usuario)**: tenía 5600 celdas de pasto y el tope general de
  16 salvajes vivos (1 cada 350 celdas; la Ruta 1, 1 cada 110). `max_alive_cap = 40` en su tabla de encuentros
  (solo ese campo; se ajusta también en el editor de mapas, pestaña Salvajes).
- **Mercado hecho (2026-10-24, pedido del usuario)**: los vendedores de las Tiendas de Ciudad Verde y Plateada venden
  (lista oficial de FireRed, precios oficiales) y compran a la mitad. Ciudad Verde, después de entregar el Correo de
  Oak (modo libre: siempre). `Mart` + `ShopScreen` + `data/shops/`. Test `--autotest-mart`, vitrina `--showcase-mart`.
- **Ajustes de combate (2026-10-24, pedido del usuario)**: combos apagados (`GameConfig.combos_enabled`), Paralizado
  con tirones al azar (6 s, mitad de velocidad), Escarcha de Seel congela con 5, Somnífero duerme a los 0,6 s, el
  veneno no despierta, la estela de la Embestida Ígnea pega como un solo fuego y el salto de cráter también sale
  hacia donde caminás. Detalle en `PLAN_IDENTIDAD_COMBATE.md` ("Ajustes de estados y ataques").
- **Animaciones de combate de SpriteCollab (2026-10-24)**: `download_sprites.py` baja además Shoot, Charge, Strike,
  Swing, Double, Hop, Rotate, Tumble, LeapForth, Faint, HitGround, LostBalance, Sleep... (las que tenga cada
  especie). La criatura las usa según la forma del ataque (`CreatureSprite.CHAINS`/`chain_for_move`): disparo y
  cono → Shoot, carga → Charge, golpes → Strike/Swing/Double, embestida → LeapForth, esquive → Hop/Rotate/Tumble,
  debilitado → Faint (se queda caído), dormido → Sleep; sin la animación cae a Attack. Test `--autotest-anims`.
  Tutorial para efectos y animaciones con IA: `docs/TUTORIAL_PIXELLAB_SORCERESS.md`.
- **Efectos de ataque con sprite (2026-10-24)**: enganche listo, falta el arte. Una hoja en
  `sprites/fx/moves/<ataque>.png` o `sprites/fx/types/<tipo>.png` (`_impacto` para el golpe), o un SpriteFrames en
  el campo `vfx`/`impact_vfx` del ataque o del tipo, reemplaza el dibujo por código del proyectil, el área, el corte
  y el impacto (`DB.vfx_for`, `VfxSprite`). Test `--autotest-vfx`. Pendiente: conos y látigos.
  **Primeras hojas hechas por código** (`tools/make_vfx.py`, sin IA): impacto de los 18 tipos (estrella, llamas,
  salpicadura, rayos, hojas, cristales, escombros, viento, aros, burbujas, destellos) y cuerpo de 5 proyectiles.
  Vitrina `--showcase-vfx`. Calidad "de programador": la idea es ir reemplazándolas por arte de PixelLab/Sorceress.
- **Día y noche, parte D (2026-10-28)**: de noche los ataques no se oscurecen (los efectos compensan el Daylight), sus
  luces crecen (hasta 0,5), los impactos de fuego/eléctrico iluminan un instante y los Pokémon de fuego alumbran con
  su llama. Solo visual. Ver `docs/PLAN_DIA_NOCHE.md`. Test `--autotest-night-combat`.
- **Arreglo: equipar en plena pelea (2026-10-26)**: al subir de nivel en combate o al equipar desde la ficha del menú
  de combate, el Pokémon que está afuera no recibía los ataques nuevos hasta terminar la pelea. Ahora se actualizan
  ahí mismo (`MoveUser.refresh`; el recién equipado arranca con su recarga). Test `--autotest-equip`.
- **Sonido (2026-10-26, pedido del usuario)**: autoload `Sound`. Música por lugar y por momento (salvaje, entrenador,
  líder, rival, torneo, victorias, evolución, Centro, captura, nivel) desde archivos con nombre en `audio/musica/`
  (la pone el usuario: su soundtrack; tabla `data/audio/musica.json` con respaldos); efectos retro hechos por código
  (`tools/make_sfx.py`: menú, bola, puertas, saltos, un golpe por tipo...) y los gritos de los 386 de PokeAPI
  (`tools/fetch_cries.py`). Volumen en Opciones (de la PC). **Cómo cambiar las canciones: `docs/AUDIO.md`.** Test
  `--autotest-audio`.
- **Objetos en peleas y equipo arrastrable (2026-10-26, pedido del usuario)**: la C (objeto rápido) anda también en
  peleas de entrenador, gimnasio y torneo; **Esc en combate** abre un menú reducido (Mochila, Equipo, Cerrar) con la
  pelea en pausa (en la Mochila, lo que no se usa en combate sale deshabilitado; en Equipo, "Poner como activo" es un
  cambio de pelea). Usar un objeto en combate te deja expuesto `use_time` s (CombatDirector escucha
  `Events.item_used`). En **Equipo**, arrastrar una tarjeta sobre otra con el clic las intercambia
  (`GameState.swap_in_party`). Chequeos en `--autotest-arena`.
- **Ajustes del juego por partida (2026-10-26, pedido del usuario)**: Esc → Opciones → "Ajustes del juego…". Por
  partida (decisión del usuario): Progresión (EXP, dinero de premios, captura), Combate (daño que hacés y que recibís,
  vida ×N, combos, reglas de arena en todo el mundo), Mundo (cantidad de salvajes, curación sola, objetos en las
  rutas) y dificultad de la IA con modo **Personalizada** (ritmo, puntería, esquive, anticipación, daño, tácticas).
  Se aplican al instante y se guardan con la partida; "Valores por defecto" vuelve a los de siempre. Test
  `--autotest-settings`, vitrina `--showcase-settings`.
- **Kits v8 — Tanda C + sinergia (2026-10-26)**: Drowzee, Grimer, Koffing (nubes que detona), Ponyta (galope con
  estela de fuego), Slowpoke (reacciona tarde) y Magikarp (Azote y EXP extra): la propuesta de kits quedó completa.
  Y **sinergia**: los Pokémon con kit aprenden todo su learnset de FireRed; los ataques oficiales toman la forma de su
  versión de kit; los de mejora propia ahora hacen algo; las firmas reaccionan por tipo (un Rayo Hielo aprendido suma
  escarcha a Seel). El equipamiento inicial sigue siendo el kit. Ver `PLAN_IDENTIDAD_COMBATE.md`. Test
  `--autotest-kits-v8` (`--only sinergia`).
- **Kits v7 — Tanda B (2026-10-26)**: Clefairy (Metrónomo: un ataque al azar de cualquier kit), Jigglypuff (se infla y
  le dibuja la cara a los dormidos), Abra (se teletransporta solo al recibir un golpe: hay que dormirlo para atraparlo),
  Goldeen (el cuerno atraviesa defensas; rápido mojado), Magnemite (flota y atrae) y Meowth (Día de Pago: suma a tu
  dinero). Ver `PLAN_IDENTIDAD_COMBATE.md` "v7". Queda la Tanda C. Test `--autotest-kits-v7`.
- **Kits v6 — Tanda A (2026-10-26, pedido del usuario)**: Raichu ahora es **jefe de Lt. Surge** (Toma de Tierra:
  planta la cola, descarga y suelo electrificado; Sobrecarga a mitad de vida), y kits propios para Zubat, Ekans,
  Machop, Nidoran♀, Nidoran♂, Horsea, Shellder, Tentacool y Voltorb (sus evoluciones los heredan). Ver
  `PLAN_IDENTIDAD_COMBATE.md` "v6" y `PROPUESTA_KITS_PENDIENTES.md` (quedan las Tandas B y C). Test `--autotest-kits-v6`.
- **IA más pareja (2026-10-25, pedido del usuario: "se quedan trabados cuando tienen un obstáculo enfrente", "no
  parece tan buena en Normal")**: los Pokémon (salvajes y de entrenadores) rodean árboles, casas y rocas en vez de
  empujar contra ellos (y si se traban buscan camino por celdas); no disparan contra una pared (se acomodan para
  tener tiro); los de cuerpo a cuerpo ya no retroceden solos; si ningún ataque llega, se acercan en vez de quedarse
  un segundo quietos; los disparos anticipan tu movimiento. **Normal** ataca más seguido (×1,2 en vez de ×1,5),
  apunta mejor (±10° en vez de ±15°), esquiva más (22%) y pega 85%; Difícil esquiva 40%. Test `--autotest-ai-steer`.
- **Mapa en el menú (2026-10-25, pedido del usuario)**: Esc → Mapa (con el objeto Mapa que da Dalia; las partidas que
  ya lo tienen lo ven sin hacer nada). La región en miniatura dibujada desde los mapas reales, con nombres de ciudades
  y rutas, tu posición (adentro de una casa o cueva, en su puerta), la estrella del objetivo de la Guía, íconos de
  Centro/Tienda/Gimnasio y niebla en lo no visitado (las partidas viejas lo arman según su avance). Rueda/+−: zoom;
  arrastrar o WASD: mover; Espacio: centrar. Test `--autotest-town-map` (24), vitrina `--showcase-town-map`.
- **Capítulo 2, parte K (2026-10-24)**: kits de Staryu y **Starmie jefa de Misty** (`tools/build_kits_v5.py`, firma
  Núcleo `core_mechanic.gd`: gira y desvía proyectiles, +daño a lo Empapado, se regenera; a mitad de vida el núcleo
  brilla) + `FightStyle` de 33 Pokémon del capítulo 2. Test `--autotest-kits-v5`. Ver `PLAN_IDENTIDAD_COMBATE.md` "v5".
  2026-10-25: kits propios para las evoluciones que cambian de forma de pelear (Butterfree, Beedrill, Kadabra con la
  firma nueva Mente Rápida, Gyarados); el resto hereda el kit de su preevolución.
- **Versión portable para amigos (2026-10-24)**: `python -I -B tools/build_portable.py . <Godot_v4.7.2-stable_win64.exe>`
  arma `export/PokemonPilot-<fecha>.zip` (~115 MB: el Godot renombrado + `PokemonPilot.pck` + `LEEME.txt`). No usa
  plantillas de exportación. Preset "Windows Desktop" en `export_presets.cfg` con la feature `portable`, que apaga
  el editor de mapas y la trampa F9. `project.godot` tiene `export/convert_text_resources_to_binary=false`: al pasar
  los .tres a binario se perdían los PackedStringArray (diálogos y banderas de la historia). Se rearma cada vez que
  haya cambios para pasar.
- **Herramienta — Editor de mapas hecha** (no corre la numeración de etapas): acceso directo "Pokémon Pilot —
  Editor de mapas" (`-- --map-editor`). Ya tiene **todos los gráficos de FireRed**, la paleta organizada como la
  hoja de tiles del mundo de FireRed y 78 sellos sacados de los mapas reales. Ver "Herramienta — Editor de mapas".
- **Etapa 3 hecha (entorno reactivo)** — ver "Etapa 3" más abajo. **Etapa 2c hecha** (título, guardado,
  equipo y movimientos).
- **386 Pokémon (Kanto, Johto y Hoenn) cargados con stats, learnsets y sprites + Pokédex** en el menú
  (2026-10-22, ver "Etapa 2d"). Los spawns NO se tocaron (siguen los 4 de prueba).
- **Etapa 4a hecha (IA de los salvajes)**: cuerpo compartido + temperamentos (agresivo, territorial, tímido,
  curioso) — ver "Etapa 4a". Definido con el usuario: **la IA de salvajes y la de entrenadores son distintas**
  (salvajes = instinto sin memoria; entrenadores = órdenes + memoria) — ver `PLAN_ENTRENADORES.md`, sección 1b.
- **Entrenadores vivos — E-0 hecha** (2026-10-23; decisiones del plan confirmadas): interruptor "Entrenadores
  vivos (en prueba)" (inicio y Opciones, apagado por defecto), datos de los 3 entrenadores (Azul, Valeria, Tomás)
  y sus NPC en Ruta 1. Detalle en `docs/PLAN_ENTRENADORES.md` ("Avance").
- **Captura, Mochila y Caja hechas** (2026-10-23, pedido del usuario antes de E-1; `docs/PLAN_CAPTURA_MOCHILA.md`):
  E lanza la Pokébola (fórmula oficial de 3ª gen), IVs al azar en los salvajes, Caja con el equipo lleno, Mochila
  con bolsillos y objetos oficiales, C usa el objeto rápido en combate, objetos en el mapa y botín de salvajes.
- **Documentación de salvajes, movimientos y kits** (2026-10-23): `docs/SALVAJES_Y_MOVIMIENTOS.md` (cómo
  funcionan el spawner, los movimientos, los temperamentos y los kits, y cómo modificarlos) y
  `docs/SALVAJES_LISTADO.md` (generado por `tools/build_wild_docs.gd`: qué aparece en cada zona y con qué
  movimientos). Arreglado: el territorial (Bellsprout) cortaba el combate a cada rato. **Propuesta a confirmar:
  llegar a ~16 kits** para el modo historia (lista en `SALVAJES_Y_MOVIMIENTOS.md`, sección 4).
- **Rework de Empapado** (2026-10-23): los ataques de agua empapan al pegar (no por el camino), Empapado dura 4 s
  y solo resta 10% de velocidad, los charcos no empapan ni asustan a la IA, y el fuego contra un empapado pega
  30% menos y lo seca. Detalle en el plan de identidad ("Rework de Empapado").
- **v3: 10 kits nuevos implementados, en prueba** (Squirtle, Pikachu, Oddish, Paras, Psyduck, Poliwag, Growlithe,
  Eevee, Seel, Geodude): ya son **16 Pokémon con kit**. Detalle en el plan de identidad ("v3"); el usuario los va
  a ir ajustando mientras los prueba. Autotest `--autotest-kits-v3`. Primer ajuste: Rayo de Pikachu cae del cielo
  en área; Burbuja de Poliwag encierra sin mojar.
- **Spawns**: se respetan los de FireRed (cada zona nueva tiene la tabla real de su lugar, coinciden con la guía de
  Rojo Fuego/Verde Hoja). **Más salvajes en mapas grandes** (2026-10-23): `EncounterTable.cells_per_wild` (uno
  más cada 150 celdas donde pueden aparecer, tope `max_alive_cap` 16) y reponen más rápido; ej. Ruta 1 ≈ 10,
  Bosque Verde 16. **Objetos tirados solo en las rutas** (3-4 al azar por ruta y Bosque Verde; nada en ciudades ni
  interiores); el botín de salvajes sigue igual.
- **v4: kits de Kanto hasta Ciudad Plateada** (2026-10-23): Caterpie, Weedle, Metapod, Kakuna, Spearow, Mankey,
  Sandshrew y **Onix como jefe** (el de Brock). 24 Pokémon con kit. La **Pokédex** muestra el estilo de pelea, la
  mecánica de firma y los 4 ataques del kit de lo que ya viste. Detalle en el plan de identidad ("v4").
- **Qué hay hoy de la historia y qué falta (guía para jugar)**: `docs/HISTORIA.md`. Importante: **todavía no hay
  eventos de trama** (Oak, laboratorio, rival, paquete = H-1/H-2).
- **Plan de historia hasta la Medalla Roca** (2026-10-23): `docs/PLAN_HISTORIA.md` (la de FireRed, fases H-0 a
  H-6; necesita E-1, el combate contra entrenadores). Decisiones tomadas: inicial en el laboratorio, E contextual
  para hablar, entrenadores de historia fijos, perder = último Centro.
- **H-0 hecha** (2026-10-23): banderas de historia (se guardan), caja de diálogo, **67 personas reales de FireRed
  que hablan** (sprites de pret, diálogos propios), E contextual (habla o lanza la bola), disparadores y bloqueos
  por bandera, enfermeras y mamá curan. **Teclas 1-6 cambian de Pokémon** (también en combate). Detalle en
  `docs/PLAN_HISTORIA.md` ("Avance").
- **E-1 hecha: combates contra entrenadores en ARENA** (2026-10-23, pedido del usuario): fundido a una arena aparte
  (claro de pinos para los de ruta; **gimnasio de roca épico** para Brock), 1 contra 1 con cambios, el rival te ve
  y te desafía, perder te devuelve al último lugar donde te curaron. Ya pelean los 5 Cazabichos del Bosque Verde,
  el Campista Liam y **Brock** (Medalla Roca). Detalle en `docs/PLAN_ENTRENADORES.md` ("E-1").
- **EXP a la mitad** (2026-10-23, pedido del usuario: "se sube de nivel muy rápido"): `GameConfig.exp_multiplier`
  = 0,5 sobre la fórmula oficial (se cambia en el inspector de `data/config/game_config.tres`).
- **H-1 hecha** (2026-10-23): la historia empieza en tu cuarto sin Pokémon ("Empezar la historia"), Oak te frena
  y te lleva al laboratorio, inicial en la mesa (Sí/No), el rival elige el ventajoso y te desafía. Guía:
  `docs/HISTORIA.md`.
- **H-2 hecha** (2026-10-23): el Correo de Oak (Tienda de Ciudad Verde → Oak), la Pokédex de regalo (en la historia
  recién ahí aparece), 5 Poké Balls, Dalia y el Mapa, y el viejo que tapa la salida al norte hasta entregar el
  correo (después te enseña a atrapar).
- **H-3 hecha** (2026-10-23): el rival te frena en la Ruta 22 (Pidgey 9 + su inicial 9).
- **Capítulo 1 completo (H-4/H-5)** (2026-10-23): objetos fijos del camino, el chico de Plateada que te lleva al
  gimnasio, Brock da la Medalla Roca y la **MT39** (las MT enseñan movimientos de verdad), **Tarjeta de entrenador**
  con las medallas (Esc → Tarjeta). De Pueblo Paleta a la Medalla Roca se juega entero.
- **Plan del Torneo de Plateada** (2026-10-23, idea del usuario): `docs/PLAN_TORNEO.md` (dinero, edificio, copas de 3/6
  Pokémon con tope de nivel para inscribirse, 6 Pociones del torneo, arena épica con agua y rocas, y los entrenadores
  con memoria como Brock que aprenden de vos).
- **Torneo T-0 a T-3 hecho** (2026-10-23): **dinero** (empezás con $3000, premios por entrenadores), **Edificio del
  Torneo** en Plateada (la puerta del anexo del museo), copas de 3/6 Pokémon (Nv. 15, 30, Libre) con 6 Pociones y sin
  curar entre rondas, Brock y Azul en el cuadro, y el **estadio épico** con lagunas, pasto, rocas, público y confeti.
  Falta T-4 (que aprendan de vos: E-2 a E-4).
- **Varias partidas con nombre** (2026-10-23, pedido del usuario): Nueva partida pide el nombre; cada partida es
  `user://saves/<nombre>.json` (con su "save_name"); Continuar muestra la lista (cargar / borrar). En la historia se
  puede guardar antes de tener Pokémon. `SaveManager.list_saves` / `use_name` / `load_from` / `path_for_name`.
- **Los Pokémon ya no se curan solos** (pedido del usuario): solo Centro Pokémon, mamá u objetos. Si cae tu Pokémon
  fuera de una arena sale el siguiente sano; sin ninguno, **desmayo total** (`StoryDirector.blackout`: volvés al
  último lugar donde te curaron, curados). El modo práctica sigue reviviendo al instante (opción aparte).
- **Modo de prueba del torneo** (pedido del usuario): título → "Probar el torneo": elegís hasta 6 Pokémon con kit, el
  nivel y la copa, y se juega el Torneo de Plateada directo; no se guarda nada (`GameState.test_tournament`); al
  terminar, repetir o volver al título.
- **Combate de arena** (2026-10-24, inspirado en Pokémon Arena 2D): estilos de movimiento (ágil/pesado/volador),
  combos (cadena de golpes + un combo con nombre por Pokémon), cráteres que deja el terreno golpeado y superficies que
  frenan. Por ahora solo en las arenas (torneo, gimnasio, entrenadores); después se ajusta para el mundo abierto
  (`GameConfig.arena_rules_everywhere`). Detalle en el plan de identidad ("Combate de arena"). Además: los que
  tienen patas **saltan los cráteres** con el esquive hacia donde apuntás; sprite del cráter (agente de mapas);
  **tope de cráteres** por ataque y por cancha. **Propuesta de combos v2** en `docs/PROPUESTA_COMBOS.md` (a decidir).
- **Guía de la historia** (2026-10-24, pedido del usuario): Esc → Guía dice en qué paso estás y qué hacer
  (`StoryGuide`: pasos por bandera + lo opcional). Arreglo: el botón de la **Pokédex** no aparecía hasta volver a
  cargar la partida (el menú se armaba una vez); ahora se revisa al abrir. En la historia el menú se abre aunque
  todavía no tengas Pokémon (para guardar y ver la Guía).
- Pedido del usuario pasado al agente de mapas: **límites de las zonas** (se podía salir a partes sin dibujar o
  saltearse zonas). Lo hace el agente de mapas.
- Pedido del usuario pasado al agente de mapas: los saltos/salientes de las colinas se tienen que poder **bajar
  pero no subir** (como en FireRed). Lo hace el agente de mapas. **Próximo:** H-6 (bot que
  juega el capítulo + revisión) o seguir con E-2 / la Ruta 3 y el Monte Moon, a decidir con el usuario.
- **Mundo = mapas reales de FireRed de Pueblo Paleta a Ciudad Plateada** (2026-10-23, ver "Región de FireRed"):
  7 exteriores agrandados ×1,75 + 21 interiores con **puertas**; las 9 zonas generadas y la Ruta 1 vieja se
  borraron (pedido del usuario). Pinceles nuevos: piso de ciudad, empedrado y piso de cueva.
- **Siguiente: E-1** (combate contra entrenador: desafío, equipos de hasta 3, cambio de Pokémon con Tab, fin y
  EXP). Después, spawns por hora (Etapa 4b/5). El usuario aprobó los kits por ahora ("me gustan los de Charmander y
  Bulbasaur"); más adelante se harán **tests de balance** de los kits.
- v2 hecho: **sin energía** (solo recargas), **4 ataques + esquive en Espacio**, Charmander **bruiser** rearmado,
  Bellsprout/Bulbasaur **control**, y por ahora **todo el mapa** solo hace aparecer **Pidgey, Bellsprout,
  Rattata y Vulpix** (`WildSpawner.use_test_pool`; apagarlo devuelve los spawns por bioma).
- Pantalla de inicio con **Modo práctica** (por defecto on) y **Dificultad de la IA** (Fácil / Normal por
  defecto / Difícil = la IA original). Detalle en el plan de identidad.
- **Kits de Pidgey (hostigador, Vuelo), Rattata (asesino, Instinto) y Vulpix (desgaste, Rescoldo)** hechos
  (2026-10-22): los 4 de la zona de prueba tienen estilo propio. Detalle en el plan de identidad.
- Identidad pendiente: **Squirtle** (tanque/parry) y **Pikachu** (cargas). Propuestas en `PLAN_IDENTIDAD_COMBATE.md`.
- Lo de la sección "Combate (Etapa 2)" más abajo que hable de energía o de ataques 1-4 genéricos quedó
  superado por la v2 (ver el plan de identidad).

## Etapas

| # | Etapa | Estado |
|---|---|---|
| 1 | Refactor data-driven + mundo abierto con zonas | ✅ Hecha |
| 1b | Arte FireRed + efectos modernos | ✅ Hecha |
| 1c | Región grande (3×3 zonas, 9 biomas) | ✅ Hecha |
| 2 | Combate en tiempo real en el mapa + estados alterados | ✅ Hecha |
| 2b | Stats oficiales (PokeAPI), curvas de EXP, velocidad por stat, balance de energía, visual de fuego/estados | ✅ Hecha |
| 2c | Título, guardado, equipo (máx. 6) y movimientos por nivel (learnset + ficha) | ✅ Hecha |
| 2d | 386 Pokémon (3 regiones) con stats, learnsets y sprites + Pokédex (vistos/luchados) | ✅ Hecha |
| 3 | Entorno reactivo (fuego, agua, eléctrico) + puzzles | ✅ Hecha |
| 4a | IA de los salvajes: cuerpo compartido + temperamentos (sin memoria) | ✅ Hecha |
| 4 | IA salvaje con estados + spawns por bioma/hora | ⏭️ Siguiente |
| 5 | Ciclo día/noche, clima, NPCs con horarios | 🟡 Día/noche: partes A, B y D hechas (2026-10-28); faltan ventanas y faroles (C), clima y horarios |
| 6 | Captura, equipo y progresión (incluye **IVs al azar al capturar**, naturalezas, EVs) | 🟡 Captura, Mochila, Caja e IVs al azar hechos (2026-10-23); faltan naturalezas, EVs, evoluciones, Centros |
| 7 | Primer gimnasio (arena con transición) | Pendiente |
| 8 | Pulido (juice, audio, partículas) | Pendiente |

## Región de FireRed: de Pueblo Paleta a Ciudad Plateada (2026-10-23)
Pedido del usuario: renombrar Ruta 1 a Pueblo Paleta, pinceles de piso de ciudad y de cueva, borrar las zonas que
había y reproducir hasta Ciudad Plateada (guía de Rojo Fuego). Durante el trabajo pidió: **adaptarlo a nuestra
escala** ("un poco más grande") y **usar el Pueblo Paleta original agrandado** en vez del que había dibujado.
Decidido con su "hacé tu mejor intento": mapas reales, puertas + interiores (el Bosque Verde se entra por sus garitas
como en FireRed) y salvajes de FireRed.
- `tools/import_frlg_maps.py`: los mapas de pret (más `data/maps/*/map.json` y `border.bin` bajados de
  pret/pokefirered) → `data/world/frlg_maps.json`. Agranda con **costuras** (ver CLAUDE.md, "Región de FireRed"):
  crecen pasto, caminos, agua, acantilados y arboledas; casas, carteles y puertas quedan como en FireRed.
  Los mapas se ubican por sus conexiones alineando los caminos; la columna Paleta–Ruta 1–Verde–Ruta 2–Plateada
  tiene un mismo ancho (los costados se rellenan con el borde de árboles), la Ruta 22 sale al oeste de Ciudad Verde.
- `tools/import_frlg_maps.gd`: zonas `hand_edited` (se siguen editando con el editor), región nueva, TileSet con la
  colisión por celda de los mapas y tablas de salvajes reales (Ruta 1: Pidgey/Rattata; Ruta 2, Ruta 22, Bosque
  Verde) **sin las filas de agua** (en FireRed son de Surf, de nivel 5-40, y nadarían al lado del inicio), y los
  árboles cortables de FireRed como objetos del entorno (Ciudad Verde, Ruta 2, Ciudad Plateada). El agua va en la
  capa Water y el pasto alto en Foliage, como con los pinceles. Borró las 9 zonas generadas y `zona_nueva` (backup en
  `scenes/world/zones/.backup/`).
- **Puertas** (`WarpSystem`, `ZoneEntry.warps`): casas, Laboratorio de Oak, Centros, Tiendas, gimnasios, Escuela,
  Museo (2 pisos), garitas de la Ruta 2 y de la Ruta 22 (la de la Ruta 22 todavía no lleva a la Calle Victoria).
  En el editor se ven con recuadro celeste y la barra dice a dónde llevan; validación de puertas.
- Pinceles nuevos (`tile_roles.tres`): **Piso de ciudad** (autotile, Ciudad Verde), **Empedrado** (autotile,
  Ciudad Plateada) y **Piso de cueva** (tile suelto).
- Entrenadores vivos: sus rutinas pasaron a Ruta 1, Ruta 22, Ruta 2 y Bosque Verde (celda transitable más cercana).
- `--autotest` reescrito: camina de Pueblo Paleta a Ciudad Plateada entrando al Laboratorio de Oak, pasando por la
  Ruta 22 y cruzando el Bosque Verde por sus garitas (`TourPlanner`).
- **Mapas del capítulo 3** (2026-10-25, pedido del usuario: "hasta el gimnasio de Ciudad Carmín respetando la
  guía"): Ruta 5 (guardería, garita), Vía Subterránea (entradas en las Rutas 5 y 6), Ruta 6 (garita), Ciudad Carmín +
  Centro, Tienda, Club de Fans, casas y Gimnasio, y el S.S. Anne entero (muelle, plantas 1 a 3, sótano, cubierta,
  cocina, 18 camarotes y el del capitán). Azafrán no se arma: se ubica para que la Ruta 6 y Carmín queden donde van
  y queda un hueco con paredes (en la guía está cerrada; se pasa por la Vía Subterránea). El Gimnasio de Carmín queda
  detrás del árbol cortable: hace falta Corte (lo hace la sesión de historia). `--autotest` llega al camarote del
  capitán; `--autotest-bounds` verifica que sin Corte no se llega al gimnasio y con Corte sí.
- **Mapas del capítulo 2** (2026-10-24, parte M de `docs/PLAN_CAPITULO_2.md`): Ruta 3, Ruta 4 + su Centro,
  Mt. Moon (3 pisos, agrandados como el Bosque Verde), Ciudad Celeste + Centro, Tienda, Gimnasio, tienda de bicis,
  casas y casa robada, Ruta 24 (Puente Pepita), Ruta 25 y la Casa de Bill, con sus puertas, personas (para la
  historia) y salvajes de FireRed (en las cuevas, en cualquier suelo). Importados con `import_frlg_maps.gd --
  --only-new`: las 28 zonas anteriores quedaron idénticas. En los mapas nuevos no se copian escaleras ni puertas al
  agrandar, y cuando un borde tiene varios caminos se alinea el del medio. Dos salientes seguidos se saltan juntos;
  una puerta sólida se usa empujándola 0,12 s (no se entra sin querer al pasar rozando). `--autotest` ahora camina
  hasta el Gimnasio de Celeste (Mt. Moon incluido) y `--autotest-bounds` verifica que no haya atajos (Bosque Verde ni
  Mt. Moon) y que se llegue a todo.
- **Límites de las zonas** (pedido del usuario: "en algunos mapas, rutas e interiores no hay límites"): los interiores
  de FireRed tienen piso hasta el borde y algunos caminos llevaban a mapas que no están (Ruta 3, Calle Victoria);
  `ZoneBounds` pone paredes invisibles en todo borde que da al vacío. Se sacó el árbol cortable de Plateada que tapaba
  la entrada del Torneo (`SKIP_OBJECTS` en el importador). `--autotest-bounds`: recorre todo lo alcanzable desde el
  inicio (con puertas), verifica las paredes caminando contra el vacío en 21 zonas, que se llegue a Centros, Tiendas,
  gimnasios, Museo y Torneo, y que sin el Bosque Verde no se llegue a Plateada. (La casa de la Ruta 2 sigue detrás de
  árboles cortables, como en FireRed.)
- **Salientes de un solo sentido** (pedido del usuario: "las colinas que tienen colisión puedo bajarlas pero no
  subirlas"): `LedgeJumper` salta el saliente caminando contra él en su dirección (behavior MB_JUMP_* de FireRed;
  hasta Plateada todos son hacia abajo) y el Pokémon salta detrás; desde abajo siguen siendo pared.
  `--autotest-ledges`.
- Pendiente: NPC, carteles y objetos (Pokébolas) de los mapas de FireRed (no se importan), editar puertas desde el editor,
  Calle Victoria / Ruta 3 en adelante.

## Herramienta — Editor de mapas (2026-10-22)
Pedido del usuario en `docs/PROMPT_EDITOR_DE_MAPAS.md`. Es una herramienta, no una etapa. Decisiones (todas las
recomendadas): **modo aparte del mismo proyecto** (`-- --map-editor` + acceso directo propio), **autotile
portado** a un script compartido (se probaron los terrains de Godot: ~7% de celdas distintas, cortan los caminos
en las salidas y no hay esquinas interiores en el 3×3 de FireRed), **marca `hand_edited`** en la zona
(`--force` la saltea, `--force-all` no), **roles y tags como datos** en `data/world/tile_roles.tres`, y los tilesets
`viridian_forest`/`pallet_town` **todavía no** (el editor quedó preparado: la paleta sale del TileSet).
- **Núcleo compartido**: `ZoneBuilder` (TileSet desde los roles, estructura de la zona, autotile, guardar),
  `ZoneGenerator` (el generador de `build_world.gd`, ahora reutilizable) y `MapRules` (colisión real por celda,
  celda libre más cercana, validaciones). Verificado: regenerar las 9 zonas y el TileSet con el núcleo nuevo da
  exactamente lo mismo que antes (celda por celda).
- **Editor** (`scenes/tools/map_editor.tscn`, `scripts/tools/map_editor/`): lienzo con las capas reales y las
  vecinas atenuadas; superposiciones (grilla, colisión, tags, sin tags, plaza/salidas, inicio); pinceles con las
  reglas (autotile, agua y follaje con pasto abajo, árboles con copa/apilado/sombra, borde de árboles, objetos de
  `scenes/world/objects/`); modo tile crudo con paleta filtrable; pincel 1-3, línea, rectángulo, balde,
  selección + copiar/pegar, gotero; deshacer/rehacer de todo; panel de tags y colisión por metatile (con backup del
  TileSet y sugerencias por behavior); zona: nombre, bioma, plaza y salidas arrastrables, inicio del juego,
  validaciones y "Nueva zona" en un lugar libre (en pasto o generada). Guardar con backup (últimos 5) y aviso de
  cambios sin guardar.
- **Probar en el juego (F5)**: proceso aparte (`OS.create_process` con `-- --debug --start-zone <id> --start-cell x,y`).
  Se eligió proceso aparte porque el juego arranca limpio (autoloads, guardado, streaming) sin arrastrar estado del
  editor, si el juego se cuelga el editor sigue abierto, y se pueden tener los dos a la vez. Usa el equipo de la
  partida guardada y guarda en `user://saves/map_editor_test.json` (no pisa la partida real).
- `World._ready()` **no** reubicaba al entrenador: ahora, si la posición guardada quedó en algo sólido o en el agua,
  aparece en la celda libre más cercana (`MapRules.nearest_walkable`).
- `EnvObject.display_name` (nombre en el editor): Roca frágil, Roca pesada, Árbol cortable.
- Autotest `--autotest-map-editor` (≈45 chequeos: ida y vuelta idéntica, arena/agua/árbol/roca con tags y
  colisión, deshacer/rehacer, balde, copiar/pegar, validaciones, zona nueva, panel de tile, la UI real manejada
  como con el mouse, reubicación del entrenador); vitrina `--showcase-map-editor`.
- **Todos los gráficos de FireRed en el editor (2026-10-22)**: se bajó del decomp pret/pokefirered (clon parcial
  de git) todo lo de tilesets + los 365 mapas. Decisiones (las recomendadas): **los 68 tilesets, interiores
  aparte** (se importan 62; los 6 sin mapas no), **tipos automáticos + editables**, **sellos de edificios** sacados
  de los mapas y **colisión desde los mapas reales**. Quedó: ~10.000 metatiles con tipo (terreno, pasto, arena,
  agua, hielo, árboles, rocas, edificios, puertas, escaleras, salientes, carteles, cercas, suelos especiales,
  suelo/paredes/muebles de interior, sin usar), 70 sellos de edificios, paleta con filtros por grupo/tileset/
  tipo/tag, pestaña Sellos y tipo editable en la pestaña Propiedades (antes "Tile"; la paleta se llama "Paleta"). Las 9 zonas quedaron con los mismos tags y colisión
  (verificado celda por celda). Pendiente: animaciones propias de los tilesets secundarios (fuentes, etc.) y
  esquinas interiores para caminos y lagos (ya anotado en pulido).

## Etapa 2d — 386 Pokémon y Pokédex (2026-10-22)
Pedido del usuario: "todos los Pokémon de las 3 primeras regiones con sus movimientos y estadísticas" (sin
tocar spawners) y la Pokédex en el menú.
- **Datos**: 386 especies (372 nuevas) con stats, tipos, experiencia, curva, captura, nombre, categoría,
  descripción (español), altura y peso; **learnset oficial completo de FRLG** para las nuevas (las 14 de antes
  conservan su kit/extras); **337 ataques** (304 nuevos, forma automática). **18 tipos** con la tabla oficial
  completa (incluye inmunidades: Normal→Fantasma, Eléctrico→Tierra, etc.). Sprites PMD de los 386 (29 MB).
- **Pokédex** (menú de pausa → Pokédex, `PokedexScreen`): pestañas Kanto/Johto/Hoenn (Tab), grilla con
  miniaturas. Lo **no visto** sale como **"?????"** con la **silueta oscura** sobre el fondo de rayos de
  "¿Quién es ese Pokémon?". Lo **visto** muestra nombre, categoría, tipos, altura, peso y descripción; lo
  **luchado** (●) suma las estadísticas base.
- **Registro** (`PokedexTracker` en el mundo → `GameState.pokedex_seen/fought`, se guarda en la partida): visto =
  un salvaje aparece en pantalla (mensaje "Pokédex: X registrado." la primera vez); luchado = entró en combate
  con tu Pokémon. El equipo cuenta como luchado. Partidas viejas: se arma con el equipo.
- Autotest `--autotest-pokedex` (14 chequeos: las 386 salen al mundo a Nv. 50 y usan sus 4 movimientos sin
  errores; registro, guardado y pantalla); vitrina `--showcase-pokedex`.

### Salvajes por zona en el editor (2026-10-22)
Decisiones (las recomendadas): **niveles fijos por fila** (como FireRed), **modo de prueba como interruptor
apagado** (Opciones → "Salvajes de prueba"), **por zona y por terreno** + (pedido del usuario a mitad de camino)
**áreas pintadas** que ajustan el % de algunos Pokémon, y **plantillas reales de FireRed**.
- `EncounterTable`/`EncounterEntry`/`EncounterArea`; tablas en `data/world/encounters/` (una por bioma con las
  especies del spawner viejo, y Ruta 1 con los 4 de prueba al 35/35/15/15, Nv. 2-5). `WildSpawner` reescrito:
  celda primero, fila de esa celda después (así cada área usa sus %), salvajes de agua que nadan.
- Editor: pestaña **Salvajes** (tabla, buscador de los 386, Copiar de FireRed con 132 lugares, densidad y
  reaparición, áreas pintadas con pincel/rectángulo/balde, % real del área y de la celda bajo el mouse),
  validaciones nuevas y deshacer de todo.
- `--autotest-encounters` (20 chequeos). Se arregló un bug del spawner (elegía celdas de lugares que la tabla no
  usaba) y se estabilizó `--autotest-input` (el spawner reponía un salvaje en medio de la prueba de teclas).
- Pendiente (Etapa 4/5): que la IA salvaje use su kit con criterio y los encuentros por hora (`time`).

### Sellos y paleta rehechos con las hojas de referencia (2026-10-22)
Pedido en `docs/PROMPT_REORGANIZAR_TILES_Y_SELLOS.md`. Decisiones (las recomendadas): lo que no está en ningún
mapa de FireRed queda **afuera y listado**; ante diferencias chicas manda **el mapa real**; variantes de color =
**un sello con selector**; los 70 sellos viejos **reemplazados**.
- Hojas de The Spriters Resource (las bajó el usuario: el sitio rechaza descargas automáticas) en
  `art_src/referencia/` (en `.gitignore`). Son una grilla de 16 px con 1 px transparente y fondo transparente.
- `tools/match_reference.py`: coincide el 85% de las celdas de edificios y el 85% de las del mundo (colores en 5
  bits; la hoja tiene retoques chicos). **78 sellos**: 57 edificios (29 casas, Centro y Tienda, 3 gimnasios, 19
  especiales, 4 garitas; 1 con variante) + 21 piezas del mundo. Cada uno coincide celda por celda (metatile y
  colisión) con su mapa real (`--check`). Sin ubicar en mapas (afuera): 7 piezas de edificios (un gimnasio de techo
  rojo, un edificio gris grande de 11×18, un edificio con banderas de 13×4, uno de 9×7 y 3 tramos de fachada) y el
  bloque de árboles redondos + estanque de la hoja del mundo, más celdas sueltas.
- Paleta: tipos y orden de la hoja del mundo (32 secciones, 13 tipos) + "Otros · …"; vista **"Como en la hoja"**.
- Tags y colisión de los tiles **sin cambios**; las 10 zonas (incluidas las que está editando el usuario) iguales
  celda por celda (17.911 celdas).
- Autotest nuevo `--autotest-stamps` (11 chequeos) y `match_reference.py --check`; vitrinas `--showcase-stamps` y
  `--showcase-stamp-sheets`.

## Etapa 4a — IA de los salvajes (2026-10-23)
Decisión del usuario: la IA de los salvajes y la de los entrenadores son **distintas** sobre una capa común.
- **Cuerpo compartido** (`CombatBody`, `scripts/creatures/ai/`): si un ataque llega, adónde apuntarlo (dirección
  y punto), esquivar proyectiles, salir de celdas peligrosas (electrificadas, mojadas). **La dificultad actúa
  solo acá** (puntería, frecuencia de ataque y de esquive). Lo usarán también los entrenadores.
- **Temperamentos** (`Temperament`, `data/ai/temperaments/*.tres`; `SpeciesData.temperament`, asignado a las 386
  por `tools/assign_temperaments.gd` con heurística por stats + ajustes a mano):
  **agresivo** (te ataca apenas te ve, persigue lejos) · **territorial** (te mira con "...", ataca solo si entrás a
  su zona y te suelta si salís) · **tímido** (huye sin pelear; si lo acorralás o le pegás, pelea; huye antes con
  poca vida) · **curioso** (se acerca a mirarte a ~55 px; si te le venís encima ataca o huye). Reparto: ~177
  territoriales, ~83 agresivos, ~78 tímidos, ~48 curiosos. "En grupo": reservado (`calls_group`) para más adelante.
- **Patrón reconocible** (sin azar): abre siempre con su ataque de acercamiento si está lejos (Rattata entra con
  Ataque Rápido) y después rota sus ataques en orden. Golpes fuertes pueden espantarlo (retrocede un momento).
- **Avisos** sobre la cabeza (`Creature.emote`): "!" te vio/pelea, "?" curiosidad, gota = miedo, "..." te ignora.
- Estados: `wander` (reacciona según temperamento), `watch` (nuevo, curioso), `chase` (correa por temperamento,
  apertura), `attack` (rotación + cuerpo), `flee` (tranquila o en combate; acorralado → pelea).
- El autotest de combate fuerza "agresivo" en el salvaje (Oddish ahora es tímido y huiría).
- Autotest `--autotest-wild-ai` (12 chequeos); vitrina `--showcase-wild-ai`.

## Etapa 3 — Entorno reactivo (2026-10-22)
- **El fuego NO interactúa con el entorno** (decisión del usuario, 2026-10-22: no le gustó que queme el pasto).
  Lo único que va a prender en el futuro son las **esporas que deje en el piso un ataque Espora** de los tipo
  planta (todavía no existe; ni Polvo Veneno ni Somnífero), que **arderán unos 3 s** quemando a quien esté adentro.
  Se sacaron los estados ardiendo/quemado, las reglas de fuego (prender, vapor, derretir, apagar) y la quema del
  árbol cortable. El código de llamas de `EnvironmentGrid` (`Look.FIRE`) quedó disponible para eso.
- **Estado por celda** (`EnvironmentGrid`, uno por zona, lo crea `ReactionSystem` al primer uso y se va con la
  zona): `data/environment/states/*.tres` (`EnvCellState`): **mojado** (15 s, Empapa), **congelado** (10 s; sobre
  el agua saca el tile de agua = **puente de hielo**, no se derrite con alguien encima), **electrificado** (1,2 s,
  Paraliza; al terminar vuelve al estado anterior). Visual: charcos, hielo y chispas.
- **Reglas** (`data/environment/reactions/*.tres`, `ReactionRule`, por prioridad): hielo congela agua y suelo
  mojado · eléctrico corre por el agua y lo mojado (propagación instantánea, hasta 80 celdas) · agua moja el suelo.
- `ReactionSystem` (en el mundo) escucha `Events.element_impact`. Los **proyectiles también tocan las celdas por
  las que pasan** (cada 14 px): el agua moja su camino.
- **Roca frágil**: se rompe con una embestida (`Events.env_object_struck` desde los estados dash/lunge;
  `EnvObject.break_power` = 30 de potencia): Embestida Ígnea, Ataque Rápido, Arañazo... abren el rincón de Ruta 1.
- `World.tags_at()` devuelve los tags con el estado aplicado.
- Autotest `--autotest-env` (17 chequeos con el mapa real, incluido que el fuego no haga nada); vitrina
  `--showcase-env` (puente de hielo y descarga en el lago).
- Pendiente: ataque Espora + esporas que arden, crecido (planta), que la IA salvaje evite lo electrificado.

## Etapa 2c — Título, guardado, equipo y movimientos (2026-10-22)
Pedido del usuario en `docs/PROMPT_MENU_GUARDADO_EQUIPO.md`. Decisiones (todas las recomendadas):
**learnset = kit al inicio + extras** (los 4 del kit en Nv. 1, 1, 3 y 5; 2 extras por especie al nivel de
FRLG), **ranuras libres**, **guardado solo manual**, debug **F9 con `-- --debug`** (o desde el editor).
- **Título** (`scenes/ui/title_screen.tscn`, escena principal): Continuar (con resumen: retratos, nivel del
  líder, zona, tiempo y fecha), Nueva partida (confirma si ya hay guardado) y Salir. Esc en la elección de
  inicial vuelve al título.
- **Guardado** (`SaveManager`, autoload): un slot `user://saves/slot_1.json`, JSON con ids y `version`,
  escritura atómica (`.tmp` + renombrar), tolerante a JSON roto o especies/movimientos que ya no existen.
  Guarda equipo (especie, nivel, EXP, IV/EV, PS, movimientos equipados, apodo/naturaleza vacíos), activo,
  Pokébolas, opciones, tiempo jugado y **posición del entrenador** (World aparece ahí). No se guarda en combate.
- **Menú de pausa** (Esc, `PauseMenu`): Equipo, Guardar, Opciones (dificultad y modo práctica), Volver al
  título (pregunta si guardar) y Cerrar. Pausa el mundo; no se abre en combate.
- **Equipo** (`PartyScreen`): 6 casillas (vacías con "—"), activo marcado; acciones Ver ficha / Poner como
  activo / Mover arriba-abajo. `GameState.MAX_PARTY = 6`, `add_to_party()` (rechaza el 7°), `set_active()`
  (no a un debilitado), `move_in_party()`.
- **Ficha** (`SummaryScreen`, Tab cambia de pestaña): Estadísticas (estilo, mecánica de firma con descripción,
  PS, EXP, 6 stats con base/IV/EV y barra, velocidad en px/s) y Movimientos (4 ranuras + learnset completo,
  bloqueados con su nivel; equipar = Enter en movimiento y en ranura; Supr vacía; nunca sin movimientos ni
  repetidos). Los cambios re-sacan al activo (`Events.equipment_changed`).
- **Modelo**: `LearnsetEntry` + `SpeciesData.learnset` (generado por `tools/build_learnsets.gd`; sin learnset
  hay uno de compatibilidad), `CreatureInstance.equipped_moves` (+ `learned_moves`, `can_equip`, `equip`,
  `default_equipment`, `to_dict`/`from_dict`), `MoveUser.setup(instance)`, `DB.all_moves` / `move_key` /
  `move_by_id` (las claves de los kits son `<pokémon>/<archivo>` porque varios kits comparten ids).
  `GameState.grant_exp()` sube de nivel, aprende ("¡Aprendió X!", `Events.move_learned`) y equipa solo si
  hay ranura libre.
- **12 ataques oficiales nuevos** para los extras: Cuchillada, Ataque Ala, Persecución, Rayo Solar, Ácido
  (adaptación: envenena 30%), Rueda Fuego, Rayo, Hidrobomba, Derribo, Golpe Cuerpo, Rayo Hielo, Viento Hielo
  (adaptación: ralentiza siempre). El fetcher ahora también baja `learnset_frlg` de cada especie.
- Autotests: `--autotest-save` (17 chequeos), `--autotest-party` (12); vitrina `--showcase-menus`.

## Decisiones tomadas (no volver a preguntar)
- Generación: **las 3 primeras regiones (Kanto, Johto, Hoenn: 386 Pokémon)**, nombres y sprites reales
  (antes solo Kanto; lo amplió el usuario el 2026-10-22).
- Control: **entrenador + Pokémon**. Explorás con el entrenador (Red) y tu Pokémon te sigue.
- Mundo: **zonas conectadas sin corte** (streaming), región continua; solo el borde exterior tiene árboles.
- Arte: **pixel art GBA (FireRed, del decomp pret) + efectos modernos**; renderer **Forward+**
  (PCs con placa decente). Pokémon con sprites PMD (8 direcciones).
- Entrar en combate (Etapa 2): cuando un salvaje te detecta o lo atacás, **tomás control directo del
  Pokémon** (cámara se centra en él); al terminar o alejarte volvés al entrenador. También se puede sacar
  al Pokémon a pelear con una tecla.
- **Estados alterados** (quemado, paralizado, congelado...) entran en la **Etapa 2**.
- Subir a GitHub al cerrar cada etapa.
- **Stats oficiales** (2b): stats base, experiencia, curvas y tasa de captura de PokeAPI; fórmula oficial
  de stats y de daño; tabla de tipos oficial (se sumaron veneno, volador y siniestro).
- **Por ahora todos los Pokémon tienen stats máximos para su nivel** (IV 31, EV 0, naturaleza neutra).
  **Más adelante (Etapa 6)** cada Pokémon capturado tendrá IVs al azar según la suerte; uno con stats
  perfectos tiene que ser **sumamente difícil** de conseguir.
- Los Pokémon **se mueven según su stat de Velocidad** (sube con el nivel, con rendimiento decreciente).
- Los ataques **no deben salir tan seguido**: energía con regeneración lenta (12/s) y recargas que crecen
  con la potencia.
- El fuego tiene que verse **rojizo**, no amarillo ni demasiado luminoso; las luces dinámicas, suaves.

## Estado actual
- 9 zonas de 48×32 (`tools/build_world.gd` → `REGION`/`BIOMES`): Bosque Profundo, Bosque Verde,
  Lago Celeste / Pradera Florida, **Ruta 1 (inicio)**, Colinas Rocosas / Humedal, Pradera Sur, Arboleda.
- Ruta 1 tiene un rincón de flores cerrado por rocas con 2 rocas frágiles (puzzle para la Etapa 3).
  Bosque Verde tiene un arroyo con vados donde lo cruzan los caminos (candidato a puente de hielo).
- 14 especies (`data/species`; se sumaron Pikachu y Seel), 21 ataques (`data/moves`), 9 tipos
  (fuego, agua, planta, normal, eléctrico, hielo, veneno, volador, siniestro), 3 estados (`data/status`:
  quemado, paralizado, congelado).

### Stats oficiales (Etapa 2b)
- Datos en `data/source/official.json` (PokeAPI) → `tools/apply_official_data.gd` → `.tres`.
  Detalle de fórmulas y adaptaciones al tiempo real en `CLAUDE.md` ("Stats, daño y progresión").
- Ejemplos verificados por `--autotest-stats`: Pikachu Nv.50 = PS 110 / At 75 / Def 60 / AtEsp 70 /
  DefEsp 70 / Vel 110; curvas de EXP a Nv.100 (1.000.000 medium, 1.059.860 medium-slow, etc.).
- Velocidad de movimiento a Nv.5 entre ~68 px/s (Oddish) y ~80 (Pikachu/Poliwag); a Nv.50 ~114-141.
- Recargas: Ascuas 1,45 s / 16 EN, Lanzallamas 2,35 s, áreas 3-5,5 s, Protección 8 s.
- Visual: fuego rojizo (centro naranja), luces dinámicas suaves; quemado con llamitas que suben, luz
  parpadeante y tinte naranja; paralizado con chispas; congelado dentro de un bloque de hielo.

### Combate (Etapa 2)
- **Modo combate** (`scripts/combat/combat_director.gd`): un salvaje te detecta (o apretás **F**) → controlás
  al Pokémon (WASD, mouse, 1-4/clic, espacio esquiva), la cámara (`CameraRig`) lo sigue y el entrenador queda
  quieto. Termina si no quedan enemigos cerca por 1,5 s, si tu Pokémon se debilita o con F. Si lo sacaste con
  F sin enemigos, no termina solo.
- **Componentes de la criatura** (`scenes/creatures/creature.tscn`): `Health`, `StatusEffects`, `MoveUser`
  (recargas/energía), `Hurtbox` (capa 6 aliada / 7 salvaje), `DashHitbox`. Estados: idle, follow, controlled,
  cast, dash, stunned, fainted, wander, chase, attack, flee.
- **Ataques**: `Projectile` (choca con paredes, capa 1), `AreaEffect`, embestida (hitbox durante el dash),
  escudo. La carga (cast time) la interrumpe un golpe fuerte (knockback ≥ 200). Daño en `Damage` (escala 0.4).
- **Estados alterados**: quemado (daño por segundo, -25% ataque, lo cura el agua), paralizado (lento +
  inmovilizado al azar), congelado (no actúa, lo derrite el fuego).
- **Feedback** (`scripts/fx/combat_feedback.gd`): números de daño (súper eficaz en grande), hitstop, temblor,
  chispas, luces dinámicas en ataques de fuego/eléctrico/hielo, destello HDR al recibir golpes, estelas al esquivar.
- `Events.element_impact(element, pos, radius)` ya se emite en cada impacto: **es la entrada del sistema de
  entorno reactivo de la Etapa 3**.
- **Provisorio** (lo reemplazan etapas futuras): `WildSpawner` (salvajes en el pasto alto según bioma; Etapa 4)
  y regeneración fuera de combate de 2%/s con vuelta al 30% (Etapa 6: Centros Pokémon / objetos).

### Pruebas automáticas
`--autotest` (recorre las 9 zonas), `--autotest-combat` (3 peleas: Charmander/Bulbasaur, Pikachu/Squirtle,
Seel/Oddish), `--autotest-input` (simula teclas reales y verifica el spawner), `--autotest-stats` (stats y
EXP contra valores oficiales), `--showcase` (vitrina visual de los 3 estados, para renderizar). Correr siempre con
`--quit-after 60000` como límite por si algo se cuelga.

## Próximo paso concreto
1. **Entrenadores vivos** (`docs/PLAN_ENTRENADORES.md`): E-0 hecha; seguir con E-1 (combate contra entrenador
   con cambio de Pokémon). La "mente" del entrenador
   (órdenes gritadas + perillas + memoria) usa el mismo `CombatBody` que los salvajes.
2. Salvajes, pendiente: "en grupo" (si atacás a uno vienen los demás), aprovechar la mecánica de firma
   (Pidgey sube al aire, Vulpix busca quemados).
3. Spawns por hora (las tablas por zona y bioma ya están: se arman en el editor de mapas, pestaña Salvajes).

## Pendientes de pulido (anotados)
- Esquinas interiores donde se cruzan caminos (quedan cuadradas).
- Lagos solo rectangulares (faltan esquinas interiores de agua).
- Bosques podrían ser más densos/variados (el tileset de Bosque Verde ya está en la paleta del editor).
- Reflejos de personajes en el agua; sombras de árboles más elaboradas.
- Verificar visualmente el pasto alto tapando las piernas.
