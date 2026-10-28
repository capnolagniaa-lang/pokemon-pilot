# Informe de balance (batería de peleas IA contra IA)

> **Generado** por `--autotest-balance` (2026-10-28). Ver cómo correrlo en `scripts/tests/balance_tests.gd`.
> Cada pelea: dos Pokémon con kit, IA en Difícil, nivel 40, reglas del mundo, emparejados por stats base (±60), cada pareja
> dos veces cambiando de lado. 2000 peleas en 941 s (semilla 1). Con pocas peleas por especie los % varían mucho:
> mirar las que tienen 10 o más.

Empates por tiempo (60 s): 9 de 1000 (1%).

## Por especie (de más fuerte a más débil)

Daño hecho/recibido = de golpes (sin veneno ni quemaduras), en vidas enteras del rival/propias por pelea (1,0 = una vida). ⬆ = gana 65% o más, ⬇ = 35% o menos (con 10+ peleas).

| Pokémon | Estilo | Stats base | Peleas | Victorias | % | Vida al ganar | Seg. por victoria | Daño hecho | Daño recibido | Empates |
|---|---|---|---|---|---|---|---|---|---|---|
| Charmeleon ⬆ | bruiser | 405 | 12 | 12 | 100% | 61% | 8.6 | 0.84 | 0.37 | 0 |
| Scizor ⬆ | asesino | 500 | 26 | 25 | 96% | 56% | 12.8 | 1.01 | 0.44 | 0 |
| Lapras ⬆ | tanque | 535 | 24 | 22 | 92% | 51% | 22.5 | 0.99 | 0.52 | 0 |
| Machop ⬆ | bruiser | 305 | 22 | 20 | 91% | 69% | 6.2 | 0.97 | 0.34 | 0 |
| Krabby ⬆ | bruiser | 325 | 28 | 24 | 86% | 51% | 11.1 | 1.00 | 0.54 | 0 |
| Cubone ⬆ | bruiser | 320 | 28 | 24 | 86% | 67% | 9.5 | 0.99 | 0.41 | 0 |
| Kadabra ⬆ | control | 400 | 26 | 22 | 85% | 72% | 6.6 | 0.96 | 0.39 | 0 |
| Victreebel ⬆ | control | 490 | 12 | 10 | 83% | 37% | 16.6 | 0.31 | 0.73 | 0 |
| Charmander ⬆ | bruiser | 309 | 22 | 18 | 82% | 59% | 7.1 | 0.80 | 0.53 | 0 |
| Charizard ⬆ | bruiser | 534 | 16 | 13 | 81% | 59% | 8.9 | 0.85 | 0.56 | 0 |
| Tauros ⬆ | bruiser | 490 | 20 | 16 | 80% | 58% | 11.0 | 0.93 | 0.47 | 0 |
| Flareon ⬆ | bruiser | 525 | 34 | 27 | 79% | 53% | 8.3 | 0.86 | 0.55 | 0 |
| Machoke ⬆ | bruiser | 405 | 28 | 22 | 79% | 54% | 8.0 | 0.94 | 0.47 | 0 |
| Haunter ⬆ | hostigador | 405 | 18 | 14 | 78% | 56% | 19.1 | 0.88 | 0.51 | 0 |
| Bulbasaur ⬆ | control | 318 | 18 | 14 | 78% | 41% | 16.6 | 0.30 | 0.71 | 0 |
| Venusaur ⬆ | control | 525 | 22 | 17 | 77% | 41% | 17.7 | 0.23 | 0.79 | 0 |
| Weedle ⬆ | asesino | 195 | 26 | 20 | 77% | 32% | 23.6 | 0.60 | 0.68 | 0 |
| Nidoran♀ ⬆ | bruiser | 275 | 20 | 15 | 75% | 40% | 14.1 | 0.66 | 0.68 | 0 |
| Snorlax ⬆ | tanque | 540 | 28 | 21 | 75% | 53% | 23.1 | 0.97 | 1.01 | 0 |
| Slowking ⬆ | tanque | 490 | 30 | 22 | 73% | 47% | 26.5 | 0.97 | 0.55 | 1 |
| Tentacruel ⬆ | control | 515 | 30 | 22 | 73% | 55% | 22.4 | 0.81 | 0.69 | 0 |
| Growlithe ⬆ | perseguidor | 350 | 30 | 22 | 73% | 56% | 10.3 | 0.85 | 0.45 | 0 |
| Nidoqueen ⬆ | bruiser | 505 | 30 | 22 | 73% | 37% | 14.9 | 0.78 | 0.65 | 0 |
| Rhyhorn ⬆ | tanque | 345 | 22 | 16 | 73% | 50% | 13.6 | 1.01 | 0.52 | 0 |
| Marowak ⬆ | bruiser | 425 | 18 | 13 | 72% | 57% | 12.1 | 0.85 | 0.56 | 0 |
| Dragonite ⬆ | bruiser | 600 | 18 | 13 | 72% | 41% | 12.3 | 1.11 | 0.70 | 0 |
| Porygon2 ⬆ | control | 515 | 32 | 23 | 72% | 41% | 16.4 | 0.84 | 0.58 | 0 |
| Hitmonchan ⬆ | bruiser | 455 | 28 | 20 | 71% | 59% | 9.8 | 0.89 | 0.55 | 0 |
| Tentacool ⬆ | control | 335 | 28 | 20 | 71% | 55% | 18.7 | 0.79 | 0.66 | 0 |
| Lickitung ⬆ | tanque | 385 | 20 | 14 | 70% | 44% | 15.3 | 0.82 | 0.66 | 0 |
| Alakazam ⬆ | control | 500 | 20 | 14 | 70% | 74% | 7.0 | 0.93 | 0.48 | 0 |
| Gloom ⬆ | desgaste | 395 | 26 | 18 | 69% | 63% | 18.1 | 0.24 | 0.72 | 0 |
| Gastly ⬆ | hostigador | 310 | 32 | 22 | 69% | 49% | 14.0 | 0.95 | 0.65 | 2 |
| Scyther ⬆ | asesino | 500 | 22 | 15 | 68% | 36% | 8.9 | 0.96 | 0.71 | 1 |
| Kangaskhan ⬆ | bruiser | 490 | 22 | 15 | 68% | 34% | 15.6 | 0.62 | 0.75 | 0 |
| Ekans ⬆ | control | 288 | 28 | 19 | 68% | 34% | 10.5 | 0.87 | 0.73 | 0 |
| Blissey ⬆ | tanque | 540 | 28 | 19 | 68% | 46% | 20.5 | 0.84 | 0.81 | 0 |
| Articuno ⬆ | control | 580 | 18 | 12 | 67% | 47% | 15.6 | 1.02 | 0.69 | 0 |
| Oddish ⬆ | desgaste | 320 | 24 | 16 | 67% | 61% | 16.6 | 0.33 | 0.68 | 0 |
| Starmie ⬆ | control | 520 | 26 | 17 | 65% | 45% | 19.0 | 1.01 | 0.89 | 2 |
| Magnemite ⬆ | espaciador | 325 | 26 | 17 | 65% | 51% | 20.1 | 0.77 | 0.65 | 0 |
| Dewgong ⬆ | tanque | 475 | 26 | 17 | 65% | 63% | 26.8 | 0.95 | 1.00 | 3 |
| Vileplume ⬆ | desgaste | 490 | 20 | 13 | 65% | 70% | 20.3 | 0.15 | 0.69 | 0 |
| Graveler | tanque | 390 | 28 | 18 | 64% | 57% | 15.7 | 0.89 | 0.62 | 0 |
| Venonat | control | 305 | 28 | 18 | 64% | 51% | 22.2 | 0.97 | 0.75 | 1 |
| Seel | tanque | 325 | 28 | 18 | 64% | 71% | 26.3 | 1.03 | 0.94 | 1 |
| Rapidash | velocista | 500 | 30 | 19 | 63% | 43% | 11.7 | 0.75 | 0.62 | 0 |
| Onix | tanque | 385 | 24 | 15 | 63% | 58% | 20.5 | 0.84 | 0.55 | 0 |
| Nidorina | bruiser | 365 | 24 | 15 | 63% | 44% | 14.6 | 0.69 | 0.64 | 0 |
| Hypno | control | 483 | 32 | 20 | 63% | 42% | 24.5 | 0.86 | 0.81 | 1 |
| Weepinbell | control | 390 | 26 | 16 | 62% | 34% | 17.5 | 0.26 | 0.80 | 0 |
| Machamp | bruiser | 505 | 36 | 22 | 61% | 41% | 10.1 | 0.91 | 0.66 | 0 |
| Rhydon | tanque | 485 | 18 | 11 | 61% | 78% | 10.1 | 0.81 | 0.52 | 0 |
| Farfetch’d | asesino | 377 | 28 | 17 | 61% | 46% | 9.9 | 0.84 | 0.66 | 0 |
| Nidoran♂ | asesino | 273 | 20 | 12 | 60% | 28% | 16.0 | 0.84 | 0.72 | 0 |
| Eevee | adaptativo | 325 | 30 | 18 | 60% | 54% | 13.3 | 0.85 | 0.53 | 2 |
| Tangela | control | 435 | 32 | 19 | 59% | 73% | 17.2 | 0.76 | 0.69 | 0 |
| Steelix | tanque | 510 | 22 | 13 | 59% | 57% | 25.5 | 0.91 | 0.56 | 2 |
| Geodude | tanque | 300 | 24 | 14 | 58% | 79% | 9.1 | 0.82 | 0.49 | 0 |
| Seaking | perseguidor | 450 | 38 | 22 | 58% | 34% | 13.0 | 0.89 | 0.74 | 0 |
| Golem | tanque | 495 | 28 | 16 | 57% | 78% | 9.9 | 1.02 | 0.53 | 2 |
| Hitmonlee | asesino | 455 | 28 | 16 | 57% | 53% | 6.6 | 0.86 | 0.68 | 0 |
| Wigglytuff | control | 435 | 30 | 17 | 57% | 42% | 15.5 | 0.92 | 0.70 | 1 |
| Dratini | control | 300 | 16 | 9 | 56% | 39% | 17.4 | 0.75 | 0.76 | 0 |
| Bellsprout | control | 300 | 32 | 18 | 56% | 28% | 16.7 | 0.32 | 0.86 | 0 |
| Pikachu | velocista | 320 | 34 | 19 | 56% | 40% | 13.9 | 0.87 | 0.72 | 0 |
| Arbok | control | 448 | 34 | 19 | 56% | 33% | 12.7 | 0.75 | 0.65 | 0 |
| Rattata | asesino | 253 | 18 | 10 | 56% | 34% | 14.6 | 0.80 | 0.77 | 0 |
| Venomoth | control | 450 | 22 | 12 | 55% | 70% | 16.2 | 0.85 | 0.65 | 0 |
| Drowzee | control | 328 | 22 | 12 | 55% | 42% | 19.5 | 0.79 | 0.84 | 0 |
| Nidorino | asesino | 365 | 22 | 12 | 55% | 35% | 16.6 | 0.83 | 0.56 | 0 |
| Mankey | bruiser | 305 | 24 | 13 | 54% | 45% | 7.7 | 0.79 | 0.70 | 0 |
| Slowpoke | tanque | 315 | 26 | 14 | 54% | 53% | 18.2 | 1.00 | 0.59 | 1 |
| Kabuto | hostigador | 355 | 26 | 14 | 54% | 59% | 17.8 | 0.79 | 0.79 | 0 |
| Shellder | tanque | 305 | 28 | 15 | 54% | 48% | 13.7 | 0.85 | 0.70 | 0 |
| Slowbro | tanque | 490 | 30 | 16 | 53% | 37% | 27.7 | 0.90 | 0.65 | 1 |
| Doduo | velocista | 310 | 30 | 16 | 53% | 42% | 10.8 | 0.83 | 0.77 | 0 |
| Bellossom | desgaste | 490 | 30 | 16 | 53% | 61% | 21.6 | 0.13 | 0.84 | 0 |
| Wartortle | tanque | 405 | 18 | 9 | 50% | 22% | 22.8 | 0.86 | 0.85 | 0 |
| Nidoking | asesino | 505 | 24 | 12 | 50% | 43% | 18.4 | 0.68 | 0.77 | 0 |
| Abra | velocista | 310 | 28 | 14 | 50% | 46% | 14.9 | 0.80 | 0.76 | 0 |
| Paras | control | 285 | 34 | 17 | 50% | 61% | 16.4 | 0.81 | 0.81 | 1 |
| Kabutops | hostigador | 495 | 24 | 12 | 50% | 40% | 20.6 | 0.88 | 0.80 | 1 |
| Ponyta | velocista | 410 | 30 | 15 | 50% | 45% | 9.8 | 0.70 | 0.76 | 0 |
| Grimer | tanque | 325 | 24 | 12 | 50% | 43% | 13.9 | 0.68 | 0.78 | 0 |
| Kakuna | tanque | 205 | 24 | 12 | 50% | 40% | 33.7 | 0.52 | 0.64 | 0 |
| Gengar | hostigador | 500 | 30 | 14 | 47% | 56% | 17.2 | 0.84 | 0.79 | 1 |
| Butterfree | control | 395 | 28 | 13 | 46% | 48% | 20.8 | 0.72 | 0.76 | 0 |
| Dodrio | velocista | 470 | 24 | 11 | 46% | 56% | 11.9 | 0.78 | 0.66 | 0 |
| Squirtle | tanque | 314 | 22 | 10 | 45% | 27% | 19.6 | 0.84 | 0.84 | 0 |
| Aerodactyl | asesino | 515 | 18 | 8 | 44% | 34% | 11.9 | 0.93 | 0.75 | 0 |
| Porygon | control | 395 | 18 | 8 | 44% | 40% | 15.1 | 0.79 | 0.79 | 0 |
| Cloyster | tanque | 525 | 36 | 16 | 44% | 34% | 21.5 | 0.83 | 0.72 | 0 |
| Kingler | bruiser | 475 | 34 | 15 | 44% | 43% | 11.9 | 0.79 | 0.71 | 0 |
| Mr. Mime | control | 460 | 28 | 12 | 43% | 46% | 12.6 | 0.79 | 0.76 | 0 |
| Metapod | tanque | 205 | 28 | 12 | 43% | 30% | 36.5 | 0.77 | 0.79 | 0 |
| Jigglypuff | control | 270 | 28 | 12 | 43% | 48% | 10.3 | 0.82 | 0.70 | 0 |
| Politoed | velocista | 500 | 28 | 12 | 43% | 40% | 19.5 | 0.74 | 0.70 | 1 |
| Meowth | asesino | 290 | 26 | 11 | 42% | 33% | 11.8 | 0.82 | 0.76 | 0 |
| Pidgey | hostigador | 251 | 24 | 10 | 42% | 45% | 16.1 | 0.83 | 0.77 | 0 |
| Spearow | asesino | 262 | 34 | 14 | 41% | 47% | 10.5 | 0.73 | 0.77 | 0 |
| Electabuzz | bruiser | 490 | 32 | 13 | 41% | 47% | 10.4 | 0.73 | 0.69 | 1 |
| Blastoise | tanque | 530 | 28 | 11 | 39% | 38% | 27.3 | 0.79 | 0.82 | 1 |
| Dragonair | control | 420 | 28 | 11 | 39% | 27% | 19.7 | 0.71 | 0.83 | 0 |
| Zubat | hostigador | 245 | 28 | 11 | 39% | 41% | 18.2 | 0.70 | 0.92 | 0 |
| Weezing | control | 490 | 36 | 14 | 39% | 19% | 16.9 | 0.39 | 0.75 | 0 |
| Psyduck | caotico | 320 | 18 | 7 | 39% | 34% | 11.7 | 0.87 | 0.74 | 0 |
| Golduck | caotico | 500 | 26 | 10 | 38% | 26% | 22.1 | 0.83 | 0.88 | 2 |
| Muk | tanque | 500 | 24 | 9 | 38% | 27% | 20.6 | 0.63 | 0.88 | 0 |
| Golbat | hostigador | 455 | 30 | 11 | 37% | 43% | 18.8 | 0.66 | 0.86 | 0 |
| Primeape | bruiser | 455 | 28 | 10 | 36% | 37% | 10.4 | 0.74 | 0.81 | 0 |
| Ivysaur | control | 405 | 28 | 10 | 36% | 39% | 18.2 | 0.16 | 0.89 | 0 |
| Magneton ⬇ | espaciador | 465 | 26 | 9 | 35% | 51% | 32.0 | 0.64 | 0.73 | 0 |
| Vaporeon ⬇ | tanque | 525 | 26 | 9 | 35% | 45% | 22.6 | 0.81 | 1.00 | 5 |
| Jolteon ⬇ | velocista | 525 | 26 | 9 | 35% | 43% | 17.2 | 0.71 | 0.74 | 0 |
| Pidgeotto ⬇ | hostigador | 349 | 32 | 11 | 34% | 29% | 18.4 | 0.80 | 0.74 | 0 |
| Parasect ⬇ | control | 405 | 30 | 10 | 33% | 41% | 23.6 | 0.61 | 0.92 | 0 |
| Exeggutor ⬇ | control | 530 | 18 | 6 | 33% | 45% | 30.1 | 0.74 | 0.85 | 0 |
| Horsea ⬇ | espaciador | 295 | 18 | 6 | 33% | 60% | 10.8 | 0.69 | 0.72 | 0 |
| Raichu ⬇ | bruiser | 485 | 30 | 10 | 33% | 39% | 8.7 | 0.53 | 0.84 | 0 |
| Voltorb ⬇ | hostigador | 330 | 18 | 6 | 33% | 24% | 16.5 | 0.76 | 0.81 | 0 |
| Seadra ⬇ | espaciador | 440 | 24 | 8 | 33% | 37% | 28.9 | 0.62 | 0.71 | 0 |
| Electrode ⬇ | hostigador | 490 | 26 | 8 | 31% | 23% | 17.9 | 0.82 | 0.92 | 0 |
| Goldeen ⬇ | perseguidor | 320 | 26 | 8 | 31% | 26% | 18.4 | 0.72 | 0.88 | 0 |
| Dugtrio ⬇ | hostigador | 425 | 26 | 8 | 31% | 30% | 19.2 | 0.66 | 0.85 | 0 |
| Jynx ⬇ | control | 455 | 36 | 11 | 31% | 49% | 16.6 | 0.66 | 0.79 | 0 |
| Pidgeot ⬇ | hostigador | 479 | 24 | 7 | 29% | 26% | 28.8 | 0.71 | 0.89 | 0 |
| Koffing ⬇ | control | 340 | 24 | 7 | 29% | 26% | 18.1 | 0.51 | 0.70 | 0 |
| Persian ⬇ | asesino | 440 | 14 | 4 | 29% | 87% | 14.9 | 0.71 | 0.74 | 0 |
| Beedrill ⬇ | asesino | 395 | 22 | 6 | 27% | 15% | 13.6 | 0.54 | 0.95 | 0 |
| Omastar ⬇ | control | 495 | 30 | 8 | 27% | 26% | 21.1 | 0.61 | 0.90 | 0 |
| Sandslash ⬇ | control | 450 | 30 | 8 | 27% | 45% | 19.8 | 0.56 | 0.82 | 0 |
| Staryu ⬇ | velocista | 340 | 28 | 7 | 25% | 37% | 13.9 | 0.78 | 1.06 | 0 |
| Arcanine ⬇ | perseguidor | 555 | 24 | 6 | 25% | 25% | 19.2 | 0.60 | 0.87 | 0 |
| Poliwrath ⬇ | velocista | 510 | 26 | 6 | 23% | 29% | 30.5 | 0.66 | 0.70 | 1 |
| Fearow ⬇ | asesino | 442 | 26 | 6 | 23% | 29% | 14.7 | 0.66 | 0.83 | 0 |
| Zapdos ⬇ | bruiser | 580 | 26 | 6 | 23% | 37% | 15.4 | 0.85 | 0.83 | 0 |
| Clefable ⬇ | caotico | 483 | 22 | 5 | 23% | 19% | 28.2 | 0.60 | 0.85 | 1 |
| Sandshrew ⬇ | control | 300 | 32 | 7 | 22% | 28% | 16.1 | 0.53 | 0.90 | 0 |
| Ninetales ⬇ | desgaste | 505 | 28 | 6 | 21% | 10% | 17.2 | 0.38 | 0.93 | 0 |
| Ditto ⬇ | caotico | 288 | 26 | 5 | 19% | 7% | 12.0 | 0.52 | 0.98 | 0 |
| Kingdra ⬇ | espaciador | 540 | 22 | 4 | 18% | 23% | 26.4 | 0.72 | 0.73 | 0 |
| Poliwhirl ⬇ | velocista | 385 | 24 | 4 | 17% | 36% | 16.5 | 0.58 | 0.84 | 0 |
| Caterpie ⬇ | control | 195 | 26 | 4 | 15% | 10% | 40.0 | 0.64 | 0.79 | 0 |
| Poliwag ⬇ | velocista | 300 | 20 | 3 | 15% | 54% | 19.6 | 0.55 | 0.87 | 0 |
| Omanyte ⬇ | control | 355 | 36 | 5 | 14% | 44% | 13.4 | 0.49 | 0.86 | 0 |
| Clefairy ⬇ | caotico | 323 | 22 | 3 | 14% | 43% | 18.0 | 0.53 | 0.80 | 0 |
| Diglett ⬇ | hostigador | 265 | 30 | 4 | 13% | 46% | 11.3 | 0.44 | 0.92 | 0 |
| Gyarados ⬇ | bruiser | 540 | 32 | 4 | 13% | 45% | 21.9 | 0.66 | 0.74 | 1 |
| Chansey ⬇ | tanque | 450 | 26 | 3 | 12% | 74% | 39.2 | 0.59 | 0.85 | 1 |
| Vulpix ⬇ | desgaste | 299 | 26 | 3 | 12% | 51% | 9.5 | 0.38 | 0.92 | 0 |
| Crobat ⬇ | hostigador | 535 | 26 | 2 | 8% | 34% | 19.2 | 0.40 | 0.99 | 0 |
| Raticate ⬇ | asesino | 413 | 26 | 2 | 8% | 14% | 15.6 | 0.69 | 0.84 | 0 |
| Exeggcute ⬇ | control | 325 | 26 | 1 | 4% | 39% | 16.9 | 0.38 | 0.96 | 0 |
| Magikarp ⬇ | caotico | 200 | 14 | 0 | 0% | — | — | 0.77 | 0.92 | 0 |

