# Informe de balance (batería de peleas IA contra IA)

> **Generado** por `--autotest-balance` (2026-10-28). Ver cómo correrlo en `scripts/tests/balance_tests.gd`.
> Cada pelea: dos Pokémon con kit, IA en Difícil, nivel 40, reglas del mundo, emparejados por stats base (±60), cada pareja
> dos veces cambiando de lado. 2000 peleas en 990 s (semilla 1). Con pocas peleas por especie los % varían mucho:
> mirar las que tienen 10 o más.

Empates por tiempo (60 s): 17 de 1000 (2%).

## Por especie (de más fuerte a más débil)

Daño hecho/recibido = de golpes (sin veneno ni quemaduras), en vidas enteras del rival/propias por pelea (1,0 = una vida). ⬆ = gana 65% o más, ⬇ = 35% o menos (con 10+ peleas).

| Pokémon | Estilo | Stats base | Peleas | Victorias | % | Vida al ganar | Seg. por victoria | Daño hecho | Daño recibido | Empates |
|---|---|---|---|---|---|---|---|---|---|---|
| Charizard ⬆ | bruiser | 534 | 28 | 27 | 96% | 64% | 6.7 | 0.91 | 0.41 | 0 |
| Venonat ⬆ | control | 305 | 26 | 24 | 92% | 57% | 18.3 | 1.00 | 0.52 | 0 |
| Tauros ⬆ | bruiser | 490 | 32 | 29 | 91% | 55% | 11.4 | 1.01 | 0.47 | 0 |
| Machop ⬆ | bruiser | 305 | 28 | 25 | 89% | 46% | 8.9 | 1.01 | 0.58 | 0 |
| Kadabra ⬆ | control | 400 | 26 | 23 | 88% | 78% | 3.7 | 0.98 | 0.30 | 0 |
| Alakazam ⬆ | control | 500 | 34 | 30 | 88% | 72% | 8.0 | 1.03 | 0.35 | 0 |
| Flareon ⬆ | bruiser | 525 | 34 | 30 | 88% | 58% | 8.1 | 0.87 | 0.46 | 0 |
| Porygon ⬆ | control | 395 | 22 | 19 | 86% | 58% | 14.4 | 0.96 | 0.42 | 0 |
| Bellossom ⬆ | desgaste | 490 | 28 | 24 | 86% | 49% | 20.6 | 0.22 | 0.71 | 0 |
| Nidoqueen ⬆ | bruiser | 505 | 20 | 17 | 85% | 52% | 12.5 | 0.70 | 0.54 | 0 |
| Krabby ⬆ | bruiser | 325 | 40 | 34 | 85% | 48% | 14.9 | 0.96 | 0.56 | 1 |
| Charmeleon ⬆ | bruiser | 405 | 30 | 25 | 83% | 48% | 9.7 | 0.74 | 0.61 | 0 |
| Rattata ⬆ | asesino | 253 | 28 | 23 | 82% | 43% | 15.2 | 0.95 | 0.60 | 0 |
| Weepinbell ⬆ | control | 390 | 30 | 24 | 80% | 44% | 15.0 | 0.32 | 0.60 | 0 |
| Slowbro ⬆ | tanque | 490 | 30 | 24 | 80% | 49% | 23.2 | 0.96 | 0.54 | 0 |
| Tangela ⬆ | control | 435 | 38 | 30 | 79% | 73% | 18.1 | 0.87 | 0.56 | 0 |
| Dewgong ⬆ | tanque | 475 | 28 | 22 | 79% | 67% | 24.5 | 0.90 | 0.83 | 0 |
| Graveler ⬆ | tanque | 390 | 26 | 20 | 77% | 59% | 13.6 | 0.87 | 0.46 | 0 |
| Slowpoke ⬆ | tanque | 315 | 30 | 23 | 77% | 53% | 23.5 | 1.05 | 0.51 | 0 |
| Cubone ⬆ | bruiser | 320 | 30 | 23 | 77% | 62% | 8.9 | 0.88 | 0.46 | 0 |
| Nidoran♀ ⬆ | bruiser | 275 | 24 | 18 | 75% | 49% | 11.8 | 0.73 | 0.63 | 0 |
| Magnemite ⬆ | espaciador | 325 | 28 | 21 | 75% | 56% | 15.6 | 0.83 | 0.57 | 0 |
| Spearow ⬆ | asesino | 262 | 30 | 22 | 73% | 39% | 11.4 | 0.91 | 0.57 | 0 |
| Oddish ⬆ | desgaste | 320 | 26 | 19 | 73% | 65% | 16.9 | 0.35 | 0.63 | 0 |
| Machamp ⬆ | bruiser | 505 | 22 | 16 | 73% | 43% | 11.0 | 1.00 | 0.66 | 0 |
| Gastly ⬆ | hostigador | 310 | 22 | 16 | 73% | 64% | 15.0 | 0.96 | 0.61 | 0 |
| Growlithe ⬆ | perseguidor | 350 | 22 | 16 | 73% | 57% | 11.6 | 0.82 | 0.49 | 1 |
| Nidorina ⬆ | bruiser | 365 | 40 | 29 | 73% | 45% | 13.3 | 0.71 | 0.62 | 0 |
| Golem ⬆ | tanque | 495 | 18 | 13 | 72% | 67% | 15.3 | 0.83 | 0.43 | 0 |
| Vileplume ⬆ | desgaste | 490 | 28 | 20 | 71% | 68% | 18.4 | 0.22 | 0.58 | 0 |
| Porygon2 ⬆ | control | 515 | 28 | 20 | 71% | 52% | 19.1 | 0.90 | 0.55 | 0 |
| Scizor ⬆ | asesino | 500 | 24 | 17 | 71% | 46% | 15.9 | 0.98 | 0.66 | 0 |
| Bellsprout ⬆ | control | 300 | 20 | 14 | 70% | 60% | 14.2 | 0.36 | 0.62 | 0 |
| Lickitung ⬆ | tanque | 385 | 26 | 18 | 69% | 50% | 16.1 | 0.97 | 0.50 | 0 |
| Farfetch’d ⬆ | asesino | 377 | 26 | 18 | 69% | 55% | 11.3 | 0.92 | 0.54 | 0 |
| Machoke ⬆ | bruiser | 405 | 32 | 22 | 69% | 59% | 8.4 | 0.89 | 0.46 | 0 |
| Venusaur ⬆ | control | 525 | 32 | 22 | 69% | 54% | 18.0 | 0.21 | 0.71 | 0 |
| Scyther ⬆ | asesino | 500 | 22 | 15 | 68% | 65% | 9.4 | 0.89 | 0.55 | 0 |
| Kangaskhan ⬆ | bruiser | 490 | 24 | 16 | 67% | 37% | 16.5 | 0.72 | 0.74 | 0 |
| Magneton ⬆ | espaciador | 465 | 26 | 17 | 65% | 56% | 23.9 | 0.89 | 0.62 | 0 |
| Pikachu | velocista | 320 | 22 | 14 | 64% | 41% | 18.7 | 0.88 | 0.66 | 0 |
| Seel | tanque | 325 | 24 | 15 | 63% | 77% | 21.7 | 0.88 | 0.98 | 0 |
| Weedle | asesino | 195 | 18 | 11 | 61% | 34% | 26.9 | 0.54 | 0.78 | 0 |
| Kingler | bruiser | 475 | 28 | 17 | 61% | 48% | 11.7 | 0.83 | 0.65 | 0 |
| Steelix | tanque | 510 | 28 | 17 | 61% | 58% | 23.7 | 0.81 | 0.44 | 3 |
| Geodude | tanque | 300 | 30 | 18 | 60% | 71% | 9.6 | 0.86 | 0.56 | 0 |
| Lapras | tanque | 535 | 30 | 18 | 60% | 36% | 21.1 | 1.06 | 0.74 | 1 |
| Mankey | bruiser | 305 | 30 | 18 | 60% | 45% | 10.6 | 0.85 | 0.72 | 0 |
| Ivysaur | control | 405 | 30 | 18 | 60% | 38% | 16.8 | 0.23 | 0.80 | 1 |
| Fearow | asesino | 442 | 30 | 18 | 60% | 51% | 13.5 | 0.82 | 0.67 | 0 |
| Marowak | bruiser | 425 | 30 | 18 | 60% | 61% | 9.6 | 0.87 | 0.60 | 0 |
| Hitmonchan | bruiser | 455 | 22 | 13 | 59% | 63% | 13.1 | 0.78 | 0.57 | 0 |
| Articuno | control | 580 | 22 | 13 | 59% | 47% | 13.5 | 0.85 | 0.71 | 0 |
| Snorlax | tanque | 540 | 24 | 14 | 58% | 69% | 19.0 | 0.84 | 0.83 | 2 |
| Tentacruel | control | 515 | 24 | 14 | 58% | 40% | 25.2 | 0.86 | 0.78 | 0 |
| Charmander | bruiser | 309 | 24 | 14 | 58% | 59% | 6.6 | 0.71 | 0.66 | 0 |
| Bulbasaur | control | 318 | 26 | 15 | 58% | 37% | 18.5 | 0.21 | 0.83 | 0 |
| Jolteon | velocista | 525 | 30 | 17 | 57% | 49% | 20.0 | 0.80 | 0.64 | 0 |
| Pidgey | hostigador | 251 | 30 | 17 | 57% | 35% | 21.6 | 0.89 | 0.73 | 0 |
| Shellder | tanque | 305 | 30 | 17 | 57% | 46% | 14.6 | 0.86 | 0.68 | 0 |
| Slowking | tanque | 490 | 16 | 9 | 56% | 60% | 25.6 | 0.94 | 0.47 | 2 |
| Haunter | hostigador | 405 | 16 | 9 | 56% | 80% | 17.3 | 0.65 | 0.62 | 0 |
| Starmie | control | 520 | 34 | 19 | 56% | 43% | 20.8 | 0.90 | 0.94 | 1 |
| Onix | tanque | 385 | 18 | 10 | 56% | 58% | 27.5 | 0.84 | 0.52 | 0 |
| Raichu | bruiser | 485 | 20 | 11 | 55% | 51% | 8.1 | 0.72 | 0.71 | 0 |
| Gloom | desgaste | 395 | 20 | 11 | 55% | 50% | 17.1 | 0.21 | 0.82 | 0 |
| Zapdos | bruiser | 580 | 20 | 11 | 55% | 57% | 13.1 | 0.93 | 0.42 | 0 |
| Doduo | velocista | 310 | 22 | 12 | 55% | 35% | 8.1 | 0.81 | 0.80 | 0 |
| Wigglytuff | control | 435 | 22 | 12 | 55% | 43% | 14.9 | 0.81 | 0.70 | 0 |
| Gengar | hostigador | 500 | 28 | 15 | 54% | 70% | 16.7 | 0.71 | 0.38 | 4 |
| Dodrio | velocista | 470 | 28 | 15 | 54% | 50% | 11.0 | 0.82 | 0.67 | 0 |
| Venomoth | control | 450 | 36 | 19 | 53% | 61% | 19.7 | 0.79 | 0.71 | 0 |
| Abra | velocista | 310 | 30 | 15 | 50% | 49% | 17.0 | 0.74 | 0.74 | 0 |
| Butterfree | control | 395 | 14 | 7 | 50% | 53% | 22.3 | 0.71 | 0.64 | 0 |
| Seadra | espaciador | 440 | 26 | 13 | 50% | 47% | 20.4 | 0.74 | 0.69 | 0 |
| Rhyhorn | tanque | 345 | 30 | 15 | 50% | 62% | 15.4 | 0.88 | 0.59 | 0 |
| Muk | tanque | 500 | 20 | 10 | 50% | 37% | 24.7 | 0.74 | 0.79 | 0 |
| Paras | control | 285 | 24 | 12 | 50% | 55% | 23.2 | 0.74 | 0.71 | 0 |
| Ponyta | velocista | 410 | 14 | 7 | 50% | 45% | 10.3 | 0.67 | 0.70 | 0 |
| Parasect | control | 405 | 26 | 13 | 50% | 54% | 25.9 | 0.66 | 0.86 | 0 |
| Tentacool | control | 335 | 24 | 12 | 50% | 51% | 16.8 | 0.66 | 0.78 | 0 |
| Kabuto | hostigador | 355 | 32 | 16 | 50% | 44% | 15.8 | 0.82 | 0.83 | 0 |
| Golduck | caotico | 500 | 28 | 14 | 50% | 38% | 22.8 | 0.79 | 0.74 | 0 |
| Weezing | control | 490 | 38 | 18 | 47% | 32% | 18.3 | 0.38 | 0.66 | 0 |
| Kakuna | tanque | 205 | 28 | 13 | 46% | 36% | 32.5 | 0.55 | 0.80 | 0 |
| Kabutops | hostigador | 495 | 26 | 12 | 46% | 56% | 18.7 | 0.91 | 0.82 | 0 |
| Eevee | adaptativo | 325 | 26 | 12 | 46% | 44% | 12.1 | 0.77 | 0.76 | 0 |
| Ninetales | desgaste | 505 | 26 | 12 | 46% | 28% | 22.8 | 0.48 | 0.74 | 2 |
| Vaporeon | tanque | 525 | 24 | 11 | 46% | 42% | 27.0 | 0.85 | 0.95 | 6 |
| Rhydon | tanque | 485 | 24 | 11 | 46% | 34% | 15.7 | 0.72 | 0.82 | 0 |
| Sandshrew | control | 300 | 24 | 11 | 46% | 25% | 21.2 | 0.66 | 0.84 | 0 |
| Aerodactyl | asesino | 515 | 20 | 9 | 45% | 30% | 11.7 | 0.85 | 0.72 | 0 |
| Arcanine | perseguidor | 555 | 18 | 8 | 44% | 28% | 16.6 | 0.71 | 0.78 | 0 |
| Nidorino | asesino | 365 | 32 | 14 | 44% | 39% | 13.4 | 0.77 | 0.72 | 0 |
| Zubat | hostigador | 245 | 28 | 12 | 43% | 69% | 17.2 | 0.70 | 0.79 | 0 |
| Wartortle | tanque | 405 | 22 | 9 | 41% | 34% | 22.0 | 0.78 | 0.83 | 2 |
| Gyarados | bruiser | 540 | 30 | 12 | 40% | 44% | 20.7 | 0.64 | 0.76 | 0 |
| Beedrill | asesino | 395 | 20 | 8 | 40% | 26% | 11.2 | 0.55 | 0.74 | 0 |
| Squirtle | tanque | 314 | 28 | 11 | 39% | 46% | 15.5 | 0.77 | 0.81 | 0 |
| Hitmonlee | asesino | 455 | 28 | 11 | 39% | 52% | 9.7 | 0.81 | 0.69 | 0 |
| Omanyte | control | 355 | 36 | 14 | 39% | 44% | 19.0 | 0.57 | 0.67 | 0 |
| Electabuzz | bruiser | 490 | 26 | 10 | 38% | 45% | 12.0 | 0.79 | 0.70 | 0 |
| Psyduck | caotico | 320 | 26 | 10 | 38% | 26% | 16.3 | 0.76 | 0.82 | 1 |
| Blastoise | tanque | 530 | 26 | 10 | 38% | 40% | 28.2 | 0.88 | 0.70 | 3 |
| Grimer | tanque | 325 | 24 | 9 | 38% | 32% | 16.7 | 0.65 | 0.88 | 0 |
| Victreebel | control | 490 | 24 | 9 | 38% | 38% | 19.0 | 0.28 | 0.85 | 0 |
| Cloyster | tanque | 525 | 30 | 11 | 37% | 56% | 17.9 | 0.89 | 0.78 | 0 |
| Rapidash | velocista | 500 | 22 | 8 | 36% | 47% | 11.7 | 0.67 | 0.82 | 0 |
| Persian ⬇ | asesino | 440 | 20 | 7 | 35% | 53% | 14.6 | 0.69 | 0.70 | 0 |
| Koffing ⬇ | control | 340 | 26 | 9 | 35% | 56% | 14.1 | 0.45 | 0.53 | 0 |
| Nidoking ⬇ | asesino | 505 | 26 | 9 | 35% | 70% | 20.3 | 0.66 | 0.72 | 0 |
| Hypno ⬇ | control | 483 | 26 | 9 | 35% | 39% | 21.7 | 0.66 | 0.84 | 0 |
| Drowzee ⬇ | control | 328 | 24 | 8 | 33% | 67% | 20.3 | 0.77 | 0.80 | 0 |
| Dugtrio ⬇ | hostigador | 425 | 28 | 9 | 32% | 50% | 13.5 | 0.64 | 0.76 | 0 |
| Nidoran♂ ⬇ | asesino | 273 | 22 | 7 | 32% | 36% | 15.9 | 0.72 | 0.77 | 0 |
| Magikarp ⬇ | caotico | 200 | 16 | 5 | 31% | 13% | 39.5 | 0.81 | 0.90 | 0 |
| Omastar ⬇ | control | 495 | 26 | 8 | 31% | 45% | 14.6 | 0.73 | 0.66 | 2 |
| Pidgeotto ⬇ | hostigador | 349 | 26 | 8 | 31% | 55% | 24.2 | 0.77 | 0.72 | 0 |
| Crobat ⬇ | hostigador | 535 | 20 | 6 | 30% | 62% | 34.0 | 0.67 | 0.91 | 0 |
| Vulpix ⬇ | desgaste | 299 | 18 | 5 | 28% | 33% | 14.9 | 0.43 | 0.84 | 0 |
| Pidgeot ⬇ | hostigador | 479 | 36 | 10 | 28% | 54% | 27.4 | 0.69 | 0.66 | 0 |
| Horsea ⬇ | espaciador | 295 | 22 | 6 | 27% | 29% | 26.3 | 0.66 | 0.85 | 0 |
| Meowth ⬇ | asesino | 290 | 22 | 6 | 27% | 30% | 11.6 | 0.69 | 0.84 | 0 |
| Staryu ⬇ | velocista | 340 | 26 | 7 | 27% | 28% | 19.6 | 0.67 | 1.11 | 0 |
| Golbat ⬇ | hostigador | 455 | 34 | 9 | 26% | 33% | 19.9 | 0.57 | 0.91 | 0 |
| Primeape ⬇ | bruiser | 455 | 26 | 6 | 23% | 45% | 11.2 | 0.86 | 0.72 | 0 |
| Poliwag ⬇ | velocista | 300 | 26 | 6 | 23% | 39% | 33.5 | 0.53 | 0.81 | 0 |
| Ekans ⬇ | control | 288 | 18 | 4 | 22% | 29% | 14.3 | 0.72 | 0.82 | 0 |
| Kingdra ⬇ | espaciador | 540 | 24 | 5 | 21% | 49% | 24.8 | 0.57 | 0.80 | 3 |
| Metapod ⬇ | tanque | 205 | 24 | 5 | 21% | 43% | 43.2 | 0.77 | 0.79 | 0 |
| Poliwhirl ⬇ | velocista | 385 | 20 | 4 | 20% | 64% | 9.7 | 0.57 | 0.82 | 0 |
| Jynx ⬇ | control | 455 | 20 | 4 | 20% | 32% | 18.4 | 0.63 | 0.86 | 0 |
| Poliwrath ⬇ | velocista | 510 | 32 | 6 | 19% | 47% | 30.3 | 0.51 | 0.84 | 2 |
| Diglett ⬇ | hostigador | 265 | 32 | 6 | 19% | 49% | 17.4 | 0.51 | 0.88 | 0 |
| Sandslash ⬇ | control | 450 | 38 | 7 | 18% | 38% | 26.1 | 0.39 | 0.85 | 2 |
| Raticate ⬇ | asesino | 413 | 22 | 4 | 18% | 48% | 20.0 | 0.54 | 0.84 | 0 |
| Jigglypuff ⬇ | control | 270 | 18 | 3 | 17% | 35% | 17.1 | 0.64 | 0.94 | 0 |
| Exeggcute ⬇ | control | 325 | 30 | 5 | 17% | 51% | 22.8 | 0.40 | 0.74 | 0 |
| Seaking ⬇ | perseguidor | 450 | 26 | 4 | 15% | 46% | 31.0 | 0.66 | 0.88 | 0 |
| Arbok ⬇ | control | 448 | 26 | 4 | 15% | 51% | 11.7 | 0.47 | 0.88 | 0 |
| Dratini ⬇ | control | 300 | 28 | 4 | 14% | 35% | 33.6 | 0.50 | 0.92 | 0 |
| Dragonite ⬇ | control | 600 | 14 | 2 | 14% | 47% | 38.7 | 0.78 | 0.86 | 4 |
| Electrode ⬇ | hostigador | 490 | 22 | 3 | 14% | 29% | 27.2 | 0.51 | 0.91 | 0 |
| Ditto ⬇ | caotico | 288 | 22 | 3 | 14% | 18% | 39.9 | 0.67 | 0.99 | 0 |
| Politoed ⬇ | velocista | 500 | 30 | 3 | 10% | 10% | 37.5 | 0.53 | 0.80 | 0 |
| Voltorb ⬇ | hostigador | 330 | 22 | 2 | 9% | 28% | 17.0 | 0.53 | 0.68 | 0 |
| Mr. Mime ⬇ | control | 460 | 22 | 2 | 9% | 36% | 23.4 | 0.57 | 0.70 | 0 |
| Goldeen ⬇ | perseguidor | 320 | 32 | 2 | 6% | 1% | 28.3 | 0.59 | 0.88 | 0 |
| Chansey ⬇ | tanque | 450 | 32 | 1 | 3% | 68% | 54.7 | 0.31 | 1.10 | 9 |
| Exeggutor ⬇ | control | 530 | 26 | 0 | 0% | — | — | 0.28 | 0.89 | 3 |
| Blissey ⬇ | tanque | 540 | 26 | 0 | 0% | — | — | 0.47 | 1.03 | 12 |
| Dragonair ⬇ | control | 420 | 22 | 0 | 0% | — | — | 0.48 | 0.90 | 1 |
| Clefairy ⬇ | caotico | 323 | 22 | 0 | 0% | — | — | 0.30 | 0.88 | 0 |
| Caterpie ⬇ | control | 195 | 20 | 0 | 0% | — | — | 0.44 | 0.86 | 0 |
| Clefable ⬇ | caotico | 483 | 16 | 0 | 0% | — | — | 0.19 | 0.91 | 0 |

