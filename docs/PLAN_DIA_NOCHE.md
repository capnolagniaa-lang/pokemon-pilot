# Plan: día, noche e iluminación "next gen" (Etapa 5, primera parte)

Estado: **aprobado por el usuario (2026-10-28)**. Primero A (sesión de gráficos), después B; C y D en paralelo sobre la señal de A.
La acordaron dos sesiones: "Workflow mejora gráficos" (A, B) y "Codigo de kits" (D). La parte C es del agente de
mapas.

## Referencias
`docs/referencias/iluminacion/`: capturas del juego (`*_original.png`) repintadas con Qwen Image Edit (workflow
`terreno_shaders` de ComfyUI): `ruta1_sol`, `verde_sol`, `plateada_sol`, `verde_noche`, `plateada_tarde`.
Son **guía visual**, no algo que se use en el juego: la IA repinta cada imagen, tarda ~1 min y sale distinta cada vez.
El look se reproduce con efectos de Godot en tiempo real.

Qué tienen las referencias:
1. **Sombras largas con la forma real** de árboles, casas, cercas, carteles y personajes, hacia abajo a la derecha. Al
   atardecer son mucho más largas y violetas.
2. **Luz que entra desde una esquina**, con glow y rayos suaves.
3. **Gradación de color** según la hora: cálida al mediodía, dorada al atardecer, azul de luna de noche.
4. **Noche**: ventanas y faroles prendidos con charcos de luz cálida en el suelo, luciérnagas.

## Lo que ya existe
- `CanvasModulate` "Daylight" en `scenes/world/world.tscn` (sin ciclo todavía).
- `shaders/post_process.gdshader`: tilt-shift, saturación, contraste, tinte, viñeta, aberración.
- `art/fx/world_environment.tres`: glow.
- `scripts/world/tree_shadows.gd`: mancha ovalada al pie de cada árbol (luz desde arriba a la izquierda).
- `shaders/cloud_shadows.gdshader`: sombras de nubes.
- `EncounterEntry.time` (día/noche): reservado para esta etapa.

## Reparto

### A) Núcleo de tiempo (sesión de gráficos) — ✅ hecho (2026-10-28)
Quedó en `scripts/world/day_night.gd` (`world.day_night`). La tabla `KEYS` dice cómo se ve cada hora, ajustada contra
las referencias. Para B y D: `darkness` (0-1; 0 en interiores y arenas), `shadow_direction`, `shadow_length`,
`shadow_alpha`, `indoor` y la señal `Events.time_changed(hour, phase)`, que avisa cada 0,1 h y al cambiar de fase.
- `DayNight` (nodo del mundo): hora del juego (0-24), que avanza con un ritmo configurable y se guarda en
  `GameState` (`to_dict`/`from_dict`). Emite `Events.time_changed(hour, phase)` (fases: amanecer, día, atardecer,
  noche).
- Mueve: el color del `Daylight`, los uniforms del post-procesado (tinte, luz de esquina, rayos) y la dirección y el
  largo de las sombras (B).
- Ajustes del juego: clave `time_lock` en `GameState.default_settings()` (-1 = el tiempo corre; 0-24 = hora fija),
  leída con `GameState.setting()`, y su fila en `SECTIONS` de `scripts/ui/game_settings_screen.gd`. **Sin otro
  sistema de opciones.**
- Interiores y cuevas: luz propia (no siguen la hora). El post-procesado se queda en la capa del mundo, para que no
  lave el HUD ni los menús (son CanvasLayer). El Mapa del menú (`TownMap`) no hereda la noche, y está bien así.
- Autotest `--autotest-daynight` y vitrina `--showcase-daynight` (las 4 fases en las 3 zonas de referencia), para
  compararlas con las referencias.

### B) Sombras con forma (sesión de gráficos) — ✅ primera versión (2026-10-28)
Cómo quedó:
- **Mapa** (`ZoneShadows`, `scripts/world/zone_shadows.gd` + `shaders/sun_shadows.gdshader`): cada zona exterior arma
  al cargarse una máscara (4 px por celda) con las celdas sólidas del TileSet, sin salientes ni agua. La altura sale
  del largo de la columna sólida (una cerca = baja, una casa = alta) y los árboles van redondos. El shader estira esa
  máscara hacia el lado contrario al sol, con un color azul violáceo. No se usaron siluetas de los sellos: la colisión
  alcanza, y las casas son rectángulos.
- **Personajes y Pokémon** (`SunShadow`, `scripts/fx/sun_shadow.gd`): su mismo cuadro, oscuro y acostado en el suelo.
  Lo agregan `CreatureSprite._ready` y `blob_shadow.gd` (entrenador, personas, entrenadores del mapa). La mancha al pie
  y `tree_shadows.gd` quedan como sombra de contacto.
