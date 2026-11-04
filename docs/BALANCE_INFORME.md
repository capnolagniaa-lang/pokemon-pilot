# Informe de balance (batería de peleas IA contra IA)

> **Generado** por `--autotest-balance` (2026-11-04). Ver cómo correrlo en `scripts/tests/balance_tests.gd`.
> Cada pelea: dos Pokémon con su habilidad, IA en Difícil, nivel 40, reglas del mundo, **los 4 que trae (últimos por nivel)**, emparejados por stats base (±60), cada pareja
> dos veces cambiando de lado. 2000 peleas en 1822 s (semilla 1). Con pocas peleas por especie los % varían mucho:
> mirar las que tienen 10 o más.

Empates por tiempo (60 s): 85 de 1000 (9%).

## Por especie (de más fuerte a más débil)

Daño hecho/recibido = de golpes (sin veneno ni quemaduras), en vidas enteras del rival/propias por pelea (1,0 = una vida). ⬆ = gana 65% o más, ⬇ = 35% o menos (con 10+ peleas).

| Pokémon | Habilidades | Stats base | Peleas | Victorias | % | Vida al ganar | Seg. por victoria | Daño hecho | Daño recibido | Empates |
|---|---|---|---|---|---|---|---|---|---|---|
| Vileplume ⬆ | Clorofila | 490 | 30 | 26 | 87% | 63% | 20.9 | 0.94 | 0.54 | 1 |
| Jolteon ⬆ | Absorbe Electricidad | 525 | 30 | 26 | 87% | 65% | 14.0 | 0.97 | 0.41 | 0 |
| Sandslash ⬆ | Velo Arena | 450 | 22 | 19 | 86% | 30% | 25.6 | 0.92 | 0.66 | 3 |
| Golbat ⬆ | Fuerza Mental | 455 | 26 | 22 | 85% | 57% | 16.9 | 0.97 | 0.52 | 0 |
| Raichu ⬆ | Electricidad Estática | 485 | 32 | 27 | 84% | 62% | 13.2 | 0.98 | 0.46 | 0 |
| Tentacruel ⬆ | Cuerpo Puro/Lodo Líquido | 515 | 28 | 23 | 82% | 63% | 13.0 | 0.83 | 0.46 | 0 |
| Zubat ⬆ | Fuerza Mental | 245 | 28 | 23 | 82% | 61% | 10.7 | 1.01 | 0.50 | 0 |
| Seel ⬆ | Sebo | 325 | 24 | 19 | 79% | 60% | 16.2 | 0.92 | 0.47 | 4 |
| Exeggcute ⬆ | Clorofila | 325 | 24 | 19 | 79% | 49% | 17.3 | 0.69 | 0.52 | 0 |
| Nidorino ⬆ | Punto Tóxico | 365 | 26 | 20 | 77% | 42% | 22.0 | 0.76 | 0.68 | 0 |
| Ekans ⬆ | Intimidación/Mudar | 288 | 24 | 18 | 75% | 38% | 17.8 | 0.90 | 0.83 | 0 |
| Dratini ⬆ | Mudar | 300 | 24 | 18 | 75% | 35% | 18.0 | 1.00 | 0.73 | 0 |
| Seaking ⬆ | Nado Rápido/Velo Agua | 450 | 28 | 21 | 75% | 36% | 17.9 | 1.04 | 0.72 | 0 |
| Snorlax ⬆ | Inmunidad/Sebo | 540 | 38 | 28 | 74% | 39% | 25.2 | 0.95 | 0.60 | 7 |
| Spearow ⬆ | Vista Lince | 262 | 34 | 25 | 74% | 60% | 7.8 | 0.92 | 0.53 | 0 |
| Bulbasaur ⬆ | Espesura | 318 | 26 | 19 | 73% | 55% | 15.3 | 0.86 | 0.69 | 0 |
| Magikarp ⬆ | Nado Rápido | 200 | 22 | 16 | 73% | 57% | 43.1 | 0.90 | 0.58 | 0 |
| Kangaskhan ⬆ | Madrugar | 490 | 22 | 16 | 73% | 41% | 16.0 | 0.97 | 0.63 | 0 |
| Blastoise ⬆ | Torrente | 530 | 18 | 13 | 72% | 52% | 21.5 | 0.89 | 0.62 | 0 |
| Moltres ⬆ | Presión | 580 | 18 | 13 | 72% | 41% | 16.4 | 0.81 | 0.62 | 0 |
| Geodude ⬆ | Cabeza Roca/Robustez | 300 | 18 | 13 | 72% | 62% | 11.2 | 0.86 | 0.53 | 1 |
| Vaporeon ⬆ | Absorbe Agua | 525 | 30 | 21 | 70% | 59% | 16.6 | 0.92 | 0.57 | 0 |
| Tentacool ⬆ | Cuerpo Puro/Lodo Líquido | 335 | 36 | 25 | 69% | 54% | 14.9 | 0.89 | 0.57 | 4 |
| Starmie ⬆ | Iluminación/Cura Natural | 520 | 26 | 18 | 69% | 42% | 26.9 | 0.85 | 0.73 | 1 |
| Onix ⬆ | Cabeza Roca/Robustez | 385 | 26 | 18 | 69% | 49% | 32.0 | 0.52 | 0.53 | 6 |
| Omastar ⬆ | Nado Rápido/Caparazón | 495 | 26 | 18 | 69% | 73% | 18.0 | 0.84 | 0.42 | 1 |
| Cubone ⬆ | Cabeza Roca/Pararrayos | 320 | 16 | 11 | 69% | 20% | 13.1 | 0.90 | 0.82 | 0 |
| Lickitung ⬆ | Ritmo Propio/Despiste | 385 | 22 | 15 | 68% | 59% | 27.7 | 0.91 | 0.32 | 5 |
| Staryu ⬆ | Iluminación/Cura Natural | 340 | 26 | 17 | 65% | 46% | 20.3 | 0.86 | 0.65 | 2 |
| Magmar ⬆ | Cuerpo Llama | 495 | 20 | 13 | 65% | 47% | 26.1 | 0.56 | 0.56 | 3 |
| Dewgong ⬆ | Sebo | 475 | 20 | 13 | 65% | 59% | 12.8 | 0.91 | 0.45 | 4 |
| Golem | Cabeza Roca/Robustez | 495 | 30 | 19 | 63% | 57% | 19.5 | 0.79 | 0.60 | 0 |
| Jigglypuff | Gran Encanto | 270 | 24 | 15 | 63% | 26% | 18.7 | 0.86 | 0.77 | 1 |
| Omanyte | Nado Rápido/Caparazón | 355 | 34 | 21 | 62% | 71% | 13.1 | 0.91 | 0.46 | 2 |
| Slowpoke | Despiste/Ritmo Propio | 315 | 36 | 22 | 61% | 65% | 32.3 | 0.94 | 0.39 | 9 |
| Weepinbell | Clorofila | 390 | 28 | 17 | 61% | 53% | 17.6 | 0.45 | 0.67 | 0 |
| Squirtle | Torrente | 314 | 22 | 13 | 59% | 26% | 31.2 | 0.87 | 0.83 | 0 |
| Charmeleon | Mar Llamas | 405 | 22 | 13 | 59% | 32% | 33.8 | 0.88 | 0.80 | 0 |
| Koffing | Levitación | 340 | 38 | 22 | 58% | 39% | 27.6 | 0.69 | 0.76 | 0 |
| Dragonair | Mudar | 420 | 26 | 15 | 58% | 33% | 22.5 | 1.27 | 0.74 | 5 |
| Venusaur | Espesura | 525 | 28 | 16 | 57% | 54% | 19.4 | 0.42 | 0.66 | 0 |
| Bellsprout | Clorofila | 300 | 28 | 16 | 57% | 59% | 8.1 | 0.86 | 0.67 | 0 |
| Pidgeotto | Vista Lince | 349 | 28 | 16 | 57% | 54% | 11.9 | 0.84 | 0.58 | 2 |
| Arbok | Intimidación/Mudar | 448 | 30 | 17 | 57% | 44% | 22.4 | 0.77 | 0.70 | 4 |
| Nidoqueen | Punto Tóxico | 505 | 30 | 17 | 57% | 35% | 17.7 | 0.68 | 0.69 | 0 |
| Seadra | Punto Tóxico | 440 | 32 | 18 | 56% | 62% | 15.1 | 0.93 | 0.54 | 5 |
| Rattata | Fuga/Agallas | 253 | 32 | 18 | 56% | 39% | 14.4 | 0.79 | 0.75 | 0 |
| Krabby | Corte Fuerte/Caparazón | 325 | 16 | 9 | 56% | 50% | 24.1 | 0.80 | 0.67 | 0 |
| Ninetales | Absorbe Fuego | 505 | 18 | 10 | 56% | 59% | 28.2 | 0.67 | 0.56 | 1 |
| Clefairy | Gran Encanto | 323 | 18 | 10 | 56% | 55% | 33.1 | 0.89 | 1.00 | 6 |
| Victreebel | Clorofila | 490 | 20 | 11 | 55% | 60% | 17.7 | 0.65 | 0.84 | 1 |
| Graveler | Cabeza Roca/Robustez | 390 | 24 | 13 | 54% | 78% | 9.8 | 0.71 | 0.47 | 2 |
| Flareon | Absorbe Fuego | 525 | 24 | 13 | 54% | 32% | 17.5 | 0.74 | 0.75 | 2 |
| Mr. Mime | Insonorizar | 460 | 26 | 14 | 54% | 27% | 16.7 | 0.92 | 0.83 | 2 |
| Magnemite | Imán/Robustez | 325 | 26 | 14 | 54% | 58% | 22.4 | 0.86 | 0.63 | 7 |
| Horsea | Nado Rápido | 295 | 26 | 14 | 54% | 37% | 17.2 | 0.83 | 0.79 | 0 |
| Fearow | Vista Lince | 442 | 28 | 15 | 54% | 46% | 9.8 | 0.77 | 0.74 | 1 |
| Arcanine | Intimidación/Absorbe Fuego | 555 | 28 | 15 | 54% | 72% | 12.8 | 0.77 | 0.58 | 0 |
| Machop | Agallas | 305 | 28 | 15 | 54% | 54% | 8.2 | 0.87 | 0.69 | 0 |
| Goldeen | Nado Rápido/Velo Agua | 320 | 30 | 16 | 53% | 28% | 16.5 | 0.79 | 0.77 | 0 |
| Psyduck | Humedad/Aclimatación | 320 | 30 | 16 | 53% | 46% | 21.3 | 0.91 | 0.70 | 2 |
| Dodrio | Fuga/Madrugar | 470 | 34 | 18 | 53% | 41% | 17.1 | 0.83 | 0.78 | 0 |
| Wigglytuff | Gran Encanto | 435 | 36 | 19 | 53% | 95% | 41.6 | 0.71 | 0.28 | 11 |
| Exeggutor | Clorofila | 530 | 36 | 19 | 53% | 55% | 18.9 | 0.79 | 0.68 | 2 |
| Nidoran♀ | Punto Tóxico | 275 | 28 | 14 | 50% | 28% | 25.3 | 0.68 | 0.86 | 0 |
| Eevee | Fuga | 325 | 28 | 14 | 50% | 40% | 20.9 | 0.82 | 0.72 | 0 |
| Dragonite | Fuerza Mental | 600 | 16 | 8 | 50% | 42% | 19.4 | 0.79 | 0.79 | 0 |
| Mew | Sincronía | 600 | 20 | 10 | 50% | 22% | 30.8 | 0.92 | 0.89 | 1 |
| Hypno | Insomnio | 483 | 30 | 15 | 50% | 35% | 20.7 | 0.58 | 0.74 | 2 |
| Zapdos | Presión | 580 | 18 | 9 | 50% | 76% | 9.4 | 0.78 | 0.60 | 0 |
| Machoke | Agallas | 405 | 24 | 12 | 50% | 45% | 14.3 | 0.73 | 0.73 | 0 |
| Nidorina | Punto Tóxico | 365 | 34 | 16 | 47% | 36% | 27.8 | 0.73 | 0.75 | 4 |
| Pidgey | Vista Lince | 251 | 34 | 16 | 47% | 68% | 9.8 | 0.87 | 0.61 | 2 |
| Doduo | Fuga/Madrugar | 310 | 34 | 16 | 47% | 46% | 9.7 | 0.77 | 0.75 | 0 |
| Growlithe | Intimidación/Absorbe Fuego | 350 | 32 | 15 | 47% | 45% | 10.6 | 0.64 | 0.77 | 0 |
| Charizard | Mar Llamas | 534 | 32 | 15 | 47% | 58% | 13.2 | 0.78 | 0.65 | 4 |
| Gloom | Clorofila | 395 | 30 | 14 | 47% | 32% | 23.8 | 0.56 | 0.78 | 6 |
| Tauros | Intimidación | 490 | 26 | 12 | 46% | 33% | 32.5 | 0.86 | 1.17 | 3 |
| Dugtrio | Velo Arena/Trampa Arena | 425 | 24 | 11 | 46% | 38% | 17.5 | 0.79 | 0.71 | 0 |
| Poliwrath | Absorbe Agua/Humedad | 510 | 24 | 11 | 46% | 50% | 17.0 | 0.75 | 0.72 | 0 |
| Oddish | Clorofila | 320 | 22 | 10 | 45% | 36% | 22.6 | 0.79 | 0.97 | 0 |
| Muk | Hedor/Viscosidad | 500 | 22 | 10 | 45% | 51% | 29.7 | 0.64 | 0.66 | 5 |
| Butterfree | Ojo Compuesto | 395 | 22 | 10 | 45% | 57% | 9.7 | 1.05 | 0.60 | 6 |
| Tangela | Clorofila | 435 | 22 | 10 | 45% | 57% | 19.4 | 0.99 | 0.74 | 0 |
| Abra | Sincronía/Fuerza Mental | 310 | 22 | 10 | 45% | 34% | 12.3 | 0.76 | 0.79 | 0 |
| Mankey | Espíritu Vital | 305 | 20 | 9 | 45% | 47% | 13.8 | 0.75 | 0.74 | 0 |
| Kadabra | Sincronía/Fuerza Mental | 400 | 34 | 15 | 44% | 61% | 24.2 | 0.73 | 1.90 | 8 |
| Ivysaur | Espesura | 405 | 32 | 14 | 44% | 42% | 27.3 | 0.83 | 0.79 | 2 |
| Drowzee | Insomnio | 328 | 32 | 14 | 44% | 46% | 21.7 | 0.58 | 0.69 | 3 |
| Charmander | Mar Llamas | 309 | 32 | 14 | 44% | 40% | 18.8 | 0.74 | 0.75 | 3 |
| Scyther | Enjambre | 500 | 24 | 10 | 42% | 59% | 14.3 | 0.80 | 0.72 | 0 |
| Primeape | Espíritu Vital | 455 | 24 | 10 | 42% | 60% | 9.3 | 0.70 | 0.70 | 0 |
| Gastly | Levitación | 310 | 30 | 12 | 40% | 71% | 16.1 | 0.73 | 0.79 | 15 |
| Electabuzz | Electricidad Estática | 490 | 28 | 11 | 39% | 52% | 24.3 | 0.80 | 0.69 | 1 |
| Gyarados | Intimidación | 540 | 26 | 10 | 38% | 40% | 30.9 | 0.74 | 0.81 | 3 |
| Gengar | Levitación | 500 | 16 | 6 | 38% | 77% | 27.0 | 0.71 | 0.53 | 7 |
| Aerodactyl | Cabeza Roca/Presión | 515 | 24 | 9 | 38% | 54% | 18.0 | 0.69 | 0.77 | 0 |
| Venomoth | Polvo Escudo | 450 | 24 | 9 | 38% | 29% | 30.6 | 0.91 | 0.95 | 0 |
| Beedrill | Enjambre | 395 | 24 | 9 | 38% | 51% | 15.1 | 0.78 | 0.76 | 0 |
| Rhyhorn | Pararrayos/Cabeza Roca | 345 | 24 | 9 | 38% | 45% | 23.5 | 0.67 | 0.73 | 1 |
| Alakazam | Sincronía/Fuerza Mental | 500 | 30 | 11 | 37% | 61% | 33.7 | 0.77 | 1.44 | 4 |
| Hitmonchan | Vista Lince | 455 | 28 | 10 | 36% | 47% | 15.3 | 0.74 | 0.81 | 0 |
| Magneton | Imán/Robustez | 465 | 34 | 12 | 35% | 60% | 26.0 | 0.59 | 0.76 | 2 |
| Weezing ⬇ | Levitación | 490 | 26 | 9 | 35% | 46% | 15.0 | 0.86 | 0.82 | 4 |
| Rhydon ⬇ | Pararrayos/Cabeza Roca | 485 | 32 | 11 | 34% | 41% | 16.6 | 0.51 | 0.75 | 5 |
| Electrode ⬇ | Insonorizar/Electricidad Estática | 490 | 36 | 12 | 33% | 26% | 25.9 | 0.97 | 0.82 | 2 |
| Kabutops ⬇ | Nado Rápido/Armadura Batalla | 495 | 22 | 7 | 32% | 51% | 33.4 | 0.74 | 0.67 | 9 |
| Pidgeot ⬇ | Vista Lince | 479 | 22 | 7 | 32% | 80% | 12.3 | 0.73 | 0.75 | 0 |
| Jynx ⬇ | Despiste | 455 | 38 | 12 | 32% | 36% | 12.9 | 0.56 | 0.87 | 0 |
| Parasect ⬇ | Efecto Espora | 405 | 32 | 10 | 31% | 53% | 27.8 | 0.63 | 0.79 | 2 |
| Golduck ⬇ | Humedad/Aclimatación | 500 | 32 | 10 | 31% | 38% | 30.9 | 0.79 | 0.88 | 6 |
| Diglett ⬇ | Velo Arena/Trampa Arena | 265 | 32 | 10 | 31% | 83% | 25.7 | 0.58 | 0.73 | 0 |
| Kingler ⬇ | Corte Fuerte/Caparazón | 475 | 26 | 8 | 31% | 39% | 26.3 | 0.69 | 0.86 | 0 |
| Grimer ⬇ | Hedor/Viscosidad | 325 | 20 | 6 | 30% | 45% | 28.1 | 0.50 | 0.80 | 1 |
| Kabuto ⬇ | Nado Rápido/Armadura Batalla | 355 | 40 | 12 | 30% | 56% | 23.9 | 0.67 | 0.72 | 7 |
| Poliwhirl ⬇ | Absorbe Agua/Humedad | 385 | 34 | 10 | 29% | 70% | 13.1 | 1.14 | 0.66 | 5 |
| Wartortle ⬇ | Torrente | 405 | 28 | 8 | 29% | 40% | 36.0 | 0.79 | 0.79 | 1 |
| Porygon ⬇ | Calco | 395 | 14 | 4 | 29% | 60% | 33.3 | 0.81 | 1.46 | 5 |
| Sandshrew ⬇ | Velo Arena | 300 | 28 | 8 | 29% | 22% | 28.4 | 0.60 | 0.89 | 3 |
| Nidoran♂ ⬇ | Punto Tóxico | 273 | 18 | 5 | 28% | 25% | 20.1 | 0.69 | 0.93 | 0 |
| Raticate ⬇ | Fuga/Agallas | 413 | 22 | 6 | 27% | 23% | 15.5 | 0.73 | 0.89 | 0 |
| Nidoking ⬇ | Punto Tóxico | 505 | 26 | 7 | 27% | 41% | 15.4 | 0.58 | 0.88 | 2 |
| Shellder ⬇ | Caparazón | 305 | 24 | 6 | 25% | 58% | 21.0 | 0.53 | 0.81 | 4 |
| Pikachu ⬇ | Electricidad Estática | 320 | 20 | 5 | 25% | 24% | 20.5 | 0.70 | 0.91 | 0 |
| Haunter ⬇ | Levitación | 405 | 24 | 6 | 25% | 75% | 20.1 | 0.64 | 0.90 | 16 |
| Articuno ⬇ | Presión | 580 | 28 | 7 | 25% | 33% | 28.9 | 0.51 | 0.80 | 0 |
| Caterpie ⬇ | Polvo Escudo | 195 | 24 | 6 | 25% | 97% | 51.1 | 0.70 | 0.69 | 1 |
| Machamp ⬇ | Agallas | 505 | 38 | 9 | 24% | 44% | 20.3 | 0.58 | 0.80 | 0 |
| Ditto ⬇ | Flexibilidad | 288 | 28 | 6 | 21% | 22% | 17.6 | 0.70 | 0.84 | 11 |
| Weedle ⬇ | Polvo Escudo | 195 | 14 | 3 | 21% | 73% | 46.0 | 0.34 | 0.71 | 2 |
| Lapras ⬇ | Absorbe Agua/Caparazón | 535 | 28 | 6 | 21% | 58% | 14.0 | 0.57 | 0.76 | 11 |
| Meowth ⬇ | Recogida | 290 | 40 | 8 | 20% | 32% | 9.9 | 0.64 | 0.88 | 1 |
| Persian ⬇ | Flexibilidad | 440 | 28 | 5 | 18% | 52% | 15.6 | 0.83 | 0.80 | 1 |
| Marowak ⬇ | Cabeza Roca/Pararrayos | 425 | 18 | 3 | 17% | 39% | 18.2 | 0.71 | 0.82 | 0 |
| Farfetch’d ⬇ | Vista Lince/Fuerza Mental | 377 | 30 | 5 | 17% | 29% | 18.7 | 0.64 | 0.91 | 2 |
| Venonat ⬇ | Ojo Compuesto | 305 | 24 | 4 | 17% | 38% | 22.3 | 0.56 | 1.01 | 1 |
| Clefable ⬇ | Gran Encanto | 483 | 30 | 5 | 17% | 57% | 20.8 | 0.56 | 0.91 | 1 |
| Rapidash ⬇ | Fuga/Absorbe Fuego | 500 | 24 | 3 | 13% | 66% | 20.1 | 0.45 | 0.88 | 1 |
| Voltorb ⬇ | Insonorizar/Electricidad Estática | 330 | 24 | 3 | 13% | 27% | 28.6 | 0.63 | 0.88 | 5 |
| Cloyster ⬇ | Caparazón | 525 | 26 | 3 | 12% | 25% | 44.6 | 0.00 | 0.89 | 2 |
| Hitmonlee ⬇ | Flexibilidad | 455 | 26 | 3 | 12% | 21% | 19.6 | 0.52 | 0.96 | 0 |
| Pinsir ⬇ | Corte Fuerte | 500 | 28 | 3 | 11% | 67% | 9.3 | 0.48 | 0.82 | 0 |
| Paras ⬇ | Efecto Espora | 285 | 32 | 3 | 9% | 69% | 12.6 | 0.36 | 1.01 | 0 |
| Poliwag ⬇ | Absorbe Agua/Humedad | 300 | 24 | 2 | 8% | 19% | 21.1 | 0.54 | 0.94 | 0 |
| Slowbro ⬇ | Despiste/Ritmo Propio | 490 | 26 | 2 | 8% | 86% | 48.5 | 0.51 | 0.39 | 21 |
| Ponyta ⬇ | Fuga/Absorbe Fuego | 410 | 16 | 1 | 6% | 31% | 17.7 | 0.49 | 0.93 | 0 |
| Kakuna ⬇ | Mudar | 205 | 22 | 0 | 0% | — | — | 0.00 | 0.68 | 9 |
| Metapod ⬇ | Mudar | 205 | 24 | 0 | 0% | — | — | 0.00 | 0.74 | 6 |
| Chansey ⬇ | Cura Natural/Dicha | 450 | 36 | 0 | 0% | — | — | 0.36 | 0.95 | 3 |
| Vulpix ⬇ | Absorbe Fuego | 299 | 30 | 0 | 0% | — | — | 0.46 | 0.98 | 1 |