## Por estilo (arquetipo del kit)

| | Especies | Peleas | % de victorias |
|---|---|---|---|
| bruiser | 24 | 612 | 62% |
| adaptativo | 1 | 30 | 60% |
| tanque | 27 | 690 | 56% |
| asesino | 16 | 380 | 50% |
| perseguidor | 4 | 118 | 49% |
| control | 39 | 1050 | 49% |
| desgaste | 6 | 154 | 47% |
| velocista | 12 | 328 | 41% |
| hostigador | 15 | 394 | 39% |
| espaciador | 5 | 116 | 38% |
| caotico | 6 | 128 | 23% |

## Por tipo (un Pokémon de dos tipos cuenta en los dos)

| | Especies | Peleas | % de victorias |
|---|---|---|---|
| Acero | 4 | 100 | 64% |
| Fantasma | 3 | 80 | 63% |
| Lucha | 8 | 220 | 59% |
| Veneno | 34 | 862 | 56% |
| Fuego | 10 | 252 | 56% |
| Hielo | 5 | 140 | 56% |
| Planta | 15 | 378 | 53% |
| Tierra | 15 | 384 | 52% |
| Psíquico | 13 | 348 | 52% |
| Bicho | 12 | 316 | 52% |
| Roca | 11 | 278 | 49% |
| Normal | 24 | 614 | 47% |
| Agua | 35 | 928 | 45% |
| Dragón | 4 | 84 | 44% |
| Volador | 19 | 484 | 41% |
| Eléctrico | 9 | 244 | 40% |
| Hada | 5 | 130 | 38% |

