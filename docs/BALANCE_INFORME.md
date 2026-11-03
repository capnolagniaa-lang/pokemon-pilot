# Informe de balance (batería de peleas IA contra IA)

> **Generado** por `--autotest-balance` (2026-11-03). Ver cómo correrlo en `scripts/tests/balance_tests.gd`.
> Cada pelea: dos Pokémon con su habilidad, IA en Difícil, nivel 40, reglas del mundo, **los 4 que trae (últimos por nivel)**, emparejados por stats base (±60), cada pareja
> dos veces cambiando de lado. 2000 peleas en 2109 s (semilla 1). Con pocas peleas por especie los % varían mucho:
> mirar las que tienen 10 o más.

Empates por tiempo (60 s): 103 de 1000 (10%).

## Por especie (de más fuerte a más débil)

Daño hecho/recibido = de golpes (sin veneno ni quemaduras), en vidas enteras del rival/propias por pelea (1,0 = una vida). ⬆ = gana 65% o más, ⬇ = 35% o menos (con 10+ peleas).

| Pokémon | Habilidades | Stats base | Peleas | Victorias | % | Vida al ganar | Seg. por victoria | Daño hecho | Daño recibido | Empates |
|---|---|---|---|---|---|---|---|---|---|---|
| Blastoise ⬆ | Torrente | 530 | 28 | 27 | 96% | 61% | 20.0 | 1.00 | 0.37 | 1 |
| Seel ⬆ | Sebo | 325 | 26 | 24 | 92% | 55% | 16.5 | 0.95 | 0.43 | 0 |
| Golbat ⬆ | Fuerza Mental | 455 | 28 | 25 | 89% | 60% | 16.5 | 0.99 | 0.40 | 2 |
| Exeggcute ⬆ | Clorofila | 325 | 30 | 26 | 87% | 55% | 15.7 | 0.89 | 0.51 | 0 |
| Nidorino ⬆ | Punto Tóxico | 365 | 22 | 19 | 86% | 60% | 21.4 | 0.96 | 0.42 | 1 |
| Tentacruel ⬆ | Cuerpo Puro/Lodo Líquido | 515 | 20 | 17 | 85% | 51% | 15.2 | 0.90 | 0.57 | 0 |
| Zubat ⬆ | Fuerza Mental | 245 | 26 | 22 | 85% | 72% | 10.1 | 0.98 | 0.39 | 0 |
| Dratini ⬆ | Mudar | 300 | 24 | 20 | 83% | 49% | 16.2 | 0.98 | 0.59 | 0 |
| Vaporeon ⬆ | Absorbe Agua | 525 | 32 | 26 | 81% | 61% | 22.2 | 0.98 | 0.44 | 2 |
| Flareon ⬆ | Absorbe Fuego | 525 | 26 | 21 | 81% | 41% | 19.6 | 0.85 | 0.62 | 1 |
| Tentacool ⬆ | Cuerpo Puro/Lodo Líquido | 335 | 28 | 22 | 79% | 61% | 14.6 | 0.95 | 0.51 | 2 |
| Magikarp ⬆ | Nado Rápido | 200 | 14 | 11 | 79% | 57% | 33.6 | 0.91 | 0.55 | 0 |
| Dragonite ⬆ | Fuerza Mental | 600 | 18 | 14 | 78% | 41% | 22.9 | 0.92 | 0.68 | 0 |
| Beedrill ⬆ | Enjambre | 395 | 22 | 17 | 77% | 60% | 17.9 | 0.92 | 0.54 | 0 |
| Venusaur ⬆ | Espesura | 525 | 26 | 20 | 77% | 55% | 20.4 | 0.61 | 0.47 | 4 |
| Slowpoke ⬆ | Despiste/Ritmo Propio | 315 | 26 | 20 | 77% | 70% | 37.6 | 0.92 | 0.38 | 4 |
| Staryu ⬆ | Iluminación/Cura Natural | 340 | 20 | 15 | 75% | 63% | 11.7 | 0.94 | 0.49 | 0 |
| Oddish ⬆ | Clorofila | 320 | 36 | 27 | 75% | 59% | 14.4 | 0.84 | 0.57 | 1 |
| Sandshrew ⬆ | Velo Arena | 300 | 20 | 15 | 75% | 62% | 28.8 | 0.86 | 0.54 | 0 |
| Weezing ⬆ | Levitación | 490 | 26 | 19 | 73% | 54% | 17.8 | 0.77 | 0.60 | 0 |
| Machoke ⬆ | Agallas | 405 | 18 | 13 | 72% | 70% | 6.3 | 0.87 | 0.48 | 0 |
| Hypno ⬆ | Insomnio | 483 | 36 | 26 | 72% | 56% | 19.1 | 0.39 | 0.58 | 0 |
| Ekans ⬆ | Intimidación/Mudar | 288 | 32 | 23 | 72% | 44% | 21.5 | 0.81 | 0.73 | 0 |
| Spearow ⬆ | Vista Lince | 262 | 28 | 20 | 71% | 67% | 9.1 | 0.85 | 0.51 | 0 |
| Raichu ⬆ | Electricidad Estática | 485 | 30 | 21 | 70% | 45% | 20.1 | 0.91 | 0.66 | 0 |
| Seadra ⬆ | Punto Tóxico | 440 | 46 | 32 | 70% | 47% | 20.3 | 0.97 | 0.63 | 3 |
| Starmie ⬆ | Iluminación/Cura Natural | 520 | 32 | 22 | 69% | 73% | 16.2 | 0.84 | 0.44 | 4 |
| Pidgeotto ⬆ | Vista Lince | 349 | 28 | 19 | 68% | 50% | 13.0 | 0.86 | 0.66 | 0 |
| Horsea ⬆ | Nado Rápido | 295 | 34 | 23 | 68% | 63% | 18.0 | 0.83 | 0.56 | 0 |
| Charizard ⬆ | Mar Llamas | 534 | 24 | 16 | 67% | 34% | 26.6 | 0.83 | 0.76 | 0 |
| Omanyte ⬆ | Nado Rápido/Caparazón | 355 | 24 | 16 | 67% | 61% | 21.9 | 0.94 | 0.39 | 1 |
| Kangaskhan ⬆ | Madrugar | 490 | 18 | 12 | 67% | 38% | 18.5 | 0.85 | 0.67 | 1 |
| Cubone ⬆ | Cabeza Roca/Pararrayos | 320 | 24 | 16 | 67% | 53% | 17.3 | 0.93 | 0.55 | 3 |
| Jolteon ⬆ | Absorbe Electricidad | 525 | 24 | 16 | 67% | 64% | 21.1 | 1.09 | 0.53 | 2 |
| Victreebel ⬆ | Clorofila | 490 | 38 | 25 | 66% | 60% | 15.3 | 0.84 | 0.76 | 4 |
| Doduo ⬆ | Fuga/Madrugar | 310 | 32 | 21 | 66% | 54% | 10.6 | 0.87 | 0.64 | 0 |
| Butterfree ⬆ | Ojo Compuesto | 395 | 26 | 17 | 65% | 50% | 15.0 | 0.90 | 0.66 | 0 |
| Nidoran♂ ⬆ | Punto Tóxico | 273 | 26 | 17 | 65% | 39% | 24.7 | 0.82 | 0.72 | 1 |
| Poliwrath ⬆ | Absorbe Agua/Humedad | 510 | 20 | 13 | 65% | 57% | 16.8 | 0.81 | 0.63 | 0 |
| Pidgey | Vista Lince | 251 | 28 | 18 | 64% | 58% | 8.2 | 0.89 | 0.61 | 0 |
| Shellder | Caparazón | 305 | 28 | 18 | 64% | 43% | 15.1 | 0.85 | 0.71 | 0 |
| Dewgong | Sebo | 475 | 36 | 23 | 64% | 55% | 19.0 | 0.91 | 0.58 | 5 |
| Snorlax | Inmunidad/Sebo | 540 | 40 | 25 | 63% | 55% | 30.5 | 1.01 | 0.59 | 3 |
| Goldeen | Nado Rápido/Velo Agua | 320 | 24 | 15 | 63% | 35% | 19.2 | 0.91 | 0.77 | 0 |
| Geodude | Cabeza Roca/Robustez | 300 | 24 | 15 | 63% | 69% | 14.0 | 0.79 | 0.54 | 0 |
| Zapdos | Presión | 580 | 18 | 11 | 61% | 51% | 16.5 | 0.76 | 0.50 | 0 |
| Fearow | Vista Lince | 442 | 36 | 22 | 61% | 44% | 15.3 | 0.85 | 0.67 | 0 |
| Lickitung | Ritmo Propio/Despiste | 385 | 30 | 18 | 60% | 53% | 29.5 | 0.82 | 0.52 | 4 |
| Sandslash | Velo Arena | 450 | 20 | 12 | 60% | 49% | 26.1 | 0.88 | 0.58 | 2 |
| Nidoqueen | Punto Tóxico | 505 | 20 | 12 | 60% | 46% | 24.5 | 0.73 | 0.66 | 1 |
| Machop | Agallas | 305 | 32 | 19 | 59% | 52% | 10.4 | 0.83 | 0.59 | 2 |
| Bellsprout | Clorofila | 300 | 24 | 14 | 58% | 54% | 11.3 | 0.83 | 0.68 | 0 |
| Machamp | Agallas | 505 | 26 | 15 | 58% | 55% | 14.3 | 0.81 | 0.67 | 0 |
| Dragonair | Mudar | 420 | 26 | 15 | 58% | 32% | 21.6 | 0.93 | 0.81 | 0 |
| Nidorina | Punto Tóxico | 365 | 28 | 16 | 57% | 43% | 26.3 | 0.69 | 0.72 | 2 |
| Vileplume | Clorofila | 490 | 30 | 17 | 57% | 68% | 20.8 | 0.91 | 0.53 | 9 |
| Voltorb | Insonorizar/Electricidad Estática | 330 | 22 | 12 | 55% | 36% | 14.4 | 0.82 | 0.72 | 0 |
| Dugtrio | Velo Arena/Trampa Arena | 425 | 26 | 14 | 54% | 37% | 16.5 | 0.83 | 0.75 | 0 |
| Golduck | Humedad/Aclimatación | 500 | 36 | 19 | 53% | 49% | 26.2 | 0.81 | 0.67 | 2 |
| Weepinbell | Clorofila | 390 | 26 | 13 | 50% | 50% | 15.2 | 0.38 | 0.75 | 0 |
| Abra | Sincronía/Fuerza Mental | 310 | 32 | 16 | 50% | 52% | 14.5 | 0.81 | 0.73 | 0 |
| Arbok | Intimidación/Mudar | 448 | 20 | 10 | 50% | 62% | 16.6 | 0.71 | 0.66 | 2 |
| Bulbasaur | Espesura | 318 | 22 | 11 | 50% | 66% | 17.8 | 0.81 | 0.77 | 2 |
| Golem | Cabeza Roca/Robustez | 495 | 20 | 10 | 50% | 74% | 10.5 | 0.64 | 0.63 | 0 |
| Omastar | Nado Rápido/Caparazón | 495 | 24 | 12 | 50% | 76% | 23.0 | 0.82 | 0.51 | 5 |
| Gloom | Clorofila | 395 | 26 | 13 | 50% | 58% | 21.2 | 0.60 | 0.78 | 2 |
| Pikachu | Electricidad Estática | 320 | 34 | 17 | 50% | 37% | 28.9 | 0.76 | 0.79 | 1 |
| Magnemite | Imán/Robustez | 325 | 18 | 9 | 50% | 50% | 20.1 | 0.75 | 0.68 | 2 |
| Dodrio | Fuga/Madrugar | 470 | 22 | 11 | 50% | 37% | 15.5 | 0.92 | 0.76 | 1 |
| Rattata | Fuga/Agallas | 253 | 34 | 16 | 47% | 59% | 12.4 | 0.79 | 0.71 | 0 |
| Scyther | Enjambre | 500 | 32 | 15 | 47% | 70% | 14.3 | 0.81 | 0.59 | 1 |
| Ninetales | Absorbe Fuego | 505 | 30 | 14 | 47% | 37% | 24.0 | 0.74 | 0.80 | 3 |
| Hitmonchan | Vista Lince | 455 | 30 | 14 | 47% | 40% | 16.5 | 0.87 | 0.74 | 0 |
| Gyarados | Intimidación | 540 | 28 | 13 | 46% | 66% | 38.7 | 0.82 | 0.56 | 2 |
| Aerodactyl | Cabeza Roca/Presión | 515 | 28 | 13 | 46% | 60% | 17.7 | 0.74 | 0.60 | 4 |
| Poliwhirl | Absorbe Agua/Humedad | 385 | 24 | 11 | 46% | 47% | 20.7 | 0.74 | 0.69 | 2 |
| Caterpie | Polvo Escudo | 195 | 24 | 11 | 46% | 91% | 49.3 | 0.77 | 0.45 | 3 |
| Exeggutor | Clorofila | 530 | 22 | 10 | 45% | 56% | 12.0 | 0.80 | 0.67 | 0 |
| Charmeleon | Mar Llamas | 405 | 22 | 10 | 45% | 41% | 23.4 | 0.76 | 0.79 | 1 |
| Drowzee | Insomnio | 328 | 20 | 9 | 45% | 43% | 20.2 | 0.21 | 0.76 | 0 |
| Persian | Flexibilidad | 440 | 40 | 18 | 45% | 23% | 18.7 | 0.78 | 0.83 | 0 |
| Rhydon | Pararrayos/Cabeza Roca | 485 | 18 | 8 | 44% | 76% | 11.0 | 0.51 | 0.58 | 0 |
| Wartortle | Torrente | 405 | 28 | 12 | 43% | 50% | 28.9 | 0.78 | 0.75 | 2 |
| Moltres | Presión | 580 | 26 | 11 | 42% | 32% | 23.3 | 0.66 | 0.86 | 0 |
| Alakazam | Sincronía/Fuerza Mental | 500 | 24 | 10 | 42% | 73% | 21.1 | 0.70 | 1.01 | 2 |
| Growlithe | Intimidación/Absorbe Fuego | 350 | 34 | 14 | 41% | 35% | 12.4 | 0.62 | 0.81 | 0 |
| Magneton | Imán/Robustez | 465 | 30 | 12 | 40% | 66% | 24.5 | 0.78 | 0.61 | 6 |
| Tangela | Clorofila | 435 | 30 | 12 | 40% | 41% | 24.3 | 0.85 | 0.80 | 3 |
| Seaking | Nado Rápido/Velo Agua | 450 | 28 | 11 | 39% | 56% | 19.1 | 0.79 | 0.68 | 3 |
| Nidoking | Punto Tóxico | 505 | 28 | 11 | 39% | 69% | 33.2 | 0.58 | 0.72 | 0 |
| Jigglypuff | Gran Encanto | 270 | 26 | 10 | 38% | 51% | 25.5 | 0.77 | 0.76 | 1 |
| Kadabra | Sincronía/Fuerza Mental | 400 | 26 | 10 | 38% | 77% | 25.3 | 0.93 | 1.00 | 6 |
| Arcanine | Intimidación/Absorbe Fuego | 555 | 16 | 6 | 38% | 56% | 20.4 | 0.73 | 0.75 | 1 |
| Grimer | Hedor/Viscosidad | 325 | 24 | 9 | 38% | 49% | 25.6 | 0.68 | 0.69 | 7 |
| Kingler | Corte Fuerte/Caparazón | 475 | 28 | 10 | 36% | 27% | 20.8 | 0.78 | 0.83 | 3 |
| Slowbro ⬇ | Despiste/Ritmo Propio | 490 | 20 | 7 | 35% | 79% | 38.7 | 0.67 | 0.45 | 11 |
| Kabuto ⬇ | Nado Rápido/Armadura Batalla | 355 | 40 | 14 | 35% | 56% | 22.1 | 0.68 | 0.64 | 6 |
| Ponyta ⬇ | Fuga/Absorbe Fuego | 410 | 26 | 9 | 35% | 39% | 15.5 | 0.63 | 0.84 | 1 |
| Electabuzz ⬇ | Electricidad Estática | 490 | 32 | 11 | 34% | 61% | 28.2 | 0.77 | 0.75 | 2 |
| Marowak ⬇ | Cabeza Roca/Pararrayos | 425 | 18 | 6 | 33% | 57% | 13.1 | 0.78 | 0.72 | 1 |
| Gastly ⬇ | Levitación | 310 | 24 | 8 | 33% | 75% | 23.6 | 0.69 | 0.72 | 2 |
| Mankey ⬇ | Espíritu Vital | 305 | 24 | 8 | 33% | 66% | 17.3 | 0.74 | 0.72 | 2 |
| Jynx ⬇ | Despiste | 455 | 28 | 9 | 32% | 37% | 19.2 | 0.60 | 0.88 | 0 |
| Paras ⬇ | Efecto Espora | 285 | 28 | 9 | 32% | 49% | 26.6 | 0.80 | 0.84 | 3 |
| Raticate ⬇ | Fuga/Agallas | 413 | 22 | 7 | 32% | 47% | 11.2 | 0.67 | 0.82 | 0 |
| Magmar ⬇ | Cuerpo Llama | 495 | 26 | 8 | 31% | 58% | 29.4 | 0.37 | 0.74 | 2 |
| Graveler ⬇ | Cabeza Roca/Robustez | 390 | 20 | 6 | 30% | 44% | 16.7 | 0.50 | 0.77 | 4 |
| Nidoran♀ ⬇ | Punto Tóxico | 275 | 24 | 7 | 29% | 27% | 34.9 | 0.74 | 0.86 | 3 |
| Onix ⬇ | Cabeza Roca/Robustez | 385 | 18 | 5 | 28% | 87% | 48.4 | 0.64 | 0.47 | 9 |
| Meowth ⬇ | Recogida | 290 | 22 | 6 | 27% | 23% | 14.8 | 0.84 | 0.83 | 2 |
| Pinsir ⬇ | Corte Fuerte | 500 | 22 | 6 | 27% | 37% | 14.5 | 0.58 | 0.83 | 1 |
| Muk ⬇ | Hedor/Viscosidad | 500 | 26 | 7 | 27% | 55% | 32.5 | 0.54 | 0.81 | 5 |
| Krabby ⬇ | Corte Fuerte/Caparazón | 325 | 26 | 7 | 27% | 39% | 23.2 | 0.70 | 0.68 | 6 |
| Haunter ⬇ | Levitación | 405 | 30 | 8 | 27% | 80% | 25.5 | 0.56 | 0.71 | 3 |
| Wigglytuff ⬇ | Gran Encanto | 435 | 34 | 9 | 26% | 78% | 38.6 | 0.59 | 0.41 | 22 |
| Mr. Mime ⬇ | Insonorizar | 460 | 38 | 10 | 26% | 43% | 20.0 | 0.60 | 0.79 | 3 |
| Eevee ⬇ | Fuga | 325 | 28 | 7 | 25% | 50% | 17.8 | 0.71 | 0.82 | 1 |
| Koffing ⬇ | Levitación | 340 | 24 | 6 | 25% | 34% | 22.1 | 0.53 | 0.79 | 5 |
| Ivysaur ⬇ | Espesura | 405 | 20 | 5 | 25% | 58% | 14.5 | 0.66 | 0.82 | 2 |
| Rhyhorn ⬇ | Pararrayos/Cabeza Roca | 345 | 28 | 7 | 25% | 63% | 21.9 | 0.47 | 0.74 | 2 |
| Rapidash ⬇ | Fuga/Absorbe Fuego | 500 | 40 | 9 | 23% | 34% | 24.1 | 0.49 | 0.88 | 0 |
| Venomoth ⬇ | Polvo Escudo | 450 | 18 | 4 | 22% | 63% | 20.6 | 0.70 | 0.78 | 2 |
| Diglett ⬇ | Velo Arena/Trampa Arena | 265 | 28 | 6 | 21% | 73% | 21.6 | 0.66 | 0.67 | 5 |
| Psyduck ⬇ | Humedad/Aclimatación | 320 | 24 | 5 | 21% | 79% | 19.1 | 0.70 | 0.70 | 3 |
| Articuno ⬇ | Presión | 580 | 20 | 4 | 20% | 58% | 25.1 | 0.42 | 0.87 | 0 |
| Squirtle ⬇ | Torrente | 314 | 26 | 5 | 19% | 54% | 44.4 | 0.61 | 0.83 | 3 |
| Kabutops ⬇ | Nado Rápido/Armadura Batalla | 495 | 30 | 5 | 17% | 57% | 31.8 | 0.47 | 0.80 | 6 |
| Porygon ⬇ | Calco | 395 | 36 | 6 | 17% | 55% | 32.4 | 0.74 | 1.18 | 23 |
| Tauros ⬇ | Intimidación | 490 | 32 | 5 | 16% | 67% | 9.6 | 0.62 | 1.25 | 15 |
| Pidgeot ⬇ | Vista Lince | 479 | 28 | 4 | 14% | 31% | 12.4 | 0.55 | 0.91 | 1 |
| Gengar ⬇ | Levitación | 500 | 22 | 3 | 14% | 69% | 43.0 | 0.58 | 0.77 | 9 |
| Primeape ⬇ | Espíritu Vital | 455 | 24 | 3 | 13% | 28% | 8.2 | 0.50 | 0.90 | 0 |
| Charmander ⬇ | Mar Llamas | 309 | 38 | 4 | 11% | 13% | 21.4 | 0.58 | 0.87 | 4 |
| Chansey ⬇ | Cura Natural/Dicha | 450 | 24 | 2 | 8% | 15% | 55.8 | 0.36 | 0.84 | 0 |
| Venonat ⬇ | Ojo Compuesto | 305 | 38 | 3 | 8% | 31% | 38.3 | 0.29 | 0.83 | 16 |
| Farfetch’d ⬇ | Vista Lince/Fuerza Mental | 377 | 38 | 3 | 8% | 20% | 14.8 | 0.66 | 0.83 | 6 |
| Electrode ⬇ | Insonorizar/Electricidad Estática | 490 | 26 | 2 | 8% | 37% | 18.4 | 0.55 | 0.85 | 4 |
| Vulpix ⬇ | Absorbe Fuego | 299 | 24 | 1 | 4% | 45% | 8.1 | 0.26 | 0.89 | 1 |
| Lapras ⬇ | Absorbe Agua/Caparazón | 535 | 30 | 1 | 3% | 54% | 42.0 | 0.27 | 0.73 | 11 |
| Mew ⬇ | Sincronía | 600 | 18 | 0 | 0% | — | — | 0.37 | 0.99 | 0 |
| Ditto ⬇ | Flexibilidad | 288 | 30 | 0 | 0% | — | — | 0.00 | 0.98 | 0 |
| Clefairy ⬇ | Gran Encanto | 323 | 28 | 0 | 0% | — | — | 0.00 | 1.22 | 22 |
| Kakuna ⬇ | Mudar | 205 | 28 | 0 | 0% | — | — | 0.00 | 0.74 | 9 |
| Parasect ⬇ | Efecto Espora | 405 | 26 | 0 | 0% | — | — | 0.30 | 0.73 | 14 |
| Poliwag ⬇ | Absorbe Agua/Humedad | 300 | 26 | 0 | 0% | — | — | 0.43 | 0.92 | 2 |
| Cloyster ⬇ | Caparazón | 525 | 26 | 0 | 0% | — | — | 0.00 | 0.87 | 8 |
| Metapod ⬇ | Mudar | 205 | 14 | 0 | 0% | — | — | 0.00 | 0.57 | 8 |
| Weedle ⬇ | Polvo Escudo | 195 | 22 | 0 | 0% | — | — | 0.13 | 0.91 | 2 |
| Hitmonlee ⬇ | Flexibilidad | 455 | 32 | 0 | 0% | — | — | 0.38 | 0.99 | 2 |
| Clefable ⬇ | Gran Encanto | 483 | 20 | 0 | 0% | — | — | 0.16 | 0.74 | 6 |