- Pendiente: lo que se corta o se rompe (EnvObjects) no proyecta, y las sombras no cruzan de una zona a la vecina.
- Una copia de la silueta de cada cosa (árbol, edificio, cerca, cartel, criatura, entrenador), oscura y sesgada según
  la dirección y el largo que marque A. Reemplaza la mancha de `tree_shadows.gd`; la sombra de contacto al pie queda.
- Toca `ZoneBuilder`/los sellos (de dónde salen las siluetas de los edificios) y `CreatureSprite` (sombra de las
  criaturas). **CreatureSprite queda para B** (la llama de Charmander va por D).

### C) Mapas — ventanas ✅ hecho 2026-10-28 (sesión de gráficos, sin tocar zonas)
Cómo quedó: `tools/find_windows.py` arma los mapas exteriores de FireRed y detecta los vidrios (manchas celestes chicas
sobre celdas sólidas de edificios; junta los paños de una misma ventana; el techo de la Tienda es grande y no entra; el
logo de la Tienda va en `NOT_WINDOWS`) → `data/world/night_windows.json` (máscara de 16×16 por metatile). `ZoneLights`
(`scripts/world/zone_lights.gd`, como `ZoneShadows`) pinta el vidrio cálido y un charco de luz delante de cada tira de
ventanas; faroles `StreetLamps` junto a los caminos; cuevas oscuras con `CaveLights` (antorchas y cristales) (los pisos altos, tapados por `Overhead`, en un nodo a z 21; el charco solo bajo la planta baja), según `DayNight.darkness` (compensa el Daylight). Test en `--autotest-daynight`. Faltan faroles y los
salvajes de noche.
- Marcar en los datos, no a mano por zona, **qué celdas son ventanas y faroles** (luz de noche) y **qué proyecta
  sombra**: en `data/world/stamps.json` / `reference_curation.json` o en los roles de tile (`TileRoleSet`).
- Salvajes de noche: filas con `EncounterEntry.time` en `data/world/encounters/` (solo si el usuario lo aprueba).

### D) Combate y ataques (sesión "Codigo de kits") — ✅ hecho 2026-10-28
Cómo quedó: `NightLight` (`scripts/fx/night_light.gd`): `apply(efecto)` al crear disparos, áreas, conos, trampas,
golpes cuerpo a cuerpo y rayos del cielo → se multiplican por la inversa del Daylight (HDR 2D: **no se oscurecen**) y
sus `PointLight2D` crecen con la oscuridad (de día igual que antes, ≤ 0,35; de noche hasta 0,5). `flash()`: destello
corto en los impactos de los tipos que brillan. `CreatureGlow` (`scripts/fx/creature_glow.gd`): llama que alumbra de
noche en los Pokémon de tipo fuego (por tipo, agregado en `Creature._ready`), sigue `Events.time_changed`. Las luces
de Quemado y del fuego en el pasto también crecen de noche. Solo visual. Test `--autotest-night-combat`, vitrina
`--showcase-night-combat`.
- Luz chica (`PointLight2D`, **energía ≤ 0,35**, ver la trampa del amarillo en CLAUDE.md) en ataques de fuego,
  eléctricos y similares; los efectos no se oscurecen de noche (material unshaded o CanvasLayer propia).
  Archivos: `scripts/combat/projectile.gd`, `area_effect.gd`, `melee_swing.gd`, `scripts/fx/combat_feedback.gd`.
- La llama de Charmander (y las colas/cuerpos que brillan): por `StatusEffects`/la firma Calor
  (`scripts/combat/status_effects.gd`, `signatures/heat_mechanic.gd`), no por CreatureSprite.
- Reglas por hora, si se aprueban (Fantasma/Siniestro más fuertes de noche, etc.): en `Damage`/`HitInfo`.
- Sonido: si se quieren variantes de noche, se suma "zonas_noche" a `data/audio/musica.json` y `Sound` escucha
  `Events.time_changed` (lo hace D).

## Orden propuesto
1. **A** (hora + color + post-procesado) → ya se ve el día, el atardecer y la noche.
2. **B** (sombras con forma) → lo que más acerca el juego a las referencias.
3. **C** (ventanas y faroles) y **D** (luces de ataques) en paralelo, sobre la señal de A.
4. Reglas de juego por hora (salvajes, tipos, música), si el usuario las quiere.

## Decisiones del usuario (2026-10-28)
- **Un día del juego = 24 min reales** (1 hora = 1 minuto).
- **Por ahora, solo visual**: la hora no cambia salvajes, tipos ni música (se decide después).
- **Reparto y orden aprobados.**