## Por habilidad (la que le tocó en cada pelea)

| | Peleas | % de victorias |
|---|---|---|
| Absorbe Electricidad | 30 | 87% |
| Cuerpo Puro | 27 | 81% |
| Sebo | 61 | 74% |
| Inmunidad | 21 | 71% |
| Lodo Líquido | 37 | 70% |
| Iluminación | 20 | 70% |
| Cuerpo Llama | 20 | 65% |
| Velo Agua | 23 | 61% |
| Clorofila | 240 | 59% |
| Fuerza Mental | 128 | 59% |
| Nado Rápido | 151 | 58% |
| Espesura | 86 | 57% |
| Hedor | 23 | 57% |
| Madrugar | 59 | 54% |
| Robustez | 85 | 52% |
| Imán | 29 | 52% |
| Torrente | 68 | 50% |
| Punto Tóxico | 194 | 50% |
| Vista Lince | 185 | 49% |
| Cabeza Roca | 100 | 49% |
| Mar Llamas | 86 | 49% |
| Intimidación | 107 | 49% |
| Velo Arena | 85 | 47% |
| Insomnio | 62 | 47% |
| Cura Natural | 46 | 46% |
| Presión | 79 | 46% |
| Gran Encanto | 108 | 45% |
| Absorbe Agua | 80 | 45% |
| Electricidad Estática | 103 | 45% |
| Despiste | 86 | 44% |
| Espíritu Vital | 44 | 43% |
| Fuga | 107 | 43% |
| Mudar | 123 | 42% |
| Agallas | 116 | 41% |
| Insonorizar | 63 | 41% |
| Levitación | 134 | 41% |
| Sincronía | 67 | 40% |
| Enjambre | 48 | 40% |
| Pararrayos | 43 | 40% |
| Caparazón | 112 | 38% |
| Trampa Arena | 21 | 38% |
| Ritmo Propio | 36 | 36% |
| Aclimatación | 38 | 34% |
| Humedad | 71 | 34% |
| Absorbe Fuego | 124 | 33% |
| Ojo Compuesto | 46 | 30% |
| Polvo Escudo | 62 | 29% |
| Calco | 14 | 29% |
| Efecto Espora | 64 | 20% |
| Recogida | 40 | 20% |
| Corte Fuerte | 48 | 19% |
| Flexibilidad | 82 | 17% |
| Viscosidad | 19 | 16% |
| Armadura Batalla | 27 | 15% |
| Dicha | 22 | 0% |