## Por ataque (los más usados)

Daño = %% de la vida del que lo recibe, sumado. Por uso = daño medio cada vez que se lanza (los de estado dan 0).

| Ataque | Usos | Golpes | Daño total | Por uso | Lo usan |
|---|---|---|---|---|---|
| Pistola Agua (`pistola_agua_poliwag`) | 1065 | 826 | 5440 | 5.1 | Poliwrath, Poliwag, Poliwhirl, Politoed |
| Polvo Veneno (`polvo_veneno`) | 1051 | 0 | 0 | 0.0 | Bellsprout, Ivysaur, Weepinbell, Venusaur +2 |
| Pistola Agua (`pistola_agua_slowpoke`) | 896 | 548 | 2927 | 3.3 | Slowbro, Slowking, Slowpoke |
| Burbuja (`burbuja_kit`) | 752 | 457 | 838 | 1.1 | Poliwrath, Poliwag, Poliwhirl, Politoed |
| Golpe Cabeza (`golpe_cabeza_slowpoke`) | 668 | 619 | 4121 | 6.2 | Slowbro, Slowking, Slowpoke |
| Absorber (`absorber_kit`) | 662 | 435 | 2085 | 3.1 | Vileplume, Bellossom, Gloom, Oddish |
| Tornado (`pidgey_tornado`) | 659 | 429 | 3398 | 5.2 | Pidgeotto, Pidgeot, Pidgey, Ditto |
| Pistola Agua (`pistola_agua_kit`) | 639 | 448 | 2719 | 4.3 | Wartortle, Blastoise, Squirtle |
| Placaje (`placaje_kit`) | 583 | 523 | 2044 | 3.5 | Wartortle, Blastoise, Squirtle |
| Polvo Veneno (`polvo_veneno_kit`) | 564 | 0 | 0 | 0.0 | Vileplume, Bellossom, Gloom, Oddish |
| Tinieblas (`tinieblas_gastly`) | 538 | 291 | 3704 | 6.9 | Gastly, Gengar, Haunter |
| Chupavidas (`chupavidas_zubat`) | 527 | 500 | 1482 | 2.8 | Crobat, Zubat, Golbat |
| Lengüetazo (`lenguetazo_gastly`) | 514 | 391 | 1733 | 3.4 | Gastly, Gengar, Haunter |
| Impactrueno (`impactrueno_magnemite`) | 487 | 301 | 3064 | 6.3 | Magnemite, Magneton |
| Ataque Rápido (`pidgey_ataque_rapido`) | 475 | 402 | 2971 | 6.3 | Pidgeotto, Pidgeot, Pidgey, Ditto |
| Pistola Agua (`pistola_agua_omanyte`) | 467 | 272 | 2311 | 4.9 | Omastar, Omanyte |
| Placaje (`placaje_shellder`) | 466 | 418 | 1534 | 3.3 | Cloyster, Shellder, Ditto |
| Carámbano (`carambano_shellder`) | 465 | 657 | 2265 | 4.9 | Cloyster, Shellder, Ditto |
| Arañazo (`aranazo_kit`) | 463 | 409 | 2154 | 4.7 | Paras, Parasect |
| Golpe Cabeza (`golpe_cabeza_kit`) | 461 | 411 | 2423 | 5.3 | Dewgong, Seel |
| Viento Hielo (`viento_hielo_kit`) | 444 | 392 | 1188 | 2.7 | Dewgong, Seel |
| Ascuas (`vulpix_ascuas`) | 443 | 261 | 1656 | 3.7 | Vulpix, Ninetales |
| Látigo Cepa (`latigo_cepa`) | 437 | 422 | 3601 | 8.2 | Bellsprout, Ivysaur, Weepinbell, Venusaur +2 |
| Arañazo (`aranazo_nidoran_f`) | 435 | 424 | 1767 | 4.1 | Nidorina, Nidoran♀, Nidoqueen |
| Bombardeo (`bombardeo_exeggcute`) | 430 | 434 | 1455 | 3.4 | Exeggutor, Exeggcute |
| Lanzarrocas (`lanzarrocas_onix`) | 430 | 370 | 2801 | 6.5 | Onix, Steelix |
| Chupavidas (`chupavidas_venonat`) | 414 | 383 | 2064 | 5.0 | Venonat, Venomoth, Ditto |
| Confusión (`confusion_drowzee`) | 406 | 238 | 2036 | 5.0 | Drowzee, Hypno |
| Constricción (`constriccion_omanyte`) | 400 | 396 | 639 | 1.6 | Omastar, Omanyte |
| Rayo Aurora (`rayo_aurora_kit`) | 398 | 218 | 1732 | 4.4 | Dewgong, Seel |
| Pesca con Cola (`pesca_cola_slowpoke`) | 396 | 388 | 1159 | 2.9 | Slowbro, Slowking, Slowpoke |
| Destructor (`destructor_jigglypuff`) | 394 | 378 | 2419 | 6.1 | Jigglypuff, Wigglytuff |
| Psicorrayo (`psicorrayo_venonat`) | 392 | 280 | 2635 | 6.7 | Venonat, Venomoth, Ditto |
| Placaje (`placaje_caterpie`) | 388 | 369 | 1675 | 4.3 | Caterpie |
| Rodar (`rodar_kit`) | 387 | 351 | 3200 | 8.3 | Graveler, Golem, Geodude, Ditto |
| Picotazo Veneno (`picotazo_veneno_kakuna`) | 379 | 265 | 609 | 1.6 | Kakuna |
| Placaje (`placaje_geodude`) | 371 | 354 | 1750 | 4.7 | Graveler, Golem, Geodude, Ditto |
| Picotazo Veneno (`picotazo_veneno_tentacool`) | 371 | 345 | 1262 | 3.4 | Tentacool, Tentacruel |
| Picotazo (`picotazo_nidoran_m`) | 370 | 350 | 2427 | 6.6 | Nidoking, Nidorino, Nidoran♂ |
| Placaje (`placaje_koffing`) | 369 | 340 | 1508 | 4.1 | Koffing, Weezing |
| Picotazo Veneno (`picotazo_veneno_sandshrew`) | 369 | 278 | 1237 | 3.4 | Sandshrew, Sandslash |
| Destructor (`destructor_drowzee`) | 360 | 326 | 1299 | 3.6 | Drowzee, Hypno |
| Destructor (`destructor_chansey`) | 351 | 325 | 2027 | 5.8 | Blissey, Chansey |
| Rodar (`rodar_jigglypuff`) | 350 | 305 | 2615 | 7.5 | Jigglypuff, Wigglytuff |
| Lanzarrocas (`lanzarrocas_kit`) | 347 | 241 | 2383 | 6.9 | Graveler, Golem, Geodude, Ditto |
| Picotazo Veneno (`picotazo_veneno_ekans`) | 346 | 312 | 2456 | 7.1 | Ditto, Ekans, Arbok |
| Doble Bofetón (`doble_bofeton_clefairy`) | 336 | 313 | 1338 | 4.0 | Clefable, Clefairy |
| Destructor (`destructor_grimer`) | 336 | 315 | 1789 | 5.3 | Grimer, Muk |
| Burbuja (`burbuja_horsea`) | 328 | 265 | 1218 | 3.7 | Seadra, Horsea |
| Placaje (`placaje_porygon`) | 322 | 262 | 1362 | 4.2 | Porygon2, Porygon |
| Picotazo (`picotazo_goldeen`) | 322 | 305 | 2716 | 8.4 | Seaking, Goldeen |
| Placaje (`placaje_metapod`) | 319 | 280 | 1336 | 4.2 | Metapod |
| Arañazo (`aranazo_kabuto`) | 317 | 307 | 1379 | 4.4 | Kabuto, Kabutops |
| Arañazo (`aranazo_sandshrew`) | 317 | 294 | 2150 | 6.8 | Sandshrew, Sandslash |
| Atadura (`atadura_onix`) | 310 | 298 | 556 | 1.8 | Onix, Steelix |
| Pistola Agua (`pistola_agua_psyduck`) | 307 | 204 | 1373 | 4.5 | Golduck, Psyduck |
| Ataque Ala (`ataque_ala_zubat`) | 306 | 516 | 3507 | 11.5 | Crobat, Zubat, Golbat |
| Absorber (`absorber_kabuto`) | 303 | 297 | 1138 | 3.8 | Kabuto, Kabutops |
| Atadura (`atadura_dratini`) | 301 | 279 | 1643 | 5.5 | Dragonair, Dratini |
| Golpe Kárate (`golpe_karate_machop`) | 301 | 288 | 2727 | 9.1 | Machamp, Machoke, Machop |
| Pistola Agua (`pistola_agua_horsea`) | 295 | 198 | 1163 | 3.9 | Seadra, Horsea |
| Disparo Demora (`disparo_demora_caterpie`) | 294 | 0 | 0 | 0.0 | Caterpie |
| Burbuja (`burbuja_krabby`) | 293 | 406 | 1146 | 3.9 | Krabby, Kingler |
| Residuos (`residuos_grimer`) | 280 | 215 | 1361 | 4.9 | Grimer, Muk |
| Agarre (`agarre_krabby`) | 279 | 270 | 2195 | 7.9 | Krabby, Kingler |
| Bomba Huevo (`bomba_huevo_chansey`) | 278 | 143 | 1969 | 7.1 | Blissey, Chansey |
| Impactrueno (`impactrueno_kit`) | 278 | 165 | 1340 | 4.8 | Pikachu |
| Doble Patada (`doble_patada_nidoran_f`) | 278 | 499 | 1476 | 5.3 | Nidorina, Nidoran♀, Nidoqueen |
| Chupavidas (`chupavidas_kit`) | 276 | 259 | 2416 | 8.8 | Paras, Parasect |
| Psicorrayo (`psicorrayo_porygon`) | 275 | 175 | 1495 | 5.4 | Porygon2, Porygon |
| Picotazo (`picotazo_spearow`) | 273 | 248 | 2381 | 8.7 | Fearow, Spearow |
| Paralizador (`paralizador_kit`) | 268 | 0 | 0 | 0.0 | Vileplume, Bellossom, Gloom, Oddish |
| Pistola Agua (`pistola_agua_vaporeon`) | 266 | 167 | 1104 | 4.2 | Vaporeon |
| Mordisco (`rattata_mordisco`) | 265 | 262 | 1095 | 4.1 | Raticate, Rattata, Ditto |
| Picotazo Veneno (`picotazo_veneno_weedle`) | 265 | 180 | 466 | 1.8 | Weedle |
| Danza Lluvia (`danza_lluvia_kit`) | 260 | 0 | 0 | 0.0 | Poliwrath, Poliwag, Poliwhirl, Politoed |
| Rayo Burbuja (`rayo_burbuja_tentacool`) | 258 | 354 | 1838 | 7.1 | Tentacool, Tentacruel |
| Mordisco (`mordisco_nidoran_f`) | 258 | 253 | 2057 | 8.0 | Nidorina, Nidoran♀, Nidoqueen |
| Paralizador (`paralizador_paras`) | 258 | 3 | 25 | 0.1 | Paras, Parasect |
| Ascuas (`ascuas_growlithe`) | 256 | 162 | 1536 | 6.0 | Arcanine, Growlithe |

