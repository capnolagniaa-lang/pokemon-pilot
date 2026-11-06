# Informe de balance (batería de peleas IA contra IA)

> **Generado** por `--autotest-balance` (2026-11-06). Ver cómo correrlo en `scripts/tests/balance_tests.gd`.
> Cada pelea: dos Pokémon con su habilidad, IA en Difícil, nivel 40, reglas del mundo, **los que trae un rival (3 de daño y 1 de estado, los mejores que sabe)**, emparejados por stats base (±60), cada pareja
> dos veces cambiando de lado. 2000 peleas en 1931 s (semilla 311). Con pocas peleas por especie los % varían mucho:
> mirar las que tienen 10 o más.

Empates por tiempo (60 s): 20 de 1000 (2%).

## Por especie (de más fuerte a más débil)

Daño hecho/recibido = de golpes (sin veneno ni quemaduras), en vidas enteras del rival/propias por pelea (1,0 = una vida). ⬆ = gana 65% o más, ⬇ = 35% o menos (con 10+ peleas).

| Pokémon | Habilidades | Stats base | Peleas | Victorias | % | Vida al ganar | Seg. por victoria | Daño hecho | Daño recibido | Empates |
|---|---|---|---|---|---|---|---|---|---|---|
| Zubat ⬆ | Fuerza Mental | 245 | 32 | 31 | 97% | 72% | 7.8 | 0.99 | 0.30 | 0 |
| Exeggcute ⬆ | Clorofila | 325 | 30 | 28 | 93% | 63% | 15.5 | 0.81 | 0.39 | 0 |
| Hypno ⬆ | Insomnio | 483 | 24 | 22 | 92% | 60% | 19.0 | 0.92 | 0.44 | 0 |
| Dewgong ⬆ | Sebo | 475 | 30 | 26 | 87% | 57% | 14.2 | 0.97 | 0.49 | 0 |
| Kadabra ⬆ | Sincronía/Fuerza Mental | 400 | 40 | 34 | 85% | 48% | 8.6 | 0.96 | 0.63 | 0 |
| Exeggutor ⬆ | Clorofila | 530 | 26 | 22 | 85% | 54% | 13.7 | 0.96 | 0.53 | 0 |
| Magikarp ⬆ | Nado Rápido | 200 | 24 | 20 | 83% | 88% | 47.7 | 0.96 | 0.27 | 1 |
| Omanyte ⬆ | Nado Rápido/Caparazón | 355 | 32 | 26 | 81% | 47% | 14.9 | 1.01 | 0.59 | 0 |
| Slowbro ⬆ | Despiste/Ritmo Propio | 490 | 26 | 21 | 81% | 61% | 16.8 | 0.93 | 0.50 | 0 |
| Drowzee ⬆ | Insomnio | 328 | 20 | 16 | 80% | 41% | 13.6 | 0.86 | 0.64 | 0 |
| Porygon ⬆ | Calco | 395 | 20 | 16 | 80% | 55% | 11.8 | 0.98 | 0.54 | 0 |
| Shellder ⬆ | Caparazón | 305 | 24 | 19 | 79% | 63% | 10.7 | 0.98 | 0.49 | 0 |
| Victreebel ⬆ | Clorofila | 490 | 24 | 19 | 79% | 54% | 19.5 | 0.95 | 0.57 | 1 |
| Gloom ⬆ | Clorofila | 395 | 28 | 22 | 79% | 73% | 11.8 | 0.81 | 0.50 | 0 |
| Snorlax ⬆ | Inmunidad/Sebo | 540 | 32 | 25 | 78% | 42% | 17.4 | 0.92 | 0.66 | 0 |
| Dragonair ⬆ | Mudar | 420 | 26 | 20 | 77% | 42% | 18.0 | 0.96 | 0.64 | 2 |
| Poliwrath ⬆ | Absorbe Agua/Humedad | 510 | 30 | 23 | 77% | 48% | 20.1 | 0.92 | 0.62 | 0 |
| Seadra ⬆ | Punto Tóxico | 440 | 24 | 18 | 75% | 60% | 11.6 | 0.84 | 0.54 | 0 |
| Jolteon ⬆ | Absorbe Electricidad | 525 | 16 | 12 | 75% | 62% | 14.8 | 0.85 | 0.53 | 0 |
| Slowpoke ⬆ | Despiste/Ritmo Propio | 315 | 24 | 18 | 75% | 66% | 13.1 | 0.87 | 0.46 | 0 |
| Magmar ⬆ | Cuerpo Llama | 495 | 30 | 22 | 73% | 59% | 17.1 | 0.67 | 0.55 | 0 |
| Dratini ⬆ | Mudar | 300 | 26 | 19 | 73% | 44% | 10.5 | 0.94 | 0.65 | 0 |
| Zapdos ⬆ | Presión | 580 | 24 | 17 | 71% | 46% | 16.8 | 0.89 | 0.67 | 0 |
| Tentacruel ⬆ | Cuerpo Puro/Lodo Líquido | 515 | 32 | 22 | 69% | 56% | 16.7 | 0.83 | 0.62 | 0 |
| Squirtle ⬆ | Torrente | 314 | 22 | 15 | 68% | 42% | 14.5 | 0.91 | 0.69 | 0 |
| Butterfree ⬆ | Ojo Compuesto | 395 | 22 | 15 | 68% | 54% | 12.5 | 0.94 | 0.62 | 0 |
| Weepinbell ⬆ | Clorofila | 390 | 22 | 15 | 68% | 60% | 9.4 | 0.81 | 0.59 | 0 |
| Tentacool ⬆ | Cuerpo Puro/Lodo Líquido | 335 | 36 | 24 | 67% | 51% | 11.9 | 0.85 | 0.66 | 0 |
| Starmie ⬆ | Iluminación/Cura Natural | 520 | 24 | 16 | 67% | 59% | 18.7 | 0.82 | 0.60 | 0 |
| Oddish ⬆ | Clorofila | 320 | 30 | 20 | 67% | 50% | 15.8 | 0.89 | 0.81 | 0 |
| Machop ⬆ | Agallas | 305 | 36 | 24 | 67% | 53% | 6.7 | 0.85 | 0.64 | 1 |
| Omastar ⬆ | Nado Rápido/Caparazón | 495 | 26 | 17 | 65% | 43% | 18.3 | 0.85 | 0.70 | 0 |
| Charmander ⬆ | Mar Llamas | 309 | 26 | 17 | 65% | 49% | 12.4 | 0.74 | 0.68 | 0 |
| Raichu ⬆ | Electricidad Estática | 485 | 26 | 17 | 65% | 45% | 13.8 | 0.85 | 0.68 | 1 |
| Vileplume ⬆ | Clorofila | 490 | 20 | 13 | 65% | 47% | 26.9 | 0.92 | 0.78 | 2 |
| Seel | Sebo | 325 | 34 | 22 | 65% | 46% | 14.4 | 0.94 | 0.66 | 0 |
| Tauros | Intimidación | 490 | 34 | 22 | 65% | 44% | 13.3 | 0.95 | 0.73 | 1 |
| Haunter | Levitación | 405 | 22 | 14 | 64% | 62% | 12.6 | 0.80 | 0.55 | 4 |
| Venusaur | Espesura | 525 | 30 | 19 | 63% | 63% | 16.2 | 0.81 | 0.60 | 1 |
| Vaporeon | Absorbe Agua | 525 | 30 | 19 | 63% | 65% | 13.8 | 0.87 | 0.56 | 0 |
| Dragonite | Fuerza Mental | 600 | 16 | 10 | 63% | 26% | 21.4 | 0.87 | 0.84 | 0 |
| Grimer | Hedor/Viscosidad | 325 | 34 | 21 | 62% | 30% | 19.0 | 0.66 | 0.82 | 0 |
| Beedrill | Enjambre | 395 | 26 | 16 | 62% | 46% | 13.2 | 0.80 | 0.69 | 2 |
| Mr. Mime | Insonorizar | 460 | 26 | 16 | 62% | 45% | 14.4 | 0.95 | 0.70 | 0 |
| Vulpix | Absorbe Fuego | 299 | 36 | 22 | 61% | 47% | 11.3 | 0.81 | 0.70 | 1 |
| Kabuto | Nado Rápido/Armadura Batalla | 355 | 28 | 17 | 61% | 45% | 17.3 | 0.87 | 0.78 | 0 |
| Blastoise | Torrente | 530 | 28 | 17 | 61% | 61% | 15.3 | 0.84 | 0.59 | 0 |
| Muk | Hedor/Viscosidad | 500 | 30 | 18 | 60% | 34% | 20.0 | 0.76 | 0.78 | 0 |
| Machoke | Agallas | 405 | 30 | 18 | 60% | 58% | 7.2 | 0.83 | 0.59 | 0 |
| Ivysaur | Espesura | 405 | 32 | 19 | 59% | 56% | 11.1 | 0.88 | 0.61 | 2 |
| Aerodactyl | Cabeza Roca/Presión | 515 | 22 | 13 | 59% | 55% | 16.1 | 0.85 | 0.60 | 0 |
| Golduck | Humedad/Aclimatación | 500 | 22 | 13 | 59% | 35% | 23.7 | 0.84 | 0.74 | 0 |
| Staryu | Iluminación/Cura Natural | 340 | 24 | 14 | 58% | 59% | 12.6 | 0.79 | 0.68 | 0 |
| Jigglypuff | Gran Encanto | 270 | 24 | 14 | 58% | 27% | 17.0 | 0.84 | 0.98 | 2 |
| Mankey | Espíritu Vital | 305 | 38 | 22 | 58% | 51% | 7.7 | 0.84 | 0.67 | 0 |
| Alakazam | Sincronía/Fuerza Mental | 500 | 26 | 15 | 58% | 57% | 16.1 | 0.85 | 0.72 | 0 |
| Horsea | Nado Rápido | 295 | 28 | 16 | 57% | 55% | 11.1 | 0.89 | 0.64 | 0 |
| Magnemite | Imán/Robustez | 325 | 28 | 16 | 57% | 51% | 10.9 | 0.82 | 0.63 | 0 |
| Geodude | Cabeza Roca/Robustez | 300 | 28 | 16 | 57% | 66% | 10.2 | 0.81 | 0.57 | 0 |
| Charmeleon | Mar Llamas | 405 | 32 | 18 | 56% | 39% | 15.1 | 0.79 | 0.77 | 0 |
| Graveler | Cabeza Roca/Robustez | 390 | 32 | 18 | 56% | 66% | 16.3 | 0.79 | 0.62 | 0 |
| Articuno | Presión | 580 | 16 | 9 | 56% | 50% | 20.9 | 0.90 | 0.67 | 0 |
| Koffing | Levitación | 340 | 20 | 11 | 55% | 49% | 21.5 | 0.77 | 0.73 | 0 |
| Onix | Cabeza Roca/Robustez | 385 | 20 | 11 | 55% | 44% | 16.4 | 0.74 | 0.68 | 0 |
| Machamp | Agallas | 505 | 22 | 12 | 55% | 57% | 9.6 | 0.75 | 0.66 | 0 |
| Weezing | Levitación | 490 | 24 | 13 | 54% | 55% | 23.3 | 0.74 | 0.70 | 0 |
| Moltres | Presión | 580 | 26 | 14 | 54% | 43% | 15.8 | 0.75 | 0.75 | 0 |
| Charizard | Mar Llamas | 534 | 30 | 16 | 53% | 30% | 18.2 | 0.76 | 0.82 | 0 |
| Bulbasaur | Espesura | 318 | 30 | 16 | 53% | 53% | 14.2 | 0.83 | 0.79 | 1 |
| Gastly | Levitación | 310 | 32 | 17 | 53% | 75% | 8.1 | 1.02 | 0.57 | 2 |
| Pidgey | Vista Lince | 251 | 36 | 19 | 53% | 72% | 8.2 | 0.72 | 0.61 | 0 |
| Nidoran♀ | Punto Tóxico | 275 | 18 | 9 | 50% | 31% | 24.1 | 0.75 | 0.82 | 1 |
| Doduo | Fuga/Madrugar | 310 | 32 | 16 | 50% | 44% | 7.8 | 0.81 | 0.73 | 0 |
| Tangela | Clorofila | 435 | 30 | 15 | 50% | 69% | 12.5 | 0.77 | 0.65 | 0 |
| Wartortle | Torrente | 405 | 20 | 10 | 50% | 70% | 10.2 | 0.76 | 0.62 | 0 |
| Arcanine | Intimidación/Absorbe Fuego | 555 | 24 | 12 | 50% | 47% | 15.7 | 0.73 | 0.66 | 0 |
| Golem | Cabeza Roca/Robustez | 495 | 26 | 13 | 50% | 86% | 9.5 | 0.71 | 0.57 | 0 |
| Golbat | Fuerza Mental | 455 | 26 | 13 | 50% | 64% | 12.5 | 0.73 | 0.68 | 0 |
| Rattata | Fuga/Agallas | 253 | 32 | 16 | 50% | 61% | 11.3 | 0.74 | 0.68 | 1 |
| Magneton | Imán/Robustez | 465 | 26 | 13 | 50% | 59% | 16.0 | 0.77 | 0.64 | 3 |
| Gyarados | Intimidación | 540 | 28 | 14 | 50% | 29% | 21.1 | 0.76 | 0.82 | 0 |
| Cloyster | Caparazón | 525 | 34 | 16 | 47% | 53% | 15.8 | 0.55 | 0.72 | 0 |
| Paras | Efecto Espora | 285 | 34 | 16 | 47% | 43% | 12.5 | 0.55 | 0.84 | 0 |
| Seaking | Nado Rápido/Velo Agua | 450 | 28 | 13 | 46% | 47% | 17.1 | 0.71 | 0.76 | 0 |
| Lapras | Absorbe Agua/Caparazón | 535 | 26 | 12 | 46% | 38% | 30.5 | 0.83 | 0.74 | 0 |
| Rhydon | Pararrayos/Cabeza Roca | 485 | 26 | 12 | 46% | 46% | 22.6 | 0.52 | 0.67 | 2 |
| Psyduck | Humedad/Aclimatación | 320 | 22 | 10 | 45% | 36% | 13.9 | 0.82 | 0.81 | 0 |
| Pidgeot | Vista Lince | 479 | 22 | 10 | 45% | 34% | 16.6 | 0.75 | 0.83 | 0 |
| Nidoqueen | Punto Tóxico | 505 | 22 | 10 | 45% | 55% | 18.8 | 0.59 | 0.74 | 0 |
| Gengar | Levitación | 500 | 22 | 10 | 45% | 80% | 10.8 | 0.78 | 0.60 | 2 |
| Ninetales | Absorbe Fuego | 505 | 38 | 17 | 45% | 38% | 18.8 | 0.58 | 0.79 | 0 |
| Goldeen | Nado Rápido/Velo Agua | 320 | 18 | 8 | 44% | 35% | 22.3 | 0.76 | 0.75 | 0 |
| Arbok | Intimidación/Mudar | 448 | 34 | 15 | 44% | 36% | 17.5 | 0.72 | 0.82 | 0 |
| Nidoking | Punto Tóxico | 505 | 16 | 7 | 44% | 28% | 14.2 | 0.58 | 0.88 | 0 |
| Pidgeotto | Vista Lince | 349 | 32 | 14 | 44% | 34% | 11.9 | 0.80 | 0.78 | 0 |
| Venomoth | Polvo Escudo | 450 | 28 | 12 | 43% | 63% | 13.7 | 0.79 | 0.72 | 2 |
| Clefairy | Gran Encanto | 323 | 28 | 12 | 43% | 39% | 25.7 | 0.80 | 1.12 | 0 |
| Bellsprout | Clorofila | 300 | 26 | 11 | 42% | 60% | 8.7 | 0.70 | 0.74 | 0 |
| Fearow | Vista Lince | 442 | 24 | 10 | 42% | 49% | 11.1 | 0.69 | 0.77 | 0 |
| Cubone | Cabeza Roca/Pararrayos | 320 | 24 | 10 | 42% | 45% | 13.0 | 0.78 | 0.74 | 0 |
| Flareon | Absorbe Fuego | 525 | 22 | 9 | 41% | 48% | 15.8 | 0.73 | 0.76 | 0 |
| Electabuzz | Electricidad Estática | 490 | 22 | 9 | 41% | 54% | 19.6 | 0.77 | 0.70 | 3 |
| Sandshrew | Velo Arena | 300 | 20 | 8 | 40% | 38% | 22.6 | 0.54 | 0.81 | 0 |
| Dodrio | Fuga/Madrugar | 470 | 28 | 11 | 39% | 36% | 19.3 | 0.66 | 0.85 | 0 |
| Venonat | Ojo Compuesto | 305 | 26 | 10 | 38% | 48% | 22.9 | 0.80 | 0.84 | 0 |
| Growlithe | Intimidación/Absorbe Fuego | 350 | 24 | 9 | 38% | 20% | 11.5 | 0.68 | 0.85 | 1 |
| Farfetch’d | Vista Lince/Fuerza Mental | 377 | 24 | 9 | 38% | 45% | 16.6 | 0.62 | 0.77 | 0 |
| Nidorino | Punto Tóxico | 365 | 38 | 14 | 37% | 33% | 17.9 | 0.54 | 0.87 | 0 |
| Nidorina | Punto Tóxico | 365 | 34 | 12 | 35% | 29% | 19.9 | 0.48 | 0.88 | 0 |
| Wigglytuff ⬇ | Gran Encanto | 435 | 46 | 16 | 35% | 69% | 45.7 | 0.59 | 0.56 | 17 |
| Pikachu ⬇ | Electricidad Estática | 320 | 26 | 9 | 35% | 40% | 12.9 | 0.76 | 0.82 | 0 |
| Primeape ⬇ | Espíritu Vital | 455 | 26 | 9 | 35% | 52% | 7.1 | 0.66 | 0.79 | 1 |
| Spearow ⬇ | Vista Lince | 262 | 32 | 11 | 34% | 47% | 12.0 | 0.70 | 0.84 | 1 |
| Hitmonlee ⬇ | Flexibilidad | 455 | 38 | 13 | 34% | 48% | 6.2 | 0.75 | 0.83 | 0 |
| Caterpie ⬇ | Polvo Escudo | 195 | 18 | 6 | 33% | 77% | 51.3 | 0.63 | 0.60 | 2 |
| Ponyta ⬇ | Fuga/Absorbe Fuego | 410 | 22 | 7 | 32% | 52% | 16.5 | 0.63 | 0.80 | 1 |
| Nidoran♂ ⬇ | Punto Tóxico | 273 | 16 | 5 | 31% | 13% | 16.4 | 0.41 | 0.94 | 0 |
| Krabby ⬇ | Corte Fuerte/Caparazón | 325 | 26 | 8 | 31% | 44% | 10.2 | 0.53 | 0.85 | 0 |
| Ekans ⬇ | Intimidación/Mudar | 288 | 24 | 7 | 29% | 31% | 20.1 | 0.68 | 1.06 | 0 |
| Parasect ⬇ | Efecto Espora | 405 | 28 | 8 | 29% | 49% | 21.0 | 0.58 | 0.90 | 1 |
| Raticate ⬇ | Fuga/Agallas | 413 | 22 | 6 | 27% | 28% | 15.0 | 0.76 | 0.86 | 0 |
| Kangaskhan ⬇ | Madrugar | 490 | 22 | 6 | 27% | 31% | 18.5 | 0.71 | 0.88 | 1 |
| Dugtrio ⬇ | Velo Arena/Trampa Arena | 425 | 26 | 7 | 27% | 56% | 8.7 | 0.48 | 0.84 | 0 |
| Marowak ⬇ | Cabeza Roca/Pararrayos | 425 | 20 | 5 | 25% | 32% | 18.0 | 0.49 | 0.90 | 0 |
| Rapidash ⬇ | Fuga/Absorbe Fuego | 500 | 28 | 7 | 25% | 29% | 17.8 | 0.47 | 0.89 | 0 |
| Rhyhorn ⬇ | Pararrayos/Cabeza Roca | 345 | 24 | 6 | 25% | 61% | 17.8 | 0.38 | 0.73 | 0 |
| Poliwhirl ⬇ | Absorbe Agua/Humedad | 385 | 26 | 6 | 23% | 66% | 13.5 | 0.63 | 0.79 | 0 |
| Electrode ⬇ | Insonorizar/Electricidad Estática | 490 | 26 | 6 | 23% | 27% | 17.5 | 0.53 | 0.91 | 0 |
| Sandslash ⬇ | Velo Arena | 450 | 40 | 9 | 23% | 35% | 15.3 | 0.54 | 0.87 | 0 |
| Abra ⬇ | Sincronía/Fuerza Mental | 310 | 24 | 5 | 21% | 34% | 10.5 | 0.66 | 0.89 | 0 |
| Eevee ⬇ | Fuga | 325 | 24 | 5 | 21% | 45% | 13.5 | 0.66 | 0.88 | 0 |
| Pinsir ⬇ | Corte Fuerte | 500 | 34 | 7 | 21% | 74% | 7.9 | 0.57 | 0.81 | 0 |
| Diglett ⬇ | Velo Arena/Trampa Arena | 265 | 30 | 6 | 20% | 72% | 21.6 | 0.42 | 0.85 | 0 |
| Kingler ⬇ | Corte Fuerte/Caparazón | 475 | 22 | 4 | 18% | 36% | 16.2 | 0.41 | 0.89 | 0 |
| Ditto ⬇ | Flexibilidad | 288 | 22 | 4 | 18% | 34% | 12.1 | 0.55 | 0.91 | 0 |
| Lickitung ⬇ | Ritmo Propio/Despiste | 385 | 24 | 4 | 17% | 55% | 16.5 | 0.58 | 0.83 | 0 |
| Scyther ⬇ | Enjambre | 500 | 30 | 5 | 17% | 43% | 11.8 | 0.46 | 0.91 | 0 |
| Voltorb ⬇ | Insonorizar/Electricidad Estática | 330 | 26 | 4 | 15% | 33% | 10.8 | 0.51 | 0.88 | 0 |
| Poliwag ⬇ | Absorbe Agua/Humedad | 300 | 36 | 5 | 14% | 38% | 20.1 | 0.67 | 0.92 | 0 |
| Mew ⬇ | Sincronía | 600 | 18 | 2 | 11% | 18% | 31.5 | 0.73 | 0.97 | 0 |
| Persian ⬇ | Flexibilidad | 440 | 28 | 3 | 11% | 71% | 11.2 | 0.63 | 0.88 | 0 |
| Hitmonchan ⬇ | Vista Lince | 455 | 20 | 2 | 10% | 14% | 10.7 | 0.48 | 0.97 | 0 |
| Chansey ⬇ | Cura Natural/Dicha | 450 | 36 | 3 | 8% | 39% | 50.2 | 0.33 | 1.17 | 7 |
| Kabutops ⬇ | Nado Rápido/Armadura Batalla | 495 | 20 | 1 | 5% | 23% | 18.5 | 0.46 | 0.94 | 0 |
| Meowth ⬇ | Recogida | 290 | 22 | 1 | 5% | 14% | 9.4 | 0.48 | 0.94 | 0 |
| Clefable ⬇ | Gran Encanto | 483 | 22 | 1 | 5% | 0% | 33.3 | 0.43 | 0.94 | 0 |
| Metapod ⬇ | Mudar | 205 | 20 | 0 | 0% | — | — | 0.00 | 0.90 | 2 |
| Jynx ⬇ | Despiste | 455 | 26 | 0 | 0% | — | — | 0.37 | 0.96 | 0 |
| Kakuna ⬇ | Mudar | 205 | 30 | 0 | 0% | — | — | 0.00 | 0.90 | 6 |
| Weedle ⬇ | Polvo Escudo | 195 | 16 | 0 | 0% | — | — | 0.20 | 0.88 | 2 |

