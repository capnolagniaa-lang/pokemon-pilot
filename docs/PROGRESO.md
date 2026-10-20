# Progreso del proyecto

Bitácora viva. Se actualiza al cerrar cada etapa (y antes de que se termine el contexto de una sesión).

## Etapas

| # | Etapa | Estado |
|---|---|---|
| 1 | Refactor data-driven + mundo abierto con zonas | ✅ Hecha |
| 1b | Arte FireRed + efectos modernos | ✅ Hecha |
| 1c | Región grande (3×3 zonas, 9 biomas) | ✅ Hecha |
| 2 | Combate en tiempo real en el mapa + estados alterados | ⏭️ Siguiente |
| 3 | Entorno reactivo (fuego, agua, eléctrico) + puzzles | Pendiente |
| 4 | IA salvaje con estados + spawns por bioma/hora | Pendiente |
| 5 | Ciclo día/noche, clima, NPCs con horarios | Pendiente |
| 6 | Captura, equipo y progresión | Pendiente |
| 7 | Primer gimnasio (arena con transición) | Pendiente |
| 8 | Pulido (juice, audio, partículas) | Pendiente |

## Decisiones tomadas (no volver a preguntar)
- Generación: **solo primera generación (Kanto)**, nombres y sprites reales.
- Control: **entrenador + Pokémon**. Explorás con el entrenador (Red) y tu Pokémon te sigue.
- Mundo: **zonas conectadas sin corte** (streaming), región continua; solo el borde exterior tiene árboles.
- Arte: **pixel art GBA (FireRed, del decomp pret) + efectos modernos**; renderer **Forward+**
  (PCs con placa decente). Pokémon con sprites PMD (8 direcciones).
- Entrar en combate (Etapa 2): cuando un salvaje te detecta o lo atacás, **tomás control directo del
  Pokémon** (cámara se centra en él); al terminar o alejarte volvés al entrenador. También se puede sacar
  al Pokémon a pelear con una tecla.
- **Estados alterados** (quemado, paralizado, congelado...) entran en la **Etapa 2**.
- Subir a GitHub al cerrar cada etapa.

## Estado actual
- 9 zonas de 48×32 (`tools/build_world.gd` → `REGION`/`BIOMES`): Bosque Profundo, Bosque Verde,
  Lago Celeste / Pradera Florida, **Ruta 1 (inicio)**, Colinas Rocosas / Humedal, Pradera Sur, Arboleda.
- Ruta 1 tiene un rincón de flores cerrado por rocas con 2 rocas frágiles (puzzle para la Etapa 3).
  Bosque Verde tiene un arroyo con vados donde lo cruzan los caminos (candidato a puente de hielo).
- 12 especies en `data/species`, 17 ataques en `data/moves` (todavía sin combate en el mapa).
- El combate del prototipo viejo se sacó en la Etapa 1 (queda en el historial de git, commit d77e28b).

## Próximo paso concreto (Etapa 2)
1. Componentes `Hitbox`/`Hurtbox` (Area2D, capas 6/7) y `Health`; `Projectile` y `AreaEffect` como
   escenas que chocan con el mundo (capa 1).
2. Estados de criatura: `attack`, `stunned`, `controlled` (jugador maneja al Pokémon), `chase`, `flee`.
3. Modo combate: transición entrenador → Pokémon (cámara), hotkeys 1-4 / clic, cooldown, cast time, esquive.
4. Un salvaje en Ruta 1 con IA básica; estados alterados (quemado, paralizado, congelado) como Resources.
5. Feedback: números de daño, hitstop, screen shake; ataques de fuego/eléctrico con luz (glow HDR).
6. Ampliar autotest: combate automático contra el salvaje.

## Pendientes de pulido (anotados)
- Esquinas interiores donde se cruzan caminos (quedan cuadradas).
- Lagos solo rectangulares (faltan esquinas interiores de agua).
- Bosques podrían ser más densos/variados (usar tileset viridian_forest ya exportado).
- Reflejos de personajes en el agua; sombras de árboles más elaboradas.
- Verificar visualmente el pasto alto tapando las piernas.