## Por estilo (arquetipo del kit)

| | Especies | Peleas | % de victorias |
|---|---|---|---|
| bruiser | 23 | 640 | 69% |
| desgaste | 6 | 146 | 62% |
| asesino | 16 | 390 | 51% |
| tanque | 27 | 696 | 51% |
| espaciador | 5 | 126 | 49% |
| adaptativo | 1 | 26 | 46% |
| control | 40 | 1044 | 46% |
| velocista | 12 | 302 | 38% |
| hostigador | 15 | 402 | 37% |
| perseguidor | 4 | 98 | 31% |
| caotico | 6 | 130 | 25% |

## Por tipo (un Pokémon de dos tipos cuenta en los dos)

| | Especies | Peleas | % de victorias |
|---|---|---|---|
| Acero | 4 | 106 | 68% |
| Fuego | 10 | 236 | 64% |
| Fantasma | 3 | 66 | 61% |
| Planta | 15 | 408 | 58% |
| Veneno | 34 | 876 | 53% |
| Lucha | 8 | 220 | 53% |
| Hielo | 5 | 130 | 52% |
| Bicho | 12 | 282 | 51% |
| Roca | 11 | 286 | 51% |
| Tierra | 15 | 402 | 51% |
| Volador | 19 | 480 | 51% |
| Normal | 24 | 622 | 49% |
| Psíquico | 13 | 348 | 49% |
| Eléctrico | 9 | 216 | 49% |
| Agua | 35 | 952 | 44% |
| Hada | 5 | 100 | 17% |
| Dragón | 4 | 88 | 13% |