## Por tipo (un Pokémon de dos tipos cuenta en los dos)

| | Especies | Peleas | % de victorias |
|---|---|---|---|
| Dragón | 3 | 66 | 62% |
| Planta | 14 | 390 | 52% |
| Veneno | 33 | 862 | 52% |
| Volador | 19 | 506 | 50% |
| Roca | 11 | 300 | 50% |
| Agua | 32 | 870 | 49% |
| Tierra | 14 | 350 | 48% |
| Eléctrico | 9 | 248 | 48% |
| Psíquico | 13 | 380 | 48% |
| Hada | 5 | 134 | 47% |
| Normal | 22 | 640 | 44% |
| Acero | 2 | 60 | 43% |
| Fuego | 12 | 296 | 42% |
| Lucha | 8 | 212 | 37% |
| Fantasma | 3 | 70 | 34% |
| Hielo | 5 | 140 | 29% |
| Bicho | 12 | 294 | 23% |

## Por ataque (los más usados)

Daño = %% de la vida del que lo recibe, sumado. Por uso = daño medio cada vez que se lanza (los de estado dan 0).

| Ataque | Usos | Golpes | Daño total | Por uso | Lo usan |
|---|---|---|---|---|---|
| Ácido (`acido`) | 2928 | 1993 | 12278 | 4.2 | Ekans, Oddish, Arbok, Tentacool +5 |
| Pistola Agua (`pistola_agua`) | 2457 | 1729 | 13175 | 5.4 | Seadra, Poliwhirl, Omanyte, Vaporeon +4 |
| Disparo Lodo (`disparo_lodo`) | 1845 | 1239 | 8556 | 4.6 | Krabby, Omanyte, Kabutops, Omastar +3 |
| Anulación (`anulacion`) | 1827 | 0 | 0 | 0.0 | Slowbro, Wigglytuff, Slowpoke, Lickitung |
| Mordisco (`mordisco`) | 1810 | 1460 | 10190 | 5.6 | Nidorina, Arcanine, Wartortle, Vaporeon +7 |
| Doble Bofetón (`doble_bofeton`) | 1785 | 1725 | 5072 | 2.8 | Wigglytuff, Jigglypuff, Jynx, Poliwhirl +4 |
| Confusión (`confusion`) | 1752 | 1122 | 8740 | 5.0 | Exeggutor, Psyduck, Exeggcute, Golduck +2 |
| Ataque Ala (`ataque_ala`) | 1524 | 1289 | 15004 | 9.8 | Scyther, Zubat, Pidgey, Pidgeot +7 |
| Placaje (`placaje`) | 1382 | 1246 | 4609 | 3.3 | Caterpie, Pidgeot, Electrode, Magikarp +1 |
| Rapidez (`rapidez`) | 1302 | 889 | 5314 | 4.1 | Staryu, Starmie, Sandslash, Sandshrew +4 |
| Persecución (`persecucion`) | 1217 | 1690 | 6823 | 5.6 | Rattata, Beedrill, Spearow, Dodrio +3 |
| Furia Dragón (`furia_dragon`) | 1151 | 891 | 6207 | 5.4 | Dragonite, Mew, Dratini, Gyarados +1 |
| Chispa (`chispa`) | 1101 | 882 | 7391 | 6.7 | Magneton, Electrode, Voltorb, Magnemite +1 |
| Hoja Afilada (`hoja_afilada`) | 1092 | 743 | 7280 | 6.7 | Bulbasaur, Jigglypuff, Bellsprout, Ivysaur +2 |
| Rayo Confuso (`rayo_confuso`) | 972 | 0 | 0 | 0.0 | Haunter, Zubat, Lapras, Starmie +5 |
| Residuos (`residuos`) | 961 | 676 | 6192 | 6.4 | Koffing, Weezing, Muk, Grimer |
| Tornado (`tornado`) | 932 | 652 | 4035 | 4.3 | Venomoth, Butterfree |
| Somnífero (`somnifero`) | 932 | 0 | 0 | 0.0 | Oddish, Gloom, Venonat, Ivysaur +3 |
| Agilidad (`agilidad`) | 930 | 0 | 0 | 0.0 | Beedrill, Articuno, Scyther, Pidgey +12 |
| Cuchillada (`cuchillada`) | 914 | 812 | 7642 | 8.4 | Parasect, Charmander, Paras, Dugtrio +7 |
| Impactrueno (`impactrueno`) | 878 | 671 | 5327 | 6.1 | Raichu, Jolteon, Zapdos, Mew |
| Protección (`proteccion`) | 869 | 0 | 0 | 0.0 | Cloyster, Wartortle, Squirtle, Omanyte +5 |
| Cornada (`cornada`) | 820 | 768 | 5716 | 7.0 | Nidorino, Goldeen, Seaking, Nidoran♂ |
| Ataque Rápido (`ataque_rapido`) | 816 | 595 | 3153 | 3.9 | Raichu, Vaporeon, Jolteon, Ninetales +3 |
| Reducción (`reduccion`) | 810 | 0 | 0 | 0.0 | Staryu, Muk, Clefable, Grimer +1 |
| Ronquido (`ronquido`) | 792 | 619 | 2862 | 3.6 | Snorlax, Mew |
| Arañazo (`aranazo`) | 782 | 647 | 2898 | 3.7 | Nidoqueen, Sandslash, Persian |
| Megaagotar (`megaagotar`) | 735 | 565 | 4011 | 5.5 | Vileplume, Tangela |
| Picotazo Veneno (`picotazo_veneno`) | 709 | 650 | 2257 | 3.2 | Nidoqueen, Nidorina, Nidorino, Nidoking +3 |
| Ascuas (`ascuas`) | 673 | 462 | 2878 | 4.3 | Arcanine, Ninetales, Flareon, Mew |
| Bofetón Lodo (`bofeton_lodo`) | 668 | 494 | 1817 | 2.7 | Dugtrio, Diglett, Ditto, Jigglypuff |
| Rodar (`rodar`) | 641 | 491 | 3584 | 5.6 | Golem, Geodude, Electrode, Voltorb +2 |
| Fortaleza (`fortaleza`) | 628 | 0 | 0 | 0.0 | Metapod, Onix, Kakuna, Pinsir |
| Paralizador (`paralizador`) | 623 | 0 | 0 | 0.0 | Parasect, Vileplume, Gloom, Bellsprout +6 |
| Psíquico (`psiquico`) | 599 | 454 | 8856 | 14.8 | Hypno, Slowpoke, Alakazam, Drowzee +2 |
| Pantalla de Humo (`pantalla_de_humo`) | 580 | 0 | 0 | 0.0 | Magmar, Seadra, Koffing, Charmander +3 |
| Rayo Aurora (`rayo_aurora`) | 574 | 426 | 2993 | 5.2 | Vaporeon, Seel, Shellder, Ditto |
| Golpe Cabeza (`golpe_cabeza`) | 546 | 486 | 4182 | 7.7 | Slowbro, Hypno, Slowpoke |
| Furia (`furia`) | 530 | 499 | 1653 | 3.1 | Onix, Kangaskhan, Doduo, Cubone +2 |
| Disparo Demora (`disparo_demora`) | 528 | 0 | 0 | 0.0 | Caterpie, Weedle |
| Azote (`azote`) | 524 | 487 | 1590 | 3.0 | Goldeen, Magikarp, Seaking |
| Rayo Burbuja (`rayo_burbuja`) | 522 | 783 | 3918 | 7.5 | Tentacool, Staryu, Tentacruel, Ditto |
| Giro Rápido (`giro_rapido`) | 500 | 461 | 2627 | 5.3 | Wartortle, Squirtle, Blastoise |
| Metrónomo (`metronomo`) | 500 | 0 | 0 | 0.0 | Clefairy, Clefable |
| Viento Hielo (`viento_hielo`) | 485 | 830 | 2781 | 5.7 | Seel, Dewgong, Ditto |
| Polución (`polucion`) | 484 | 295 | 1121 | 2.3 | Magmar |
| Recuperación (`recuperacion`) | 445 | 0 | 0 | 0.0 | Kadabra, Alakazam, Porygon, Starmie |
| Chirrido (`chirrido`) | 445 | 0 | 0 | 0.0 | Arbok, Psyduck, Meowth, Muk +5 |
| Nieve Polvo (`nieve_polvo`) | 442 | 443 | 2721 | 6.2 | Articuno, Jynx, Mew |
| Refuerzo (`refuerzo`) | 441 | 0 | 0 | 0.0 | Growlithe, Nidorina, Nidorino, Nidoran♀ +1 |
| Amnesia (`amnesia`) | 409 | 0 | 0 | 0.0 | Slowbro, Slowpoke |
| Golpe Cuerpo (`golpe_cuerpo`) | 406 | 365 | 4474 | 11.0 | Snorlax, Nidoqueen, Jigglypuff, Poliwhirl +2 |
| Aguante (`aguante`) | 402 | 0 | 0 | 0.0 | Kangaskhan, Kabuto, Kabutops, Moltres +1 |
| Constricción (`constriccion`) | 401 | 401 | 959 | 2.4 | Arbok, Lickitung, Mew, Dragonite +4 |
| Lanzallamas (`lanzallamas`) | 396 | 323 | 5094 | 12.9 | Vulpix, Charmander, Charmeleon, Charizard |
| Dragoaliento (`dragoaliento`) | 392 | 293 | 1038 | 2.6 | Onix |
| Atizar (`atizar`) | 379 | 318 | 3083 | 8.1 | Lickitung, Dragonite, Dratini, Dragonair +3 |
| Foco Energía (`foco_energia`) | 363 | 0 | 0 | 0.0 | Rattata, Nidoking, Mankey, Hitmonlee +2 |
| Malicioso (`malicioso`) | 363 | 0 | 0 | 0.0 | Magmar, Omanyte, Horsea, Omastar +5 |
| Cara Susto (`cara_susto`) | 362 | 0 | 0 | 0.0 | Charmander, Rhyhorn, Tauros, Charmeleon +4 |
| Velo Sagrado (`velo_sagrado`) | 361 | 0 | 0 | 0.0 | Vulpix, Ninetales, Butterfree |
| Polvo Veneno (`polvo_veneno`) | 353 | 0 | 0 | 0.0 | Weepinbell, Exeggcute, Venusaur, Ditto |
| Ataque Arena (`ataque_arena`) | 342 | 0 | 0 | 0.0 | Kabutops, Kabuto |
| Pantalla de Luz (`pantalla_de_luz`) | 336 | 0 | 0 | 0.0 | Voltorb, Electabuzz, Staryu, Ditto |
| Ciclón (`ciclon`) | 323 | 323 | 1549 | 4.8 | Seadra, Horsea, Dratini, Gyarados +1 |
| Sísmico (`sismico`) | 321 | 343 | 4472 | 13.9 | Machoke, Mankey, Machamp, Primeape |
| Fanfarronear (`fanfarronear`) | 318 | 0 | 0 | 0.0 | Tauros, Mankey |
| Refugio (`refugio`) | 301 | 0 | 0 | 0.0 | Slowbro, Cloyster |
| Psicorrayo (`psicorrayo`) | 298 | 1636 | 3622 | 12.2 | Mr. Mime, Venonat, Venomoth, Butterfree |
| Espora (`espora`) | 292 | 0 | 0 | 0.0 | Parasect, Paras |
| Golpes Furia (`golpes_furia`) | 286 | 267 | 644 | 2.3 | Psyduck, Diglett, Primeape, Dugtrio +4 |
| Fijar Blanco (`fijar_blanco`) | 281 | 0 | 0 | 0.0 | Magneton, Magnemite, Porygon, Ditto |
| Finta (`finta`) | 277 | 333 | 1782 | 6.4 | Meowth, Persian |
| Pisotón (`pisoton`) | 267 | 220 | 1730 | 6.5 | Lickitung, Exeggutor, Ponyta, Krabby +2 |
| Armadura Ácida (`armadura_acida`) | 262 | 0 | 0 | 0.0 | Muk, Grimer |
| Rizo Defensa (`rizo_defensa`) | 258 | 0 | 0 | 0.0 | Wigglytuff, Clefairy |
| Niebla (`niebla`) | 254 | 0 | 0 | 0.0 | Koffing, Weezing |
| Pedrada (`pedrada`) | 253 | 229 | 2123 | 8.4 | Rhydon, Rhyhorn, Geodude, Golem +1 |
| Picotazo (`picotazo`) | 251 | 244 | 1085 | 4.3 | Nidoking, Fearow |
| Hidrochorro (`hidrochorro`) | 248 | 246 | 1181 | 4.8 | Seaking, Golduck |