## Por habilidad (la que le tocó en cada pelea)

| | Peleas | % de victorias |
|---|---|---|
| Insomnio | 44 | 86% |
| Calco | 20 | 80% |
| Sebo | 80 | 76% |
| Absorbe Electricidad | 16 | 75% |
| Inmunidad | 16 | 75% |
| Cuerpo Llama | 30 | 73% |
| Lodo Líquido | 36 | 72% |
| Iluminación | 24 | 71% |
| Clorofila | 236 | 70% |
| Viscosidad | 34 | 68% |
| Fuerza Mental | 128 | 64% |
| Cuerpo Puro | 32 | 63% |
| Ritmo Propio | 45 | 62% |
| Torrente | 70 | 60% |
| Espesura | 92 | 59% |
| Presión | 79 | 58% |
| Mar Llamas | 88 | 58% |
| Caparazón | 128 | 58% |
| Nado Rápido | 126 | 56% |
| Agallas | 114 | 56% |
| Imán | 25 | 56% |
| Levitación | 120 | 54% |
| Hedor | 30 | 53% |
| Cabeza Roca | 112 | 53% |
| Ojo Compuesto | 48 | 52% |
| Velo Agua | 25 | 52% |
| Robustez | 83 | 52% |
| Aclimatación | 20 | 50% |
| Sincronía | 66 | 48% |
| Espíritu Vital | 64 | 48% |
| Absorbe Agua | 87 | 48% |
| Intimidación | 107 | 46% |
| Absorbe Fuego | 158 | 45% |
| Punto Tóxico | 168 | 45% |
| Humedad | 70 | 43% |
| Insonorizar | 53 | 42% |
| Mudar | 133 | 41% |
| Vista Lince | 178 | 40% |
| Electricidad Estática | 99 | 39% |
| Armadura Batalla | 23 | 39% |
| Efecto Espora | 62 | 39% |
| Madrugar | 53 | 38% |
| Cura Natural | 40 | 38% |
| Enjambre | 56 | 38% |
| Gran Encanto | 120 | 36% |
| Fuga | 99 | 35% |
| Velo Arena | 88 | 30% |
| Polvo Escudo | 62 | 29% |
| Despiste | 55 | 27% |
| Pararrayos | 43 | 26% |
| Flexibilidad | 88 | 23% |
| Corte Fuerte | 57 | 19% |
| Trampa Arena | 28 | 14% |
| Dicha | 20 | 5% |
| Recogida | 22 | 5% |