## Por ataque (los más usados)

Daño = %% de la vida del que lo recibe, sumado. Por uso = daño medio cada vez que se lanza (los de estado dan 0).

| Ataque | Usos | Golpes | Daño total | Por uso | Lo usan |
|---|---|---|---|---|---|
| Pistola Agua (`pistola_agua_poliwag`) | 1208 | 939 | 4999 | 4.1 | Poliwrath, Poliwhirl, Poliwag, Politoed +1 |
| Polvo Veneno (`polvo_veneno`) | 1189 | 0 | 0 | 0.0 | Bellsprout, Ivysaur, Weepinbell, Venusaur +2 |
| Tornado (`pidgey_tornado`) | 870 | 541 | 3907 | 4.5 | Pidgeot, Pidgey, Pidgeotto, Ditto |
| Destructor (`destructor_chansey`) | 825 | 742 | 1583 | 1.9 | Chansey, Blissey |
| Pistola Agua (`pistola_agua_slowpoke`) | 798 | 487 | 2745 | 3.4 | Slowbro, Slowking, Slowpoke |
| Absorber (`absorber_kit`) | 764 | 508 | 2568 | 3.4 | Vileplume, Bellossom, Gloom, Oddish |
| Pistola Agua (`pistola_agua_kit`) | 752 | 512 | 2775 | 3.7 | Squirtle, Wartortle, Blastoise, Ditto |
| Burbuja (`burbuja_kit`) | 747 | 449 | 835 | 1.1 | Poliwrath, Poliwhirl, Poliwag, Politoed +1 |
| Atadura (`atadura_dratini`) | 694 | 680 | 2159 | 3.1 | Dragonite, Dratini, Dragonair |
| Placaje (`placaje_kit`) | 671 | 559 | 2446 | 3.6 | Squirtle, Wartortle, Blastoise, Ditto |
| Ataque Rápido (`pidgey_ataque_rapido`) | 618 | 546 | 3345 | 5.4 | Pidgeot, Pidgey, Pidgeotto, Ditto |
| Impactrueno (`impactrueno_magnemite`) | 614 | 314 | 3937 | 6.4 | Magnemite, Magneton |
| Polvo Veneno (`polvo_veneno_kit`) | 613 | 0 | 0 | 0.0 | Vileplume, Bellossom, Gloom, Oddish |
| Burbuja (`burbuja_horsea`) | 611 | 448 | 1523 | 2.5 | Seadra, Horsea, Kingdra |
| Golpe Cabeza (`golpe_cabeza_slowpoke`) | 579 | 537 | 3861 | 6.7 | Slowbro, Slowking, Slowpoke |
| Chupavidas (`chupavidas_zubat`) | 578 | 550 | 1423 | 2.5 | Crobat, Zubat, Golbat |
| Bombardeo (`bombardeo_exeggcute`) | 578 | 484 | 1021 | 1.8 | Exeggcute, Exeggutor, Ditto |
| Picotazo Veneno (`picotazo_veneno_sandshrew`) | 572 | 341 | 779 | 1.4 | Sandshrew, Sandslash |
| Pistola Agua (`pistola_agua_horsea`) | 547 | 340 | 2245 | 4.1 | Seadra, Horsea, Kingdra |
| Látigo Cepa (`latigo_cepa`) | 525 | 512 | 4234 | 8.1 | Bellsprout, Ivysaur, Weepinbell, Venusaur +2 |
| Pistola Agua (`pistola_agua_omanyte`) | 479 | 259 | 2486 | 5.2 | Omanyte, Omastar |
| Chupavidas (`chupavidas_venonat`) | 469 | 449 | 2091 | 4.5 | Venonat, Venomoth, Ditto |
| Arañazo (`aranazo_sandshrew`) | 462 | 431 | 2299 | 5.0 | Sandshrew, Sandslash |
| Arañazo (`aranazo_nidoran_f`) | 451 | 432 | 1883 | 4.2 | Nidorina, Nidoran♀, Nidoqueen |
| Ascuas (`vulpix_ascuas`) | 438 | 252 | 1656 | 3.8 | Vulpix, Ninetales |
| Tinieblas (`tinieblas_gastly`) | 438 | 214 | 2749 | 6.3 | Gastly, Haunter, Gengar |
| Constricción (`constriccion_omanyte`) | 434 | 414 | 668 | 1.5 | Omanyte, Omastar |
| Psicorrayo (`psicorrayo_venonat`) | 433 | 315 | 3372 | 7.8 | Venonat, Venomoth, Ditto |
| Lanzarrocas (`lanzarrocas_onix`) | 428 | 315 | 2437 | 5.7 | Steelix, Onix |
| Placaje (`placaje_shellder`) | 416 | 389 | 1828 | 4.4 | Cloyster, Shellder |
| Lengüetazo (`lenguetazo_gastly`) | 415 | 273 | 1210 | 2.9 | Gastly, Haunter, Gengar |
| Placaje (`placaje_koffing`) | 412 | 389 | 1564 | 3.8 | Weezing, Koffing |
| Picotazo (`picotazo_nidoran_m`) | 404 | 386 | 2328 | 5.8 | Nidoking, Nidorino, Nidoran♂ |
| Carámbano (`carambano_shellder`) | 398 | 579 | 2080 | 5.2 | Cloyster, Shellder |
| Picotazo Veneno (`picotazo_veneno_kakuna`) | 396 | 314 | 799 | 2.0 | Kakuna |
| Arañazo (`aranazo_kit`) | 388 | 358 | 1781 | 4.6 | Paras, Parasect, Ditto |
| Golpe Cabeza (`golpe_cabeza_kit`) | 377 | 338 | 2057 | 5.5 | Dewgong, Seel |
| Picotazo (`picotazo_goldeen`) | 374 | 359 | 1882 | 5.0 | Goldeen, Seaking |
| Arañazo (`aranazo_kabuto`) | 369 | 361 | 1850 | 5.0 | Kabuto, Kabutops |
| Destructor (`destructor_grimer`) | 364 | 353 | 1555 | 4.3 | Grimer, Muk |
| Confusión (`confusion_drowzee`) | 358 | 208 | 1570 | 4.4 | Drowzee, Hypno |
| Viento Hielo (`viento_hielo_kit`) | 356 | 345 | 1159 | 3.3 | Dewgong, Seel |
| Pistola Agua (`pistola_agua_psyduck`) | 352 | 232 | 1763 | 5.0 | Golduck, Psyduck |
| Bomba Huevo (`bomba_huevo_chansey`) | 349 | 150 | 628 | 1.8 | Chansey, Blissey |
| Doble Bofetón (`doble_bofeton_clefairy`) | 347 | 324 | 766 | 2.2 | Clefairy, Clefable, Ditto |
| Danza Lluvia (`danza_lluvia_kit`) | 345 | 0 | 0 | 0.0 | Poliwrath, Poliwhirl, Poliwag, Politoed +1 |
| Pesca con Cola (`pesca_cola_slowpoke`) | 341 | 328 | 940 | 2.8 | Slowbro, Slowking, Slowpoke |
| Placaje (`placaje_porygon`) | 340 | 280 | 1547 | 4.6 | Porygon2, Porygon |
| Burbuja (`burbuja_krabby`) | 339 | 524 | 1356 | 4.0 | Kingler, Krabby |
| Picotazo (`picotazo_spearow`) | 335 | 322 | 3158 | 9.4 | Fearow, Spearow |
| Picotazo Veneno (`picotazo_veneno_tentacool`) | 332 | 311 | 1092 | 3.3 | Tentacruel, Tentacool |
| Rodar (`rodar_kit`) | 329 | 312 | 2963 | 9.0 | Graveler, Geodude, Golem |
| Ataque Ala (`ataque_ala_zubat`) | 329 | 571 | 3821 | 11.6 | Crobat, Zubat, Golbat |
| Rayo Aurora (`rayo_aurora_kit`) | 321 | 189 | 1417 | 4.4 | Dewgong, Seel |
| Placaje (`placaje_metapod`) | 320 | 297 | 1130 | 3.5 | Metapod |
| Agarre (`agarre_krabby`) | 314 | 289 | 2544 | 8.1 | Kingler, Krabby |
| Destructor (`destructor_drowzee`) | 314 | 296 | 1036 | 3.3 | Drowzee, Hypno |
| Absorber (`absorber_kabuto`) | 313 | 301 | 1103 | 3.5 | Kabuto, Kabutops |
| Atadura (`atadura_onix`) | 311 | 302 | 520 | 1.7 | Steelix, Onix |
| Ataque Arena (`ataque_arena`) | 311 | 0 | 0 | 0.0 | Pidgeot, Pidgey, Pidgeotto, Ditto |
| Pistola Agua (`pistola_agua_vaporeon`) | 311 | 215 | 948 | 3.0 | Vaporeon |
| Furia Dragón (`furia_dragon_dratini`) | 309 | 164 | 1373 | 4.4 | Dragonite, Dratini, Dragonair |
| Mordisco (`rattata_mordisco`) | 307 | 278 | 1353 | 4.4 | Raticate, Rattata, Ditto |
| Golpe Kárate (`golpe_karate_machop`) | 306 | 284 | 2521 | 8.2 | Machoke, Machamp, Machop |
| Destructor (`destructor_jigglypuff`) | 301 | 283 | 1707 | 5.7 | Wigglytuff, Jigglypuff |
| Psicorrayo (`psicorrayo_porygon`) | 300 | 194 | 1641 | 5.5 | Porygon2, Porygon |
| Doble Patada (`doble_patada_nidoran_f`) | 292 | 482 | 1677 | 5.7 | Nidorina, Nidoran♀, Nidoqueen |
| Confusión (`confusion_kit`) | 289 | 164 | 1158 | 4.0 | Golduck, Psyduck |
| Residuos (`residuos_grimer`) | 289 | 219 | 1473 | 5.1 | Grimer, Muk |
| Lanzarrocas (`lanzarrocas_kit`) | 284 | 197 | 2019 | 7.1 | Graveler, Geodude, Golem |
| Hipnosis (`hipnosis_kit`) | 283 | 0 | 0 | 0.0 | Poliwrath, Poliwhirl, Poliwag, Politoed +1 |
| Arañazo (`aranazo_diglett`) | 279 | 265 | 1363 | 4.9 | Diglett, Dugtrio |
| Hidropulso (`hidropulso_starmie`) | 277 | 194 | 1730 | 6.2 | Starmie |
| Placaje (`placaje_geodude`) | 276 | 261 | 1347 | 4.9 | Graveler, Geodude, Golem |
| Placaje (`placaje_caterpie`) | 276 | 270 | 893 | 3.2 | Caterpie |
| Hueso Palo (`hueso_palo_cubone`) | 275 | 174 | 2519 | 9.2 | Cubone, Marowak |
| Paralizador (`paralizador_kit`) | 274 | 0 | 0 | 0.0 | Vileplume, Bellossom, Gloom, Oddish |
| Látigo Cepa (`latigo_cepa_tangela`) | 272 | 271 | 1496 | 5.5 | Tangela |
| Huesomerang (`huesomerang_cubone`) | 270 | 185 | 2004 | 7.4 | Cubone, Marowak |
| Cornada (`cornada_rhyhorn`) | 268 | 258 | 1721 | 6.4 | Rhydon, Rhyhorn |

