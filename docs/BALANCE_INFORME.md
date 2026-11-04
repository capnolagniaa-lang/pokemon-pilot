# Informe de balance (batería de peleas IA contra IA)

> **Generado** por `--autotest-balance` (2026-11-04). Ver cómo correrlo en `scripts/tests/balance_tests.gd`.
> Cada pelea: dos Pokémon con su habilidad, IA en Difícil, nivel 40, reglas del mundo, **los que trae un rival (3 de daño y 1 de estado, los mejores que sabe)**, emparejados por stats base (±60), cada pareja
> dos veces cambiando de lado. 2000 peleas en 1682 s (semilla 1). Con pocas peleas por especie los % varían mucho:
> mirar las que tienen 10 o más.

Empates por tiempo (60 s): 22 de 1000 (2%).

## Por especie (de más fuerte a más débil)

Daño hecho/recibido = de golpes (sin veneno ni quemaduras), en vidas enteras del rival/propias por pelea (1,0 = una vida). ⬆ = gana 65% o más, ⬇ = 35% o menos (con 10+ peleas).

| Pokémon | Habilidades | Stats base | Peleas | Victorias | % | Vida al ganar | Seg. por victoria | Daño hecho | Daño recibido | Empates |
|---|---|---|---|---|---|---|---|---|---|---|
| Kadabra ⬆ | Sincronía/Fuerza Mental | 400 | 20 | 19 | 95% | 48% | 7.8 | 1.01 | 0.56 | 0 |
| Venomoth ⬆ | Polvo Escudo | 450 | 20 | 18 | 90% | 57% | 14.0 | 0.97 | 0.49 | 0 |
| Slowbro ⬆ | Despiste/Ritmo Propio | 490 | 30 | 26 | 87% | 64% | 14.5 | 0.96 | 0.44 | 0 |
| Graveler ⬆ | Cabeza Roca/Robustez | 390 | 22 | 19 | 86% | 72% | 11.0 | 0.92 | 0.35 | 0 |
| Hypno ⬆ | Insomnio | 483 | 20 | 17 | 85% | 34% | 16.9 | 0.81 | 0.69 | 0 |
| Oddish ⬆ | Clorofila | 320 | 32 | 27 | 84% | 50% | 19.2 | 0.93 | 0.77 | 0 |
| Dratini ⬆ | Mudar | 300 | 18 | 15 | 83% | 61% | 9.7 | 1.01 | 0.48 | 0 |
| Seel ⬆ | Sebo | 325 | 32 | 26 | 81% | 48% | 12.8 | 0.93 | 0.57 | 1 |
| Drowzee ⬆ | Insomnio | 328 | 32 | 26 | 81% | 57% | 11.3 | 0.88 | 0.52 | 0 |
| Squirtle ⬆ | Torrente | 314 | 26 | 21 | 81% | 40% | 13.4 | 0.95 | 0.66 | 0 |
| Charizard ⬆ | Mar Llamas | 534 | 20 | 16 | 80% | 41% | 14.3 | 0.93 | 0.64 | 0 |
| Exeggcute ⬆ | Clorofila | 325 | 30 | 24 | 80% | 56% | 11.6 | 0.84 | 0.54 | 0 |
| Weepinbell ⬆ | Clorofila | 390 | 28 | 22 | 79% | 67% | 8.1 | 0.87 | 0.48 | 0 |
| Tauros ⬆ | Intimidación | 490 | 32 | 25 | 78% | 34% | 14.3 | 0.96 | 0.73 | 0 |
| Magikarp ⬆ | Nado Rápido | 200 | 26 | 20 | 77% | 82% | 45.5 | 0.90 | 0.36 | 0 |
| Beedrill ⬆ | Enjambre | 395 | 26 | 20 | 77% | 39% | 14.8 | 0.78 | 0.70 | 0 |
| Victreebel ⬆ | Clorofila | 490 | 30 | 23 | 77% | 68% | 10.5 | 0.93 | 0.45 | 2 |
| Slowpoke ⬆ | Despiste/Ritmo Propio | 315 | 30 | 23 | 77% | 49% | 15.8 | 0.93 | 0.57 | 0 |
| Tentacruel ⬆ | Cuerpo Puro/Lodo Líquido | 515 | 34 | 26 | 76% | 52% | 15.3 | 0.75 | 0.58 | 0 |
| Magnemite ⬆ | Imán/Robustez | 325 | 38 | 29 | 76% | 49% | 17.8 | 0.91 | 0.60 | 0 |
| Venusaur ⬆ | Espesura | 525 | 20 | 15 | 75% | 57% | 17.0 | 0.92 | 0.57 | 0 |
| Zubat ⬆ | Fuerza Mental | 245 | 20 | 15 | 75% | 61% | 8.9 | 0.95 | 0.54 | 1 |
| Mr. Mime ⬆ | Insonorizar | 460 | 20 | 15 | 75% | 41% | 11.6 | 0.91 | 0.66 | 0 |
| Exeggutor ⬆ | Clorofila | 530 | 30 | 22 | 73% | 47% | 14.0 | 0.89 | 0.65 | 0 |
| Jolteon ⬆ | Absorbe Electricidad | 525 | 30 | 22 | 73% | 56% | 17.6 | 0.90 | 0.56 | 0 |
| Vaporeon ⬆ | Absorbe Agua | 525 | 26 | 19 | 73% | 37% | 19.2 | 0.94 | 0.71 | 0 |
| Dragonair ⬆ | Mudar | 420 | 22 | 16 | 73% | 43% | 16.1 | 0.92 | 0.68 | 1 |
| Bellsprout ⬆ | Clorofila | 300 | 32 | 23 | 72% | 51% | 10.2 | 0.86 | 0.63 | 0 |
| Omastar ⬆ | Nado Rápido/Caparazón | 495 | 28 | 20 | 71% | 72% | 13.6 | 0.85 | 0.48 | 0 |
| Omanyte ⬆ | Nado Rápido/Caparazón | 355 | 30 | 21 | 70% | 54% | 12.8 | 0.90 | 0.62 | 0 |
| Charmander ⬆ | Mar Llamas | 309 | 20 | 14 | 70% | 50% | 11.5 | 0.76 | 0.63 | 0 |
| Grimer ⬆ | Hedor/Viscosidad | 325 | 26 | 18 | 69% | 47% | 14.4 | 0.84 | 0.67 | 0 |
| Shellder ⬆ | Caparazón | 305 | 32 | 22 | 69% | 57% | 12.9 | 0.82 | 0.59 | 0 |
| Kabuto ⬆ | Nado Rápido/Armadura Batalla | 355 | 22 | 15 | 68% | 60% | 17.6 | 0.84 | 0.60 | 0 |
| Charmeleon ⬆ | Mar Llamas | 405 | 28 | 19 | 68% | 39% | 14.2 | 0.83 | 0.73 | 0 |
| Zapdos ⬆ | Presión | 580 | 24 | 16 | 67% | 54% | 14.4 | 0.84 | 0.64 | 0 |
| Horsea ⬆ | Nado Rápido | 295 | 24 | 16 | 67% | 64% | 9.8 | 0.81 | 0.56 | 0 |
| Seadra ⬆ | Punto Tóxico | 440 | 32 | 21 | 66% | 57% | 13.5 | 0.80 | 0.61 | 0 |
| Alakazam ⬆ | Sincronía/Fuerza Mental | 500 | 32 | 21 | 66% | 48% | 11.0 | 0.91 | 0.69 | 0 |
| Pikachu ⬆ | Electricidad Estática | 320 | 26 | 17 | 65% | 41% | 14.4 | 0.91 | 0.70 | 0 |
| Golbat | Fuerza Mental | 455 | 34 | 22 | 65% | 44% | 16.0 | 0.89 | 0.71 | 0 |
| Pidgey | Vista Lince | 251 | 34 | 22 | 65% | 62% | 11.1 | 0.78 | 0.58 | 0 |
| Bulbasaur | Espesura | 318 | 30 | 19 | 63% | 51% | 18.2 | 0.83 | 0.83 | 0 |
| Porygon | Calco | 395 | 30 | 19 | 63% | 44% | 17.6 | 0.87 | 0.71 | 0 |
| Magneton | Imán/Robustez | 465 | 38 | 24 | 63% | 51% | 22.2 | 0.92 | 0.63 | 4 |
| Gloom | Clorofila | 395 | 32 | 20 | 63% | 64% | 18.9 | 0.72 | 0.79 | 0 |
| Poliwag | Absorbe Agua/Humedad | 300 | 32 | 20 | 63% | 41% | 14.8 | 0.87 | 0.75 | 0 |
| Muk | Hedor/Viscosidad | 500 | 34 | 21 | 62% | 39% | 19.7 | 0.61 | 0.76 | 0 |
| Geodude | Cabeza Roca/Robustez | 300 | 28 | 17 | 61% | 71% | 12.8 | 0.81 | 0.56 | 0 |
| Dragonite | Fuerza Mental | 600 | 20 | 12 | 60% | 55% | 18.4 | 0.89 | 0.67 | 0 |
| Poliwrath | Absorbe Agua/Humedad | 510 | 20 | 12 | 60% | 45% | 31.8 | 0.92 | 0.57 | 1 |
| Butterfree | Ojo Compuesto | 395 | 28 | 16 | 57% | 47% | 17.3 | 0.86 | 0.73 | 1 |
| Raichu | Electricidad Estática | 485 | 30 | 17 | 57% | 43% | 14.7 | 0.90 | 0.70 | 2 |
| Ninetales | Absorbe Fuego | 505 | 30 | 17 | 57% | 29% | 22.9 | 0.72 | 0.79 | 1 |
| Haunter | Levitación | 405 | 36 | 20 | 56% | 69% | 14.7 | 0.80 | 0.69 | 0 |
| Snorlax | Inmunidad/Sebo | 540 | 36 | 20 | 56% | 39% | 18.1 | 0.79 | 0.72 | 4 |
| Machop | Agallas | 305 | 22 | 12 | 55% | 57% | 4.9 | 0.81 | 0.68 | 0 |
| Tentacool | Cuerpo Puro/Lodo Líquido | 335 | 22 | 12 | 55% | 32% | 18.4 | 0.86 | 0.83 | 0 |
| Vulpix | Absorbe Fuego | 299 | 28 | 15 | 54% | 44% | 12.5 | 0.78 | 0.74 | 1 |
| Magmar | Cuerpo Llama | 495 | 28 | 15 | 54% | 52% | 24.2 | 0.59 | 0.69 | 0 |
| Staryu | Iluminación/Cura Natural | 340 | 34 | 18 | 53% | 47% | 12.2 | 0.80 | 0.79 | 0 |
| Gastly | Levitación | 310 | 34 | 18 | 53% | 70% | 7.8 | 0.84 | 0.65 | 0 |
| Lapras | Absorbe Agua/Caparazón | 535 | 38 | 20 | 53% | 53% | 22.4 | 0.83 | 0.68 | 3 |
| Wartortle | Torrente | 405 | 24 | 12 | 50% | 50% | 18.8 | 0.83 | 0.70 | 2 |
| Koffing | Levitación | 340 | 30 | 15 | 50% | 40% | 16.7 | 0.76 | 0.80 | 0 |
| Cloyster | Caparazón | 525 | 22 | 11 | 50% | 44% | 25.0 | 0.46 | 0.73 | 0 |
| Ivysaur | Espesura | 405 | 22 | 11 | 50% | 47% | 20.2 | 0.86 | 0.77 | 0 |
| Psyduck | Humedad/Aclimatación | 320 | 24 | 12 | 50% | 38% | 16.4 | 0.77 | 0.79 | 0 |
| Pidgeot | Vista Lince | 479 | 32 | 16 | 50% | 41% | 17.2 | 0.86 | 0.77 | 1 |
| Goldeen | Nado Rápido/Velo Agua | 320 | 30 | 15 | 50% | 43% | 13.0 | 0.79 | 0.76 | 0 |
| Aerodactyl | Cabeza Roca/Presión | 515 | 26 | 13 | 50% | 46% | 17.0 | 0.88 | 0.73 | 0 |
| Arcanine | Intimidación/Absorbe Fuego | 555 | 40 | 19 | 48% | 45% | 16.6 | 0.62 | 0.74 | 0 |
| Tangela | Clorofila | 435 | 32 | 15 | 47% | 56% | 14.2 | 0.73 | 0.73 | 0 |
| Clefairy | Gran Encanto | 323 | 30 | 14 | 47% | 53% | 23.0 | 0.74 | 0.99 | 0 |
| Rattata | Fuga/Agallas | 253 | 30 | 14 | 47% | 80% | 11.0 | 0.81 | 0.61 | 1 |
| Gyarados | Intimidación | 540 | 30 | 14 | 47% | 37% | 26.4 | 0.82 | 0.81 | 0 |
| Dewgong | Sebo | 475 | 28 | 13 | 46% | 53% | 14.3 | 0.85 | 0.64 | 0 |
| Mankey | Espíritu Vital | 305 | 26 | 12 | 46% | 56% | 7.2 | 0.84 | 0.72 | 0 |
| Scyther | Enjambre | 500 | 26 | 12 | 46% | 47% | 10.6 | 0.66 | 0.77 | 0 |
| Cubone | Cabeza Roca/Pararrayos | 320 | 24 | 11 | 46% | 36% | 14.4 | 0.67 | 0.83 | 0 |
| Nidoqueen | Punto Tóxico | 505 | 24 | 11 | 46% | 45% | 12.9 | 0.60 | 0.79 | 1 |
| Ponyta | Fuga/Absorbe Fuego | 410 | 24 | 11 | 46% | 39% | 13.5 | 0.69 | 0.82 | 0 |
| Flareon | Absorbe Fuego | 525 | 22 | 10 | 45% | 47% | 21.2 | 0.86 | 0.77 | 0 |
| Primeape | Espíritu Vital | 455 | 22 | 10 | 45% | 74% | 6.0 | 0.70 | 0.63 | 0 |
| Blastoise | Torrente | 530 | 22 | 10 | 45% | 58% | 17.6 | 0.77 | 0.58 | 0 |
| Moltres | Presión | 580 | 22 | 10 | 45% | 23% | 21.0 | 0.69 | 0.89 | 0 |
| Marowak | Cabeza Roca/Pararrayos | 425 | 18 | 8 | 44% | 33% | 21.7 | 0.65 | 0.85 | 0 |
| Articuno | Presión | 580 | 18 | 8 | 44% | 33% | 23.9 | 0.84 | 0.84 | 0 |
| Arbok | Intimidación/Mudar | 448 | 30 | 13 | 43% | 49% | 17.3 | 0.75 | 0.78 | 1 |
| Weezing | Levitación | 490 | 30 | 13 | 43% | 39% | 16.4 | 0.59 | 0.82 | 0 |
| Farfetch’d | Vista Lince/Fuerza Mental | 377 | 28 | 12 | 43% | 33% | 13.4 | 0.87 | 0.82 | 0 |
| Seaking | Nado Rápido/Velo Agua | 450 | 26 | 11 | 42% | 35% | 13.6 | 0.76 | 0.82 | 0 |
| Wigglytuff | Gran Encanto | 435 | 24 | 10 | 42% | 96% | 39.5 | 0.78 | 0.26 | 12 |
| Paras | Efecto Espora | 285 | 24 | 10 | 42% | 54% | 10.5 | 0.47 | 0.84 | 0 |
| Golem | Cabeza Roca/Robustez | 495 | 24 | 10 | 42% | 47% | 12.8 | 0.66 | 0.79 | 0 |
| Starmie | Iluminación/Cura Natural | 520 | 22 | 9 | 41% | 31% | 26.4 | 0.79 | 0.86 | 2 |
| Eevee | Fuga | 325 | 22 | 9 | 41% | 40% | 16.2 | 0.82 | 0.84 | 0 |
| Electabuzz | Electricidad Estática | 490 | 22 | 9 | 41% | 36% | 22.6 | 0.82 | 0.79 | 1 |
| Gengar | Levitación | 500 | 22 | 9 | 41% | 62% | 17.5 | 0.80 | 0.57 | 4 |
| Venonat | Ojo Compuesto | 305 | 32 | 13 | 41% | 51% | 20.7 | 0.89 | 0.80 | 0 |
| Vileplume | Clorofila | 490 | 20 | 8 | 40% | 62% | 15.8 | 0.74 | 0.96 | 0 |
| Kangaskhan | Madrugar | 490 | 40 | 16 | 40% | 33% | 16.8 | 0.77 | 0.83 | 0 |
| Golduck | Humedad/Aclimatación | 500 | 30 | 12 | 40% | 36% | 22.4 | 0.76 | 0.84 | 1 |
| Hitmonchan | Vista Lince | 455 | 28 | 11 | 39% | 30% | 13.0 | 0.68 | 0.83 | 0 |
| Sandshrew | Velo Arena | 300 | 18 | 7 | 39% | 29% | 22.3 | 0.55 | 0.88 | 0 |
| Kingler | Corte Fuerte/Caparazón | 475 | 26 | 10 | 38% | 57% | 10.0 | 0.48 | 0.75 | 3 |
| Doduo | Fuga/Madrugar | 310 | 24 | 9 | 38% | 54% | 6.5 | 0.68 | 0.79 | 0 |
| Caterpie | Polvo Escudo | 195 | 16 | 6 | 38% | 100% | 55.8 | 0.74 | 0.50 | 2 |
| Parasect | Efecto Espora | 405 | 22 | 8 | 36% | 61% | 16.8 | 0.70 | 0.84 | 0 |
| Nidoking | Punto Tóxico | 505 | 22 | 8 | 36% | 55% | 12.2 | 0.59 | 0.78 | 0 |
| Onix ⬇ | Cabeza Roca/Robustez | 385 | 26 | 9 | 35% | 57% | 30.7 | 0.62 | 0.71 | 2 |
| Pidgeotto ⬇ | Vista Lince | 349 | 30 | 10 | 33% | 38% | 13.7 | 0.73 | 0.80 | 0 |
| Machoke ⬇ | Agallas | 405 | 28 | 9 | 32% | 32% | 11.4 | 0.65 | 0.82 | 0 |
| Clefable ⬇ | Gran Encanto | 483 | 28 | 9 | 32% | 28% | 26.9 | 0.60 | 0.91 | 0 |
| Fearow ⬇ | Vista Lince | 442 | 26 | 8 | 31% | 39% | 11.0 | 0.72 | 0.86 | 0 |
| Spearow ⬇ | Vista Lince | 262 | 26 | 8 | 31% | 48% | 9.0 | 0.76 | 0.81 | 0 |
| Raticate ⬇ | Fuga/Agallas | 413 | 20 | 6 | 30% | 42% | 9.8 | 0.62 | 0.83 | 0 |
| Growlithe ⬇ | Intimidación/Absorbe Fuego | 350 | 20 | 6 | 30% | 47% | 6.6 | 0.62 | 0.85 | 0 |
| Nidoran♀ ⬇ | Punto Tóxico | 275 | 20 | 6 | 30% | 15% | 17.1 | 0.62 | 0.95 | 0 |
| Machamp ⬇ | Agallas | 505 | 24 | 7 | 29% | 30% | 15.0 | 0.61 | 0.88 | 0 |
| Hitmonlee ⬇ | Flexibilidad | 455 | 26 | 7 | 27% | 35% | 8.9 | 0.58 | 0.90 | 0 |
| Poliwhirl ⬇ | Absorbe Agua/Humedad | 385 | 20 | 5 | 25% | 38% | 18.1 | 0.72 | 0.89 | 0 |
| Mew ⬇ | Sincronía | 600 | 16 | 4 | 25% | 17% | 19.4 | 0.73 | 0.95 | 0 |
| Sandslash ⬇ | Velo Arena | 450 | 28 | 7 | 25% | 56% | 21.0 | 0.64 | 0.83 | 2 |
| Ditto ⬇ | Flexibilidad | 288 | 26 | 6 | 23% | 34% | 14.2 | 0.67 | 0.91 | 0 |
| Pinsir ⬇ | Corte Fuerte | 500 | 32 | 7 | 22% | 53% | 13.3 | 0.62 | 0.87 | 0 |
| Ekans ⬇ | Intimidación/Mudar | 288 | 28 | 6 | 21% | 21% | 23.9 | 0.75 | 1.11 | 0 |
| Dugtrio ⬇ | Velo Arena/Trampa Arena | 425 | 28 | 6 | 21% | 58% | 10.8 | 0.42 | 0.87 | 0 |
| Abra ⬇ | Sincronía/Fuerza Mental | 310 | 28 | 6 | 21% | 39% | 8.6 | 0.79 | 0.88 | 0 |
| Voltorb ⬇ | Insonorizar/Electricidad Estática | 330 | 28 | 6 | 21% | 19% | 22.0 | 0.57 | 0.87 | 0 |
| Rhyhorn ⬇ | Pararrayos/Cabeza Roca | 345 | 38 | 8 | 21% | 42% | 26.3 | 0.38 | 0.90 | 0 |
| Dodrio ⬇ | Fuga/Madrugar | 470 | 24 | 5 | 21% | 33% | 12.4 | 0.60 | 0.89 | 0 |
| Kabutops ⬇ | Nado Rápido/Armadura Batalla | 495 | 20 | 4 | 20% | 51% | 26.7 | 0.47 | 0.78 | 0 |
| Nidorina ⬇ | Punto Tóxico | 365 | 26 | 5 | 19% | 38% | 26.7 | 0.64 | 0.93 | 0 |
| Nidorino ⬇ | Punto Tóxico | 365 | 26 | 5 | 19% | 49% | 12.6 | 0.43 | 0.91 | 0 |
| Nidoran♂ ⬇ | Punto Tóxico | 273 | 16 | 3 | 19% | 23% | 15.9 | 0.45 | 0.92 | 0 |
| Persian ⬇ | Flexibilidad | 440 | 38 | 7 | 18% | 50% | 12.8 | 0.60 | 0.90 | 0 |
| Lickitung ⬇ | Ritmo Propio/Despiste | 385 | 22 | 4 | 18% | 21% | 15.9 | 0.68 | 0.91 | 1 |
| Jigglypuff ⬇ | Gran Encanto | 270 | 18 | 3 | 17% | 31% | 8.0 | 0.70 | 0.93 | 0 |
| Krabby ⬇ | Corte Fuerte/Caparazón | 325 | 26 | 4 | 15% | 36% | 16.0 | 0.43 | 0.93 | 0 |
| Weedle ⬇ | Polvo Escudo | 195 | 20 | 3 | 15% | 100% | 49.4 | 0.36 | 0.60 | 5 |
| Rapidash ⬇ | Fuga/Absorbe Fuego | 500 | 30 | 4 | 13% | 33% | 16.5 | 0.50 | 0.91 | 0 |
| Diglett ⬇ | Velo Arena/Trampa Arena | 265 | 32 | 4 | 13% | 100% | 29.5 | 0.41 | 0.87 | 0 |
| Rhydon ⬇ | Pararrayos/Cabeza Roca | 485 | 32 | 4 | 13% | 44% | 23.3 | 0.39 | 0.87 | 6 |
| Electrode ⬇ | Insonorizar/Electricidad Estática | 490 | 34 | 4 | 12% | 25% | 21.4 | 0.63 | 0.93 | 0 |
| Meowth ⬇ | Recogida | 290 | 28 | 3 | 11% | 28% | 9.7 | 0.42 | 0.93 | 0 |
| Jynx ⬇ | Despiste | 455 | 18 | 1 | 6% | 29% | 7.9 | 0.37 | 0.95 | 0 |
| Chansey ⬇ | Cura Natural/Dicha | 450 | 20 | 0 | 0% | — | — | 0.24 | 1.09 | 0 |
| Kakuna ⬇ | Mudar | 205 | 28 | 0 | 0% | — | — | 0.00 | 0.75 | 9 |
| Metapod ⬇ | Mudar | 205 | 28 | 0 | 0% | — | — | 0.00 | 0.74 | 10 |