## Por tipo (un Pokémon de dos tipos cuenta en los dos)

| | Especies | Peleas | % de victorias |
|---|---|---|---|
| Dragón | 3 | 68 | 72% |
| Psíquico | 13 | 334 | 64% |
| Planta | 14 | 390 | 62% |
| Agua | 32 | 854 | 57% |
| Fantasma | 3 | 76 | 54% |
| Acero | 2 | 54 | 54% |
| Veneno | 33 | 880 | 53% |
| Roca | 11 | 284 | 53% |
| Lucha | 8 | 240 | 51% |
| Volador | 19 | 502 | 51% |
| Fuego | 12 | 338 | 50% |
| Hielo | 5 | 132 | 48% |
| Eléctrico | 9 | 220 | 47% |
| Hada | 5 | 146 | 40% |
| Normal | 22 | 618 | 39% |
| Tierra | 14 | 354 | 39% |
| Bicho | 12 | 312 | 30% |

## Por ataque (los más usados)

Daño = %% de la vida del que lo recibe, sumado. Por uso = daño medio cada vez que se lanza (los de estado dan 0).

| Ataque | Usos | Golpes | Daño total | Por uso | Lo usan |
|---|---|---|---|---|---|
| Placaje (`placaje`) | 2916 | 2478 | 10357 | 3.6 | Ivysaur, Weezing, Pidgey, Venonat +19 |
| Confusión (`confusion`) | 2662 | 1872 | 17698 | 6.6 | Slowbro, Mr. Mime, Hypno, Alakazam +10 |
| Pistola Agua (`pistola_agua`) | 2466 | 1729 | 13960 | 5.7 | Slowbro, Seadra, Horsea, Staryu +11 |
| Mordisco (`mordisco`) | 2097 | 1557 | 12841 | 6.1 | Aerodactyl, Meowth, Golbat, Eevee +16 |
| Doble Bofetón (`doble_bofeton`) | 2031 | 1875 | 5657 | 2.8 | Wigglytuff, Chansey, Mr. Mime, Jynx +6 |
| Ascuas (`ascuas`) | 1932 | 1228 | 8765 | 4.5 | Magmar, Charizard, Moltres, Vulpix +6 |
| Ataque Furia (`ataque_furia`) | 1500 | 1406 | 4482 | 3.0 | Fearow, Rhydon, Rapidash, Seaking +10 |
| Ataque Ala (`ataque_ala`) | 1335 | 1074 | 13561 | 10.2 | Zubat, Moltres, Charizard, Aerodactyl +5 |
| Burbuja (`burbuja`) | 1253 | 829 | 6687 | 5.3 | Seadra, Poliwag, Horsea, Squirtle +4 |
| Ácido (`acido`) | 1215 | 793 | 5908 | 4.9 | Gloom, Oddish, Arbok, Bellsprout +3 |
| Destructor (`destructor`) | 1192 | 1107 | 5343 | 4.5 | Chansey, Hypno, Jynx, Grimer +6 |
| Ataque Rápido (`ataque_rapido`) | 1180 | 957 | 5959 | 5.1 | Raticate, Rattata, Vulpix, Pidgey +8 |
| Impactrueno (`impactrueno`) | 1111 | 804 | 7174 | 6.5 | Raichu, Pikachu, Magneton, Magnemite +2 |
| Arañazo (`aranazo`) | 1088 | 787 | 4729 | 4.3 | Parasect, Paras, Kabuto, Persian +5 |
| Picotazo (`picotazo`) | 1053 | 973 | 6975 | 6.6 | Fearow, Seaking, Spearow, Doduo +8 |
| Hoja Afilada (`hoja_afilada`) | 970 | 712 | 5954 | 6.1 | Victreebel, Ivysaur, Venusaur, Bulbasaur +1 |
| Rayo Burbuja (`rayo_burbuja`) | 894 | 1071 | 5597 | 6.3 | Staryu, Tentacool, Tentacruel |
| Anulación (`anulacion`) | 843 | 0 | 0 | 0.0 | Wigglytuff |
| Látigo Cepa (`latigo_cepa`) | 835 | 629 | 5552 | 6.6 | Victreebel, Ivysaur, Venusaur, Tangela +3 |
| Residuos (`residuos`) | 814 | 524 | 4013 | 4.9 | Weezing, Grimer, Ditto, Koffing +1 |
| Lanzarrocas (`lanzarrocas`) | 756 | 418 | 5075 | 6.7 | Onix, Graveler, Geodude, Golem |
| Picotazo Veneno (`picotazo_veneno`) | 754 | 665 | 2662 | 3.5 | Weedle, Sandshrew, Arbok, Ekans +9 |
| Viento Hielo (`viento_hielo`) | 752 | 1090 | 5418 | 7.2 | Seel, Dewgong |
| Disparo Lodo (`disparo_lodo`) | 624 | 441 | 3845 | 6.2 | Kabuto, Omastar, Omanyte |
| Golpes Furia (`golpes_furia`) | 622 | 572 | 1604 | 2.6 | Sandshrew, Meowth, Nidorina, Diglett +3 |
| Megaagotar (`megaagotar`) | 622 | 461 | 3108 | 5.0 | Tangela, Vileplume |
| Golpe Kárate (`golpe_karate`) | 622 | 598 | 6122 | 9.8 | Machoke, Machop, Mankey, Primeape +1 |
| Fortaleza (`fortaleza`) | 569 | 0 | 0 | 0.0 | Kakuna, Pinsir, Metapod |
| Cuchillada (`cuchillada`) | 536 | 489 | 4868 | 9.1 | Parasect, Paras, Meowth, Sandshrew +7 |
| Rayo Aurora (`rayo_aurora`) | 479 | 354 | 3180 | 6.6 | Cloyster, Shellder, Vaporeon, Dewgong |
| Rayo Confuso (`rayo_confuso`) | 478 | 0 | 0 | 0.0 | Golbat, Haunter, Lapras, Ninetales +3 |
| Azote (`azote`) | 463 | 454 | 934 | 2.0 | Magikarp |
| Atizar (`atizar`) | 460 | 407 | 4341 | 9.4 | Tangela, Pikachu, Dratini, Dragonair +2 |
| Chispa (`chispa`) | 455 | 315 | 3330 | 7.3 | Voltorb, Electrode, Magneton, Magnemite |
| Golpe Cuerpo (`golpe_cuerpo`) | 450 | 351 | 3848 | 8.6 | Poliwag, Poliwhirl, Lapras, Snorlax +2 |
| Tornado (`tornado`) | 447 | 260 | 1696 | 3.8 | Butterfree, Articuno, Venomoth |
| Furia Dragón (`furia_dragon`) | 440 | 335 | 2825 | 6.4 | Dratini, Dragonair, Dragonite |
| Disparo Demora (`disparo_demora`) | 435 | 0 | 0 | 0.0 | Weedle, Caterpie |
| Absorber (`absorber`) | 431 | 277 | 1694 | 3.9 | Gloom, Kabuto, Oddish, Vileplume |
| Rapidez (`rapidez`) | 416 | 292 | 2447 | 5.9 | Staryu, Magnemite, Starmie, Electabuzz |
| Metrónomo (`metronomo`) | 406 | 0 | 0 | 0.0 | Clefable, Clefairy, Mew |
| Rizo Defensa (`rizo_defensa`) | 395 | 0 | 0 | 0.0 | Wigglytuff |
| Pisotón (`pisoton`) | 370 | 331 | 3191 | 8.6 | Rapidash, Kingler, Lickitung, Ponyta +4 |
| Psíquico (`psiquico`) | 354 | 254 | 4683 | 13.2 | Hypno, Alakazam, Slowpoke, Kadabra +3 |
| Cornada (`cornada`) | 339 | 300 | 3133 | 9.2 | Seaking, Tauros |
| Polución (`polucion`) | 335 | 206 | 856 | 2.6 | Magmar, Weezing, Ditto, Koffing |
| Pin Misil (`pin_misil`) | 317 | 564 | 1871 | 5.9 | Beedrill, Jolteon |
| Hipnosis (`hipnosis`) | 314 | 0 | 0 | 0.0 | Poliwag, Poliwhirl, Poliwrath, Exeggutor |
| Sísmico (`sismico`) | 304 | 321 | 4268 | 14.0 | Machoke, Mankey, Machop, Primeape +2 |
| Gas Venenoso (`gas_venenoso`) | 258 | 0 | 0 | 0.0 | Hypno, Grimer, Ditto, Muk +1 |
| Tinieblas (`tinieblas`) | 254 | 177 | 2724 | 10.7 | Haunter, Gengar, Gastly, Ditto |
| Pico Taladro (`pico_taladro`) | 239 | 220 | 4090 | 17.1 | Fearow, Spearow, Doduo |
| Ataque Arena (`ataque_arena`) | 222 | 0 | 0 | 0.0 | Sandshrew, Kabutops, Kabuto, Vaporeon +4 |
| Paralizador (`paralizador`) | 213 | 0 | 0 | 0.0 | Parasect, Gloom, Venonat, Venomoth +2 |
| Lanzallamas (`lanzallamas`) | 203 | 1031 | 3431 | 16.9 | Vulpix, Charmeleon |
| Magnitud (`magnitud`) | 200 | 197 | 3005 | 15.0 | Dugtrio, Diglett, Graveler, Geodude +1 |
| Derribo (`derribo`) | 195 | 149 | 1621 | 8.3 | Rapidash, Seel, Ponyta, Growlithe |
| Ciclón (`ciclon`) | 192 | 194 | 1211 | 6.3 | Seadra, Horsea, Dratini, Dragonair +1 |
| Comesueños (`comesuenos`) | 183 | 151 | 2628 | 14.4 | Haunter, Gengar, Gastly, Ditto |
| Psicorrayo (`psicorrayo`) | 178 | 939 | 2556 | 14.4 | Butterfree, Porygon |
| Poder Oculto (`poder_oculto`) | 178 | 146 | 1596 | 9.0 | Abra |
| Escupir (`escupir`) | 174 | 138 | 902 | 5.2 | Victreebel, Ekans |
| Golpe Cabeza (`golpe_cabeza`) | 174 | 157 | 1442 | 8.3 | Seel, Slowbro, Slowpoke, Snorlax +2 |
| Chirrido (`chirrido`) | 173 | 0 | 0 | 0.0 | Voltorb, Meowth, Grimer, Ditto +8 |
| Hoja Mágica (`hoja_magica`) | 171 | 106 | 1035 | 6.1 | Mr. Mime |
| Alboroto (`alboroto`) | 162 | 123 | 1210 | 7.5 | Exeggcute, Dodrio, Ditto |
| Carámbano (`carambano`) | 161 | 362 | 1505 | 9.3 | Shellder |
| Viento Plata (`viento_plata`) | 160 | 121 | 1114 | 7.0 | Venomoth |
| Superdiente (`superdiente`) | 155 | 137 | 1818 | 11.7 | Raticate, Rattata, Ditto |
| Camelo (`camelo`) | 152 | 0 | 0 | 0.0 | Nidoran♂, Nidoran♀ |
| Agilidad (`agilidad`) | 150 | 0 | 0 | 0.0 | Hitmonchan, Moltres, Beedrill, Articuno |
| Tajo Cruzado (`tajo_cruzado`) | 147 | 112 | 2772 | 18.9 | Mankey, Machop, Primeape |
| Sumisión (`sumision`) | 146 | 108 | 1503 | 10.3 | Poliwrath |
| Polvo Veneno (`polvo_veneno`) | 139 | 0 | 0 | 0.0 | Exeggcute, Paras, Ditto |
| Pantalla de Humo (`pantalla_de_humo`) | 139 | 0 | 0 | 0.0 | Seadra, Magmar, Weezing, Ditto +1 |
| Guillotina (`guillotina`) | 137 | 110 | 1152 | 8.4 | Kingler, Pinsir, Krabby |
| Megapuño (`megapuno`) | 134 | 104 | 1166 | 8.7 | Kangaskhan, Mew |
| Rayo (`rayo`) | 127 | 54 | 1054 | 8.3 | Raichu, Pikachu |
| Agitacola (`agitacola`) | 126 | 0 | 0 | 0.0 | Rattata, Nidorina, Rapidash, Wartortle +7 |
| Bomba Huevo (`bomba_huevo`) | 120 | 102 | 575 | 4.8 | Chansey, Exeggutor |