## Por habilidad (la que le tocó en cada pelea)

| | Peleas | % de victorias |
|---|---|---|
| Cuerpo Puro | 22 | 91% |
| Inmunidad | 19 | 74% |
| Lodo Líquido | 26 | 73% |
| Sebo | 83 | 70% |
| Iluminación | 33 | 70% |
| Absorbe Electricidad | 24 | 67% |
| Ritmo Propio | 35 | 63% |
| Insomnio | 56 | 63% |
| Madrugar | 40 | 63% |
| Fuerza Mental | 130 | 62% |
| Clorofila | 262 | 60% |
| Enjambre | 54 | 59% |
| Punto Tóxico | 194 | 59% |
| Agallas | 106 | 58% |
| Velo Arena | 63 | 57% |
| Velo Agua | 33 | 55% |
| Torrente | 82 | 54% |
| Espesura | 68 | 53% |
| Absorbe Agua | 78 | 51% |
| Pararrayos | 45 | 51% |
| Nado Rápido | 129 | 50% |
| Vista Lince | 199 | 49% |
| Cura Natural | 29 | 48% |
| Electricidad Estática | 113 | 48% |
| Viscosidad | 21 | 48% |
| Despiste | 69 | 46% |
| Robustez | 74 | 43% |
| Mudar | 117 | 43% |
| Presión | 75 | 43% |
| Absorbe Fuego | 143 | 41% |
| Imán | 22 | 41% |
| Cabeza Roca | 94 | 39% |
| Intimidación | 112 | 39% |
| Humedad | 72 | 38% |
| Fuga | 114 | 37% |
| Caparazón | 125 | 37% |
| Mar Llamas | 84 | 36% |
| Trampa Arena | 31 | 35% |
| Levitación | 126 | 35% |
| Sincronía | 59 | 34% |
| Aclimatación | 25 | 32% |
| Ojo Compuesto | 64 | 31% |
| Cuerpo Llama | 26 | 31% |
| Armadura Batalla | 32 | 28% |
| Insonorizar | 69 | 28% |
| Recogida | 22 | 27% |
| Corte Fuerte | 46 | 24% |
| Polvo Escudo | 64 | 23% |
| Espíritu Vital | 48 | 23% |
| Hedor | 29 | 21% |
| Flexibilidad | 102 | 18% |
| Gran Encanto | 108 | 18% |
| Efecto Espora | 54 | 17% |
| Calco | 36 | 17% |
| Dicha | 14 | 14% |