## Por habilidad (la que le tocó en cada pelea)

| | Peleas | % de victorias |
|---|---|---|
| Insomnio | 52 | 83% |
| Absorbe Electricidad | 30 | 73% |
| Cuerpo Puro | 26 | 73% |
| Mar Llamas | 68 | 72% |
| Clorofila | 266 | 69% |
| Viscosidad | 24 | 67% |
| Robustez | 87 | 66% |
| Hedor | 36 | 64% |
| Imán | 33 | 64% |
| Absorbe Agua | 85 | 64% |
| Calco | 30 | 63% |
| Lodo Líquido | 30 | 63% |
| Espesura | 72 | 63% |
| Enjambre | 52 | 62% |
| Sebo | 78 | 62% |
| Inmunidad | 18 | 61% |
| Torrente | 72 | 60% |
| Ritmo Propio | 46 | 59% |
| Fuerza Mental | 143 | 58% |
| Nado Rápido | 128 | 58% |
| Caparazón | 123 | 57% |
| Armadura Batalla | 23 | 57% |
| Iluminación | 32 | 56% |
| Presión | 78 | 54% |
| Cuerpo Llama | 28 | 54% |
| Velo Agua | 28 | 54% |
| Intimidación | 127 | 51% |
| Sincronía | 47 | 51% |
| Despiste | 54 | 50% |
| Levitación | 152 | 49% |
| Ojo Compuesto | 60 | 48% |
| Polvo Escudo | 56 | 48% |
| Espíritu Vital | 48 | 46% |
| Absorbe Fuego | 132 | 45% |
| Cabeza Roca | 119 | 45% |
| Electricidad Estática | 109 | 44% |
| Vista Lince | 184 | 43% |
| Aclimatación | 28 | 43% |
| Humedad | 55 | 42% |
| Insonorizar | 51 | 39% |
| Efecto Espora | 46 | 39% |
| Madrugar | 60 | 38% |
| Agallas | 98 | 37% |
| Gran Encanto | 100 | 36% |
| Punto Tóxico | 166 | 36% |
| Fuga | 103 | 33% |
| Mudar | 124 | 32% |
| Velo Arena | 70 | 31% |
| Cura Natural | 34 | 26% |
| Corte Fuerte | 64 | 23% |
| Flexibilidad | 90 | 22% |
| Pararrayos | 61 | 20% |
| Recogida | 28 | 11% |
| Trampa Arena | 36 | 6% |
| Dicha | 10 | 0% |