## Por tipo (un Pokémon de dos tipos cuenta en los dos)

| | Especies | Peleas | % de victorias |
|---|---|---|---|
| Dragón | 3 | 68 | 72% |
| Volador | 19 | 514 | 54% |
| Planta | 14 | 384 | 53% |
| Agua | 32 | 882 | 52% |
| Veneno | 33 | 854 | 50% |
| Psíquico | 13 | 352 | 50% |
| Eléctrico | 9 | 234 | 47% |
| Tierra | 14 | 312 | 46% |
| Acero | 2 | 48 | 44% |
| Lucha | 8 | 206 | 41% |
| Roca | 11 | 274 | 41% |
| Normal | 22 | 656 | 39% |
| Fuego | 12 | 332 | 37% |
| Bicho | 12 | 300 | 27% |
| Hielo | 5 | 140 | 26% |
| Fantasma | 3 | 76 | 25% |
| Hada | 5 | 146 | 20% |

## Por ataque (los más usados)

Daño = %% de la vida del que lo recibe, sumado. Por uso = daño medio cada vez que se lanza (los de estado dan 0).

| Ataque | Usos | Golpes | Daño total | Por uso | Lo usan |
|---|---|---|---|---|---|
| Pistola Agua (`pistola_agua`) | 2914 | 1974 | 14338 | 4.9 | Poliwrath, Blastoise, Seadra, Poliwhirl +4 |
| Ácido (`acido`) | 2225 | 1585 | 10724 | 4.8 | Bellsprout, Ekans, Tentacruel, Tentacool +4 |
| Disparo Lodo (`disparo_lodo`) | 2018 | 1280 | 8722 | 4.3 | Kabutops, Kabuto, Krabby, Kingler +2 |
| Mordisco (`mordisco`) | 1808 | 1409 | 9362 | 5.2 | Nidoran♀, Wartortle, Blastoise, Aerodactyl +6 |
| Paralizador (`paralizador`) | 1759 | 0 | 0 | 0.0 | Vileplume, Bellsprout, Tangela, Venonat +5 |
| Ataque Ala (`ataque_ala`) | 1623 | 1356 | 14904 | 9.2 | Pidgeotto, Zubat, Charizard, Scyther +4 |
| Anulación (`anulacion`) | 1604 | 0 | 0 | 0.0 | Slowpoke, Lickitung, Wigglytuff, Slowbro |
| Doble Bofetón (`doble_bofeton`) | 1574 | 1498 | 4094 | 2.6 | Poliwrath, Clefable, Poliwhirl, Poliwag +4 |
| Confusión (`confusion`) | 1527 | 1113 | 8239 | 5.4 | Golduck, Psyduck, Exeggutor, Exeggcute |
| Ataque Rápido (`ataque_rapido`) | 1356 | 953 | 4446 | 3.3 | Pidgeotto, Raichu, Flareon, Ninetales +3 |
| Rayo Confuso (`rayo_confuso`) | 1262 | 0 | 0 | 0.0 | Haunter, Lapras, Gengar, Zubat +4 |
| Persecución (`persecucion`) | 1262 | 1605 | 6190 | 4.9 | Tauros, Dodrio, Beedrill, Raticate +3 |
| Placaje (`placaje`) | 1183 | 1053 | 3849 | 3.3 | Electrode, Weezing, Pidgeot, Caterpie +1 |
| Agilidad (`agilidad`) | 1159 | 0 | 0 | 0.0 | Ponyta, Rapidash, Farfetch’d, Horsea +11 |
| Furia Dragón (`furia_dragon`) | 1153 | 897 | 5351 | 4.6 | Gyarados, Dragonite, Dratini, Dragonair |
| Somnífero (`somnifero`) | 1128 | 0 | 0 | 0.0 | Venonat, Gloom, Oddish, Exeggcute +2 |
| Rapidez (`rapidez`) | 1106 | 747 | 3933 | 3.6 | Sandshrew, Sandslash, Staryu, Starmie +2 |
| Hoja Afilada (`hoja_afilada`) | 1060 | 709 | 5823 | 5.5 | Bulbasaur, Bellsprout, Venusaur, Ivysaur |
| Pantalla de Humo (`pantalla_de_humo`) | 1005 | 0 | 0 | 0.0 | Charmeleon, Koffing, Charizard, Seadra +3 |
| Residuos (`residuos`) | 940 | 650 | 5606 | 6.0 | Koffing, Muk, Weezing, Grimer |
| Metrónomo (`metronomo`) | 908 | 0 | 0 | 0.0 | Clefable, Clefairy, Mew |
| Megaagotar (`megaagotar`) | 890 | 639 | 4061 | 4.6 | Vileplume, Tangela |
| Chispa (`chispa`) | 845 | 638 | 5915 | 7.0 | Electrode, Magneton, Voltorb, Magnemite |
| Impactrueno (`impactrueno`) | 835 | 577 | 3984 | 4.8 | Raichu, Jolteon, Zapdos |
| Cornada (`cornada`) | 823 | 755 | 5964 | 7.2 | Goldeen, Seaking, Nidorino, Nidoran♂ |
| Reducción (`reduccion`) | 822 | 0 | 0 | 0.0 | Clefable, Muk, Staryu, Grimer +1 |
| Cuchillada (`cuchillada`) | 785 | 694 | 6804 | 8.7 | Sandshrew, Paras, Sandslash, Scyther +6 |
| Arañazo (`aranazo`) | 778 | 611 | 3305 | 4.2 | Persian, Nidoqueen, Sandslash |
| Fijar Blanco (`fijar_blanco`) | 762 | 0 | 0 | 0.0 | Magneton, Porygon, Magnemite |
| Ronquido (`ronquido`) | 747 | 612 | 3022 | 4.0 | Snorlax |
| Tornado (`tornado`) | 734 | 447 | 3400 | 4.6 | Butterfree, Venomoth |
| Protección (`proteccion`) | 702 | 0 | 0 | 0.0 | Wartortle, Blastoise, Krabby, Shellder +4 |
| Danza Lluvia (`danza_lluvia`) | 696 | 0 | 0 | 0.0 | Lapras, Wartortle, Poliwhirl, Poliwag +1 |
| Disparo Demora (`disparo_demora`) | 694 | 0 | 0 | 0.0 | Weedle, Caterpie |
| Furia (`furia`) | 689 | 649 | 1740 | 2.5 | Doduo, Kangaskhan, Dodrio, Onix +3 |
| Mismo Destino (`mismo_destino`) | 674 | 0 | 0 | 0.0 | Haunter, Gengar, Gastly |
| Bofetón Lodo (`bofeton_lodo`) | 667 | 523 | 1733 | 2.6 | Diglett, Dugtrio |
| Ascuas (`ascuas`) | 658 | 433 | 2796 | 4.2 | Flareon, Ninetales, Arcanine |
| Picotazo Veneno (`picotazo_veneno`) | 635 | 591 | 1832 | 2.9 | Nidoqueen, Sandshrew, Sandslash, Nidorino +3 |
| Espora (`espora`) | 616 | 0 | 0 | 0.0 | Paras, Parasect |
| Giro Rápido (`giro_rapido`) | 573 | 499 | 2613 | 4.6 | Wartortle, Blastoise, Squirtle |
| Atizar (`atizar`) | 564 | 461 | 4395 | 7.8 | Tangela, Pikachu, Lickitung, Dragonite +2 |
| Viento Hielo (`viento_hielo`) | 553 | 804 | 3955 | 7.2 | Seel, Dewgong |
| Malicioso (`malicioso`) | 517 | 0 | 0 | 0.0 | Kabuto, Gyarados, Shellder, Horsea +3 |
| Fanfarronear (`fanfarronear`) | 513 | 0 | 0 | 0.0 | Tauros, Mankey |
| Chirrido (`chirrido`) | 497 | 0 | 0 | 0.0 | Golduck, Muk, Psyduck, Grimer +4 |
| Cara Susto (`cara_susto`) | 491 | 0 | 0 | 0.0 | Charmeleon, Tauros, Charizard, Charmander +4 |
| Rodar (`rodar`) | 484 | 369 | 2581 | 5.3 | Electrode, Golem, Graveler, Voltorb +1 |
| Rayo Aurora (`rayo_aurora`) | 484 | 335 | 3790 | 7.8 | Seel, Shellder, Vaporeon |
| Psíquico (`psiquico`) | 465 | 380 | 6297 | 13.5 | Hypno, Slowpoke, Kadabra, Drowzee +2 |
| Látigo Cepa (`latigo_cepa`) | 454 | 362 | 3187 | 7.0 | Victreebel |
| Rayo Burbuja (`rayo_burbuja`) | 449 | 570 | 3969 | 8.8 | Tentacruel, Staryu, Tentacool |
| Ciclón (`ciclon`) | 443 | 443 | 2285 | 5.2 | Gyarados, Horsea, Seadra, Dratini |
| Camelo (`camelo`) | 430 | 0 | 0 | 0.0 | Nidoran♀, Nidoran♂ |
| Golpe Cabeza (`golpe_cabeza`) | 427 | 386 | 3580 | 8.4 | Hypno, Slowpoke, Slowbro |
| Foco Energía (`foco_energia`) | 426 | 0 | 0 | 0.0 | Mankey, Primeape, Marowak, Nidoking +2 |
| Fortaleza (`fortaleza`) | 405 | 0 | 0 | 0.0 | Onix, Pinsir, Metapod, Kakuna |
| Polución (`polucion`) | 398 | 281 | 957 | 2.4 | Magmar |
| Gas Venenoso (`gas_venenoso`) | 380 | 0 | 0 | 0.0 | Hypno, Drowzee |
| Constricción (`constriccion`) | 377 | 376 | 834 | 2.2 | Lickitung, Dragonite, Dragonair, Arbok +2 |
| Golpe Cuerpo (`golpe_cuerpo`) | 371 | 321 | 3957 | 10.7 | Poliwhirl, Nidoqueen, Poliwag, Snorlax +1 |
| Rizo Defensa (`rizo_defensa`) | 362 | 0 | 0 | 0.0 | Clefairy, Wigglytuff |
| Ataque Arena (`ataque_arena`) | 359 | 0 | 0 | 0.0 | Kabuto, Kabutops |
| Canto Mortal (`canto_mortal`) | 357 | 0 | 0 | 0.0 | Lapras |
| Armadura Ácida (`armadura_acida`) | 350 | 0 | 0 | 0.0 | Muk, Grimer |
| Pisotón (`pisoton`) | 340 | 291 | 2541 | 7.5 | Ponyta, Krabby, Kingler, Lickitung +1 |
| Poder Oculto (`poder_oculto`) | 339 | 249 | 2587 | 7.6 | Abra |
| Aguante (`aguante`) | 334 | 0 | 0 | 0.0 | Kabutops, Kabuto, Kangaskhan, Moltres |
| Transformación (`transformacion`) | 332 | 0 | 0 | 0.0 | Ditto, Mew |
| Refuerzo (`refuerzo`) | 327 | 0 | 0 | 0.0 | Nidoran♀, Growlithe, Nidorino, Nidoran♂ +1 |
| Supersónico (`supersonico`) | 326 | 0 | 0 | 0.0 | Shellder, Cloyster, Aerodactyl |
| Picotazo (`picotazo`) | 325 | 315 | 1289 | 4.0 | Fearow, Nidoking |
| Imitación (`imitacion`) | 319 | 0 | 0 | 0.0 | Mr. Mime, Kadabra |
| Velo Sagrado (`velo_sagrado`) | 316 | 0 | 0 | 0.0 | Butterfree, Vulpix, Ninetales |
| Absorber (`absorber`) | 315 | 197 | 465 | 1.5 | Vileplume |
| Azote (`azote`) | 314 | 297 | 1165 | 3.7 | Goldeen, Seaking, Magikarp |
| Púas (`puas`) | 310 | 0 | 0 | 0.0 | Cloyster |
| Triataque (`triataque`) | 309 | 240 | 3532 | 11.4 | Doduo, Dodrio, Porygon |
| Giro Fuego (`giro_fuego`) | 297 | 249 | 1550 | 5.2 | Rapidash, Ponyta, Flareon, Moltres |
| Derribo (`derribo`) | 291 | 240 | 2489 | 8.6 | Ponyta, Rapidash, Seel, Growlithe |