## Por tipo (un Pokémon de dos tipos cuenta en los dos)

| | Especies | Peleas | % de victorias |
|---|---|---|---|
| Dragón | 3 | 60 | 72% |
| Acero | 2 | 76 | 70% |
| Psíquico | 13 | 328 | 65% |
| Planta | 14 | 384 | 64% |
| Agua | 32 | 868 | 58% |
| Eléctrico | 9 | 270 | 53% |
| Veneno | 33 | 886 | 53% |
| Fantasma | 3 | 92 | 51% |
| Fuego | 12 | 312 | 50% |
| Volador | 19 | 492 | 50% |
| Roca | 11 | 296 | 47% |
| Hielo | 5 | 124 | 43% |
| Hada | 5 | 120 | 43% |
| Lucha | 8 | 196 | 41% |
| Normal | 22 | 610 | 38% |
| Bicho | 12 | 302 | 37% |
| Tierra | 14 | 364 | 35% |

## Por ataque (los más usados)

Daño = %% de la vida del que lo recibe, sumado. Por uso = daño medio cada vez que se lanza (los de estado dan 0).

| Ataque | Usos | Golpes | Daño total | Por uso | Lo usan |
|---|---|---|---|---|---|
| Placaje (`placaje`) | 3773 | 3200 | 13211 | 3.5 | Snorlax, Tauros, Golem, Venonat +18 |
| Pistola Agua (`pistola_agua`) | 3246 | 2357 | 16195 | 5.0 | Squirtle, Slowpoke, Omanyte, Slowbro +11 |
| Confusión (`confusion`) | 2821 | 1997 | 19793 | 7.0 | Hypno, Mr. Mime, Venonat, Alakazam +10 |
| Mordisco (`mordisco`) | 2734 | 2037 | 16489 | 6.0 | Ekans, Arcanine, Flareon, Omanyte +17 |
| Ácido (`acido`) | 1909 | 1261 | 8452 | 4.4 | Oddish, Bellsprout, Tentacruel, Arbok +3 |
| Ascuas (`ascuas`) | 1768 | 1224 | 8857 | 5.0 | Magmar, Flareon, Charmander, Vulpix +5 |
| Ataque Rápido (`ataque_rapido`) | 1511 | 1208 | 6655 | 4.4 | Rattata, Flareon, Raichu, Vulpix +7 |
| Ataque Ala (`ataque_ala`) | 1431 | 1201 | 14278 | 10.0 | Scyther, Pidgey, Pidgeot, Pidgeotto +5 |
| Burbuja (`burbuja`) | 1412 | 996 | 7593 | 5.4 | Squirtle, Poliwag, Seadra, Poliwhirl +4 |
| Impactrueno (`impactrueno`) | 1301 | 977 | 7968 | 6.1 | Raichu, Jolteon, Magneton, Magnemite +2 |
| Arañazo (`aranazo`) | 1150 | 895 | 4982 | 4.3 | Parasect, Psyduck, Paras, Persian +5 |
| Doble Bofetón (`doble_bofeton`) | 1025 | 976 | 2794 | 2.7 | Wigglytuff, Jigglypuff, Poliwag, Poliwhirl +7 |
| Residuos (`residuos`) | 958 | 724 | 6651 | 6.9 | Muk, Koffing, Grimer, Weezing |
| Látigo Cepa (`latigo_cepa`) | 903 | 700 | 6245 | 6.9 | Bellsprout, Victreebel, Tangela, Weepinbell +3 |
| Chispa (`chispa`) | 880 | 663 | 6633 | 7.5 | Voltorb, Magnemite, Electrode, Magneton |
| Picotazo (`picotazo`) | 871 | 802 | 5650 | 6.5 | Spearow, Dodrio, Fearow, Farfetch’d +8 |
| Hoja Afilada (`hoja_afilada`) | 802 | 586 | 5428 | 6.8 | Bellsprout, Victreebel, Ivysaur, Bulbasaur +1 |
| Rayo Confuso (`rayo_confuso`) | 775 | 0 | 0 | 0.0 | Haunter, Lapras, Starmie, Gastly +3 |
| Absorber (`absorber`) | 765 | 505 | 1607 | 2.1 | Oddish, Vileplume, Kabuto, Gloom |
| Lanzarrocas (`lanzarrocas`) | 745 | 492 | 4800 | 6.4 | Golem, Onix, Geodude, Graveler |
| Picotazo Veneno (`picotazo_veneno`) | 730 | 667 | 2633 | 3.6 | Ekans, Tentacruel, Ditto, Nidorina +10 |
| Rayo Aurora (`rayo_aurora`) | 729 | 531 | 4448 | 6.1 | Cloyster, Dewgong, Shellder, Vaporeon |
| Destructor (`destructor`) | 711 | 663 | 2916 | 4.1 | Hypno, Jigglypuff, Muk, Drowzee +5 |
| Fortaleza (`fortaleza`) | 708 | 0 | 0 | 0.0 | Kakuna, Metapod, Pinsir |
| Tornado (`tornado`) | 687 | 458 | 2991 | 4.4 | Butterfree, Articuno, Venomoth |
| Disparo Demora (`disparo_demora`) | 615 | 0 | 0 | 0.0 | Caterpie, Weedle |
| Metrónomo (`metronomo`) | 580 | 0 | 0 | 0.0 | Clefairy, Clefable, Mew |
| Cuchillada (`cuchillada`) | 562 | 493 | 5111 | 9.1 | Scyther, Parasect, Paras, Dugtrio +7 |
| Rapidez (`rapidez`) | 553 | 367 | 2956 | 5.3 | Staryu, Starmie, Magnemite, Electabuzz |
| Furia Dragón (`furia_dragon`) | 498 | 411 | 3274 | 6.6 | Dragonite, Dratini, Dragonair, Ditto |
| Pisotón (`pisoton`) | 492 | 427 | 3538 | 7.2 | Rapidash, Krabby, Rhyhorn, Ditto +5 |
| Megaagotar (`megaagotar`) | 481 | 376 | 2329 | 4.8 | Vileplume, Tangela |
| Anulación (`anulacion`) | 466 | 0 | 0 | 0.0 | Wigglytuff |
| Azote (`azote`) | 437 | 430 | 917 | 2.1 | Magikarp |
| Atizar (`atizar`) | 402 | 333 | 3146 | 7.8 | Tangela, Dragonite, Dratini, Lickitung +3 |
| Ataque Arena (`ataque_arena`) | 395 | 0 | 0 | 0.0 | Flareon, Jolteon, Dugtrio, Kabuto +4 |
| Disparo Lodo (`disparo_lodo`) | 392 | 269 | 2808 | 7.2 | Omanyte, Omastar, Kabuto |
| Hipnosis (`hipnosis`) | 386 | 0 | 0 | 0.0 | Poliwag, Poliwhirl, Poliwrath, Exeggutor +1 |
| Golpe Cuerpo (`golpe_cuerpo`) | 386 | 309 | 3203 | 8.3 | Snorlax, Jigglypuff, Poliwag, Poliwhirl +3 |
| Cornada (`cornada`) | 386 | 358 | 3549 | 9.2 | Tauros, Seaking |
| Polución (`polucion`) | 364 | 241 | 974 | 2.7 | Magmar, Koffing, Weezing |
| Tinieblas (`tinieblas`) | 364 | 252 | 3804 | 10.5 | Haunter, Gastly, Gengar |
| Viento Hielo (`viento_hielo`) | 355 | 565 | 3283 | 9.2 | Seel, Dewgong |
| Sísmico (`sismico`) | 324 | 375 | 4846 | 15.0 | Machoke, Machamp, Mankey, Machop +3 |
| Rayo Burbuja (`rayo_burbuja`) | 324 | 417 | 2657 | 8.2 | Tentacruel, Staryu, Tentacool |
| Paralizador (`paralizador`) | 295 | 0 | 0 | 0.0 | Parasect, Venonat, Vileplume, Tangela +2 |
| Chirrido (`chirrido`) | 288 | 0 | 0 | 0.0 | Muk, Onix, Voltorb, Psyduck +8 |
| Ciclón (`ciclon`) | 273 | 275 | 1684 | 6.2 | Seadra, Dragonite, Dratini, Dragonair +2 |
| Psíquico (`psiquico`) | 272 | 201 | 3983 | 14.6 | Hypno, Slowpoke, Alakazam, Drowzee +3 |
| Pin Misil (`pin_misil`) | 259 | 471 | 1699 | 6.6 | Beedrill, Jolteon |
| Agitacola (`agitacola`) | 257 | 0 | 0 | 0.0 | Rapidash, Raichu, Nidorina, Wartortle +7 |
| Pico Taladro (`pico_taladro`) | 247 | 237 | 4105 | 16.6 | Spearow, Fearow, Doduo |
| Gas Venenoso (`gas_venenoso`) | 246 | 3 | 6 | 0.0 | Hypno, Muk, Drowzee, Grimer |
| Malicioso (`malicioso`) | 239 | 0 | 0 | 0.0 | Omastar, Horsea, Gyarados, Shellder +10 |
| Perforador (`perforador`) | 238 | 213 | 1406 | 5.9 | Rhyhorn, Ditto, Rhydon |
| Escupir (`escupir`) | 232 | 181 | 1093 | 4.7 | Ekans, Ditto, Victreebel |
| Poder Oculto (`poder_oculto`) | 230 | 184 | 2224 | 9.7 | Abra |
| Supersónico (`supersonico`) | 229 | 0 | 0 | 0.0 | Tentacruel, Cloyster, Butterfree, Tentacool +3 |
| Agilidad (`agilidad`) | 219 | 0 | 0 | 0.0 | Beedrill, Articuno, Moltres, Hitmonchan |
| Derribo (`derribo`) | 217 | 174 | 1861 | 8.6 | Rapidash, Seel, Ponyta, Growlithe |
| Golpe Cabeza (`golpe_cabeza`) | 208 | 185 | 1518 | 7.3 | Snorlax, Slowpoke, Slowbro, Seel +2 |
| Ataque Furia (`ataque_furia`) | 206 | 192 | 558 | 2.7 | Rapidash, Beedrill, Spearow, Dodrio +10 |
| Cara Susto (`cara_susto`) | 203 | 0 | 0 | 0.0 | Charmander, Rhyhorn, Ditto, Charizard +4 |
| Megapuño (`megapuno`) | 202 | 159 | 1846 | 9.1 | Kangaskhan, Mew |
| Guillotina (`guillotina`) | 199 | 177 | 1490 | 7.5 | Krabby, Pinsir, Kingler |
| Pantalla de Humo (`pantalla_de_humo`) | 190 | 0 | 0 | 0.0 | Magmar, Koffing, Weezing, Seadra |
| Golpe Kárate (`golpe_karate`) | 185 | 178 | 1797 | 9.7 | Machoke, Mankey, Machop, Primeape +2 |
| Fijar Blanco (`fijar_blanco`) | 180 | 0 | 0 | 0.0 | Magnemite, Magneton, Porygon |
| Reducción (`reduccion`) | 177 | 0 | 0 | 0.0 | Clefable |
| Lanzallamas (`lanzallamas`) | 172 | 126 | 2270 | 13.2 | Charmander, Vulpix, Charizard, Charmeleon |
| Magnitud (`magnitud`) | 169 | 169 | 2382 | 14.1 | Geodude, Diglett, Dugtrio, Graveler +2 |
| Luz Lunar (`luz_lunar`) | 164 | 0 | 0 | 0.0 | Oddish, Clefairy, Gloom |
| Sorpresa (`sorpresa`) | 162 | 140 | 748 | 4.6 | Kangaskhan |
| Comesueños (`comesuenos`) | 153 | 131 | 2075 | 13.6 | Haunter, Gastly, Gengar |
| Doble Patada (`doble_patada`) | 142 | 222 | 900 | 6.3 | Jolteon, Nidoqueen |
| Camelo (`camelo`) | 140 | 0 | 0 | 0.0 | Nidoran♀, Nidoran♂ |
| Giro Rápido (`giro_rapido`) | 139 | 83 | 316 | 2.3 | Starmie |
| Doble Ataque (`doble_ataque`) | 138 | 218 | 1058 | 7.7 | Beedrill |
| Superdiente (`superdiente`) | 136 | 123 | 1598 | 11.8 | Rattata, Raticate |
| Cascada (`cascada`) | 134 | 122 | 2085 | 15.6 | Goldeen, Ditto |

