# Pokémon: habilidades y ataques que aprenden

> **Generado** por `tools/build_pokemon_docs.gd` (2026-10-28). No editar a mano: cambiar las habilidades/learnsets y volver
> a correr la herramienta. Habilidades: `tools/apply_abilities.gd` · salvajes por zona: `docs/SALVAJES_LISTADO.md`.

**386 especies** · aparecen hoy en el juego: 135. Cada Pokémon nace con una de sus habilidades (al azar). Los ataques
se comportan igual para todos; viene con los últimos 4 que aprendió por nivel y desde la ficha (Esc → Equipo) se
elige entre todo lo de nivel y MT: el estilo de pelea lo arma el jugador. Los Pokémon de los líderes de gimnasio con
"kit de jefe" pelean con él (firma + 4 ataques propios).

## Índice

| N.º | Pokémon | Tipos | Habilidades | Kit de jefe | ¿En el juego? |
|---|---|---|---|---|---|
| 001 | [Bulbasaur](#001-bulbasaur) | Planta/Veneno | Espesura |  | sí |
| 002 | [Ivysaur](#002-ivysaur) | Planta/Veneno | Espesura |  | sí |
| 003 | [Venusaur](#003-venusaur) | Planta/Veneno | Espesura |  | sí |
| 004 | [Charmander](#004-charmander) | Fuego | Mar Llamas |  | sí |
| 005 | [Charmeleon](#005-charmeleon) | Fuego | Mar Llamas |  | sí |
| 006 | [Charizard](#006-charizard) | Fuego/Volador | Mar Llamas |  | sí |
| 007 | [Squirtle](#007-squirtle) | Agua | Torrente |  | sí |
| 008 | [Wartortle](#008-wartortle) | Agua | Torrente |  | sí |
| 009 | [Blastoise](#009-blastoise) | Agua | Torrente |  | sí |
| 010 | [Caterpie](#010-caterpie) | Bicho | Polvo Escudo |  | sí |
| 011 | [Metapod](#011-metapod) | Bicho | Mudar |  | sí |
| 012 | [Butterfree](#012-butterfree) | Bicho/Volador | Ojo Compuesto |  | sí |
| 013 | [Weedle](#013-weedle) | Bicho/Veneno | Polvo Escudo |  | sí |
| 014 | [Kakuna](#014-kakuna) | Bicho/Veneno | Mudar |  | sí |
| 015 | [Beedrill](#015-beedrill) | Bicho/Veneno | Enjambre |  | sí |
| 016 | [Pidgey](#016-pidgey) | Normal/Volador | Vista Lince |  | sí |
| 017 | [Pidgeotto](#017-pidgeotto) | Normal/Volador | Vista Lince |  | sí |
| 018 | [Pidgeot](#018-pidgeot) | Normal/Volador | Vista Lince |  | sí |
| 019 | [Rattata](#019-rattata) | Normal | Fuga / Agallas |  | sí |
| 020 | [Raticate](#020-raticate) | Normal | Fuga / Agallas |  | sí |
| 021 | [Spearow](#021-spearow) | Normal/Volador | Vista Lince |  | sí |
| 022 | [Fearow](#022-fearow) | Normal/Volador | Vista Lince |  | sí |
| 023 | [Ekans](#023-ekans) | Veneno | Intimidación / Mudar |  | sí |
| 024 | [Arbok](#024-arbok) | Veneno | Intimidación / Mudar |  | sí |
| 025 | [Pikachu](#025-pikachu) | Eléctrico | Electricidad Estática |  | sí |
| 026 | [Raichu](#026-raichu) | Eléctrico | Electricidad Estática | Toma de Tierra | sí |
| 027 | [Sandshrew](#027-sandshrew) | Tierra | Velo Arena |  | sí |
| 028 | [Sandslash](#028-sandslash) | Tierra | Velo Arena |  | sí |
| 029 | [Nidoran♀](#029-nidoran) | Veneno | Punto Tóxico |  | sí |
| 030 | [Nidorina](#030-nidorina) | Veneno | Punto Tóxico |  | sí |
| 031 | [Nidoqueen](#031-nidoqueen) | Veneno/Tierra | Punto Tóxico |  | sí |
| 032 | [Nidoran♂](#032-nidoran) | Veneno | Punto Tóxico |  | sí |
| 033 | [Nidorino](#033-nidorino) | Veneno | Punto Tóxico |  | sí |
| 034 | [Nidoking](#034-nidoking) | Veneno/Tierra | Punto Tóxico |  | sí |
| 035 | [Clefairy](#035-clefairy) | Hada | Gran Encanto |  | sí |
| 036 | [Clefable](#036-clefable) | Hada | Gran Encanto |  |  |
| 037 | [Vulpix](#037-vulpix) | Fuego | Absorbe Fuego |  | sí |
| 038 | [Ninetales](#038-ninetales) | Fuego | Absorbe Fuego |  | sí |
| 039 | [Jigglypuff](#039-jigglypuff) | Normal/Hada | Gran Encanto |  | sí |
| 040 | [Wigglytuff](#040-wigglytuff) | Normal/Hada | Gran Encanto |  | sí |
| 041 | [Zubat](#041-zubat) | Veneno/Volador | Fuerza Mental |  | sí |
| 042 | [Golbat](#042-golbat) | Veneno/Volador | Fuerza Mental |  | sí |
| 043 | [Oddish](#043-oddish) | Planta/Veneno | Clorofila |  | sí |
| 044 | [Gloom](#044-gloom) | Planta/Veneno | Clorofila |  | sí |
| 045 | [Vileplume](#045-vileplume) | Planta/Veneno | Clorofila |  | sí |
| 046 | [Paras](#046-paras) | Bicho/Planta | Efecto Espora |  | sí |
| 047 | [Parasect](#047-parasect) | Bicho/Planta | Efecto Espora |  | sí |
| 048 | [Venonat](#048-venonat) | Bicho/Veneno | Ojo Compuesto |  | sí |
| 049 | [Venomoth](#049-venomoth) | Bicho/Veneno | Polvo Escudo |  | sí |
| 050 | [Diglett](#050-diglett) | Tierra | Velo Arena / Trampa Arena |  | sí |
| 051 | [Dugtrio](#051-dugtrio) | Tierra | Velo Arena / Trampa Arena |  | sí |
| 052 | [Meowth](#052-meowth) | Normal | Recogida |  | sí |
| 053 | [Persian](#053-persian) | Normal | Flexibilidad |  | sí |
| 054 | [Psyduck](#054-psyduck) | Agua | Humedad / Aclimatación |  | sí |
| 055 | [Golduck](#055-golduck) | Agua | Humedad / Aclimatación |  | sí |
| 056 | [Mankey](#056-mankey) | Lucha | Espíritu Vital |  | sí |
| 057 | [Primeape](#057-primeape) | Lucha | Espíritu Vital |  | sí |
| 058 | [Growlithe](#058-growlithe) | Fuego | Intimidación / Absorbe Fuego |  | sí |
| 059 | [Arcanine](#059-arcanine) | Fuego | Intimidación / Absorbe Fuego |  | sí |
| 060 | [Poliwag](#060-poliwag) | Agua | Absorbe Agua / Humedad |  | sí |
| 061 | [Poliwhirl](#061-poliwhirl) | Agua | Absorbe Agua / Humedad |  | sí |
| 062 | [Poliwrath](#062-poliwrath) | Agua/Lucha | Absorbe Agua / Humedad |  |  |
| 063 | [Abra](#063-abra) | Psíquico | Sincronía / Fuerza Mental |  | sí |
| 064 | [Kadabra](#064-kadabra) | Psíquico | Sincronía / Fuerza Mental |  | sí |
| 065 | [Alakazam](#065-alakazam) | Psíquico | Sincronía / Fuerza Mental |  | sí |
| 066 | [Machop](#066-machop) | Lucha | Agallas |  | sí |
| 067 | [Machoke](#067-machoke) | Lucha | Agallas |  | sí |
| 068 | [Machamp](#068-machamp) | Lucha | Agallas |  | sí |
| 069 | [Bellsprout](#069-bellsprout) | Planta/Veneno | Clorofila |  | sí |
| 070 | [Weepinbell](#070-weepinbell) | Planta/Veneno | Clorofila |  | sí |
| 071 | [Victreebel](#071-victreebel) | Planta/Veneno | Clorofila |  | sí |
| 072 | [Tentacool](#072-tentacool) | Agua/Veneno | Cuerpo Puro / Lodo Líquido |  | sí |
| 073 | [Tentacruel](#073-tentacruel) | Agua/Veneno | Cuerpo Puro / Lodo Líquido |  | sí |
| 074 | [Geodude](#074-geodude) | Roca/Tierra | Cabeza Roca / Robustez |  | sí |
| 075 | [Graveler](#075-graveler) | Roca/Tierra | Cabeza Roca / Robustez |  | sí |
| 076 | [Golem](#076-golem) | Roca/Tierra | Cabeza Roca / Robustez |  |  |
| 077 | [Ponyta](#077-ponyta) | Fuego | Fuga / Absorbe Fuego |  | sí |
| 078 | [Rapidash](#078-rapidash) | Fuego | Fuga / Absorbe Fuego |  | sí |
| 079 | [Slowpoke](#079-slowpoke) | Agua/Psíquico | Despiste / Ritmo Propio |  | sí |
| 080 | [Slowbro](#080-slowbro) | Agua/Psíquico | Despiste / Ritmo Propio |  | sí |
| 081 | [Magnemite](#081-magnemite) | Eléctrico/Acero | Imán / Robustez |  | sí |
| 082 | [Magneton](#082-magneton) | Eléctrico/Acero | Imán / Robustez |  | sí |
| 083 | [Farfetch’d](#083-farfetchd) | Normal/Volador | Vista Lince / Fuerza Mental |  | sí |
| 084 | [Doduo](#084-doduo) | Normal/Volador | Fuga / Madrugar |  | sí |
| 085 | [Dodrio](#085-dodrio) | Normal/Volador | Fuga / Madrugar |  | sí |
| 086 | [Seel](#086-seel) | Agua | Sebo |  | sí |
| 087 | [Dewgong](#087-dewgong) | Agua/Hielo | Sebo |  | sí |
| 088 | [Grimer](#088-grimer) | Veneno | Hedor / Viscosidad |  | sí |
| 089 | [Muk](#089-muk) | Veneno | Hedor / Viscosidad |  | sí |
| 090 | [Shellder](#090-shellder) | Agua | Caparazón |  | sí |
| 091 | [Cloyster](#091-cloyster) | Agua/Hielo | Caparazón |  | sí |
| 092 | [Gastly](#092-gastly) | Fantasma/Veneno | Levitación |  | sí |
| 093 | [Haunter](#093-haunter) | Fantasma/Veneno | Levitación |  | sí |
| 094 | [Gengar](#094-gengar) | Fantasma/Veneno | Levitación |  | sí |
| 095 | [Onix](#095-onix) | Roca/Tierra | Cabeza Roca / Robustez | Coloso | sí |
| 096 | [Drowzee](#096-drowzee) | Psíquico | Insomnio |  | sí |
| 097 | [Hypno](#097-hypno) | Psíquico | Insomnio |  | sí |
| 098 | [Krabby](#098-krabby) | Agua | Corte Fuerte / Caparazón |  |  |
| 099 | [Kingler](#099-kingler) | Agua | Corte Fuerte / Caparazón |  | sí |
| 100 | [Voltorb](#100-voltorb) | Eléctrico | Insonorizar / Electricidad Estática |  | sí |
| 101 | [Electrode](#101-electrode) | Eléctrico | Insonorizar / Electricidad Estática |  | sí |
| 102 | [Exeggcute](#102-exeggcute) | Planta/Psíquico | Clorofila |  | sí |
| 103 | [Exeggutor](#103-exeggutor) | Planta/Psíquico | Clorofila |  | sí |
| 104 | [Cubone](#104-cubone) | Tierra | Cabeza Roca / Pararrayos |  | sí |
| 105 | [Marowak](#105-marowak) | Tierra | Cabeza Roca / Pararrayos |  | sí |
| 106 | [Hitmonlee](#106-hitmonlee) | Lucha | Flexibilidad |  | sí |
| 107 | [Hitmonchan](#107-hitmonchan) | Lucha | Vista Lince |  | sí |
| 108 | [Lickitung](#108-lickitung) | Normal | Ritmo Propio / Despiste |  | sí |
| 109 | [Koffing](#109-koffing) | Veneno | Levitación |  | sí |
| 110 | [Weezing](#110-weezing) | Veneno | Levitación |  | sí |
| 111 | [Rhyhorn](#111-rhyhorn) | Tierra/Roca | Pararrayos / Cabeza Roca |  | sí |
| 112 | [Rhydon](#112-rhydon) | Tierra/Roca | Pararrayos / Cabeza Roca |  | sí |
| 113 | [Chansey](#113-chansey) | Normal | Cura Natural / Dicha |  | sí |
| 114 | [Tangela](#114-tangela) | Planta | Clorofila |  | sí |
| 115 | [Kangaskhan](#115-kangaskhan) | Normal | Madrugar |  | sí |
| 116 | [Horsea](#116-horsea) | Agua | Nado Rápido |  | sí |
| 117 | [Seadra](#117-seadra) | Agua | Punto Tóxico |  | sí |
| 118 | [Goldeen](#118-goldeen) | Agua | Nado Rápido / Velo Agua |  | sí |
| 119 | [Seaking](#119-seaking) | Agua | Nado Rápido / Velo Agua |  | sí |
| 120 | [Staryu](#120-staryu) | Agua | Iluminación / Cura Natural |  | sí |
| 121 | [Starmie](#121-starmie) | Agua/Psíquico | Iluminación / Cura Natural | Núcleo Prisma | sí |
| 122 | [Mr. Mime](#122-mr-mime) | Psíquico/Hada | Insonorizar |  | sí |
| 123 | [Scyther](#123-scyther) | Bicho/Volador | Enjambre |  | sí |
| 124 | [Jynx](#124-jynx) | Hielo/Psíquico | Despiste |  | sí |
| 125 | [Electabuzz](#125-electabuzz) | Eléctrico | Electricidad Estática |  | sí |
| 126 | [Magmar](#126-magmar) | Fuego | Cuerpo Llama |  |  |
| 127 | [Pinsir](#127-pinsir) | Bicho | Corte Fuerte |  |  |
| 128 | [Tauros](#128-tauros) | Normal | Intimidación |  | sí |
| 129 | [Magikarp](#129-magikarp) | Agua | Nado Rápido |  | sí |
| 130 | [Gyarados](#130-gyarados) | Agua/Volador | Intimidación |  | sí |
| 131 | [Lapras](#131-lapras) | Agua/Hielo | Absorbe Agua / Caparazón |  | sí |
| 132 | [Ditto](#132-ditto) | Normal | Flexibilidad |  | sí |
| 133 | [Eevee](#133-eevee) | Normal | Fuga |  | sí |
| 134 | [Vaporeon](#134-vaporeon) | Agua | Absorbe Agua |  |  |
| 135 | [Jolteon](#135-jolteon) | Eléctrico | Absorbe Electricidad |  |  |
| 136 | [Flareon](#136-flareon) | Fuego | Absorbe Fuego |  |  |
| 137 | [Porygon](#137-porygon) | Normal | Calco |  |  |
| 138 | [Omanyte](#138-omanyte) | Roca/Agua | Nado Rápido / Caparazón |  | sí |
| 139 | [Omastar](#139-omastar) | Roca/Agua | Nado Rápido / Caparazón |  |  |
| 140 | [Kabuto](#140-kabuto) | Roca/Agua | Nado Rápido / Armadura Batalla |  | sí |
| 141 | [Kabutops](#141-kabutops) | Roca/Agua | Nado Rápido / Armadura Batalla |  |  |
| 142 | [Aerodactyl](#142-aerodactyl) | Roca/Volador | Cabeza Roca / Presión |  | sí |
| 143 | [Snorlax](#143-snorlax) | Normal | Inmunidad / Sebo |  | sí |
| 144 | [Articuno](#144-articuno) | Hielo/Volador | Presión |  | sí |
| 145 | [Zapdos](#145-zapdos) | Eléctrico/Volador | Presión |  | sí |
| 146 | [Moltres](#146-moltres) | Fuego/Volador | Presión |  |  |
| 147 | [Dratini](#147-dratini) | Dragón | Mudar |  |  |
| 148 | [Dragonair](#148-dragonair) | Dragón | Mudar |  | sí |
| 149 | [Dragonite](#149-dragonite) | Dragón/Volador | Fuerza Mental |  | sí |
| 150 | [Mewtwo](#150-mewtwo) | Psíquico | Presión |  |  |
| 151 | [Mew](#151-mew) | Psíquico | Sincronía |  |  |
| 152 | [Chikorita](#152-chikorita) | Planta | Espesura |  |  |
| 153 | [Bayleef](#153-bayleef) | Planta | Espesura |  |  |
| 154 | [Meganium](#154-meganium) | Planta | Espesura |  |  |
| 155 | [Cyndaquil](#155-cyndaquil) | Fuego | Mar Llamas |  |  |
| 156 | [Quilava](#156-quilava) | Fuego | Mar Llamas |  |  |
| 157 | [Typhlosion](#157-typhlosion) | Fuego | Mar Llamas |  |  |
| 158 | [Totodile](#158-totodile) | Agua | Torrente |  |  |
| 159 | [Croconaw](#159-croconaw) | Agua | Torrente |  |  |
| 160 | [Feraligatr](#160-feraligatr) | Agua | Torrente |  |  |
| 161 | [Sentret](#161-sentret) | Normal | Fuga / Vista Lince |  |  |
| 162 | [Furret](#162-furret) | Normal | Fuga / Vista Lince |  |  |
| 163 | [Hoothoot](#163-hoothoot) | Normal/Volador | Insomnio / Vista Lince |  |  |
| 164 | [Noctowl](#164-noctowl) | Normal/Volador | Insomnio / Vista Lince |  |  |
| 165 | [Ledyba](#165-ledyba) | Bicho/Volador | Enjambre / Madrugar |  |  |
| 166 | [Ledian](#166-ledian) | Bicho/Volador | Enjambre / Madrugar |  |  |
| 167 | [Spinarak](#167-spinarak) | Bicho/Veneno | Enjambre / Insomnio |  |  |
| 168 | [Ariados](#168-ariados) | Bicho/Veneno | Enjambre / Insomnio |  |  |
| 169 | [Crobat](#169-crobat) | Veneno/Volador | Fuerza Mental |  |  |
| 170 | [Chinchou](#170-chinchou) | Agua/Eléctrico | Absorbe Electricidad / Iluminación |  |  |
| 171 | [Lanturn](#171-lanturn) | Agua/Eléctrico | Absorbe Electricidad / Iluminación |  |  |
| 172 | [Pichu](#172-pichu) | Eléctrico | Electricidad Estática |  |  |
| 173 | [Cleffa](#173-cleffa) | Hada | Gran Encanto |  |  |
| 174 | [Igglybuff](#174-igglybuff) | Normal/Hada | Gran Encanto |  |  |
| 175 | [Togepi](#175-togepi) | Hada | Entusiasmo / Dicha |  |  |
| 176 | [Togetic](#176-togetic) | Hada/Volador | Entusiasmo / Dicha |  |  |
| 177 | [Natu](#177-natu) | Psíquico/Volador | Sincronía / Madrugar |  |  |
| 178 | [Xatu](#178-xatu) | Psíquico/Volador | Sincronía / Madrugar |  |  |
| 179 | [Mareep](#179-mareep) | Eléctrico | Electricidad Estática |  |  |
| 180 | [Flaaffy](#180-flaaffy) | Eléctrico | Electricidad Estática |  |  |
| 181 | [Ampharos](#181-ampharos) | Eléctrico | Electricidad Estática |  |  |
| 182 | [Bellossom](#182-bellossom) | Planta | Clorofila |  |  |
| 183 | [Marill](#183-marill) | Agua/Hada | Sebo / Potencia |  |  |
| 184 | [Azumarill](#184-azumarill) | Agua/Hada | Sebo / Potencia |  |  |
| 185 | [Sudowoodo](#185-sudowoodo) | Roca | Robustez / Cabeza Roca |  |  |
| 186 | [Politoed](#186-politoed) | Agua | Absorbe Agua / Humedad |  |  |
| 187 | [Hoppip](#187-hoppip) | Planta/Volador | Clorofila |  |  |
| 188 | [Skiploom](#188-skiploom) | Planta/Volador | Clorofila |  |  |
| 189 | [Jumpluff](#189-jumpluff) | Planta/Volador | Clorofila |  |  |
| 190 | [Aipom](#190-aipom) | Normal | Fuga / Recogida |  |  |
| 191 | [Sunkern](#191-sunkern) | Planta | Clorofila |  |  |
| 192 | [Sunflora](#192-sunflora) | Planta | Clorofila |  |  |
| 193 | [Yanma](#193-yanma) | Bicho/Volador | Impulso / Ojo Compuesto |  |  |
| 194 | [Wooper](#194-wooper) | Agua/Tierra | Humedad / Absorbe Agua |  |  |
| 195 | [Quagsire](#195-quagsire) | Agua/Tierra | Humedad / Absorbe Agua |  |  |
| 196 | [Espeon](#196-espeon) | Psíquico | Sincronía |  |  |
| 197 | [Umbreon](#197-umbreon) | Siniestro | Sincronía |  |  |
| 198 | [Murkrow](#198-murkrow) | Siniestro/Volador | Insomnio |  |  |
| 199 | [Slowking](#199-slowking) | Agua/Psíquico | Despiste / Ritmo Propio |  |  |
| 200 | [Misdreavus](#200-misdreavus) | Fantasma | Levitación |  |  |
| 201 | [Unown](#201-unown) | Psíquico | Levitación |  |  |
| 202 | [Wobbuffet](#202-wobbuffet) | Psíquico | Sombra Trampa |  |  |
| 203 | [Girafarig](#203-girafarig) | Normal/Psíquico | Fuerza Mental / Madrugar |  |  |
| 204 | [Pineco](#204-pineco) | Bicho | Robustez |  |  |
| 205 | [Forretress](#205-forretress) | Bicho/Acero | Robustez |  |  |
| 206 | [Dunsparce](#206-dunsparce) | Normal | Dicha / Fuga |  |  |
| 207 | [Gligar](#207-gligar) | Tierra/Volador | Corte Fuerte / Velo Arena |  |  |
| 208 | [Steelix](#208-steelix) | Acero/Tierra | Cabeza Roca / Robustez |  |  |
| 209 | [Snubbull](#209-snubbull) | Hada | Intimidación / Fuga |  |  |
| 210 | [Granbull](#210-granbull) | Hada | Intimidación |  |  |
| 211 | [Qwilfish](#211-qwilfish) | Agua/Veneno | Punto Tóxico / Nado Rápido |  |  |
| 212 | [Scizor](#212-scizor) | Bicho/Acero | Enjambre |  |  |
| 213 | [Shuckle](#213-shuckle) | Bicho/Roca | Robustez |  |  |
| 214 | [Heracross](#214-heracross) | Bicho/Lucha | Enjambre / Agallas |  |  |
| 215 | [Sneasel](#215-sneasel) | Siniestro/Hielo | Fuerza Mental / Vista Lince |  |  |
| 216 | [Teddiursa](#216-teddiursa) | Normal | Recogida |  |  |
| 217 | [Ursaring](#217-ursaring) | Normal | Agallas |  |  |
| 218 | [Slugma](#218-slugma) | Fuego | Escudo Magma / Cuerpo Llama |  |  |
| 219 | [Magcargo](#219-magcargo) | Fuego/Roca | Escudo Magma / Cuerpo Llama |  |  |
| 220 | [Swinub](#220-swinub) | Hielo/Tierra | Despiste |  |  |
| 221 | [Piloswine](#221-piloswine) | Hielo/Tierra | Despiste |  |  |
| 222 | [Corsola](#222-corsola) | Agua/Roca | Entusiasmo / Cura Natural |  |  |
| 223 | [Remoraid](#223-remoraid) | Agua | Entusiasmo |  |  |
| 224 | [Octillery](#224-octillery) | Agua | Ventosas |  |  |
| 225 | [Delibird](#225-delibird) | Hielo/Volador | Espíritu Vital / Entusiasmo |  |  |
| 226 | [Mantine](#226-mantine) | Agua/Volador | Nado Rápido / Absorbe Agua |  |  |
| 227 | [Skarmory](#227-skarmory) | Acero/Volador | Vista Lince / Robustez |  |  |
| 228 | [Houndour](#228-houndour) | Siniestro/Fuego | Madrugar / Absorbe Fuego |  |  |
| 229 | [Houndoom](#229-houndoom) | Siniestro/Fuego | Madrugar / Absorbe Fuego |  |  |
| 230 | [Kingdra](#230-kingdra) | Agua/Dragón | Nado Rápido |  |  |
| 231 | [Phanpy](#231-phanpy) | Tierra | Recogida |  |  |
| 232 | [Donphan](#232-donphan) | Tierra | Robustez |  |  |
| 233 | [Porygon2](#233-porygon2) | Normal | Calco |  |  |
| 234 | [Stantler](#234-stantler) | Normal | Intimidación |  |  |
| 235 | [Smeargle](#235-smeargle) | Normal | Ritmo Propio |  |  |
| 236 | [Tyrogue](#236-tyrogue) | Lucha | Agallas |  |  |
| 237 | [Hitmontop](#237-hitmontop) | Lucha | Intimidación |  |  |
| 238 | [Smoochum](#238-smoochum) | Hielo/Psíquico | Despiste |  |  |
| 239 | [Elekid](#239-elekid) | Eléctrico | Electricidad Estática |  |  |
| 240 | [Magby](#240-magby) | Fuego | Cuerpo Llama |  |  |
| 241 | [Miltank](#241-miltank) | Normal | Sebo |  |  |
| 242 | [Blissey](#242-blissey) | Normal | Cura Natural / Dicha |  |  |
| 243 | [Raikou](#243-raikou) | Eléctrico | Presión |  |  |
| 244 | [Entei](#244-entei) | Fuego | Presión |  |  |
| 245 | [Suicune](#245-suicune) | Agua | Presión |  |  |
| 246 | [Larvitar](#246-larvitar) | Roca/Tierra | Agallas |  |  |
| 247 | [Pupitar](#247-pupitar) | Roca/Tierra | Mudar |  |  |
| 248 | [Tyranitar](#248-tyranitar) | Roca/Siniestro | Chorro Arena |  |  |
| 249 | [Lugia](#249-lugia) | Psíquico/Volador | Presión |  |  |
| 250 | [Ho-Oh](#250-hooh) | Fuego/Volador | Presión |  |  |
| 251 | [Celebi](#251-celebi) | Psíquico/Planta | Cura Natural |  |  |
| 252 | [Treecko](#252-treecko) | Planta | Espesura |  |  |
| 253 | [Grovyle](#253-grovyle) | Planta | Espesura |  |  |
| 254 | [Sceptile](#254-sceptile) | Planta | Espesura |  |  |
| 255 | [Torchic](#255-torchic) | Fuego | Mar Llamas |  |  |
| 256 | [Combusken](#256-combusken) | Fuego/Lucha | Mar Llamas |  |  |
| 257 | [Blaziken](#257-blaziken) | Fuego/Lucha | Mar Llamas |  |  |
| 258 | [Mudkip](#258-mudkip) | Agua | Torrente |  |  |
| 259 | [Marshtomp](#259-marshtomp) | Agua/Tierra | Torrente |  |  |
| 260 | [Swampert](#260-swampert) | Agua/Tierra | Torrente |  |  |
| 261 | [Poochyena](#261-poochyena) | Siniestro | Fuga |  |  |
| 262 | [Mightyena](#262-mightyena) | Siniestro | Intimidación |  |  |
| 263 | [Zigzagoon](#263-zigzagoon) | Normal | Recogida |  |  |
| 264 | [Linoone](#264-linoone) | Normal | Recogida |  |  |
| 265 | [Wurmple](#265-wurmple) | Bicho | Polvo Escudo |  |  |
| 266 | [Silcoon](#266-silcoon) | Bicho | Mudar |  |  |
| 267 | [Beautifly](#267-beautifly) | Bicho/Volador | Enjambre |  |  |
| 268 | [Cascoon](#268-cascoon) | Bicho | Mudar |  |  |
| 269 | [Dustox](#269-dustox) | Bicho/Veneno | Polvo Escudo |  |  |
| 270 | [Lotad](#270-lotad) | Agua/Planta | Nado Rápido / Cura Lluvia |  |  |
| 271 | [Lombre](#271-lombre) | Agua/Planta | Nado Rápido / Cura Lluvia |  |  |
| 272 | [Ludicolo](#272-ludicolo) | Agua/Planta | Nado Rápido / Cura Lluvia |  |  |
| 273 | [Seedot](#273-seedot) | Planta | Clorofila / Madrugar |  |  |
| 274 | [Nuzleaf](#274-nuzleaf) | Planta/Siniestro | Clorofila / Madrugar |  |  |
| 275 | [Shiftry](#275-shiftry) | Planta/Siniestro | Clorofila |  |  |
| 276 | [Taillow](#276-taillow) | Normal/Volador | Agallas |  |  |
| 277 | [Swellow](#277-swellow) | Normal/Volador | Agallas |  |  |
| 278 | [Wingull](#278-wingull) | Agua/Volador | Vista Lince |  |  |
| 279 | [Pelipper](#279-pelipper) | Agua/Volador | Vista Lince / Llovizna |  |  |
| 280 | [Ralts](#280-ralts) | Psíquico/Hada | Sincronía / Calco |  |  |
| 281 | [Kirlia](#281-kirlia) | Psíquico/Hada | Sincronía / Calco |  |  |
| 282 | [Gardevoir](#282-gardevoir) | Psíquico/Hada | Sincronía / Calco |  |  |
| 283 | [Surskit](#283-surskit) | Bicho/Agua | Nado Rápido |  |  |
| 284 | [Masquerain](#284-masquerain) | Bicho/Volador | Intimidación |  |  |
| 285 | [Shroomish](#285-shroomish) | Planta | Efecto Espora |  |  |
| 286 | [Breloom](#286-breloom) | Planta/Lucha | Efecto Espora |  |  |
| 287 | [Slakoth](#287-slakoth) | Normal | Ausente |  |  |
| 288 | [Vigoroth](#288-vigoroth) | Normal | Espíritu Vital |  |  |
| 289 | [Slaking](#289-slaking) | Normal | Ausente |  |  |
| 290 | [Nincada](#290-nincada) | Bicho/Tierra | Ojo Compuesto |  |  |
| 291 | [Ninjask](#291-ninjask) | Bicho/Volador | Impulso |  |  |
| 292 | [Shedinja](#292-shedinja) | Bicho/Fantasma | Superguarda |  |  |
| 293 | [Whismur](#293-whismur) | Normal | Insonorizar |  |  |
| 294 | [Loudred](#294-loudred) | Normal | Insonorizar |  |  |
| 295 | [Exploud](#295-exploud) | Normal | Insonorizar |  |  |
| 296 | [Makuhita](#296-makuhita) | Lucha | Sebo / Agallas |  |  |
| 297 | [Hariyama](#297-hariyama) | Lucha | Sebo / Agallas |  |  |
| 298 | [Azurill](#298-azurill) | Normal/Hada | Sebo / Potencia |  |  |
| 299 | [Nosepass](#299-nosepass) | Roca | Robustez / Imán |  |  |
| 300 | [Skitty](#300-skitty) | Normal | Gran Encanto |  |  |
| 301 | [Delcatty](#301-delcatty) | Normal | Gran Encanto |  |  |
| 302 | [Sableye](#302-sableye) | Siniestro/Fantasma | Vista Lince |  |  |
| 303 | [Mawile](#303-mawile) | Acero/Hada | Corte Fuerte / Intimidación |  |  |
| 304 | [Aron](#304-aron) | Acero/Roca | Robustez / Cabeza Roca |  |  |
| 305 | [Lairon](#305-lairon) | Acero/Roca | Robustez / Cabeza Roca |  |  |
| 306 | [Aggron](#306-aggron) | Acero/Roca | Robustez / Cabeza Roca |  |  |
| 307 | [Meditite](#307-meditite) | Lucha/Psíquico | Energía Pura |  |  |
| 308 | [Medicham](#308-medicham) | Lucha/Psíquico | Energía Pura |  |  |
| 309 | [Electrike](#309-electrike) | Eléctrico | Electricidad Estática / Pararrayos |  |  |
| 310 | [Manectric](#310-manectric) | Eléctrico | Electricidad Estática / Pararrayos |  |  |
| 311 | [Plusle](#311-plusle) | Eléctrico | Más |  |  |
| 312 | [Minun](#312-minun) | Eléctrico | Menos |  |  |
| 313 | [Volbeat](#313-volbeat) | Bicho | Iluminación / Enjambre |  |  |
| 314 | [Illumise](#314-illumise) | Bicho | Despiste |  |  |
| 315 | [Roselia](#315-roselia) | Planta/Veneno | Cura Natural / Punto Tóxico |  |  |
| 316 | [Gulpin](#316-gulpin) | Veneno | Lodo Líquido / Viscosidad |  |  |
| 317 | [Swalot](#317-swalot) | Veneno | Lodo Líquido / Viscosidad |  |  |
| 318 | [Carvanha](#318-carvanha) | Agua/Siniestro | Piel Tosca |  |  |
| 319 | [Sharpedo](#319-sharpedo) | Agua/Siniestro | Piel Tosca |  |  |
| 320 | [Wailmer](#320-wailmer) | Agua | Velo Agua / Despiste |  |  |
| 321 | [Wailord](#321-wailord) | Agua | Velo Agua / Despiste |  |  |
| 322 | [Numel](#322-numel) | Fuego/Tierra | Despiste |  |  |
| 323 | [Camerupt](#323-camerupt) | Fuego/Tierra | Escudo Magma |  |  |
| 324 | [Torkoal](#324-torkoal) | Fuego | Humo Blanco / Sequía |  |  |
| 325 | [Spoink](#325-spoink) | Psíquico | Sebo / Ritmo Propio |  |  |
| 326 | [Grumpig](#326-grumpig) | Psíquico | Sebo / Ritmo Propio |  |  |
| 327 | [Spinda](#327-spinda) | Normal | Ritmo Propio |  |  |
| 328 | [Trapinch](#328-trapinch) | Tierra | Corte Fuerte / Trampa Arena |  |  |
| 329 | [Vibrava](#329-vibrava) | Tierra/Dragón | Levitación |  |  |
| 330 | [Flygon](#330-flygon) | Tierra/Dragón | Levitación |  |  |
| 331 | [Cacnea](#331-cacnea) | Planta | Velo Arena |  |  |
| 332 | [Cacturne](#332-cacturne) | Planta/Siniestro | Velo Arena |  |  |
| 333 | [Swablu](#333-swablu) | Normal/Volador | Cura Natural |  |  |
| 334 | [Altaria](#334-altaria) | Dragón/Volador | Cura Natural |  |  |
| 335 | [Zangoose](#335-zangoose) | Normal | Inmunidad |  |  |
| 336 | [Seviper](#336-seviper) | Veneno | Mudar |  |  |
| 337 | [Lunatone](#337-lunatone) | Roca/Psíquico | Levitación |  |  |
| 338 | [Solrock](#338-solrock) | Roca/Psíquico | Levitación |  |  |
| 339 | [Barboach](#339-barboach) | Agua/Tierra | Despiste |  |  |
| 340 | [Whiscash](#340-whiscash) | Agua/Tierra | Despiste |  |  |
| 341 | [Corphish](#341-corphish) | Agua | Corte Fuerte / Caparazón |  |  |
| 342 | [Crawdaunt](#342-crawdaunt) | Agua/Siniestro | Corte Fuerte / Caparazón |  |  |
| 343 | [Baltoy](#343-baltoy) | Tierra/Psíquico | Levitación |  |  |
| 344 | [Claydol](#344-claydol) | Tierra/Psíquico | Levitación |  |  |
| 345 | [Lileep](#345-lileep) | Roca/Planta | Ventosas |  |  |
| 346 | [Cradily](#346-cradily) | Roca/Planta | Ventosas |  |  |
| 347 | [Anorith](#347-anorith) | Roca/Bicho | Armadura Batalla |  |  |
| 348 | [Armaldo](#348-armaldo) | Roca/Bicho | Armadura Batalla |  |  |
| 349 | [Feebas](#349-feebas) | Agua | Nado Rápido / Despiste |  |  |
| 350 | [Milotic](#350-milotic) | Agua | Escama Especial |  |  |
| 351 | [Castform](#351-castform) | Normal | Predicción |  |  |
| 352 | [Kecleon](#352-kecleon) | Normal | Cambio Color |  |  |
| 353 | [Shuppet](#353-shuppet) | Fantasma | Insomnio |  |  |
| 354 | [Banette](#354-banette) | Fantasma | Insomnio |  |  |
| 355 | [Duskull](#355-duskull) | Fantasma | Levitación |  |  |
| 356 | [Dusclops](#356-dusclops) | Fantasma | Presión |  |  |
| 357 | [Tropius](#357-tropius) | Planta/Volador | Clorofila |  |  |
| 358 | [Chimecho](#358-chimecho) | Psíquico | Levitación |  |  |
| 359 | [Absol](#359-absol) | Siniestro | Presión |  |  |
| 360 | [Wynaut](#360-wynaut) | Psíquico | Sombra Trampa |  |  |
| 361 | [Snorunt](#361-snorunt) | Hielo | Fuerza Mental |  |  |
| 362 | [Glalie](#362-glalie) | Hielo | Fuerza Mental |  |  |
| 363 | [Spheal](#363-spheal) | Hielo/Agua | Sebo |  |  |
| 364 | [Sealeo](#364-sealeo) | Hielo/Agua | Sebo |  |  |
| 365 | [Walrein](#365-walrein) | Hielo/Agua | Sebo |  |  |
| 366 | [Clamperl](#366-clamperl) | Agua | Caparazón |  |  |
| 367 | [Huntail](#367-huntail) | Agua | Nado Rápido |  |  |
| 368 | [Gorebyss](#368-gorebyss) | Agua | Nado Rápido |  |  |
| 369 | [Relicanth](#369-relicanth) | Agua/Roca | Nado Rápido / Cabeza Roca |  |  |
| 370 | [Luvdisc](#370-luvdisc) | Agua | Nado Rápido |  |  |
| 371 | [Bagon](#371-bagon) | Dragón | Cabeza Roca |  |  |
| 372 | [Shelgon](#372-shelgon) | Dragón | Cabeza Roca |  |  |
| 373 | [Salamence](#373-salamence) | Dragón/Volador | Intimidación |  |  |
| 374 | [Beldum](#374-beldum) | Acero/Psíquico | Cuerpo Puro |  |  |
| 375 | [Metang](#375-metang) | Acero/Psíquico | Cuerpo Puro |  |  |
| 376 | [Metagross](#376-metagross) | Acero/Psíquico | Cuerpo Puro |  |  |
| 377 | [Regirock](#377-regirock) | Roca | Cuerpo Puro |  |  |
| 378 | [Regice](#378-regice) | Hielo | Cuerpo Puro |  |  |
| 379 | [Registeel](#379-registeel) | Acero | Cuerpo Puro |  |  |
| 380 | [Latias](#380-latias) | Dragón/Psíquico | Levitación |  |  |
| 381 | [Latios](#381-latios) | Dragón/Psíquico | Levitación |  |  |
| 382 | [Kyogre](#382-kyogre) | Agua | Llovizna |  |  |
| 383 | [Groudon](#383-groudon) | Tierra | Sequía |  |  |
| 384 | [Rayquaza](#384-rayquaza) | Dragón/Volador | Bucle Aire |  |  |
| 385 | [Jirachi](#385-jirachi) | Acero/Psíquico | Dicha |  |  |
| 386 | [Deoxys](#386-deoxys) | Psíquico | Presión |  |  |

## Fichas

### 001 Bulbasaur

Planta/Veneno · Pokémon Semilla · **aparece en el juego**

**Habilidad — Espesura**: Con menos de 1/3 de vida sus ataques de tipo Planta pegan ×1,5.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 4 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 7 | Drenadoras | Planta | Estado | Área | — | 6.0 s |
| 10 | Látigo Cepa | Planta | Físico | Embestida | 45 | 1.6 s |
| 15 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 15 | Somnífero | Planta | Estado | Zona | — | 12.0 s |
| 20 | Hoja Afilada | Planta | Físico | Disparo | 55 | 1.7 s |
| 25 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 32 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 39 | Fotosíntesis | Planta | Estado | Mejora propia | — | 10.0 s |
| 46 | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 002 Ivysaur

Planta/Veneno · Pokémon Semilla · **aparece en el juego**

**Habilidad — Espesura**: Con menos de 1/3 de vida sus ataques de tipo Planta pegan ×1,5.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Drenadoras | Planta | Estado | Área | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 10 | Látigo Cepa | Planta | Físico | Embestida | 45 | 1.6 s |
| 15 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 15 | Somnífero | Planta | Estado | Zona | — | 12.0 s |
| 22 | Hoja Afilada | Planta | Físico | Disparo | 55 | 1.7 s |
| 29 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 38 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 47 | Fotosíntesis | Planta | Estado | Mejora propia | — | 10.0 s |
| 56 | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 003 Venusaur

Planta/Veneno · Pokémon Semilla · **aparece en el juego**

**Habilidad — Espesura**: Con menos de 1/3 de vida sus ataques de tipo Planta pegan ×1,5.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Drenadoras | Planta | Estado | Área | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Látigo Cepa | Planta | Físico | Embestida | 45 | 1.6 s |
| 15 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 15 | Somnífero | Planta | Estado | Zona | — | 12.0 s |
| 22 | Hoja Afilada | Planta | Físico | Disparo | 55 | 1.7 s |
| 29 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 41 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 53 | Fotosíntesis | Planta | Estado | Mejora propia | — | 10.0 s |
| 65 | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 004 Charmander

Fuego · Pokémon Lagartija · **aparece en el juego**

**Habilidad — Mar Llamas**: Con menos de 1/3 de vida sus ataques de tipo Fuego pegan ×1,5.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 7 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 13 | Garra Metal | Acero | Físico | Golpe | 50 | 1.3 s |
| 19 | Pantalla de Humo | Normal | Estado | Zona | — | 9.0 s |
| 25 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 31 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| 37 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 43 | Furia Dragón | Dragón | Especial | Disparo | 50 | 2.0 s |
| 49 | Giro Fuego | Fuego | Especial | Área | 35 | 3.0 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 005 Charmeleon

Fuego · Pokémon Llama · **aparece en el juego**

**Habilidad — Mar Llamas**: Con menos de 1/3 de vida sus ataques de tipo Fuego pegan ×1,5.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 13 | Garra Metal | Acero | Físico | Golpe | 50 | 1.3 s |
| 20 | Pantalla de Humo | Normal | Estado | Zona | — | 9.0 s |
| 27 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 34 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| 41 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 48 | Furia Dragón | Dragón | Especial | Disparo | 50 | 2.0 s |
| 55 | Giro Fuego | Fuego | Especial | Área | 35 | 3.0 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 006 Charizard

Fuego/Volador · Pokémon Llama · **aparece en el juego**

**Habilidad — Mar Llamas**: Con menos de 1/3 de vida sus ataques de tipo Fuego pegan ×1,5.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Onda Ígnea | Fuego | Especial | Área | 95 | 4.7 s |
| 1 | Garra Metal | Acero | Físico | Golpe | 50 | 1.3 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 20 | Pantalla de Humo | Normal | Estado | Zona | — | 9.0 s |
| 27 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 34 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| 36 | Ataque Ala | Volador | Físico | Embestida | 60 | 1.9 s |
| 44 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 54 | Furia Dragón | Dragón | Especial | Disparo | 50 | 2.0 s |
| 64 | Giro Fuego | Fuego | Especial | Área | 35 | 3.0 s |

**Por MT/MO (28)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 007 Squirtle

Agua · Pokémon Tortuguita · **aparece en el juego**

**Habilidad — Torrente**: Con menos de 1/3 de vida sus ataques de tipo Agua pegan ×1,5.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 4 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 7 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 10 | Refugio | Agua | Estado | Mejora propia | — | 9.0 s |
| 13 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 18 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 23 | Giro Rápido | Normal | Físico | Embestida | 50 | 7.0 s |
| 28 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 33 | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| 40 | Cabezazo | Normal | Físico | Embestida | 130 | 2.9 s |
| 47 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 008 Wartortle

Agua · Pokémon Tortuga · **aparece en el juego**

**Habilidad — Torrente**: Con menos de 1/3 de vida sus ataques de tipo Agua pegan ×1,5.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 10 | Refugio | Agua | Estado | Mejora propia | — | 9.0 s |
| 13 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 19 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 25 | Giro Rápido | Normal | Físico | Embestida | 50 | 7.0 s |
| 31 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 37 | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| 45 | Cabezazo | Normal | Físico | Embestida | 130 | 2.9 s |
| 53 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 009 Blastoise

Agua · Pokémon Armazón · **aparece en el juego**

**Habilidad — Torrente**: Con menos de 1/3 de vida sus ataques de tipo Agua pegan ×1,5.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 1 | Refugio | Agua | Estado | Mejora propia | — | 9.0 s |
| 13 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 19 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 25 | Giro Rápido | Normal | Físico | Embestida | 50 | 7.0 s |
| 31 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 42 | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| 55 | Cabezazo | Normal | Físico | Embestida | 130 | 2.9 s |
| 68 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (27)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 010 Caterpie

Bicho · Pokémon Gusano · **aparece en el juego**

**Habilidad — Polvo Escudo**: La mitad de las veces no le entra un problema de estado.


**Ataques que puede aprender (2)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Disparo Demora | Bicho | Estado | Disparo | — | 2.5 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |

### 011 Metapod

Bicho · Pokémon Capullo · **aparece en el juego**

**Habilidad — Mudar**: Cada 4 s se saca de encima los problemas de estado.


**Ataques que puede aprender (1)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |

### 012 Butterfree

Bicho/Volador · Pokémon Mariposa · **aparece en el juego**

**Habilidad — Ojo Compuesto**: Sus ataques con estado lo ponen un 30% más seguido.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 13 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 14 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 15 | Somnífero | Planta | Estado | Zona | — | 12.0 s |
| 18 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 23 | Remolino | Volador | Estado | Zona | — | 9.0 s |
| 28 | Tornado | Volador | Especial | Disparo | 40 | 1.5 s |
| 34 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 40 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 47 | Viento Plata | Bicho | Especial | Disparo | 60 | 1.8 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 013 Weedle

Bicho/Veneno · Pokémon Oruga · **aparece en el juego**

**Habilidad — Polvo Escudo**: La mitad de las veces no le entra un problema de estado.


**Ataques que puede aprender (2)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 1 | Disparo Demora | Bicho | Estado | Disparo | — | 2.5 s |

### 014 Kakuna

Bicho/Veneno · Pokémon Capullo · **aparece en el juego**

**Habilidad — Mudar**: Cada 4 s se saca de encima los problemas de estado.


**Ataques que puede aprender (1)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |

### 015 Beedrill

Bicho/Veneno · Pokémon Abeja Veneno · **aparece en el juego**

**Habilidad — Enjambre**: Con menos de 1/3 de vida sus ataques de tipo Bicho pegan ×1,5.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 15 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 20 | Doble Ataque | Bicho | Físico | Embestida+combo | 30 | 3.0 s |
| 25 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 30 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 35 | Pin Misil | Bicho | Físico | Disparo | 25 | 4.5 s |
| 40 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 45 | Esfuerzo | Normal | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 016 Pidgey

Normal/Volador · Pokémon Pajarito · **aparece en el juego**

**Habilidad — Vista Lince**: No lo desorientan y sus disparos pegan +10%.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 5 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 9 | Tornado | Volador | Especial | Disparo | 40 | 1.5 s |
| 13 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 19 | Remolino | Volador | Estado | Zona | — | 9.0 s |
| 25 | Ataque Ala | Volador | Físico | Embestida | 60 | 1.9 s |
| 31 | Danza Pluma | Volador | Estado | Área | — | 6.0 s |
| 39 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 47 | Espejo | Volador | Estado | Área | — | 6.0 s |

**Por MT/MO (16)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 017 Pidgeotto

Normal/Volador · Pokémon Pájaro · **aparece en el juego**

**Habilidad — Vista Lince**: No lo desorientan y sus disparos pegan +10%.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Tornado | Volador | Especial | Disparo | 40 | 1.5 s |
| 1 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 13 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 20 | Remolino | Volador | Estado | Zona | — | 9.0 s |
| 27 | Ataque Ala | Volador | Físico | Embestida | 60 | 1.9 s |
| 34 | Danza Pluma | Volador | Estado | Área | — | 6.0 s |
| 43 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 52 | Espejo | Volador | Estado | Área | — | 6.0 s |

**Por MT/MO (16)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 018 Pidgeot

Normal/Volador · Pokémon Pájaro · **aparece en el juego**

**Habilidad — Vista Lince**: No lo desorientan y sus disparos pegan +10%.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Tornado | Volador | Especial | Disparo | 40 | 1.5 s |
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 20 | Remolino | Volador | Estado | Zona | — | 9.0 s |
| 27 | Ataque Ala | Volador | Físico | Embestida | 60 | 1.9 s |
| 34 | Danza Pluma | Volador | Estado | Área | — | 6.0 s |
| 48 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 62 | Espejo | Volador | Estado | Área | — | 6.0 s |

**Por MT/MO (17)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 019 Rattata

Normal · Pokémon Ratón · **aparece en el juego**

**Habilidad — Fuga**: Esquiva mucho más seguido (recarga del esquive −40%).

**Habilidad — Agallas**: Con un problema de estado sus ataques físicos pegan ×1,5.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 7 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 13 | Hipercolmillo | Normal | Físico | Golpe | 80 | 10.0 s |
| 20 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 27 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 34 | Superdiente | Normal | Físico | Golpe | 60 | 1.4 s |
| 41 | Esfuerzo | Normal | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 020 Raticate

Normal · Pokémon Ratón · **aparece en el juego**

**Habilidad — Fuga**: Esquiva mucho más seguido (recarga del esquive −40%).

**Habilidad — Agallas**: Con un problema de estado sus ataques físicos pegan ×1,5.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 13 | Hipercolmillo | Normal | Físico | Golpe | 80 | 10.0 s |
| 20 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 30 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 40 | Superdiente | Normal | Físico | Golpe | 60 | 1.4 s |
| 50 | Esfuerzo | Normal | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (27)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 021 Spearow

Normal/Volador · Pokémon Pajarito · **aparece en el juego**

**Habilidad — Vista Lince**: No lo desorientan y sus disparos pegan +10%.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 7 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 13 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 19 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 25 | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| 31 | Espejo | Volador | Estado | Área | — | 6.0 s |
| 37 | Pico Taladro | Volador | Físico | Embestida | 80 | 2.1 s |
| 43 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (16)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 022 Fearow

Normal/Volador · Pokémon Pico · **aparece en el juego**

**Habilidad — Vista Lince**: No lo desorientan y sus disparos pegan +10%.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 26 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 32 | Espejo | Volador | Estado | Área | — | 6.0 s |
| 40 | Pico Taladro | Volador | Físico | Embestida | 80 | 2.1 s |
| 47 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (17)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 023 Ekans

Veneno · Pokémon Serpiente · **aparece en el juego**

**Habilidad — Intimidación**: Al encarar a un rival lo deja Intimidado (pega menos).

**Habilidad — Mudar**: Cada 4 s se saca de encima los problemas de estado.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 8 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 13 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 20 | Deslumbrar | Normal | Estado | Canalizado | — | 9.0 s |
| 25 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 32 | Ácido | Veneno | Especial | Disparo | 40 | 1.5 s |
| 37 | Escupir | Normal | Especial | Disparo | 60 | 1.8 s |
| 37 | Reserva | Normal | Estado | Mejora propia | — | 10.0 s |
| 37 | Tragar | Normal | Estado | Mejora propia | — | 10.0 s |
| 44 | Niebla | Hielo | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 024 Arbok

Veneno · Pokémon Cobra · **aparece en el juego**

**Habilidad — Intimidación**: Al encarar a un rival lo deja Intimidado (pega menos).

**Habilidad — Mudar**: Cada 4 s se saca de encima los problemas de estado.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 1 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 20 | Deslumbrar | Normal | Estado | Canalizado | — | 9.0 s |
| 28 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 38 | Ácido | Veneno | Especial | Disparo | 40 | 1.5 s |
| 46 | Escupir | Normal | Especial | Disparo | 60 | 1.8 s |
| 46 | Reserva | Normal | Estado | Mejora propia | — | 10.0 s |
| 46 | Tragar | Normal | Estado | Mejora propia | — | 10.0 s |
| 56 | Niebla | Hielo | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 025 Pikachu

Eléctrico · Pokémon Ratón · **aparece en el juego**

**Habilidad — Electricidad Estática**: Al que le pega cuerpo a cuerpo lo paraliza (30%).


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Impactrueno | Eléctrico | Especial | Disparo | 40 | 1.5 s |
| 6 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 8 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 11 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 15 | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| 20 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 26 | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| 33 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 41 | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| 50 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 026 Raichu

Eléctrico · Pokémon Ratón · **aparece en el juego**

**Habilidad — Electricidad Estática**: Al que le pega cuerpo a cuerpo lo paraliza (30%).

**Kit de jefe** (solo con un líder de gimnasio), firma **Toma de Tierra**: Jefe. La barra sube al pegar y al recibir; llena, planta la cola 1 s (quieto: castigalo) y suelta una descarga en anillo que deja el suelo chamuscado y electrificado 8 s. Cuerpo ×1,3, casi no lo empujan. A mitad de vida entra en Sobrecarga (+20% de daño) hasta el final.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Puño Trueno | Eléctrico | Físico | Golpe | 75 | 1.4 s |
| Clic der. | Impactrueno Triple | Eléctrico | Especial | Disparo | 40 | 2.0 s |
| Q | Chispa | Eléctrico | Físico | Embestida | 65 | 6.0 s |
| R | Trueno | Eléctrico | Especial | Zona | 90 | 9.0 s |

**Ataques que puede aprender (4)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 1 | Impactrueno | Eléctrico | Especial | Disparo | 40 | 1.5 s |
| 1 | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 027 Sandshrew

Tierra · Pokémon Ratón · **aparece en el juego**

**Habilidad — Velo Arena**: Un 12% de los golpes no le entran.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 6 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 11 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 17 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 23 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 30 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 37 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 45 | Bucle Arena | Tierra | Físico | Golpe | 35 | 1.1 s |
| 53 | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 028 Sandslash

Tierra · Pokémon Ratón · **aparece en el juego**

**Habilidad — Velo Arena**: Un 12% de los golpes no le entran.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 17 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 24 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 33 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 42 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 52 | Bucle Arena | Tierra | Físico | Golpe | 35 | 1.1 s |
| 62 | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 029 Nidoran♀

Veneno · Pokémon Pin Veneno · **aparece en el juego**

**Habilidad — Punto Tóxico**: Al que le pega cuerpo a cuerpo lo envenena (30%).


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 8 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 12 | Doble Patada | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| 17 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 20 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 23 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 30 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 38 | Camelo | Siniestro | Estado | Disparo | — | 6.0 s |
| 47 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 030 Nidorina

Veneno · Pokémon Pin Veneno · **aparece en el juego**

**Habilidad — Punto Tóxico**: Al que le pega cuerpo a cuerpo lo envenena (30%).


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 8 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 12 | Doble Patada | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| 18 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 22 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 26 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 34 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 43 | Camelo | Siniestro | Estado | Disparo | — | 6.0 s |
| 53 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 031 Nidoqueen

Veneno/Tierra · Pokémon Taladro · **aparece en el juego**

**Habilidad — Punto Tóxico**: Al que le pega cuerpo a cuerpo lo envenena (30%).


**Ataques que puede aprender (6)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Doble Patada | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| 1 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 22 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 43 | Fuerza Bruta | Lucha | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (39)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 032 Nidoran♂

Veneno · Pokémon Pin Veneno · **aparece en el juego**

**Habilidad — Punto Tóxico**: Al que le pega cuerpo a cuerpo lo envenena (30%).


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 8 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 12 | Doble Patada | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| 17 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 20 | Cornada | Normal | Físico | Embestida | 65 | 5.0 s |
| 23 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 30 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 38 | Camelo | Siniestro | Estado | Disparo | — | 6.0 s |
| 47 | Perforador | Normal | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 033 Nidorino

Veneno · Pokémon Pin Veneno · **aparece en el juego**

**Habilidad — Punto Tóxico**: Al que le pega cuerpo a cuerpo lo envenena (30%).


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 8 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 12 | Doble Patada | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| 18 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 22 | Cornada | Normal | Físico | Embestida | 65 | 5.0 s |
| 26 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 34 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 43 | Camelo | Siniestro | Estado | Disparo | — | 6.0 s |
| 53 | Perforador | Normal | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 034 Nidoking

Veneno/Tierra · Pokémon Taladro · **aparece en el juego**

**Habilidad — Punto Tóxico**: Al que le pega cuerpo a cuerpo lo envenena (30%).


**Ataques que puede aprender (6)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Doble Patada | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| 1 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 1 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 1 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 22 | Saña | Normal | Físico | Embestida | 120 | 2.7 s |
| 43 | Megacuerno | Bicho | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (38)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 035 Clefairy

Hada · Pokémon Hada · **aparece en el juego**

**Habilidad — Gran Encanto**: Al que le pega cuerpo a cuerpo lo deja Intimidado (30%).


**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 5 | Otra Vez | Normal | Estado | Área | — | 6.0 s |
| 9 | Canto | Normal | Estado | Zona | — | 12.0 s |
| 13 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 17 | Señuelo | Normal | Estado | Mejora propia | — | 10.0 s |
| 21 | Reducción | Normal | Estado | Mejora propia | — | 9.0 s |
| 25 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 29 | Metrónomo | Normal | Estado | Mejora propia | — | 10.0 s |
| 33 | Masa Cósmica | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 37 | Luz Lunar | Hada | Estado | Mejora propia | — | 10.0 s |
| 41 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 45 | Puño Meteoro | Acero | Físico | Embestida | 90 | 2.3 s |

**Por MT/MO (34)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 036 Clefable

Hada · Pokémon Hada

**Habilidad — Gran Encanto**: Al que le pega cuerpo a cuerpo lo deja Intimidado (30%).


**Ataques que puede aprender (4)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 1 | Metrónomo | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Reducción | Normal | Estado | Mejora propia | — | 9.0 s |
| 1 | Canto | Normal | Estado | Zona | — | 12.0 s |

**Por MT/MO (35)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 037 Vulpix

Fuego · Pokémon Zorro · **aparece en el juego**

**Habilidad — Absorbe Fuego**: Los ataques de Fuego no le hacen nada y le suben un 50% los suyos de Fuego por 8 s.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 5 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 9 | Rugido | Normal | Estado | Área | — | 6.0 s |
| 13 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 17 | Fuego Fatuo | Fuego | Estado | Disparo | — | 6.0 s |
| 21 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 25 | Sellar | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 29 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| 33 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 37 | Rabia | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 41 | Giro Fuego | Fuego | Especial | Área | 35 | 3.0 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 038 Ninetales

Fuego · Pokémon Zorro · **aparece en el juego**

**Habilidad — Absorbe Fuego**: Los ataques de Fuego no le hacen nada y le suben un 50% los suyos de Fuego por 8 s.


**Ataques que puede aprender (5)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 1 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 45 | Giro Fuego | Fuego | Especial | Área | 35 | 3.0 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 039 Jigglypuff

Normal/Hada · Pokémon Globo · **aparece en el juego**

**Habilidad — Gran Encanto**: Al que le pega cuerpo a cuerpo lo deja Intimidado (30%).


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Canto | Normal | Estado | Zona | — | 12.0 s |
| 4 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 9 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 14 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 19 | Rodar | Roca | Físico | Embestida | 30 | 2.0 s |
| 24 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 29 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 34 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 39 | Mimético | Normal | Estado | Área | — | 6.0 s |
| 44 | Vozarrón | Normal | Especial | Área | 90 | 4.5 s |
| 49 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (32)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 040 Wigglytuff

Normal/Hada · Pokémon Globo · **aparece en el juego**

**Habilidad — Gran Encanto**: Al que le pega cuerpo a cuerpo lo deja Intimidado (30%).


**Ataques que puede aprender (4)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 1 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 1 | Canto | Normal | Estado | Zona | — | 12.0 s |

**Por MT/MO (33)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 041 Zubat

Veneno/Volador · Pokémon Murciélago · **aparece en el juego**

**Habilidad — Fuerza Mental**: No sufre el stagger de los golpes: puede contestar enseguida.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Chupavidas | Bicho | Físico | Golpe | 80 | 3.0 s |
| 6 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 11 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 16 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 21 | Ataque Ala | Volador | Físico | Embestida | 60 | 1.9 s |
| 26 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 31 | Aire Afilado | Volador | Especial | Área | 60 | 3.7 s |
| 36 | Mal de Ojo | Normal | Estado | Área | — | 6.0 s |
| 41 | Colmillo Veneno | Veneno | Físico | Golpe | 50 | 1.3 s |
| 46 | Niebla | Hielo | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 042 Golbat

Veneno/Volador · Pokémon Murciélago · **aparece en el juego**

**Habilidad — Fuerza Mental**: No sufre el stagger de los golpes: puede contestar enseguida.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 1 | Chupavidas | Bicho | Físico | Golpe | 80 | 3.0 s |
| 1 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 1 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 16 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 21 | Ataque Ala | Volador | Físico | Embestida | 60 | 1.9 s |
| 28 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 35 | Aire Afilado | Volador | Especial | Área | 60 | 3.7 s |
| 42 | Mal de Ojo | Normal | Estado | Área | — | 6.0 s |
| 49 | Colmillo Veneno | Veneno | Físico | Golpe | 50 | 1.3 s |
| 56 | Niebla | Hielo | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 043 Oddish

Planta/Veneno · Pokémon Hierbajo · **aparece en el juego**

**Habilidad — Clorofila**: De día se mueve un 30% más rápido.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 7 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 14 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 16 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 18 | Somnífero | Planta | Estado | Zona | — | 12.0 s |
| 23 | Ácido | Veneno | Especial | Disparo | 40 | 1.5 s |
| 32 | Luz Lunar | Hada | Estado | Mejora propia | — | 10.0 s |
| 39 | Danza Pétalo | Planta | Especial | Área | 120 | 5.5 s |

**Por MT/MO (17)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 044 Gloom

Planta/Veneno · Pokémon Hierbajo · **aparece en el juego**

**Habilidad — Clorofila**: De día se mueve un 30% más rápido.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 1 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 1 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 16 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 18 | Somnífero | Planta | Estado | Zona | — | 12.0 s |
| 24 | Ácido | Veneno | Especial | Disparo | 40 | 1.5 s |
| 35 | Luz Lunar | Hada | Estado | Mejora propia | — | 10.0 s |
| 44 | Danza Pétalo | Planta | Especial | Área | 120 | 5.5 s |

**Por MT/MO (17)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 045 Vileplume

Planta/Veneno · Pokémon Flor · **aparece en el juego**

**Habilidad — Clorofila**: De día se mueve un 30% más rápido.


**Ataques que puede aprender (5)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 1 | Aromaterapia | Planta | Estado | Mejora propia | — | 10.0 s |
| 1 | Megaagotar | Planta | Especial | Disparo | 40 | 1.5 s |
| 1 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 44 | Danza Pétalo | Planta | Especial | Área | 120 | 5.5 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 046 Paras

Bicho/Planta · Pokémon Hongo · **aparece en el juego**

**Habilidad — Efecto Espora**: Al que le pega cuerpo a cuerpo le pone veneno, parálisis o sueño (30%).


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 7 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 13 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 19 | Chupavidas | Bicho | Físico | Golpe | 80 | 3.0 s |
| 25 | Espora | Planta | Estado | Zona | — | 11.0 s |
| 31 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 37 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 43 | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| 49 | Aromaterapia | Planta | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 047 Parasect

Bicho/Planta · Pokémon Hongo · **aparece en el juego**

**Habilidad — Efecto Espora**: Al que le pega cuerpo a cuerpo le pone veneno, parálisis o sueño (30%).


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 19 | Chupavidas | Bicho | Físico | Golpe | 80 | 3.0 s |
| 27 | Espora | Planta | Estado | Zona | — | 11.0 s |
| 35 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 43 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 51 | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| 59 | Aromaterapia | Planta | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 048 Venonat

Bicho/Veneno · Pokémon Insecto · **aparece en el juego**

**Habilidad — Ojo Compuesto**: Sus ataques con estado lo ponen un 30% más seguido.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 1 | Profecía | Normal | Estado | Área | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 9 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 17 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 20 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 25 | Chupavidas | Bicho | Físico | Golpe | 80 | 3.0 s |
| 28 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 33 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 36 | Somnífero | Planta | Estado | Zona | — | 12.0 s |
| 41 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 049 Venomoth

Bicho/Veneno · Pokémon Polilla Ven. · **aparece en el juego**

**Habilidad — Polvo Escudo**: La mitad de las veces no le entra un problema de estado.


**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 1 | Profecía | Normal | Estado | Área | — | 6.0 s |
| 1 | Viento Plata | Bicho | Especial | Disparo | 60 | 1.8 s |
| 1 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 17 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 20 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 25 | Chupavidas | Bicho | Físico | Golpe | 80 | 3.0 s |
| 28 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 31 | Tornado | Volador | Especial | Disparo | 40 | 1.5 s |
| 36 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 42 | Somnífero | Planta | Estado | Zona | — | 12.0 s |
| 52 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 050 Diglett

Tierra · Pokémon Topo · **aparece en el juego**

**Habilidad — Velo Arena**: Un 12% de los golpes no le entran.

**Habilidad — Trampa Arena**: Los rivales cerca suyo quedan ralentizados.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 5 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 9 | Magnitud | Tierra | Físico | Área | 60 | 3.7 s |
| 17 | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| 21 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 25 | Bofetón Lodo | Tierra | Especial | Disparo | 20 | 1.1 s |
| 33 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 41 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 49 | Fisura | Tierra | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 051 Dugtrio

Tierra · Pokémon Topo · **aparece en el juego**

**Habilidad — Velo Arena**: Un 12% de los golpes no le entran.

**Habilidad — Trampa Arena**: Los rivales cerca suyo quedan ralentizados.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Triataque | Normal | Especial | Disparo | 80 | 2.1 s |
| 9 | Magnitud | Tierra | Físico | Área | 60 | 3.7 s |
| 17 | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| 21 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 25 | Bofetón Lodo | Tierra | Especial | Disparo | 20 | 1.1 s |
| 26 | Bucle Arena | Tierra | Físico | Golpe | 35 | 1.1 s |
| 38 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 51 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 64 | Fisura | Tierra | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 052 Meowth

Normal · Pokémon Gato Araña · **aparece en el juego**

**Habilidad — Recogida**: Si gana una pelea, a veces encuentra una Poción (tu equipo).


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 10 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 18 | Día de Pago | Normal | Físico | Golpe | 40 | 1.1 s |
| 25 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 31 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 36 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 40 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 43 | Sorpresa | Normal | Físico | Embestida | 40 | 1.6 s |
| 45 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 053 Persian

Normal · Pokémon Gato Fino · **aparece en el juego**

**Habilidad — Flexibilidad**: No lo paralizan.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 18 | Día de Pago | Normal | Físico | Golpe | 40 | 1.1 s |
| 25 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 34 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 42 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 49 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 55 | Sorpresa | Normal | Físico | Embestida | 40 | 1.6 s |
| 61 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |

**Por MT/MO (28)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 054 Psyduck

Agua · Pokémon Pato · **aparece en el juego**

**Habilidad — Humedad**: No lo queman y el fuego le hace un 20% menos.

**Habilidad — Aclimatación**: No lo empapan ni le afecta el clima del suelo (mojado, hielo).


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Hidrochorro | Agua | Especial | Área | 15 | 6.0 s |
| 5 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 10 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 16 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 23 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 31 | Autosugestión | Normal | Estado | Área | — | 6.0 s |
| 40 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 50 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (27)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 055 Golduck

Agua · Pokémon Pato · **aparece en el juego**

**Habilidad — Humedad**: No lo queman y el fuego le hace un 20% menos.

**Habilidad — Aclimatación**: No lo empapan ni le afecta el clima del suelo (mojado, hielo).


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 1 | Hidrochorro | Agua | Especial | Área | 15 | 6.0 s |
| 16 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 23 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 31 | Autosugestión | Normal | Estado | Área | — | 6.0 s |
| 44 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 58 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (28)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 056 Mankey

Lucha · Pokémon Mono Cerdo · **aparece en el juego**

**Habilidad — Espíritu Vital**: No lo duermen.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 6 | Patada Baja | Lucha | Físico | Golpe | 50 | 3.5 s |
| 11 | Golpe Kárate | Lucha | Físico | Golpe | 50 | 0.9 s |
| 16 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 21 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 26 | Sísmico | Lucha | Físico | Embestida+combo | 70 | 7.0 s |
| 31 | Tajo Cruzado | Lucha | Físico | Embestida | 100 | 2.5 s |
| 36 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 41 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 46 | Saña | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (27)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 057 Primeape

Lucha · Pokémon Mono Cerdo · **aparece en el juego**

**Habilidad — Espíritu Vital**: No lo duermen.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Patada Baja | Lucha | Físico | Golpe | 50 | 3.5 s |
| 1 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 11 | Golpe Kárate | Lucha | Físico | Golpe | 50 | 0.9 s |
| 16 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 21 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 26 | Sísmico | Lucha | Físico | Embestida+combo | 70 | 7.0 s |
| 35 | Tajo Cruzado | Lucha | Físico | Embestida | 100 | 2.5 s |
| 44 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 53 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 62 | Saña | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (28)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 058 Growlithe

Fuego · Pokémon Perrito · **aparece en el juego**

**Habilidad — Intimidación**: Al encarar a un rival lo deja Intimidado (pega menos).

**Habilidad — Absorbe Fuego**: Los ataques de Fuego no le hacen nada y le suben un 50% los suyos de Fuego por 8 s.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 1 | Rugido | Normal | Estado | Área | — | 6.0 s |
| 7 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 13 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 19 | Rastreo | Normal | Estado | Área | — | 6.0 s |
| 25 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 31 | Rueda Fuego | Fuego | Físico | Embestida | 60 | 1.9 s |
| 37 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 43 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 49 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 059 Arcanine

Fuego · Pokémon Leyenda · **aparece en el juego**

**Habilidad — Intimidación**: Al encarar a un rival lo deja Intimidado (pega menos).

**Habilidad — Absorbe Fuego**: Los ataques de Fuego no le hacen nada y le suben un 50% los suyos de Fuego por 8 s.


**Ataques que puede aprender (5)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 1 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 1 | Rastreo | Normal | Estado | Área | — | 6.0 s |
| 1 | Rugido | Normal | Estado | Área | — | 6.0 s |
| 49 | Velocidad Extrema | Normal | Físico | Embestida | 80 | 2.1 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 060 Poliwag

Agua · Pokémon Renacuajo · **aparece en el juego**

**Habilidad — Absorbe Agua**: Los ataques de Agua no le hacen nada y lo curan un 25%.

**Habilidad — Humedad**: No lo queman y el fuego le hace un 20% menos.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 7 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 13 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 19 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 25 | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| 31 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 37 | Tambor | Normal | Estado | Mejora propia | — | 10.0 s |
| 43 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 061 Poliwhirl

Agua · Pokémon Renacuajo · **aparece en el juego**

**Habilidad — Absorbe Agua**: Los ataques de Agua no le hacen nada y lo curan un 25%.

**Habilidad — Humedad**: No lo queman y el fuego le hace un 20% menos.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 1 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 19 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 27 | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| 35 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 43 | Tambor | Normal | Estado | Mejora propia | — | 10.0 s |
| 51 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 062 Poliwrath

Agua/Lucha · Pokémon Renacuajo

**Habilidad — Absorbe Agua**: Los ataques de Agua no le hacen nada y lo curan un 25%.

**Habilidad — Humedad**: No lo queman y el fuego le hace un 20% menos.


**Ataques que puede aprender (5)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 1 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 1 | Sumisión | Lucha | Físico | Embestida | 80 | 2.1 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 51 | Telépata | Normal | Estado | Área | — | 6.0 s |

**Por MT/MO (29)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 063 Abra

Psíquico · Pokémon Psi · **aparece en el juego**

**Habilidad — Sincronía**: Los problemas de estado que le ponen se los devuelve al que se los puso.

**Habilidad — Fuerza Mental**: No sufre el stagger de los golpes: puede contestar enseguida.


**Ataques que puede aprender (1)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Teletransporte | Psíquico | Estado | Embestida | — | 3.0 s |

**Por MT/MO (27)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 064 Kadabra

Psíquico · Pokémon Psi · **aparece en el juego**

**Habilidad — Sincronía**: Los problemas de estado que le ponen se los devuelve al que se los puso.

**Habilidad — Fuerza Mental**: No sufre el stagger de los golpes: puede contestar enseguida.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 1 | Kinético | Psíquico | Estado | Área | — | 8.0 s |
| 1 | Teletransporte | Psíquico | Estado | Embestida | — | 3.0 s |
| 18 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 21 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 23 | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 25 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |
| 30 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |
| 33 | Imitación | Psíquico | Estado | Área | — | 6.0 s |
| 36 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 43 | Truco | Psíquico | Estado | Área | — | 6.0 s |

**Por MT/MO (27)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 065 Alakazam

Psíquico · Pokémon Psi · **aparece en el juego**

**Habilidad — Sincronía**: Los problemas de estado que le ponen se los devuelve al que se los puso.

**Habilidad — Fuerza Mental**: No sufre el stagger de los golpes: puede contestar enseguida.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 1 | Kinético | Psíquico | Estado | Área | — | 8.0 s |
| 1 | Teletransporte | Psíquico | Estado | Embestida | — | 3.0 s |
| 18 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 21 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 23 | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 25 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |
| 30 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |
| 33 | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 36 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 43 | Truco | Psíquico | Estado | Área | — | 6.0 s |

**Por MT/MO (28)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 066 Machop

Lucha · Pokémon Superpoder · **aparece en el juego**

**Habilidad — Agallas**: Con un problema de estado sus ataques físicos pegan ×1,5.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Patada Baja | Lucha | Físico | Golpe | 50 | 3.5 s |
| 7 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 13 | Golpe Kárate | Lucha | Físico | Golpe | 50 | 0.9 s |
| 19 | Sísmico | Lucha | Físico | Embestida+combo | 70 | 7.0 s |
| 22 | Profecía | Normal | Estado | Área | — | 6.0 s |
| 25 | Desquite | Lucha | Físico | Golpe | 60 | 1.4 s |
| 31 | Llave Vital | Lucha | Físico | Golpe | 70 | 1.5 s |
| 37 | Sumisión | Lucha | Físico | Embestida | 80 | 2.1 s |
| 40 | Tajo Cruzado | Lucha | Físico | Embestida | 100 | 2.5 s |
| 43 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 49 | Puño Dinámico | Lucha | Físico | Embestida | 100 | 2.5 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 067 Machoke

Lucha · Pokémon Superpoder · **aparece en el juego**

**Habilidad — Agallas**: Con un problema de estado sus ataques físicos pegan ×1,5.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Patada Baja | Lucha | Físico | Golpe | 50 | 3.5 s |
| 13 | Golpe Kárate | Lucha | Físico | Golpe | 50 | 0.9 s |
| 19 | Sísmico | Lucha | Físico | Embestida+combo | 70 | 7.0 s |
| 22 | Profecía | Normal | Estado | Área | — | 6.0 s |
| 25 | Desquite | Lucha | Físico | Golpe | 60 | 1.4 s |
| 33 | Llave Vital | Lucha | Físico | Golpe | 70 | 1.5 s |
| 41 | Sumisión | Lucha | Físico | Embestida | 80 | 2.1 s |
| 46 | Tajo Cruzado | Lucha | Físico | Embestida | 100 | 2.5 s |
| 51 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 59 | Puño Dinámico | Lucha | Físico | Embestida | 100 | 2.5 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 068 Machamp

Lucha · Pokémon Superpoder · **aparece en el juego**

**Habilidad — Agallas**: Con un problema de estado sus ataques físicos pegan ×1,5.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Patada Baja | Lucha | Físico | Golpe | 50 | 3.5 s |
| 13 | Golpe Kárate | Lucha | Físico | Golpe | 50 | 0.9 s |
| 19 | Sísmico | Lucha | Físico | Embestida+combo | 70 | 7.0 s |
| 22 | Profecía | Normal | Estado | Área | — | 6.0 s |
| 25 | Desquite | Lucha | Físico | Golpe | 60 | 1.4 s |
| 33 | Llave Vital | Lucha | Físico | Golpe | 70 | 1.5 s |
| 41 | Sumisión | Lucha | Físico | Embestida | 80 | 2.1 s |
| 46 | Tajo Cruzado | Lucha | Físico | Embestida | 100 | 2.5 s |
| 51 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 59 | Puño Dinámico | Lucha | Físico | Embestida | 100 | 2.5 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 069 Bellsprout

Planta/Veneno · Pokémon Flor · **aparece en el juego**

**Habilidad — Clorofila**: De día se mueve un 30% más rápido.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Látigo Cepa | Planta | Físico | Embestida | 45 | 1.6 s |
| 6 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 11 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 15 | Somnífero | Planta | Estado | Zona | — | 12.0 s |
| 17 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 19 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 23 | Ácido | Veneno | Especial | Disparo | 40 | 1.5 s |
| 30 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 37 | Hoja Afilada | Planta | Físico | Disparo | 55 | 1.7 s |
| 45 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 070 Weepinbell

Planta/Veneno · Pokémon Matamoscas · **aparece en el juego**

**Habilidad — Clorofila**: De día se mueve un 30% más rápido.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Látigo Cepa | Planta | Físico | Embestida | 45 | 1.6 s |
| 1 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 15 | Somnífero | Planta | Estado | Zona | — | 12.0 s |
| 17 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 19 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 24 | Ácido | Veneno | Especial | Disparo | 40 | 1.5 s |
| 33 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 42 | Hoja Afilada | Planta | Físico | Disparo | 55 | 1.7 s |
| 54 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 071 Victreebel

Planta/Veneno · Pokémon Matamoscas · **aparece en el juego**

**Habilidad — Clorofila**: De día se mueve un 30% más rápido.


**Ataques que puede aprender (7)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Hoja Afilada | Planta | Físico | Disparo | 55 | 1.7 s |
| 1 | Somnífero | Planta | Estado | Zona | — | 12.0 s |
| 1 | Escupir | Normal | Especial | Disparo | 60 | 1.8 s |
| 1 | Reserva | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Tragar | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 1 | Látigo Cepa | Planta | Físico | Embestida | 45 | 1.6 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 072 Tentacool

Agua/Veneno · Pokémon Medusa · **aparece en el juego**

**Habilidad — Cuerpo Puro**: No le bajan nada: no lo intimidan, exponen ni ralentizan.

**Habilidad — Lodo Líquido**: El que le roba vida (Absorber, Chupavidas...) en vez de curarse se lastima.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 6 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 12 | Restricción | Normal | Físico | Látigo | 15 | 5.0 s |
| 19 | Ácido | Veneno | Especial | Disparo | 40 | 1.5 s |
| 25 | Rayo Burbuja | Agua | Especial | Disparo | 30 | 3.0 s |
| 30 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 36 | Barrera | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 43 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 49 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 073 Tentacruel

Agua/Veneno · Pokémon Medusa · **aparece en el juego**

**Habilidad — Cuerpo Puro**: No le bajan nada: no lo intimidan, exponen ni ralentizan.

**Habilidad — Lodo Líquido**: El que le roba vida (Absorber, Chupavidas...) en vez de curarse se lastima.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Restricción | Normal | Físico | Látigo | 15 | 5.0 s |
| 1 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 1 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 19 | Ácido | Veneno | Especial | Disparo | 40 | 1.5 s |
| 25 | Rayo Burbuja | Agua | Especial | Disparo | 30 | 3.0 s |
| 30 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 38 | Barrera | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 47 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 55 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 074 Geodude

Roca/Tierra · Pokémon Roca · **aparece en el juego**

**Habilidad — Cabeza Roca**: Sus embestidas pegan +25%.

**Habilidad — Robustez**: Con la vida llena, un golpe que lo debilitaría lo deja con 1 de vida.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 6 | Chapoteo Lodo | Tierra | Estado | Mejora propia | — | 10.0 s |
| 11 | Lanzarrocas | Roca | Físico | Disparo | 50 | 1.6 s |
| 16 | Magnitud | Tierra | Físico | Área | 60 | 3.7 s |
| 21 | Autodestrucción | Normal | Físico | Área | 130 | 20.0 s |
| 26 | Rodar | Roca | Físico | Embestida | 30 | 2.0 s |
| 31 | Pedrada | Roca | Físico | Golpe | 25 | 0.9 s |
| 36 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 41 | Explosión | Normal | Físico | Área | 250 | 9.2 s |
| 46 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 075 Graveler

Roca/Tierra · Pokémon Roca · **aparece en el juego**

**Habilidad — Cabeza Roca**: Sus embestidas pegan +25%.

**Habilidad — Robustez**: Con la vida llena, un golpe que lo debilitaría lo deja con 1 de vida.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Chapoteo Lodo | Tierra | Estado | Mejora propia | — | 10.0 s |
| 1 | Lanzarrocas | Roca | Físico | Disparo | 50 | 1.6 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 16 | Magnitud | Tierra | Físico | Área | 60 | 3.7 s |
| 21 | Autodestrucción | Normal | Físico | Área | 130 | 20.0 s |
| 29 | Rodar | Roca | Físico | Embestida | 30 | 2.0 s |
| 37 | Pedrada | Roca | Físico | Golpe | 25 | 0.9 s |
| 45 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 53 | Explosión | Normal | Físico | Área | 250 | 9.2 s |
| 62 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 076 Golem

Roca/Tierra · Pokémon Megatón

**Habilidad — Cabeza Roca**: Sus embestidas pegan +25%.

**Habilidad — Robustez**: Con la vida llena, un golpe que lo debilitaría lo deja con 1 de vida.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Chapoteo Lodo | Tierra | Estado | Mejora propia | — | 10.0 s |
| 1 | Lanzarrocas | Roca | Físico | Disparo | 50 | 1.6 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 16 | Magnitud | Tierra | Físico | Área | 60 | 3.7 s |
| 21 | Autodestrucción | Normal | Físico | Área | 130 | 20.0 s |
| 29 | Rodar | Roca | Físico | Embestida | 30 | 2.0 s |
| 37 | Pedrada | Roca | Físico | Golpe | 25 | 0.9 s |
| 45 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 53 | Explosión | Normal | Físico | Área | 250 | 9.2 s |
| 62 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 077 Ponyta

Fuego · Pokémon Caballo Fuego · **aparece en el juego**

**Habilidad — Fuga**: Esquiva mucho más seguido (recarga del esquive −40%).

**Habilidad — Absorbe Fuego**: Los ataques de Fuego no le hacen nada y le suben un 50% los suyos de Fuego por 8 s.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 5 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 9 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 14 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 19 | Pisotón | Normal | Físico | Golpe | 65 | 1.2 s |
| 25 | Giro Fuego | Fuego | Especial | Área | 35 | 3.0 s |
| 31 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 38 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 45 | Bote | Volador | Físico | Embestida | 85 | 2.2 s |
| 53 | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (17)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 078 Rapidash

Fuego · Pokémon Caballo Fuego · **aparece en el juego**

**Habilidad — Fuga**: Esquiva mucho más seguido (recarga del esquive −40%).

**Habilidad — Absorbe Fuego**: Los ataques de Fuego no le hacen nada y le suben un 50% los suyos de Fuego por 8 s.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 19 | Pisotón | Normal | Físico | Golpe | 65 | 1.2 s |
| 25 | Giro Fuego | Fuego | Especial | Área | 35 | 3.0 s |
| 31 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 38 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 40 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 50 | Bote | Volador | Físico | Embestida | 85 | 2.2 s |
| 63 | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 079 Slowpoke

Agua/Psíquico · Pokémon Atontado · **aparece en el juego**

**Habilidad — Despiste**: No lo intimidan ni lo desorientan.

**Habilidad — Ritmo Propio**: No lo desorientan.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Maldición | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Bostezo | Normal | Estado | Disparo | — | 9.0 s |
| 6 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 13 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 17 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 24 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 29 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 36 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 40 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 47 | Autosugestión | Normal | Estado | Área | — | 6.0 s |

**Por MT/MO (30)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 080 Slowbro

Agua/Psíquico · Pokémon Ermitaño · **aparece en el juego**

**Habilidad — Despiste**: No lo intimidan ni lo desorientan.

**Habilidad — Ritmo Propio**: No lo desorientan.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Maldición | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Bostezo | Normal | Estado | Disparo | — | 9.0 s |
| 13 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 17 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 24 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 29 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 36 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 37 | Refugio | Agua | Estado | Mejora propia | — | 9.0 s |
| 44 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 55 | Autosugestión | Normal | Estado | Área | — | 6.0 s |

**Por MT/MO (34)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 081 Magnemite

Eléctrico/Acero · Pokémon Imán · **aparece en el juego**

**Habilidad — Imán**: Sus ataques pegan +30% a los de tipo Acero.

**Habilidad — Robustez**: Con la vida llena, un golpe que lo debilitaría lo deja con 1 de vida.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Eco Metálico | Acero | Estado | Área | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 6 | Impactrueno | Eléctrico | Especial | Disparo | 40 | 1.5 s |
| 11 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 16 | Bomba Sónica | Normal | Especial | Área | 25 | 4.0 s |
| 21 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 26 | Chispa | Eléctrico | Físico | Embestida | 65 | 6.0 s |
| 32 | Fijar Blanco | Normal | Estado | Disparo | — | 8.0 s |
| 38 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 44 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 50 | Electrocañón | Eléctrico | Especial | Disparo | 120 | 2.9 s |

**Por MT/MO (16)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 082 Magneton

Eléctrico/Acero · Pokémon Imán · **aparece en el juego**

**Habilidad — Imán**: Sus ataques pegan +30% a los de tipo Acero.

**Habilidad — Robustez**: Con la vida llena, un golpe que lo debilitaría lo deja con 1 de vida.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Eco Metálico | Acero | Estado | Área | — | 6.0 s |
| 1 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Impactrueno | Eléctrico | Especial | Disparo | 40 | 1.5 s |
| 16 | Bomba Sónica | Normal | Especial | Área | 25 | 4.0 s |
| 21 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 26 | Chispa | Eléctrico | Físico | Embestida | 65 | 6.0 s |
| 35 | Fijar Blanco | Normal | Estado | Disparo | — | 8.0 s |
| 44 | Triataque | Normal | Especial | Disparo | 80 | 2.1 s |
| 53 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 62 | Electrocañón | Eléctrico | Especial | Disparo | 120 | 2.9 s |

**Por MT/MO (17)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 083 Farfetch’d

Normal/Volador · Pokémon Pato Salvaje · **aparece en el juego**

**Habilidad — Vista Lince**: No lo desorientan y sus disparos pegan +10%.

**Habilidad — Fuerza Mental**: No sufre el stagger de los golpes: puede contestar enseguida.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 6 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 11 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 16 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 21 | Desarme | Siniestro | Físico | Golpe | 65 | 1.4 s |
| 26 | Corte Furia | Bicho | Físico | Golpe | 40 | 1.1 s |
| 31 | Danza Espada | Normal | Estado | Mejora propia | — | 10.0 s |
| 36 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 41 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 46 | Falso Tortazo | Normal | Físico | Golpe | 40 | 1.1 s |

**Por MT/MO (17)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 084 Doduo

Normal/Volador · Pokémon Ave Gemela · **aparece en el juego**

**Habilidad — Fuga**: Esquiva mucho más seguido (recarga del esquive −40%).

**Habilidad — Madrugar**: Dormido, se despierta solo al segundo.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 9 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 13 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 21 | Triataque | Normal | Especial | Disparo | 80 | 2.1 s |
| 25 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 33 | Alboroto | Normal | Especial | Disparo | 90 | 2.4 s |
| 37 | Pico Taladro | Volador | Físico | Embestida | 80 | 2.1 s |
| 45 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (15)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 085 Dodrio

Normal/Volador · Pokémon Ave Triple · **aparece en el juego**

**Habilidad — Fuga**: Esquiva mucho más seguido (recarga del esquive −40%).

**Habilidad — Madrugar**: Dormido, se despierta solo al segundo.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 1 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 21 | Triataque | Normal | Especial | Disparo | 80 | 2.1 s |
| 25 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 38 | Alboroto | Normal | Especial | Disparo | 90 | 2.4 s |
| 47 | Pico Taladro | Volador | Físico | Embestida | 80 | 2.1 s |
| 60 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 086 Seel

Agua · Pokémon León Marino · **aparece en el juego**

**Habilidad — Sebo**: El fuego y el hielo le hacen la mitad.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 9 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 17 | Viento Hielo | Hielo | Especial | Disparo | 55 | 1.7 s |
| 21 | Rayo Aurora | Hielo | Especial | Disparo | 65 | 1.9 s |
| 29 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 37 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 41 | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| 49 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 087 Dewgong

Agua/Hielo · Pokémon León Marino · **aparece en el juego**

**Habilidad — Sebo**: El fuego y el hielo le hacen la mitad.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Rayo Aurora | Hielo | Especial | Disparo | 65 | 1.9 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 1 | Viento Hielo | Hielo | Especial | Disparo | 55 | 1.7 s |
| 1 | Rayo Señal | Bicho | Especial | Disparo | 75 | 2.1 s |
| 29 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 34 | Frío Polar | Hielo | Especial | Disparo | 60 | 1.8 s |
| 42 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 51 | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| 64 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 088 Grimer

Veneno · Pokémon Lodo · **aparece en el juego**

**Habilidad — Hedor**: Sus golpes a veces aturden al rival un instante (10%).

**Habilidad — Viscosidad**: Casi no lo empujan.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gas Venenoso | Veneno | Estado | Zona | — | 5.0 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 4 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 8 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 13 | Residuos | Veneno | Especial | Disparo | 65 | 2.2 s |
| 19 | Reducción | Normal | Estado | Mejora propia | — | 9.0 s |
| 26 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 34 | Armadura Ácida | Veneno | Estado | Mejora propia | — | 10.0 s |
| 43 | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| 53 | Legado | Siniestro | Estado | Área | — | 6.0 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 089 Muk

Veneno · Pokémon Lodo · **aparece en el juego**

**Habilidad — Hedor**: Sus golpes a veces aturden al rival un instante (10%).

**Habilidad — Viscosidad**: Casi no lo empujan.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 1 | Gas Venenoso | Veneno | Estado | Zona | — | 5.0 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 8 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 13 | Residuos | Veneno | Especial | Disparo | 65 | 2.2 s |
| 19 | Reducción | Normal | Estado | Mejora propia | — | 9.0 s |
| 26 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 34 | Armadura Ácida | Veneno | Estado | Mejora propia | — | 10.0 s |
| 47 | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| 61 | Legado | Siniestro | Estado | Área | — | 6.0 s |

**Por MT/MO (29)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 090 Shellder

Agua · Pokémon Bivalvo · **aparece en el juego**

**Habilidad — Caparazón**: Lo cubre su caparazón: recibe 15% menos de frente.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Refugio | Agua | Estado | Mejora propia | — | 9.0 s |
| 8 | Carámbano | Hielo | Físico | Disparo | 25 | 1.6 s |
| 15 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 22 | Rayo Aurora | Hielo | Especial | Disparo | 65 | 1.9 s |
| 29 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 36 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 43 | Tenaza | Agua | Físico | Embestida+combo | 35 | 6.0 s |
| 50 | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |

**Por MT/MO (17)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 091 Cloyster

Agua/Hielo · Pokémon Bivalvo · **aparece en el juego**

**Habilidad — Caparazón**: Lo cubre su caparazón: recibe 15% menos de frente.


**Ataques que puede aprender (6)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Rayo Aurora | Hielo | Especial | Disparo | 65 | 1.9 s |
| 1 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 1 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 1 | Refugio | Agua | Estado | Mejora propia | — | 9.0 s |
| 36 | Púas | Tierra | Estado | Mejora propia | — | 10.0 s |
| 43 | Clavo Cañón | Normal | Físico | Golpe | 20 | 0.9 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 092 Gastly

Fantasma/Veneno · Pokémon Gas · **aparece en el juego**

**Habilidad — Levitación**: Flota: los ataques de Tierra no le hacen nada.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 1 | Lengüetazo | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 8 | Rencor | Fantasma | Estado | Área | — | 6.0 s |
| 13 | Maldición | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 16 | Tinieblas | Fantasma | Especial | Disparo | 60 | 1.8 s |
| 21 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 28 | Comesueños | Psíquico | Especial | Disparo | 100 | 7.0 s |
| 33 | Mismo Destino | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 36 | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| 41 | Pesadilla | Fantasma | Estado | Área | — | 6.0 s |
| 48 | Mal de Ojo | Normal | Estado | Área | — | 6.0 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 093 Haunter

Fantasma/Veneno · Pokémon Gas · **aparece en el juego**

**Habilidad — Levitación**: Flota: los ataques de Tierra no le hacen nada.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 1 | Lengüetazo | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 1 | Rencor | Fantasma | Estado | Área | — | 6.0 s |
| 13 | Maldición | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 16 | Tinieblas | Fantasma | Especial | Disparo | 60 | 1.8 s |
| 21 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 25 | Puño Sombra | Fantasma | Físico | Golpe | 60 | 1.4 s |
| 31 | Comesueños | Psíquico | Especial | Disparo | 100 | 7.0 s |
| 39 | Mismo Destino | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 45 | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| 53 | Pesadilla | Fantasma | Estado | Área | — | 6.0 s |
| 64 | Mal de Ojo | Normal | Estado | Área | — | 6.0 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 094 Gengar

Fantasma/Veneno · Pokémon Sombra · **aparece en el juego**

**Habilidad — Levitación**: Flota: los ataques de Tierra no le hacen nada.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 1 | Lengüetazo | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 1 | Rencor | Fantasma | Estado | Área | — | 6.0 s |
| 13 | Maldición | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 16 | Tinieblas | Fantasma | Especial | Disparo | 60 | 1.8 s |
| 21 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 25 | Puño Sombra | Fantasma | Físico | Golpe | 60 | 1.4 s |
| 31 | Comesueños | Psíquico | Especial | Disparo | 100 | 7.0 s |
| 39 | Mismo Destino | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 45 | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| 53 | Pesadilla | Fantasma | Estado | Área | — | 6.0 s |
| 64 | Mal de Ojo | Normal | Estado | Área | — | 6.0 s |

**Por MT/MO (28)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 095 Onix

Roca/Tierra · Pokémon Serpiente Roca · **aparece en el juego**

**Habilidad — Cabeza Roca**: Sus embestidas pegan +25%.

**Habilidad — Robustez**: Con la vida llena, un golpe que lo debilitaría lo deja con 1 de vida.

**Kit de jefe** (solo con un líder de gimnasio), firma **Coloso**: Jefe. Enorme: no lo empujan ni lo tambalean y recibe 25% menos de daño físico. Aplasta lo atrapado: +30% contra lo ralentizado. A mitad de vida ruge (empuja y deja Expuesto) y entra en Furia de Roca hasta el final.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Atadura | Normal | Físico | Látigo | 15 | 3.0 s |
| Clic der. | Lanzarrocas | Roca | Físico | Disparo | 50 | 1.8 s |
| Q | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| R | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 8 | Atadura | Normal | Físico | Látigo | 15 | 3.0 s |
| 12 | Lanzarrocas | Roca | Físico | Disparo | 50 | 1.6 s |
| 19 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 23 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 30 | Dragoaliento | Dragón | Especial | Disparo | 60 | 1.8 s |
| 34 | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| 41 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 45 | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| 52 | Bucle Arena | Tierra | Físico | Golpe | 35 | 1.1 s |
| 56 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 096 Drowzee

Psíquico · Pokémon Hipnosis · **aparece en el juego**

**Habilidad — Insomnio**: No lo duermen.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 7 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 11 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 17 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 21 | Gas Venenoso | Veneno | Estado | Zona | — | 5.0 s |
| 27 | Meditación | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 31 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 37 | Autosugestión | Normal | Estado | Área | — | 6.0 s |
| 41 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 47 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 097 Hypno

Psíquico · Pokémon Hipnosis · **aparece en el juego**

**Habilidad — Insomnio**: No lo duermen.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 1 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 1 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 1 | Pesadilla | Fantasma | Estado | Área | — | 6.0 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 17 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 21 | Gas Venenoso | Veneno | Estado | Zona | — | 5.0 s |
| 29 | Meditación | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 35 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 43 | Autosugestión | Normal | Estado | Área | — | 6.0 s |
| 49 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 57 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |

**Por MT/MO (27)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 098 Krabby

Agua · Pokémon Cangrejo

**Habilidad — Corte Fuerte**: No lo intimidan.

**Habilidad — Caparazón**: Lo cubre su caparazón: recibe 15% menos de frente.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 5 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 12 | Agarre | Normal | Físico | Golpe | 55 | 1.3 s |
| 16 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 23 | Disparo Lodo | Tierra | Especial | Disparo | 55 | 1.7 s |
| 27 | Pisotón | Normal | Físico | Golpe | 65 | 1.2 s |
| 34 | Guillotina | Normal | Físico | Golpe | 60 | 1.4 s |
| 38 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 45 | Martillazo | Agua | Físico | Embestida | 100 | 2.5 s |
| 49 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 099 Kingler

Agua · Pokémon Tenaza · **aparece en el juego**

**Habilidad — Corte Fuerte**: No lo intimidan.

**Habilidad — Caparazón**: Lo cubre su caparazón: recibe 15% menos de frente.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Garra Metal | Acero | Físico | Golpe | 50 | 1.3 s |
| 1 | Agarre | Normal | Físico | Golpe | 55 | 1.3 s |
| 23 | Disparo Lodo | Tierra | Especial | Disparo | 55 | 1.7 s |
| 27 | Pisotón | Normal | Físico | Golpe | 65 | 1.2 s |
| 38 | Guillotina | Normal | Físico | Golpe | 60 | 1.4 s |
| 42 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 57 | Martillazo | Agua | Físico | Embestida | 100 | 2.5 s |
| 65 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 100 Voltorb

Eléctrico · Pokémon Bola · **aparece en el juego**

**Habilidad — Insonorizar**: No le afectan los sonidos: no lo duermen con Canto ni lo desorientan con Supersónico.

**Habilidad — Electricidad Estática**: Al que le pega cuerpo a cuerpo lo paraliza (30%).


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Carga | Eléctrico | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 8 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 15 | Bomba Sónica | Normal | Especial | Área | 25 | 4.0 s |
| 21 | Chispa | Eléctrico | Físico | Embestida | 65 | 6.0 s |
| 27 | Autodestrucción | Normal | Físico | Área | 130 | 20.0 s |
| 32 | Rodar | Roca | Físico | Embestida | 30 | 2.0 s |
| 37 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 42 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 46 | Explosión | Normal | Físico | Área | 250 | 9.2 s |
| 49 | Manto Espejo | Psíquico | Especial | Disparo | 60 | 1.8 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 101 Electrode

Eléctrico · Pokémon Bola · **aparece en el juego**

**Habilidad — Insonorizar**: No le afectan los sonidos: no lo duermen con Canto ni lo desorientan con Supersónico.

**Habilidad — Electricidad Estática**: Al que le pega cuerpo a cuerpo lo paraliza (30%).


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Carga | Eléctrico | Estado | Mejora propia | — | 10.0 s |
| 1 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 1 | Bomba Sónica | Normal | Especial | Área | 25 | 4.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 21 | Chispa | Eléctrico | Físico | Embestida | 65 | 6.0 s |
| 27 | Autodestrucción | Normal | Físico | Área | 130 | 20.0 s |
| 34 | Rodar | Roca | Físico | Embestida | 30 | 2.0 s |
| 41 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 48 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 54 | Explosión | Normal | Físico | Área | 250 | 9.2 s |
| 59 | Manto Espejo | Psíquico | Especial | Disparo | 60 | 1.8 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 102 Exeggcute

Planta/Psíquico · Pokémon Huevo · **aparece en el juego**

**Habilidad — Clorofila**: De día se mueve un 30% más rápido.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Bombardeo | Normal | Físico | Golpe | 15 | 0.8 s |
| 1 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 1 | Alboroto | Normal | Especial | Disparo | 90 | 2.4 s |
| 7 | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 13 | Drenadoras | Planta | Estado | Área | — | 6.0 s |
| 19 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 25 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 31 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 37 | Somnífero | Planta | Estado | Zona | — | 12.0 s |
| 43 | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 103 Exeggutor

Planta/Psíquico · Pokémon Coco · **aparece en el juego**

**Habilidad — Clorofila**: De día se mueve un 30% más rápido.


**Ataques que puede aprender (5)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Bombardeo | Normal | Físico | Golpe | 15 | 0.8 s |
| 1 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 1 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 19 | Pisotón | Normal | Físico | Golpe | 65 | 1.2 s |
| 31 | Bomba Huevo | Normal | Físico | Embestida | 100 | 2.5 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 104 Cubone

Tierra · Pokémon Solitario · **aparece en el juego**

**Habilidad — Cabeza Roca**: Sus embestidas pegan +25%.

**Habilidad — Pararrayos**: Atrae los rayos: los ataques Eléctricos no le hacen nada y le suben los suyos.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 5 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 9 | Hueso Palo | Tierra | Físico | Golpe | 65 | 1.4 s |
| 13 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 17 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 21 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 25 | Huesomerang | Tierra | Físico | Golpe | 50 | 1.3 s |
| 29 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 33 | Falso Tortazo | Normal | Físico | Golpe | 40 | 1.1 s |
| 37 | Saña | Normal | Físico | Embestida | 120 | 2.7 s |
| 41 | Ataque Óseo | Tierra | Físico | Golpe | 25 | 0.9 s |
| 45 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 105 Marowak

Tierra · Pokémon Apilahueso · **aparece en el juego**

**Habilidad — Cabeza Roca**: Sus embestidas pegan +25%.

**Habilidad — Pararrayos**: Atrae los rayos: los ataques Eléctricos no le hacen nada y le suben los suyos.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Hueso Palo | Tierra | Físico | Golpe | 65 | 1.4 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 17 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 21 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 25 | Huesomerang | Tierra | Físico | Golpe | 50 | 1.3 s |
| 32 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 39 | Falso Tortazo | Normal | Físico | Golpe | 40 | 1.1 s |
| 46 | Saña | Normal | Físico | Embestida | 120 | 2.7 s |
| 53 | Ataque Óseo | Tierra | Físico | Golpe | 25 | 0.9 s |
| 61 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (27)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 106 Hitmonlee

Lucha · Pokémon Patada · **aparece en el juego**

**Habilidad — Flexibilidad**: No lo paralizan.


**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Doble Patada | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| 1 | Desquite | Lucha | Físico | Golpe | 60 | 1.4 s |
| 6 | Meditación | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 11 | Patada Giro | Lucha | Físico | Golpe | 60 | 1.4 s |
| 16 | Patada Salto | Lucha | Físico | Embestida | 100 | 2.5 s |
| 20 | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| 21 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 26 | Patada Salto Alta | Lucha | Físico | Embestida | 130 | 2.9 s |
| 31 | Telépata | Normal | Estado | Área | — | 6.0 s |
| 36 | Profecía | Normal | Estado | Área | — | 6.0 s |
| 41 | Aguante | Normal | Estado | Defensa | — | 8.0 s |
| 46 | Megapatada | Normal | Físico | Embestida | 120 | 2.7 s |
| 51 | Inversión | Lucha | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 107 Hitmonchan

Lucha · Pokémon Puñetazo · **aparece en el juego**

**Habilidad — Vista Lince**: No lo desorientan y sus disparos pegan +10%.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Puño Cometa | Normal | Físico | Golpe | 18 | 0.8 s |
| 1 | Desquite | Lucha | Físico | Golpe | 60 | 1.4 s |
| 7 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 13 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 20 | Ultrapuño | Lucha | Físico | Embestida | 40 | 1.6 s |
| 26 | Puño Fuego | Fuego | Físico | Golpe | 75 | 1.6 s |
| 26 | Puño Hielo | Hielo | Físico | Golpe | 75 | 1.6 s |
| 26 | Puño Trueno | Eléctrico | Físico | Golpe | 75 | 1.4 s |
| 32 | Gancho Alto | Lucha | Físico | Embestida | 85 | 2.2 s |
| 38 | Megapuño | Normal | Físico | Embestida | 80 | 2.1 s |
| 44 | Detección | Lucha | Estado | Defensa | — | 8.0 s |
| 50 | Contraataque | Lucha | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 108 Lickitung

Normal · Pokémon Lametazo · **aparece en el juego**

**Habilidad — Ritmo Propio**: No lo desorientan.

**Habilidad — Despiste**: No lo intimidan ni lo desorientan.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Lengüetazo | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 7 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 12 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 18 | Desarme | Siniestro | Físico | Golpe | 65 | 1.4 s |
| 23 | Pisotón | Normal | Físico | Golpe | 65 | 1.2 s |
| 29 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 34 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 40 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 45 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 51 | Alivio | Normal | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (35)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 109 Koffing

Veneno · Pokémon Gas Venenoso · **aparece en el juego**

**Habilidad — Levitación**: Flota: los ataques de Tierra no le hacen nada.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gas Venenoso | Veneno | Estado | Zona | — | 5.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 9 | Polución | Veneno | Especial | Disparo | 30 | 1.3 s |
| 17 | Autodestrucción | Normal | Físico | Área | 130 | 20.0 s |
| 21 | Residuos | Veneno | Especial | Disparo | 65 | 2.2 s |
| 25 | Pantalla de Humo | Normal | Estado | Zona | — | 9.0 s |
| 33 | Niebla | Hielo | Estado | Mejora propia | — | 10.0 s |
| 41 | Explosión | Normal | Físico | Área | 250 | 9.2 s |
| 45 | Mismo Destino | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 49 | Legado | Siniestro | Estado | Área | — | 6.0 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 110 Weezing

Veneno · Pokémon Gas Venenoso · **aparece en el juego**

**Habilidad — Levitación**: Flota: los ataques de Tierra no le hacen nada.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gas Venenoso | Veneno | Estado | Zona | — | 5.0 s |
| 1 | Autodestrucción | Normal | Físico | Área | 130 | 20.0 s |
| 1 | Polución | Veneno | Especial | Disparo | 30 | 1.3 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 21 | Residuos | Veneno | Especial | Disparo | 65 | 2.2 s |
| 25 | Pantalla de Humo | Normal | Estado | Zona | — | 9.0 s |
| 33 | Niebla | Hielo | Estado | Mejora propia | — | 10.0 s |
| 44 | Explosión | Normal | Físico | Área | 250 | 9.2 s |
| 51 | Mismo Destino | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 58 | Legado | Siniestro | Estado | Área | — | 6.0 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 111 Rhyhorn

Tierra/Roca · Pokémon Clavos · **aparece en el juego**

**Habilidad — Pararrayos**: Atrae los rayos: los ataques Eléctricos no le hacen nada y le suben los suyos.

**Habilidad — Cabeza Roca**: Sus embestidas pegan +25%.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Cornada | Normal | Físico | Embestida | 65 | 5.0 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 10 | Pisotón | Normal | Físico | Golpe | 65 | 1.2 s |
| 15 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 24 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 29 | Pedrada | Roca | Físico | Golpe | 25 | 0.9 s |
| 38 | Perforador | Normal | Físico | Golpe | 60 | 1.4 s |
| 43 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 52 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 57 | Megacuerno | Bicho | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (28)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 112 Rhydon

Tierra/Roca · Pokémon Taladro · **aparece en el juego**

**Habilidad — Pararrayos**: Atrae los rayos: los ataques Eléctricos no le hacen nada y le suben los suyos.

**Habilidad — Cabeza Roca**: Sus embestidas pegan +25%.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 1 | Cornada | Normal | Físico | Embestida | 65 | 5.0 s |
| 1 | Pisotón | Normal | Físico | Golpe | 65 | 1.2 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 24 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 29 | Pedrada | Roca | Físico | Golpe | 25 | 0.9 s |
| 38 | Perforador | Normal | Físico | Golpe | 60 | 1.4 s |
| 46 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 58 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 66 | Megacuerno | Bicho | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (33)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 113 Chansey

Normal · Pokémon Huevo · **aparece en el juego**

**Habilidad — Cura Natural**: Cada 8 s se cura los problemas de estado.

**Habilidad — Dicha**: Sus ataques con estado lo ponen el doble de seguido.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 5 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 9 | Alivio | Normal | Estado | Mejora propia | — | 10.0 s |
| 13 | Ovocuración | Normal | Estado | Mejora propia | — | 10.0 s |
| 17 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 23 | Reducción | Normal | Estado | Mejora propia | — | 9.0 s |
| 29 | Canto | Normal | Estado | Zona | — | 12.0 s |
| 35 | Bomba Huevo | Normal | Físico | Embestida | 100 | 2.5 s |
| 41 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 49 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 57 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (39)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 114 Tangela

Planta · Pokémon Enredadera · **aparece en el juego**

**Habilidad — Clorofila**: De día se mueve un 30% más rápido.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Restricción | Normal | Físico | Látigo | 15 | 5.0 s |
| 1 | Arraigo | Planta | Estado | Mejora propia | — | 10.0 s |
| 4 | Somnífero | Planta | Estado | Zona | — | 12.0 s |
| 10 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 13 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 19 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 22 | Látigo Cepa | Planta | Físico | Embestida | 45 | 1.6 s |
| 28 | Atadura | Normal | Físico | Látigo | 15 | 3.0 s |
| 31 | Megaagotar | Planta | Especial | Disparo | 40 | 1.5 s |
| 37 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 40 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 46 | Cosquillas | Normal | Estado | Área | — | 6.0 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 115 Kangaskhan

Normal · Pokémon Maternal · **aparece en el juego**

**Habilidad — Madrugar**: Dormido, se despierta solo al segundo.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Puño Cometa | Normal | Físico | Golpe | 18 | 0.8 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 7 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 13 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 19 | Sorpresa | Normal | Físico | Embestida | 40 | 1.6 s |
| 25 | Megapuño | Normal | Físico | Embestida | 80 | 2.1 s |
| 31 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 37 | Aguante | Normal | Estado | Defensa | — | 8.0 s |
| 43 | Puño Mareo | Normal | Físico | Golpe | 70 | 1.5 s |
| 49 | Inversión | Lucha | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (38)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 116 Horsea

Agua · Pokémon Dragón · **aparece en el juego**

**Habilidad — Nado Rápido**: Mojado (agua, suelo mojado o empapado) se mueve un 40% más rápido.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 8 | Pantalla de Humo | Normal | Estado | Zona | — | 9.0 s |
| 15 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 22 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 29 | Ciclón | Dragón | Especial | Área | 40 | 6.0 s |
| 36 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 43 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |
| 50 | Danza Dragón | Dragón | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 117 Seadra

Agua · Pokémon Dragón · **aparece en el juego**

**Habilidad — Punto Tóxico**: Al que le pega cuerpo a cuerpo lo envenena (30%).


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Pantalla de Humo | Normal | Estado | Zona | — | 9.0 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 29 | Ciclón | Dragón | Especial | Área | 40 | 6.0 s |
| 40 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 51 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |
| 62 | Danza Dragón | Dragón | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 118 Goldeen

Agua · Pokémon Pez Color · **aparece en el juego**

**Habilidad — Nado Rápido**: Mojado (agua, suelo mojado o empapado) se mueve un 40% más rápido.

**Habilidad — Velo Agua**: No lo queman.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 1 | Hidrochorro | Agua | Especial | Área | 15 | 6.0 s |
| 10 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 15 | Cornada | Normal | Físico | Embestida | 65 | 5.0 s |
| 24 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |
| 29 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 38 | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |
| 43 | Perforador | Normal | Físico | Golpe | 60 | 1.4 s |
| 52 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 57 | Megacuerno | Bicho | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 119 Seaking

Agua · Pokémon Pez Color · **aparece en el juego**

**Habilidad — Nado Rápido**: Mojado (agua, suelo mojado o empapado) se mueve un 40% más rápido.

**Habilidad — Velo Agua**: No lo queman.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 1 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 1 | Hidrochorro | Agua | Especial | Área | 15 | 6.0 s |
| 15 | Cornada | Normal | Físico | Embestida | 65 | 5.0 s |
| 24 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |
| 29 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 41 | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |
| 49 | Perforador | Normal | Físico | Golpe | 60 | 1.4 s |
| 61 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 69 | Megacuerno | Bicho | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 120 Staryu

Agua · Pokémon Estrella · **aparece en el juego**

**Habilidad — Iluminación**: Brilla: sus golpes a veces dejan Expuesto al rival (20%).

**Habilidad — Cura Natural**: Cada 8 s se cura los problemas de estado.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 6 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 10 | Giro Rápido | Normal | Físico | Embestida | 50 | 7.0 s |
| 15 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |
| 19 | Camuflaje | Normal | Estado | Mejora propia | — | 10.0 s |
| 24 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 28 | Rayo Burbuja | Agua | Especial | Disparo | 30 | 3.0 s |
| 33 | Reducción | Normal | Estado | Mejora propia | — | 9.0 s |
| 37 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 42 | Masa Cósmica | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 46 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 121 Starmie

Agua/Psíquico · Pokémon Misterioso · **aparece en el juego**

**Habilidad — Iluminación**: Brilla: sus golpes a veces dejan Expuesto al rival (20%).

**Habilidad — Cura Natural**: Cada 8 s se cura los problemas de estado.

**Kit de jefe** (solo con un líder de gimnasio), firma **Núcleo Prisma**: Jefa. Grande y casi no la empujan. Girando desvía los proyectiles; le pega 25% más a lo Empapado; la barra llena regenera 8% de la vida. A mitad de vida el núcleo brilla: una onda empuja y moja a todos y queda más fuerte y rápida hasta el final.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| Clic der. | Rapidez | Normal | Especial | Disparo | 35 | 3.5 s |
| Q | Giro Rápido | Normal | Físico | Embestida | 30 | 3.5 s |
| R | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |

**Ataques que puede aprender (5)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Giro Rápido | Normal | Físico | Embestida | 50 | 7.0 s |
| 1 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |
| 1 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 33 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 122 Mr. Mime

Psíquico/Hada · Pokémon Barrera · **aparece en el juego**

**Habilidad — Insonorizar**: No le afectan los sonidos: no lo duermen con Canto ni lo desorientan con Supersónico.


**Ataques que puede aprender (16)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Barrera | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 5 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 8 | Sustituto | Normal | Estado | Mejora propia | — | 10.0 s |
| 12 | Meditación | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 15 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 19 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 19 | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 22 | Hoja Mágica | Planta | Especial | Disparo | 60 | 1.8 s |
| 26 | Otra Vez | Normal | Estado | Área | — | 6.0 s |
| 29 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 33 | Reciclaje | Normal | Estado | Mejora propia | — | 10.0 s |
| 36 | Truco | Psíquico | Estado | Área | — | 6.0 s |
| 40 | Imitación | Psíquico | Estado | Área | — | 6.0 s |
| 43 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 47 | Relevo | Normal | Estado | Mejora propia | — | 10.0 s |
| 50 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (31)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 123 Scyther

Bicho/Volador · Pokémon Mantis · **aparece en el juego**

**Habilidad — Enjambre**: Con menos de 1/3 de vida sus ataques de tipo Bicho pegan ×1,5.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 6 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 11 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 16 | Falso Tortazo | Normal | Físico | Golpe | 40 | 1.1 s |
| 21 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 26 | Ataque Ala | Volador | Físico | Embestida | 60 | 1.9 s |
| 31 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 36 | Danza Espada | Normal | Estado | Mejora propia | — | 10.0 s |
| 41 | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| 46 | Corte Furia | Bicho | Físico | Golpe | 40 | 1.1 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 124 Jynx

Hielo/Psíquico · Pokémon Forma Humana · **aparece en el juego**

**Habilidad — Despiste**: No lo intimidan ni lo desorientan.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Lengüetazo | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 1 | Beso Amoroso | Normal | Estado | Disparo | — | 6.0 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Nieve Polvo | Hielo | Especial | Área | 40 | 3.2 s |
| 21 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 25 | Puño Hielo | Hielo | Físico | Golpe | 75 | 1.6 s |
| 35 | Mal de Ojo | Normal | Estado | Área | — | 6.0 s |
| 41 | Llanto Falso | Siniestro | Estado | Área | — | 6.0 s |
| 51 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 57 | Canto Mortal | Normal | Estado | Mejora propia | — | 10.0 s |
| 67 | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |

**Por MT/MO (28)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 125 Electabuzz

Eléctrico · Pokémon Eléctrico · **aparece en el juego**

**Habilidad — Electricidad Estática**: Al que le pega cuerpo a cuerpo lo paraliza (30%).


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Puño Trueno | Eléctrico | Físico | Golpe | 75 | 1.4 s |
| 17 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 25 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 36 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 47 | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| 58 | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 126 Magmar

Fuego · Pokémon Escupefuego

**Habilidad — Cuerpo Llama**: Al que le pega cuerpo a cuerpo lo quema (30%).


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 1 | Puño Fuego | Fuego | Físico | Golpe | 75 | 1.6 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Polución | Veneno | Especial | Disparo | 30 | 1.3 s |
| 25 | Pantalla de Humo | Normal | Estado | Zona | — | 9.0 s |
| 33 | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| 41 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| 49 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 57 | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 127 Pinsir

Bicho · Pokémon Escarabajo

**Habilidad — Corte Fuerte**: No lo intimidan.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 1 | Agarre | Normal | Físico | Golpe | 55 | 1.3 s |
| 7 | Atadura | Normal | Físico | Látigo | 15 | 3.0 s |
| 13 | Sísmico | Lucha | Físico | Embestida+combo | 70 | 7.0 s |
| 19 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 25 | Desquite | Lucha | Físico | Golpe | 60 | 1.4 s |
| 31 | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| 37 | Guillotina | Normal | Físico | Golpe | 60 | 1.4 s |
| 43 | Sumisión | Lucha | Físico | Embestida | 80 | 2.1 s |
| 49 | Danza Espada | Normal | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 128 Tauros

Normal · Pokémon Toro Bravo · **aparece en el juego**

**Habilidad — Intimidación**: Al encarar a un rival lo deja Intimidado (pega menos).


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 4 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 8 | Cornada | Normal | Físico | Embestida | 65 | 5.0 s |
| 13 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 19 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 26 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 34 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 43 | Saña | Normal | Físico | Embestida | 120 | 2.7 s |
| 53 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |

**Por MT/MO (29)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 129 Magikarp

Agua · Pokémon Pez · **aparece en el juego**

**Habilidad — Nado Rápido**: Mojado (agua, suelo mojado o empapado) se mueve un 40% más rápido.


**Ataques que puede aprender (3)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Salpicadura | Normal | Estado | Embestida | — | 1.5 s |
| 15 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 30 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |

### 130 Gyarados

Agua/Volador · Pokémon Atrocidad · **aparece en el juego**

**Habilidad — Intimidación**: Al encarar a un rival lo deja Intimidado (pega menos).


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Saña | Normal | Físico | Embestida | 120 | 2.7 s |
| 20 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 25 | Furia Dragón | Dragón | Especial | Disparo | 50 | 2.0 s |
| 30 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 35 | Ciclón | Dragón | Especial | Área | 40 | 6.0 s |
| 40 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |
| 45 | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| 50 | Danza Dragón | Dragón | Estado | Mejora propia | — | 10.0 s |
| 55 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

**Por MT/MO (30)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 131 Lapras

Agua/Hielo · Pokémon Transporte · **aparece en el juego**

**Habilidad — Absorbe Agua**: Los ataques de Agua no le hacen nada y lo curan un 25%.

**Habilidad — Caparazón**: Lo cubre su caparazón: recibe 15% menos de frente.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Canto | Normal | Estado | Zona | — | 12.0 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 7 | Neblina | Hielo | Estado | Mejora propia | — | 10.0 s |
| 13 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 19 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 25 | Canto Mortal | Normal | Estado | Mejora propia | — | 10.0 s |
| 31 | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| 37 | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| 43 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 49 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |
| 55 | Frío Polar | Hielo | Especial | Disparo | 60 | 1.8 s |

**Por MT/MO (28)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 132 Ditto

Normal · Pokémon Transformación · **aparece en el juego**

**Habilidad — Flexibilidad**: No lo paralizan.


**Ataques que puede aprender (1)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Transformación | Normal | Estado | Área | — | 6.0 s |

### 133 Eevee

Normal · Pokémon Evolución · **aparece en el juego**

**Habilidad — Fuga**: Esquiva mucho más seguido (recarga del esquive −40%).


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 8 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 16 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 23 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 30 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 36 | Relevo | Normal | Estado | Mejora propia | — | 10.0 s |
| 42 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |

**Por MT/MO (15)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 134 Vaporeon

Agua · Pokémon Burbuja

**Habilidad — Absorbe Agua**: Los ataques de Agua no le hacen nada y lo curan un 25%.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 8 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 16 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 23 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 30 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 36 | Rayo Aurora | Hielo | Especial | Disparo | 65 | 1.9 s |
| 42 | Niebla | Hielo | Estado | Mejora propia | — | 10.0 s |
| 47 | Armadura Ácida | Veneno | Estado | Mejora propia | — | 10.0 s |
| 52 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 135 Jolteon

Eléctrico · Pokémon Relámpago

**Habilidad — Absorbe Electricidad**: Los ataques Eléctricos no le hacen nada y lo curan un 25%.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 8 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 16 | Impactrueno | Eléctrico | Especial | Disparo | 40 | 1.5 s |
| 23 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 30 | Doble Patada | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| 36 | Pin Misil | Bicho | Físico | Disparo | 25 | 4.5 s |
| 42 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 47 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 52 | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 136 Flareon

Fuego · Pokémon Llama

**Habilidad — Absorbe Fuego**: Los ataques de Fuego no le hacen nada y le suben un 50% los suyos de Fuego por 8 s.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 8 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 16 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 23 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 30 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 36 | Giro Fuego | Fuego | Especial | Área | 35 | 3.0 s |
| 42 | Polución | Veneno | Especial | Disparo | 30 | 1.3 s |
| 47 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 52 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 137 Porygon

Normal · Pokémon Virtual

**Habilidad — Calco**: Copia la habilidad del primer rival que encara.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Conversión | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Conversión 2 | Normal | Estado | Área | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 9 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 12 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 20 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |
| 24 | Afilar | Normal | Estado | Mejora propia | — | 10.0 s |
| 32 | Fijar Blanco | Normal | Estado | Disparo | — | 8.0 s |
| 36 | Triataque | Normal | Especial | Disparo | 80 | 2.1 s |
| 44 | Reciclaje | Normal | Estado | Mejora propia | — | 10.0 s |
| 48 | Electrocañón | Eléctrico | Especial | Disparo | 120 | 2.9 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 138 Omanyte

Roca/Agua · Pokémon Espiral · **aparece en el juego**

**Habilidad — Nado Rápido**: Mojado (agua, suelo mojado o empapado) se mueve un 40% más rápido.

**Habilidad — Caparazón**: Lo cubre su caparazón: recibe 15% menos de frente.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Restricción | Normal | Físico | Látigo | 15 | 5.0 s |
| 1 | Refugio | Agua | Estado | Mejora propia | — | 9.0 s |
| 13 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 19 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 25 | Disparo Lodo | Tierra | Especial | Disparo | 55 | 1.7 s |
| 31 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 37 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 43 | Cosquillas | Normal | Estado | Área | — | 6.0 s |
| 49 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 55 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 139 Omastar

Roca/Agua · Pokémon Espiral

**Habilidad — Nado Rápido**: Mojado (agua, suelo mojado o empapado) se mueve un 40% más rápido.

**Habilidad — Caparazón**: Lo cubre su caparazón: recibe 15% menos de frente.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 1 | Restricción | Normal | Físico | Látigo | 15 | 5.0 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 1 | Refugio | Agua | Estado | Mejora propia | — | 9.0 s |
| 25 | Disparo Lodo | Tierra | Especial | Disparo | 55 | 1.7 s |
| 31 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 37 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 40 | Clavo Cañón | Normal | Físico | Golpe | 20 | 0.9 s |
| 46 | Cosquillas | Normal | Estado | Área | — | 6.0 s |
| 55 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 65 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 140 Kabuto

Roca/Agua · Pokémon Armazón · **aparece en el juego**

**Habilidad — Nado Rápido**: Mojado (agua, suelo mojado o empapado) se mueve un 40% más rápido.

**Habilidad — Armadura Batalla**: Su armadura lo cubre: recibe 15% menos de frente.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 13 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 19 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 25 | Disparo Lodo | Tierra | Especial | Disparo | 55 | 1.7 s |
| 31 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 37 | Aguante | Normal | Estado | Defensa | — | 8.0 s |
| 43 | Eco Metálico | Acero | Estado | Área | — | 6.0 s |
| 49 | Megaagotar | Planta | Especial | Disparo | 40 | 1.5 s |
| 55 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 141 Kabutops

Roca/Agua · Pokémon Armazón

**Habilidad — Nado Rápido**: Mojado (agua, suelo mojado o empapado) se mueve un 40% más rápido.

**Habilidad — Armadura Batalla**: Su armadura lo cubre: recibe 15% menos de frente.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 1 | Corte Furia | Bicho | Físico | Golpe | 40 | 1.1 s |
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 25 | Disparo Lodo | Tierra | Especial | Disparo | 55 | 1.7 s |
| 31 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 37 | Aguante | Normal | Estado | Defensa | — | 8.0 s |
| 40 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 46 | Eco Metálico | Acero | Estado | Área | — | 6.0 s |
| 55 | Megaagotar | Planta | Especial | Disparo | 40 | 1.5 s |
| 65 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |

**Por MT/MO (28)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 142 Aerodactyl

Roca/Volador · Pokémon Fósil · **aparece en el juego**

**Habilidad — Cabeza Roca**: Sus embestidas pegan +25%.

**Habilidad — Presión**: Cada golpe suyo le suma 0,3 s a las recargas del rival.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ataque Ala | Volador | Físico | Embestida | 60 | 1.9 s |
| 8 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 15 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 22 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 29 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 36 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 43 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 50 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

**Por MT/MO (29)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 143 Snorlax

Normal · Pokémon Dormir · **aparece en el juego**

**Habilidad — Inmunidad**: No lo envenenan.

**Habilidad — Sebo**: El fuego y el hielo le hacen la mitad.


**Ataques que puede aprender (14)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 5 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 9 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 13 | Tambor | Normal | Estado | Mejora propia | — | 10.0 s |
| 17 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 21 | Bostezo | Normal | Estado | Disparo | — | 9.0 s |
| 25 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 29 | Ronquido | Normal | Especial | Disparo | 50 | 1.6 s |
| 33 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 37 | Sonámbulo | Normal | Estado | Mejora propia | — | 10.0 s |
| 41 | Bloqueo | Normal | Estado | Área | — | 6.0 s |
| 45 | Antojo | Normal | Físico | Golpe | 60 | 1.4 s |
| 49 | Rodar | Roca | Físico | Embestida | 30 | 2.0 s |
| 53 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

**Por MT/MO (31)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 144 Articuno

Hielo/Volador · Pokémon Congelar · **aparece en el juego**

**Habilidad — Presión**: Cada golpe suyo le suma 0,3 s a las recargas del rival.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Tornado | Volador | Especial | Disparo | 40 | 1.5 s |
| 1 | Nieve Polvo | Hielo | Especial | Área | 40 | 3.2 s |
| 13 | Neblina | Hielo | Estado | Mejora propia | — | 10.0 s |
| 25 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 37 | Telépata | Normal | Estado | Área | — | 6.0 s |
| 49 | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| 61 | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 73 | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| 85 | Frío Polar | Hielo | Especial | Disparo | 60 | 1.8 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 145 Zapdos

Eléctrico/Volador · Pokémon Eléctrico · **aparece en el juego**

**Habilidad — Presión**: Cada golpe suyo le suma 0,3 s a las recargas del rival.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 1 | Impactrueno | Eléctrico | Especial | Disparo | 40 | 1.5 s |
| 13 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 25 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 37 | Detección | Lucha | Estado | Defensa | — | 8.0 s |
| 49 | Pico Taladro | Volador | Físico | Embestida | 80 | 2.1 s |
| 61 | Carga | Eléctrico | Estado | Mejora propia | — | 10.0 s |
| 73 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 85 | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 146 Moltres

Fuego/Volador · Pokémon Llama

**Habilidad — Presión**: Cada golpe suyo le suma 0,3 s a las recargas del rival.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 1 | Ataque Ala | Volador | Físico | Embestida | 60 | 1.9 s |
| 13 | Giro Fuego | Fuego | Especial | Área | 35 | 3.0 s |
| 25 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 37 | Aguante | Normal | Estado | Defensa | — | 8.0 s |
| 49 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| 61 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 73 | Onda Ígnea | Fuego | Especial | Área | 95 | 4.7 s |
| 85 | Ataque Aéreo | Volador | Físico | Embestida | 140 | 3.0 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 147 Dratini

Dragón · Pokémon Dragón

**Habilidad — Mudar**: Cada 4 s se saca de encima los problemas de estado.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 8 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 15 | Ciclón | Dragón | Especial | Área | 40 | 6.0 s |
| 22 | Furia Dragón | Dragón | Especial | Disparo | 50 | 2.0 s |
| 29 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 36 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 43 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 50 | Enfado | Dragón | Físico | Embestida | 120 | 2.7 s |
| 57 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 148 Dragonair

Dragón · Pokémon Dragón · **aparece en el juego**

**Habilidad — Mudar**: Cada 4 s se saca de encima los problemas de estado.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 1 | Ciclón | Dragón | Especial | Área | 40 | 6.0 s |
| 1 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 22 | Furia Dragón | Dragón | Especial | Disparo | 50 | 2.0 s |
| 29 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 38 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 47 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 56 | Enfado | Dragón | Físico | Embestida | 120 | 2.7 s |
| 65 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 149 Dragonite

Dragón/Volador · Pokémon Dragón · **aparece en el juego**

**Habilidad — Fuerza Mental**: No sufre el stagger de los golpes: puede contestar enseguida.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 1 | Ciclón | Dragón | Especial | Área | 40 | 6.0 s |
| 1 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 22 | Furia Dragón | Dragón | Especial | Disparo | 50 | 2.0 s |
| 29 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 38 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 47 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 55 | Ataque Ala | Volador | Físico | Embestida | 60 | 1.9 s |
| 61 | Enfado | Dragón | Físico | Embestida | 120 | 2.7 s |
| 75 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

**Por MT/MO (40)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 150 Mewtwo

Psíquico · Pokémon Genético

**Habilidad — Presión**: Cada golpe suyo le suma 0,3 s a las recargas del rival.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 1 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 11 | Barrera | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 22 | Neblina | Hielo | Estado | Mejora propia | — | 10.0 s |
| 33 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 44 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |
| 55 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 66 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 77 | Autosugestión | Normal | Estado | Área | — | 6.0 s |
| 88 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |
| 99 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (43)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 151 Mew

Psíquico · Pokémon Nueva Especie

**Habilidad — Sincronía**: Los problemas de estado que le ponen se los devuelve al que se los puso.


**Ataques que puede aprender (6)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 10 | Transformación | Normal | Estado | Área | — | 6.0 s |
| 20 | Megapuño | Normal | Físico | Embestida | 80 | 2.1 s |
| 30 | Metrónomo | Normal | Estado | Mejora propia | — | 10.0 s |
| 40 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 50 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |

**Por MT/MO (58)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 152 Chikorita

Planta · Pokémon Hoja

**Habilidad — Espesura**: Con menos de 1/3 de vida sus ataques de tipo Planta pegan ×1,5.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 8 | Hoja Afilada | Planta | Físico | Disparo | 55 | 1.7 s |
| 12 | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 15 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 22 | Fotosíntesis | Planta | Estado | Mejora propia | — | 10.0 s |
| 29 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 36 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 43 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 50 | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 153 Bayleef

Planta · Pokémon Hoja

**Habilidad — Espesura**: Con menos de 1/3 de vida sus ataques de tipo Planta pegan ×1,5.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Hoja Afilada | Planta | Físico | Disparo | 55 | 1.7 s |
| 1 | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 15 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 23 | Fotosíntesis | Planta | Estado | Mejora propia | — | 10.0 s |
| 31 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 39 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 47 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 55 | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 154 Meganium

Planta · Pokémon Hierba

**Habilidad — Espesura**: Con menos de 1/3 de vida sus ataques de tipo Planta pegan ×1,5.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Hoja Afilada | Planta | Físico | Disparo | 55 | 1.7 s |
| 1 | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 15 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 23 | Fotosíntesis | Planta | Estado | Mejora propia | — | 10.0 s |
| 31 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 41 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 51 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 61 | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 155 Cyndaquil

Fuego · Pokémon Ratón Fuego

**Habilidad — Mar Llamas**: Con menos de 1/3 de vida sus ataques de tipo Fuego pegan ×1,5.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 6 | Pantalla de Humo | Normal | Estado | Zona | — | 9.0 s |
| 12 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 19 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 27 | Rueda Fuego | Fuego | Físico | Embestida | 60 | 1.9 s |
| 36 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 46 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |

**Por MT/MO (17)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 156 Quilava

Fuego · Pokémon Volcán

**Habilidad — Mar Llamas**: Con menos de 1/3 de vida sus ataques de tipo Fuego pegan ×1,5.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Pantalla de Humo | Normal | Estado | Zona | — | 9.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 12 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 21 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 31 | Rueda Fuego | Fuego | Físico | Embestida | 60 | 1.9 s |
| 42 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 54 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 157 Typhlosion

Fuego · Pokémon Volcán

**Habilidad — Mar Llamas**: Con menos de 1/3 de vida sus ataques de tipo Fuego pegan ×1,5.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Pantalla de Humo | Normal | Estado | Zona | — | 9.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 21 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 31 | Rueda Fuego | Fuego | Físico | Embestida | 60 | 1.9 s |
| 45 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 60 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 158 Totodile

Agua · Pokémon Fauces

**Habilidad — Torrente**: Con menos de 1/3 de vida sus ataques de tipo Agua pegan ×1,5.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 7 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 13 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 20 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 27 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 35 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 43 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 52 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 159 Croconaw

Agua · Pokémon Fauces

**Habilidad — Torrente**: Con menos de 1/3 de vida sus ataques de tipo Agua pegan ×1,5.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 13 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 21 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 28 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 37 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 45 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 55 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (27)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 160 Feraligatr

Agua · Pokémon Fauces

**Habilidad — Torrente**: Con menos de 1/3 de vida sus ataques de tipo Agua pegan ×1,5.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 21 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 28 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 38 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 47 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 58 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (30)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 161 Sentret

Normal · Pokémon Explorador

**Habilidad — Fuga**: Esquiva mucho más seguido (recarga del esquive −40%).

**Habilidad — Vista Lince**: No lo desorientan y sus disparos pegan +10%.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 4 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 7 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 12 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 17 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 24 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 31 | Señuelo | Normal | Estado | Mejora propia | — | 10.0 s |
| 40 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 49 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 162 Furret

Normal · Pokémon Alargado

**Habilidad — Fuga**: Esquiva mucho más seguido (recarga del esquive −40%).

**Habilidad — Vista Lince**: No lo desorientan y sus disparos pegan +10%.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 12 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 19 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 28 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 37 | Señuelo | Normal | Estado | Mejora propia | — | 10.0 s |
| 48 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 59 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (31)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 163 Hoothoot

Normal/Volador · Pokémon Búho

**Habilidad — Insomnio**: No lo duermen.

**Habilidad — Vista Lince**: No lo desorientan y sus disparos pegan +10%.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 6 | Profecía | Normal | Estado | Área | — | 6.0 s |
| 11 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 16 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 22 | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 28 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 34 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 48 | Comesueños | Psíquico | Especial | Disparo | 100 | 7.0 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 164 Noctowl

Normal/Volador · Pokémon Búho

**Habilidad — Insomnio**: No lo duermen.

**Habilidad — Vista Lince**: No lo desorientan y sus disparos pegan +10%.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Profecía | Normal | Estado | Área | — | 6.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 16 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 25 | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 33 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 41 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 57 | Comesueños | Psíquico | Especial | Disparo | 100 | 7.0 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 165 Ledyba

Bicho/Volador · Pokémon 5 Estrellas

**Habilidad — Enjambre**: Con menos de 1/3 de vida sus ataques de tipo Bicho pegan ×1,5.

**Habilidad — Madrugar**: Dormido, se despierta solo al segundo.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 8 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 15 | Puño Cometa | Normal | Físico | Golpe | 18 | 0.8 s |
| 22 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 22 | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 22 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 29 | Relevo | Normal | Estado | Mejora propia | — | 10.0 s |
| 36 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 43 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 50 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 166 Ledian

Bicho/Volador · Pokémon 5 Estrellas

**Habilidad — Enjambre**: Con menos de 1/3 de vida sus ataques de tipo Bicho pegan ×1,5.

**Habilidad — Madrugar**: Dormido, se despierta solo al segundo.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 15 | Puño Cometa | Normal | Físico | Golpe | 18 | 0.8 s |
| 24 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 24 | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 24 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 33 | Relevo | Normal | Estado | Mejora propia | — | 10.0 s |
| 42 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 51 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 60 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 167 Spinarak

Bicho/Veneno · Pokémon Escupesoga

**Habilidad — Enjambre**: Con menos de 1/3 de vida sus ataques de tipo Bicho pegan ×1,5.

**Habilidad — Insomnio**: No lo duermen.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 1 | Disparo Demora | Bicho | Estado | Disparo | — | 2.5 s |
| 6 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 11 | Restricción | Normal | Físico | Látigo | 15 | 5.0 s |
| 17 | Tinieblas | Fantasma | Especial | Disparo | 60 | 1.8 s |
| 23 | Chupavidas | Bicho | Físico | Golpe | 80 | 3.0 s |
| 30 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 37 | Telaraña | Bicho | Estado | Zona | — | 6.0 s |
| 45 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 53 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 168 Ariados

Bicho/Veneno · Pokémon Pata Larga

**Habilidad — Enjambre**: Con menos de 1/3 de vida sus ataques de tipo Bicho pegan ×1,5.

**Habilidad — Insomnio**: No lo duermen.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Restricción | Normal | Físico | Látigo | 15 | 5.0 s |
| 1 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 1 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 1 | Disparo Demora | Bicho | Estado | Disparo | — | 2.5 s |
| 17 | Tinieblas | Fantasma | Especial | Disparo | 60 | 1.8 s |
| 25 | Chupavidas | Bicho | Físico | Golpe | 80 | 3.0 s |
| 34 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 43 | Telaraña | Bicho | Estado | Zona | — | 6.0 s |
| 53 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 63 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 169 Crobat

Veneno/Volador · Pokémon Murciélago

**Habilidad — Fuerza Mental**: No sufre el stagger de los golpes: puede contestar enseguida.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 1 | Chupavidas | Bicho | Físico | Golpe | 80 | 3.0 s |
| 1 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 1 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 16 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 21 | Ataque Ala | Volador | Físico | Embestida | 60 | 1.9 s |
| 28 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 35 | Aire Afilado | Volador | Especial | Área | 60 | 3.7 s |
| 42 | Mal de Ojo | Normal | Estado | Área | — | 6.0 s |
| 49 | Colmillo Veneno | Veneno | Físico | Golpe | 50 | 1.3 s |
| 56 | Niebla | Hielo | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 170 Chinchou

Agua/Eléctrico · Pokémon Rape

**Habilidad — Absorbe Electricidad**: Los ataques Eléctricos no le hacen nada y lo curan un 25%.

**Habilidad — Iluminación**: Brilla: sus golpes a veces dejan Expuesto al rival (20%).


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 1 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 5 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 13 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |
| 17 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 25 | Chispa | Eléctrico | Físico | Embestida | 65 | 6.0 s |
| 29 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 37 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 41 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |
| 49 | Carga | Eléctrico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 171 Lanturn

Agua/Eléctrico · Pokémon Luz

**Habilidad — Absorbe Electricidad**: Los ataques Eléctricos no le hacen nada y lo curan un 25%.

**Habilidad — Iluminación**: Brilla: sus golpes a veces dejan Expuesto al rival (20%).


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 1 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 1 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 13 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |
| 17 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 25 | Chispa | Eléctrico | Físico | Embestida | 65 | 6.0 s |
| 32 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 43 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 50 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |
| 61 | Carga | Eléctrico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 172 Pichu

Eléctrico · Pokémon Ratoncito

**Habilidad — Electricidad Estática**: Al que le pega cuerpo a cuerpo lo paraliza (30%).


**Ataques que puede aprender (5)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Encanto | Hada | Estado | Área | — | 6.0 s |
| 1 | Impactrueno | Eléctrico | Especial | Disparo | 40 | 1.5 s |
| 6 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 8 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 11 | Beso Dulce | Hada | Estado | Disparo | — | 6.0 s |

**Por MT/MO (17)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 173 Cleffa

Hada · Pokémon Estrella

**Habilidad — Gran Encanto**: Al que le pega cuerpo a cuerpo lo deja Intimidado (30%).


**Ataques que puede aprender (6)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Encanto | Hada | Estado | Área | — | 6.0 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 4 | Otra Vez | Normal | Estado | Área | — | 6.0 s |
| 8 | Canto | Normal | Estado | Zona | — | 12.0 s |
| 13 | Beso Dulce | Hada | Estado | Disparo | — | 6.0 s |
| 17 | Hoja Mágica | Planta | Especial | Disparo | 60 | 1.8 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 174 Igglybuff

Normal/Hada · Pokémon Globo

**Habilidad — Gran Encanto**: Al que le pega cuerpo a cuerpo lo deja Intimidado (30%).


**Ataques que puede aprender (5)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Encanto | Hada | Estado | Área | — | 6.0 s |
| 1 | Canto | Normal | Estado | Zona | — | 12.0 s |
| 4 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 9 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 14 | Beso Dulce | Hada | Estado | Disparo | — | 6.0 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 175 Togepi

Hada · Pokémon Bolaclavos

**Habilidad — Entusiasmo**: Sus golpes cuerpo a cuerpo pegan +30%.

**Habilidad — Dicha**: Sus ataques con estado lo ponen el doble de seguido.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Encanto | Hada | Estado | Área | — | 6.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 4 | Metrónomo | Normal | Estado | Mejora propia | — | 10.0 s |
| 9 | Beso Dulce | Hada | Estado | Disparo | — | 6.0 s |
| 13 | Bostezo | Normal | Estado | Disparo | — | 9.0 s |
| 17 | Otra Vez | Normal | Estado | Área | — | 6.0 s |
| 21 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 25 | Señuelo | Normal | Estado | Mejora propia | — | 10.0 s |
| 29 | Deseo | Normal | Estado | Mejora propia | — | 10.0 s |
| 33 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 37 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |
| 41 | Relevo | Normal | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 176 Togetic

Hada/Volador · Pokémon Felicidad

**Habilidad — Entusiasmo**: Sus golpes cuerpo a cuerpo pegan +30%.

**Habilidad — Dicha**: Sus ataques con estado lo ponen el doble de seguido.


**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Encanto | Hada | Estado | Área | — | 6.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Hoja Mágica | Planta | Especial | Disparo | 60 | 1.8 s |
| 1 | Metrónomo | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Beso Dulce | Hada | Estado | Disparo | — | 6.0 s |
| 13 | Bostezo | Normal | Estado | Disparo | — | 9.0 s |
| 17 | Otra Vez | Normal | Estado | Área | — | 6.0 s |
| 21 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 25 | Señuelo | Normal | Estado | Mejora propia | — | 10.0 s |
| 29 | Deseo | Normal | Estado | Mejora propia | — | 10.0 s |
| 33 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 37 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |
| 41 | Relevo | Normal | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (30)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 177 Natu

Psíquico/Volador · Pokémon Pajarito

**Habilidad — Sincronía**: Los problemas de estado que le ponen se los devuelve al que se los puso.

**Habilidad — Madrugar**: Dormido, se despierta solo al segundo.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 10 | Tinieblas | Fantasma | Especial | Disparo | 60 | 1.8 s |
| 20 | Teletransporte | Psíquico | Estado | Embestida | — | 3.0 s |
| 30 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |
| 30 | Deseo | Normal | Estado | Mejora propia | — | 10.0 s |
| 40 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 50 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 178 Xatu

Psíquico/Volador · Pokémon Místico

**Habilidad — Sincronía**: Los problemas de estado que le ponen se los devuelve al que se los puso.

**Habilidad — Madrugar**: Dormido, se despierta solo al segundo.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 10 | Tinieblas | Fantasma | Especial | Disparo | 60 | 1.8 s |
| 20 | Teletransporte | Psíquico | Estado | Embestida | — | 3.0 s |
| 35 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |
| 35 | Deseo | Normal | Estado | Mejora propia | — | 10.0 s |
| 50 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 65 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 179 Mareep

Eléctrico · Pokémon Lana

**Habilidad — Electricidad Estática**: Al que le pega cuerpo a cuerpo lo paraliza (30%).


**Ataques que puede aprender (7)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 9 | Impactrueno | Eléctrico | Especial | Disparo | 40 | 1.5 s |
| 16 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 23 | Esporagodón | Planta | Estado | Área | — | 6.0 s |
| 30 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 37 | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |

**Por MT/MO (17)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 180 Flaaffy

Eléctrico · Pokémon Lana

**Habilidad — Electricidad Estática**: Al que le pega cuerpo a cuerpo lo paraliza (30%).


**Ataques que puede aprender (7)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Impactrueno | Eléctrico | Especial | Disparo | 40 | 1.5 s |
| 18 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 27 | Esporagodón | Planta | Estado | Área | — | 6.0 s |
| 36 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 45 | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 181 Ampharos

Eléctrico · Pokémon Luz

**Habilidad — Electricidad Estática**: Al que le pega cuerpo a cuerpo lo paraliza (30%).


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Impactrueno | Eléctrico | Especial | Disparo | 40 | 1.5 s |
| 1 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 27 | Esporagodón | Planta | Estado | Área | — | 6.0 s |
| 30 | Puño Trueno | Eléctrico | Físico | Golpe | 75 | 1.4 s |
| 42 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 57 | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 182 Bellossom

Planta · Pokémon Flor

**Habilidad — Clorofila**: De día se mueve un 30% más rápido.


**Ataques que puede aprender (6)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 1 | Hoja Mágica | Planta | Especial | Disparo | 60 | 1.8 s |
| 1 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 1 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 44 | Danza Pétalo | Planta | Especial | Área | 120 | 5.5 s |
| 55 | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 183 Marill

Agua/Hada · Pokémon Ratón Agua

**Habilidad — Sebo**: El fuego y el hielo le hacen la mitad.

**Habilidad — Potencia**: Sus golpes cuerpo a cuerpo pegan +50%.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 3 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 6 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 10 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 15 | Rodar | Roca | Físico | Embestida | 30 | 2.0 s |
| 21 | Rayo Burbuja | Agua | Especial | Disparo | 30 | 3.0 s |
| 28 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |
| 36 | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| 45 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 184 Azumarill

Agua/Hada · Pokémon Conejo Agua

**Habilidad — Sebo**: El fuego y el hielo le hacen la mitad.

**Habilidad — Potencia**: Sus golpes cuerpo a cuerpo pegan +50%.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 15 | Rodar | Roca | Físico | Embestida | 30 | 2.0 s |
| 24 | Rayo Burbuja | Agua | Especial | Disparo | 30 | 3.0 s |
| 34 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |
| 45 | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| 57 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 185 Sudowoodo

Roca · Pokémon Imitación

**Habilidad — Robustez**: Con la vida llena, un golpe que lo debilitaría lo deja con 1 de vida.

**Habilidad — Cabeza Roca**: Sus embestidas pegan +25%.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mimético | Normal | Estado | Área | — | 6.0 s |
| 1 | Lanzarrocas | Roca | Físico | Disparo | 50 | 1.6 s |
| 9 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |
| 17 | Patada Baja | Lucha | Físico | Golpe | 50 | 3.5 s |
| 25 | Avalancha | Roca | Físico | Área | 75 | 4.2 s |
| 33 | Bloqueo | Normal | Estado | Área | — | 6.0 s |
| 41 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 49 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 57 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 186 Politoed

Agua · Pokémon Rana

**Habilidad — Absorbe Agua**: Los ataques de Agua no le hacen nada y lo curan un 25%.

**Habilidad — Humedad**: No lo queman y el fuego le hace un 20% menos.


**Ataques que puede aprender (5)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 1 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 1 | Canto Mortal | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 51 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |

**Por MT/MO (27)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 187 Hoppip

Planta/Volador · Pokémon Algadón

**Habilidad — Clorofila**: De día se mueve un 30% más rápido.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Salpicadura | Normal | Estado | Embestida | — | 1.5 s |
| 5 | Fotosíntesis | Planta | Estado | Mejora propia | — | 10.0 s |
| 5 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 10 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 13 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 15 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 17 | Somnífero | Planta | Estado | Zona | — | 12.0 s |
| 20 | Drenadoras | Planta | Estado | Área | — | 6.0 s |
| 25 | Esporagodón | Planta | Estado | Área | — | 6.0 s |
| 30 | Megaagotar | Planta | Especial | Disparo | 40 | 1.5 s |

**Por MT/MO (16)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 188 Skiploom

Planta/Volador · Pokémon Algadón

**Habilidad — Clorofila**: De día se mueve un 30% más rápido.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Salpicadura | Normal | Estado | Embestida | — | 1.5 s |
| 1 | Fotosíntesis | Planta | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 13 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 15 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 17 | Somnífero | Planta | Estado | Zona | — | 12.0 s |
| 22 | Drenadoras | Planta | Estado | Área | — | 6.0 s |
| 29 | Esporagodón | Planta | Estado | Área | — | 6.0 s |
| 36 | Megaagotar | Planta | Especial | Disparo | 40 | 1.5 s |

**Por MT/MO (16)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 189 Jumpluff

Planta/Volador · Pokémon Algadón

**Habilidad — Clorofila**: De día se mueve un 30% más rápido.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Salpicadura | Normal | Estado | Embestida | — | 1.5 s |
| 1 | Fotosíntesis | Planta | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 13 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 15 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 17 | Somnífero | Planta | Estado | Zona | — | 12.0 s |
| 22 | Drenadoras | Planta | Estado | Área | — | 6.0 s |
| 33 | Esporagodón | Planta | Estado | Área | — | 6.0 s |
| 44 | Megaagotar | Planta | Especial | Disparo | 40 | 1.5 s |

**Por MT/MO (17)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 190 Aipom

Normal · Pokémon Cola Larga

**Habilidad — Fuga**: Esquiva mucho más seguido (recarga del esquive −40%).

**Habilidad — Recogida**: Si gana una pelea, a veces encuentra una Poción (tu equipo).


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 6 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 13 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 18 | Relevo | Normal | Estado | Mejora propia | — | 10.0 s |
| 25 | Cosquillas | Normal | Estado | Área | — | 6.0 s |
| 31 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 38 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 43 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 50 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (29)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 191 Sunkern

Planta · Pokémon Semilla

**Habilidad — Clorofila**: De día se mueve un 30% más rápido.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 6 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 13 | Megaagotar | Planta | Especial | Disparo | 40 | 1.5 s |
| 18 | Arraigo | Planta | Estado | Mejora propia | — | 10.0 s |
| 25 | Esfuerzo | Normal | Físico | Golpe | 60 | 1.4 s |
| 30 | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| 37 | Fotosíntesis | Planta | Estado | Mejora propia | — | 10.0 s |
| 42 | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 192 Sunflora

Planta · Pokémon Sol

**Habilidad — Clorofila**: De día se mueve un 30% más rápido.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 6 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 13 | Hoja Afilada | Planta | Físico | Disparo | 55 | 1.7 s |
| 18 | Arraigo | Planta | Estado | Mejora propia | — | 10.0 s |
| 25 | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| 30 | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| 37 | Danza Pétalo | Planta | Especial | Área | 120 | 5.5 s |
| 42 | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 193 Yanma

Bicho/Volador · Pokémon Ala Clara

**Habilidad — Impulso**: Siempre un 15% más rápido.

**Habilidad — Ojo Compuesto**: Sus ataques con estado lo ponen un 30% más seguido.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Profecía | Normal | Estado | Área | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 6 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 12 | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| 17 | Bomba Sónica | Normal | Especial | Área | 25 | 4.0 s |
| 23 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 28 | Detección | Lucha | Estado | Defensa | — | 8.0 s |
| 34 | Alboroto | Normal | Especial | Disparo | 90 | 2.4 s |
| 39 | Ataque Ala | Volador | Físico | Embestida | 60 | 1.9 s |
| 45 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 50 | Chirrido | Normal | Estado | Área | — | 6.0 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 194 Wooper

Agua/Tierra · Pokémon Pez Agua

**Habilidad — Humedad**: No lo queman y el fuego le hace un 20% menos.

**Habilidad — Absorbe Agua**: Los ataques de Agua no le hacen nada y lo curan un 25%.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 11 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 16 | Disparo Lodo | Tierra | Especial | Disparo | 55 | 1.7 s |
| 21 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 31 | Bostezo | Normal | Estado | Disparo | — | 9.0 s |
| 36 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 41 | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| 51 | Niebla | Hielo | Estado | Mejora propia | — | 10.0 s |
| 51 | Neblina | Hielo | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 195 Quagsire

Agua/Tierra · Pokémon Pez Agua

**Habilidad — Humedad**: No lo queman y el fuego le hace un 20% menos.

**Habilidad — Absorbe Agua**: Los ataques de Agua no le hacen nada y lo curan un 25%.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 11 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 16 | Disparo Lodo | Tierra | Especial | Disparo | 55 | 1.7 s |
| 23 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 35 | Bostezo | Normal | Estado | Disparo | — | 9.0 s |
| 42 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 49 | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| 61 | Niebla | Hielo | Estado | Mejora propia | — | 10.0 s |
| 61 | Neblina | Hielo | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (30)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 196 Espeon

Psíquico · Pokémon Sol

**Habilidad — Sincronía**: Los problemas de estado que le ponen se los devuelve al que se los puso.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 8 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 16 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 23 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 30 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 36 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 42 | Autosugestión | Normal | Estado | Área | — | 6.0 s |
| 47 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 52 | Sol Matinal | Normal | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 197 Umbreon

Siniestro · Pokémon Luz Lunar

**Habilidad — Sincronía**: Los problemas de estado que le ponen se los devuelve al que se los puso.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 8 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 16 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 23 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 30 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 36 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 42 | Mal de Ojo | Normal | Estado | Área | — | 6.0 s |
| 47 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 52 | Luz Lunar | Hada | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 198 Murkrow

Siniestro/Volador · Pokémon Oscuridad

**Habilidad — Insomnio**: No lo duermen.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 9 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 14 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 22 | Niebla | Hielo | Estado | Mejora propia | — | 10.0 s |
| 27 | Tinieblas | Fantasma | Especial | Disparo | 60 | 1.8 s |
| 35 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 40 | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| 48 | Mal de Ojo | Normal | Estado | Área | — | 6.0 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 199 Slowking

Agua/Psíquico · Pokémon Regio

**Habilidad — Despiste**: No lo intimidan ni lo desorientan.

**Habilidad — Ritmo Propio**: No lo desorientan.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Maldición | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Bostezo | Normal | Estado | Disparo | — | 9.0 s |
| 6 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 13 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 17 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 24 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 29 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 36 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 40 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 47 | Autosugestión | Normal | Estado | Área | — | 6.0 s |

**Por MT/MO (34)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 200 Misdreavus

Fantasma · Pokémon Chirrido

**Habilidad — Levitación**: Flota: los ataques de Tierra no le hacen nada.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Psicoonda | Psíquico | Especial | Disparo | 60 | 1.8 s |
| 6 | Rencor | Fantasma | Estado | Área | — | 6.0 s |
| 11 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 17 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 23 | Mal de Ojo | Normal | Estado | Área | — | 6.0 s |
| 30 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 37 | Divide Dolor | Normal | Estado | Área | — | 6.0 s |
| 45 | Canto Mortal | Normal | Estado | Mejora propia | — | 10.0 s |
| 53 | Rabia | Fantasma | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 201 Unown

Psíquico · Pokémon Símbolo

**Habilidad — Levitación**: Flota: los ataques de Tierra no le hacen nada.


**Ataques que puede aprender (1)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |

### 202 Wobbuffet

Psíquico · Pokémon Paciente

**Habilidad — Sombra Trampa**: Los rivales cerca suyo quedan ralentizados.


**Ataques que puede aprender (4)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Contraataque | Lucha | Físico | Golpe | 60 | 1.4 s |
| 1 | Mismo Destino | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 1 | Manto Espejo | Psíquico | Especial | Disparo | 60 | 1.8 s |
| 1 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |

### 203 Girafarig

Normal/Psíquico · Pokémon Gran Cuello

**Habilidad — Fuerza Mental**: No sufre el stagger de los golpes: puede contestar enseguida.

**Habilidad — Madrugar**: Dormido, se despierta solo al segundo.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 7 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 13 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 19 | Pisotón | Normal | Físico | Golpe | 65 | 1.2 s |
| 25 | Rastreo | Normal | Estado | Área | — | 6.0 s |
| 31 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 37 | Relevo | Normal | Estado | Mejora propia | — | 10.0 s |
| 43 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 49 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |

**Por MT/MO (27)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 204 Pineco

Bicho · Pokémon Larva

**Habilidad — Robustez**: Con la vida llena, un golpe que lo debilitaría lo deja con 1 de vida.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 8 | Autodestrucción | Normal | Físico | Área | 130 | 20.0 s |
| 15 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 22 | Giro Rápido | Normal | Físico | Embestida | 50 | 7.0 s |
| 29 | Venganza | Normal | Físico | Embestida | 60 | 1.9 s |
| 36 | Explosión | Normal | Físico | Área | 250 | 9.2 s |
| 43 | Púas | Tierra | Estado | Mejora propia | — | 10.0 s |
| 50 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 205 Forretress

Bicho/Acero · Pokémon Larva

**Habilidad — Robustez**: Con la vida llena, un golpe que lo debilitaría lo deja con 1 de vida.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 1 | Autodestrucción | Normal | Físico | Área | 130 | 20.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 15 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 22 | Giro Rápido | Normal | Físico | Embestida | 50 | 7.0 s |
| 29 | Venganza | Normal | Físico | Embestida | 60 | 1.9 s |
| 31 | Electrocañón | Eléctrico | Especial | Disparo | 120 | 2.9 s |
| 39 | Explosión | Normal | Físico | Área | 250 | 9.2 s |
| 49 | Púas | Tierra | Estado | Mejora propia | — | 10.0 s |
| 59 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 206 Dunsparce

Normal · Pokémon Serpiente Tierra

**Habilidad — Dicha**: Sus ataques con estado lo ponen el doble de seguido.

**Habilidad — Fuga**: Esquiva mucho más seguido (recarga del esquive −40%).


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 4 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 11 | Bostezo | Normal | Estado | Disparo | — | 9.0 s |
| 14 | Deslumbrar | Normal | Estado | Canalizado | — | 9.0 s |
| 21 | Rodar | Roca | Físico | Embestida | 30 | 2.0 s |
| 24 | Rencor | Fantasma | Estado | Área | — | 6.0 s |
| 31 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 34 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 41 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 44 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |
| 51 | Esfuerzo | Normal | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (30)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 207 Gligar

Tierra/Volador · Pokémon Escorpiala

**Habilidad — Corte Fuerte**: No lo intimidan.

**Habilidad — Velo Arena**: Un 12% de los golpes no le entran.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 6 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 13 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 20 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 28 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 36 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 44 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 52 | Guillotina | Normal | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 208 Steelix

Acero/Tierra · Pokémon Serpiente Férrea

**Habilidad — Cabeza Roca**: Sus embestidas pegan +25%.

**Habilidad — Robustez**: Con la vida llena, un golpe que lo debilitaría lo deja con 1 de vida.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 8 | Atadura | Normal | Físico | Látigo | 15 | 3.0 s |
| 12 | Lanzarrocas | Roca | Físico | Disparo | 50 | 1.6 s |
| 19 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 23 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 30 | Dragoaliento | Dragón | Especial | Disparo | 60 | 1.8 s |
| 34 | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| 41 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 45 | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| 52 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 56 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 209 Snubbull

Hada · Pokémon Hada

**Habilidad — Intimidación**: Al encarar a un rival lo deja Intimidado (pega menos).

**Habilidad — Fuga**: Esquiva mucho más seguido (recarga del esquive −40%).


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 4 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 8 | Encanto | Hada | Estado | Área | — | 6.0 s |
| 13 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 19 | Lengüetazo | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 26 | Rugido | Normal | Estado | Área | — | 6.0 s |
| 34 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 43 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 53 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |

**Por MT/MO (33)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 210 Granbull

Hada · Pokémon Hada

**Habilidad — Intimidación**: Al encarar a un rival lo deja Intimidado (pega menos).


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 4 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 8 | Encanto | Hada | Estado | Área | — | 6.0 s |
| 13 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 19 | Lengüetazo | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 28 | Rugido | Normal | Estado | Área | — | 6.0 s |
| 38 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 49 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 61 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |

**Por MT/MO (36)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 211 Qwilfish

Agua/Veneno · Pokémon Globo

**Habilidad — Punto Tóxico**: Al que le pega cuerpo a cuerpo lo envenena (30%).

**Habilidad — Nado Rápido**: Mojado (agua, suelo mojado o empapado) se mueve un 40% más rápido.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 1 | Púas | Tierra | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 9 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 9 | Reducción | Normal | Estado | Mejora propia | — | 9.0 s |
| 13 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 21 | Pin Misil | Bicho | Físico | Disparo | 25 | 4.5 s |
| 25 | Desquite | Lucha | Físico | Golpe | 60 | 1.4 s |
| 33 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 37 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |
| 45 | Mismo Destino | Fantasma | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 212 Scizor

Bicho/Acero · Pokémon Tenaza

**Habilidad — Enjambre**: Con menos de 1/3 de vida sus ataques de tipo Bicho pegan ×1,5.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 6 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 11 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 16 | Falso Tortazo | Normal | Físico | Golpe | 40 | 1.1 s |
| 21 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 26 | Garra Metal | Acero | Físico | Golpe | 50 | 1.3 s |
| 31 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 36 | Danza Espada | Normal | Estado | Mejora propia | — | 10.0 s |
| 41 | Defensa Férrea | Acero | Estado | Mejora propia | — | 10.0 s |
| 46 | Corte Furia | Bicho | Físico | Golpe | 40 | 1.1 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 213 Shuckle

Bicho/Roca · Pokémon Moho

**Habilidad — Robustez**: Con la vida llena, un golpe que lo debilitaría lo deja con 1 de vida.


**Ataques que puede aprender (7)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Restricción | Normal | Físico | Látigo | 15 | 5.0 s |
| 1 | Refugio | Agua | Estado | Mejora propia | — | 9.0 s |
| 9 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 14 | Otra Vez | Normal | Estado | Área | — | 6.0 s |
| 23 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 28 | Venganza | Normal | Físico | Embestida | 60 | 1.9 s |
| 37 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 214 Heracross

Bicho/Lucha · Pokémon Cuerno

**Habilidad — Enjambre**: Con menos de 1/3 de vida sus ataques de tipo Bicho pegan ×1,5.

**Habilidad — Agallas**: Con un problema de estado sus ataques físicos pegan ×1,5.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 6 | Cornada | Normal | Físico | Embestida | 65 | 5.0 s |
| 11 | Aguante | Normal | Estado | Defensa | — | 8.0 s |
| 17 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 23 | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| 30 | Contraataque | Lucha | Físico | Golpe | 60 | 1.4 s |
| 37 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 45 | Inversión | Lucha | Físico | Golpe | 60 | 1.4 s |
| 53 | Megacuerno | Bicho | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 215 Sneasel

Siniestro/Hielo · Pokémon Garra Filo

**Habilidad — Fuerza Mental**: No sufre el stagger de los golpes: puede contestar enseguida.

**Habilidad — Vista Lince**: No lo desorientan y sus disparos pegan +10%.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| 8 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 15 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 22 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 29 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 36 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 43 | Viento Hielo | Hielo | Especial | Disparo | 55 | 1.7 s |
| 50 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 57 | Paliza | Siniestro | Físico | Golpe | 60 | 1.4 s |
| 64 | Garra Metal | Acero | Físico | Golpe | 50 | 1.3 s |

**Por MT/MO (30)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 216 Teddiursa

Normal · Pokémon Osito

**Habilidad — Recogida**: Si gana una pelea, a veces encuentra una Poción (tu equipo).


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 7 | Lengüetazo | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 13 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 19 | Llanto Falso | Siniestro | Estado | Área | — | 6.0 s |
| 25 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 31 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 37 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 43 | Ronquido | Normal | Especial | Disparo | 50 | 1.6 s |
| 49 | Saña | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 217 Ursaring

Normal · Pokémon Hibernante

**Habilidad — Agallas**: Con un problema de estado sus ataques físicos pegan ×1,5.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Lengüetazo | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 19 | Llanto Falso | Siniestro | Estado | Área | — | 6.0 s |
| 25 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 31 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 37 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 43 | Ronquido | Normal | Especial | Disparo | 50 | 1.6 s |
| 49 | Saña | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (27)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 218 Slugma

Fuego · Pokémon Lava

**Habilidad — Escudo Magma**: No lo congelan.

**Habilidad — Cuerpo Llama**: Al que le pega cuerpo a cuerpo lo quema (30%).


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Polución | Veneno | Especial | Disparo | 30 | 1.3 s |
| 1 | Bostezo | Normal | Estado | Disparo | — | 9.0 s |
| 8 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 15 | Lanzarrocas | Roca | Físico | Disparo | 50 | 1.6 s |
| 22 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 29 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 36 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| 43 | Avalancha | Roca | Físico | Área | 75 | 4.2 s |
| 50 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |

**Por MT/MO (17)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 219 Magcargo

Fuego/Roca · Pokémon Lava

**Habilidad — Escudo Magma**: No lo congelan.

**Habilidad — Cuerpo Llama**: Al que le pega cuerpo a cuerpo lo quema (30%).


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 1 | Lanzarrocas | Roca | Físico | Disparo | 50 | 1.6 s |
| 1 | Polución | Veneno | Especial | Disparo | 30 | 1.3 s |
| 1 | Bostezo | Normal | Estado | Disparo | — | 9.0 s |
| 22 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 29 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 36 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| 48 | Avalancha | Roca | Físico | Área | 75 | 4.2 s |
| 60 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 220 Swinub

Hielo/Tierra · Pokémon Cerdo

**Habilidad — Despiste**: No lo intimidan ni lo desorientan.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Rastreo | Normal | Estado | Área | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 10 | Nieve Polvo | Hielo | Especial | Área | 40 | 3.2 s |
| 19 | Aguante | Normal | Estado | Defensa | — | 8.0 s |
| 28 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 37 | Neblina | Hielo | Estado | Mejora propia | — | 10.0 s |
| 46 | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| 55 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 221 Piloswine

Hielo/Tierra · Pokémon Puerco

**Habilidad — Despiste**: No lo intimidan ni lo desorientan.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Aguante | Normal | Estado | Defensa | — | 8.0 s |
| 1 | Cornada | Normal | Físico | Embestida | 65 | 5.0 s |
| 1 | Rastreo | Normal | Estado | Área | — | 6.0 s |
| 1 | Nieve Polvo | Hielo | Especial | Área | 40 | 3.2 s |
| 28 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 33 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 42 | Neblina | Hielo | Estado | Mejora propia | — | 10.0 s |
| 56 | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| 70 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 222 Corsola

Agua/Roca · Pokémon Coral

**Habilidad — Entusiasmo**: Sus golpes cuerpo a cuerpo pegan +30%.

**Habilidad — Cura Natural**: Cada 8 s se cura los problemas de estado.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 6 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 12 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 17 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |
| 17 | Alivio | Normal | Estado | Mejora propia | — | 10.0 s |
| 23 | Rayo Burbuja | Agua | Especial | Disparo | 30 | 3.0 s |
| 28 | Clavo Cañón | Normal | Físico | Golpe | 20 | 0.9 s |
| 34 | Pedrada | Roca | Físico | Golpe | 25 | 0.9 s |
| 39 | Manto Espejo | Psíquico | Especial | Disparo | 60 | 1.8 s |
| 45 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |

**Por MT/MO (29)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 223 Remoraid

Agua · Pokémon Reactor

**Habilidad — Entusiasmo**: Sus golpes cuerpo a cuerpo pegan +30%.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 11 | Fijar Blanco | Normal | Estado | Disparo | — | 8.0 s |
| 22 | Rayo Aurora | Hielo | Especial | Disparo | 65 | 1.9 s |
| 22 | Rayo Burbuja | Agua | Especial | Disparo | 30 | 3.0 s |
| 22 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 33 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 44 | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| 55 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 224 Octillery

Agua · Pokémon Reactor

**Habilidad — Ventosas**: Se agarra al suelo: casi no lo empujan.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 11 | Restricción | Normal | Físico | Látigo | 15 | 5.0 s |
| 22 | Rayo Aurora | Hielo | Especial | Disparo | 65 | 1.9 s |
| 22 | Rayo Burbuja | Agua | Especial | Disparo | 30 | 3.0 s |
| 22 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 25 | Pulpocañón | Agua | Especial | Disparo | 65 | 1.9 s |
| 38 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 54 | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| 70 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 225 Delibird

Hielo/Volador · Pokémon Reparto

**Habilidad — Espíritu Vital**: No lo duermen.

**Habilidad — Entusiasmo**: Sus golpes cuerpo a cuerpo pegan +30%.


**Ataques que puede aprender (1)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Presente | Normal | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 226 Mantine

Agua/Volador · Pokémon Milano

**Habilidad — Nado Rápido**: Mojado (agua, suelo mojado o empapado) se mueve un 40% más rápido.

**Habilidad — Absorbe Agua**: Los ataques de Agua no le hacen nada y lo curan un 25%.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 8 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 15 | Rayo Burbuja | Agua | Especial | Disparo | 30 | 3.0 s |
| 22 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 29 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 36 | Ataque Ala | Volador | Físico | Embestida | 60 | 1.9 s |
| 43 | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| 50 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 227 Skarmory

Acero/Volador · Pokémon Coraza Ave

**Habilidad — Vista Lince**: No lo desorientan y sus disparos pegan +10%.

**Habilidad — Robustez**: Con la vida llena, un golpe que lo debilitaría lo deja con 1 de vida.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 10 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 13 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 16 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 26 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 29 | Aire Afilado | Volador | Especial | Área | 60 | 3.7 s |
| 32 | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| 42 | Púas | Tierra | Estado | Mejora propia | — | 10.0 s |
| 45 | Eco Metálico | Acero | Estado | Área | — | 6.0 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 228 Houndour

Siniestro/Fuego · Pokémon Siniestro

**Habilidad — Madrugar**: Dormido, se despierta solo al segundo.

**Habilidad — Absorbe Fuego**: Los ataques de Fuego no le hacen nada y le suben un 50% los suyos de Fuego por 8 s.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 7 | Aullido | Normal | Estado | Mejora propia | — | 10.0 s |
| 13 | Polución | Veneno | Especial | Disparo | 30 | 1.3 s |
| 19 | Rugido | Normal | Estado | Área | — | 6.0 s |
| 25 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 31 | Rastreo | Normal | Estado | Área | — | 6.0 s |
| 37 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 43 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| 49 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 229 Houndoom

Siniestro/Fuego · Pokémon Siniestro

**Habilidad — Madrugar**: Dormido, se despierta solo al segundo.

**Habilidad — Absorbe Fuego**: Los ataques de Fuego no le hacen nada y le suben un 50% los suyos de Fuego por 8 s.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 1 | Aullido | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 13 | Polución | Veneno | Especial | Disparo | 30 | 1.3 s |
| 19 | Rugido | Normal | Estado | Área | — | 6.0 s |
| 27 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 35 | Rastreo | Normal | Estado | Área | — | 6.0 s |
| 43 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 51 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| 59 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 230 Kingdra

Agua/Dragón · Pokémon Dragón

**Habilidad — Nado Rápido**: Mojado (agua, suelo mojado o empapado) se mueve un 40% más rápido.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Pantalla de Humo | Normal | Estado | Zona | — | 9.0 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 29 | Ciclón | Dragón | Especial | Área | 40 | 6.0 s |
| 40 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 51 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |
| 62 | Danza Dragón | Dragón | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 231 Phanpy

Tierra · Pokémon Narizotas

**Habilidad — Recogida**: Si gana una pelea, a veces encuentra una Poción (tu equipo).


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Rastreo | Normal | Estado | Área | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 9 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 17 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |
| 25 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 33 | Rodar | Roca | Físico | Embestida | 30 | 2.0 s |
| 41 | Aguante | Normal | Estado | Defensa | — | 8.0 s |
| 49 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 232 Donphan

Tierra · Pokémon Coraza

**Habilidad — Robustez**: Con la vida llena, un golpe que lo debilitaría lo deja con 1 de vida.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Cornada | Normal | Físico | Embestida | 65 | 5.0 s |
| 1 | Rastreo | Normal | Estado | Área | — | 6.0 s |
| 9 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 17 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |
| 25 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 33 | Rodar | Roca | Físico | Embestida | 30 | 2.0 s |
| 41 | Giro Rápido | Normal | Físico | Embestida | 50 | 7.0 s |
| 49 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 233 Porygon2

Normal · Pokémon Virtual

**Habilidad — Calco**: Copia la habilidad del primer rival que encara.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Conversión | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Conversión 2 | Normal | Estado | Área | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 9 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 12 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 20 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |
| 24 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 32 | Fijar Blanco | Normal | Estado | Disparo | — | 8.0 s |
| 36 | Triataque | Normal | Especial | Disparo | 80 | 2.1 s |
| 44 | Reciclaje | Normal | Estado | Mejora propia | — | 10.0 s |
| 48 | Electrocañón | Eléctrico | Especial | Disparo | 120 | 2.9 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 234 Stantler

Normal · Pokémon Gran Cuerno

**Habilidad — Intimidación**: Al encarar a un rival lo deja Intimidado (pega menos).


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 7 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 11 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 17 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 21 | Pisotón | Normal | Físico | Golpe | 65 | 1.2 s |
| 27 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 31 | Imitación | Psíquico | Estado | Área | — | 6.0 s |
| 37 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 41 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 47 | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (27)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 235 Smeargle

Normal · Pokémon Pintor

**Habilidad — Ritmo Propio**: No lo desorientan.


**Ataques que puede aprender (1)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Esquema | Normal | Estado | Área | — | 6.0 s |

### 236 Tyrogue

Lucha · Pokémon Peleón

**Habilidad — Agallas**: Con un problema de estado sus ataques físicos pegan ×1,5.


**Ataques que puede aprender (1)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 237 Hitmontop

Lucha · Pokémon Boca Abajo

**Habilidad — Intimidación**: Al encarar a un rival lo deja Intimidado (pega menos).


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Desquite | Lucha | Físico | Golpe | 60 | 1.4 s |
| 1 | Patada Giro | Lucha | Físico | Golpe | 60 | 1.4 s |
| 7 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 13 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 19 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 20 | Triple Patada | Lucha | Físico | Golpe | 10 | 0.7 s |
| 25 | Giro Rápido | Normal | Físico | Embestida | 50 | 7.0 s |
| 31 | Contraataque | Lucha | Físico | Golpe | 60 | 1.4 s |
| 37 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 43 | Detección | Lucha | Estado | Defensa | — | 8.0 s |
| 49 | Esfuerzo | Normal | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 238 Smoochum

Hielo/Psíquico · Pokémon Beso

**Habilidad — Despiste**: No lo intimidan ni lo desorientan.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Lengüetazo | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 9 | Beso Dulce | Hada | Estado | Disparo | — | 6.0 s |
| 13 | Nieve Polvo | Hielo | Especial | Área | 40 | 3.2 s |
| 21 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 25 | Canto | Normal | Estado | Zona | — | 12.0 s |
| 33 | Mal de Ojo | Normal | Estado | Área | — | 6.0 s |
| 37 | Llanto Falso | Siniestro | Estado | Área | — | 6.0 s |
| 45 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 49 | Canto Mortal | Normal | Estado | Mejora propia | — | 10.0 s |
| 57 | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 239 Elekid

Eléctrico · Pokémon Eléctrico

**Habilidad — Electricidad Estática**: Al que le pega cuerpo a cuerpo lo paraliza (30%).


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 9 | Puño Trueno | Eléctrico | Físico | Golpe | 75 | 1.4 s |
| 17 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 25 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 33 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 41 | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| 49 | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 240 Magby

Fuego · Pokémon Ascuas

**Habilidad — Cuerpo Llama**: Al que le pega cuerpo a cuerpo lo quema (30%).


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 7 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 13 | Polución | Veneno | Especial | Disparo | 30 | 1.3 s |
| 19 | Puño Fuego | Fuego | Físico | Golpe | 75 | 1.6 s |
| 25 | Pantalla de Humo | Normal | Estado | Zona | — | 9.0 s |
| 31 | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| 37 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| 43 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 49 | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 241 Miltank

Normal · Pokémon Lechera

**Habilidad — Sebo**: El fuego y el hielo le hacen la mitad.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 4 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 8 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 13 | Pisotón | Normal | Físico | Golpe | 65 | 1.2 s |
| 19 | Batido | Normal | Estado | Mejora propia | — | 10.0 s |
| 26 | Venganza | Normal | Físico | Embestida | 60 | 1.9 s |
| 34 | Rodar | Roca | Físico | Embestida | 30 | 2.0 s |
| 43 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 53 | Cascabel Cura | Normal | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (30)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 242 Blissey

Normal · Pokémon Felicidad

**Habilidad — Cura Natural**: Cada 8 s se cura los problemas de estado.

**Habilidad — Dicha**: Sus ataques con estado lo ponen el doble de seguido.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 4 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 7 | Alivio | Normal | Estado | Mejora propia | — | 10.0 s |
| 10 | Ovocuración | Normal | Estado | Mejora propia | — | 10.0 s |
| 13 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 18 | Reducción | Normal | Estado | Mejora propia | — | 9.0 s |
| 23 | Canto | Normal | Estado | Zona | — | 12.0 s |
| 28 | Bomba Huevo | Normal | Físico | Embestida | 100 | 2.5 s |
| 33 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 40 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 47 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (39)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 243 Raikou

Eléctrico · Pokémon Trueno

**Habilidad — Presión**: Cada golpe suyo le suma 0,3 s a las recargas del rival.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 11 | Impactrueno | Eléctrico | Especial | Disparo | 40 | 1.5 s |
| 21 | Rugido | Normal | Estado | Área | — | 6.0 s |
| 31 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 41 | Chispa | Eléctrico | Físico | Embestida | 65 | 6.0 s |
| 51 | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 61 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 71 | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| 81 | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 244 Entei

Fuego · Pokémon Volcán

**Habilidad — Presión**: Cada golpe suyo le suma 0,3 s a las recargas del rival.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 11 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 21 | Rugido | Normal | Estado | Área | — | 6.0 s |
| 31 | Giro Fuego | Fuego | Especial | Área | 35 | 3.0 s |
| 41 | Pisotón | Normal | Físico | Golpe | 65 | 1.2 s |
| 51 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| 61 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 71 | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| 81 | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 245 Suicune

Agua · Pokémon Aurora

**Habilidad — Presión**: Cada golpe suyo le suma 0,3 s a las recargas del rival.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 11 | Rayo Burbuja | Agua | Especial | Disparo | 30 | 3.0 s |
| 21 | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| 31 | Tornado | Volador | Especial | Disparo | 40 | 1.5 s |
| 41 | Rayo Aurora | Hielo | Especial | Disparo | 65 | 1.9 s |
| 51 | Neblina | Hielo | Estado | Mejora propia | — | 10.0 s |
| 61 | Manto Espejo | Psíquico | Especial | Disparo | 60 | 1.8 s |
| 71 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |
| 81 | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (27)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 246 Larvitar

Roca/Tierra · Pokémon Piel Roca

**Habilidad — Agallas**: Con un problema de estado sus ataques físicos pegan ×1,5.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 8 | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| 15 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 22 | Avalancha | Roca | Físico | Área | 75 | 4.2 s |
| 29 | Saña | Normal | Físico | Embestida | 120 | 2.7 s |
| 36 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 43 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 50 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 57 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 247 Pupitar

Roca/Tierra · Pokémon Caparazón

**Habilidad — Mudar**: Cada 4 s se saca de encima los problemas de estado.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| 1 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 22 | Avalancha | Roca | Físico | Área | 75 | 4.2 s |
| 29 | Saña | Normal | Físico | Embestida | 120 | 2.7 s |
| 38 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 47 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 56 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 65 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 248 Tyranitar

Roca/Siniestro · Pokémon Coraza

**Habilidad — Chorro Arena**: Levanta arena: los rivales cerca suyo quedan desorientados.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| 1 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 22 | Avalancha | Roca | Físico | Área | 75 | 4.2 s |
| 29 | Saña | Normal | Físico | Embestida | 120 | 2.7 s |
| 38 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 47 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 61 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 75 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

**Por MT/MO (37)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 249 Lugia

Psíquico/Volador · Pokémon Buceo

**Habilidad — Presión**: Cada golpe suyo le suma 0,3 s a las recargas del rival.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Remolino | Volador | Estado | Zona | — | 9.0 s |
| 11 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 22 | Tornado | Volador | Especial | Disparo | 40 | 1.5 s |
| 33 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |
| 44 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |
| 55 | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| 66 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 77 | Aerochorro | Volador | Especial | Disparo | 100 | 2.5 s |
| 88 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 99 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |

**Por MT/MO (39)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 250 Ho-Oh

Fuego/Volador · Pokémon Arcoíris

**Habilidad — Presión**: Cada golpe suyo le suma 0,3 s a las recargas del rival.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Remolino | Volador | Estado | Zona | — | 9.0 s |
| 11 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 22 | Tornado | Volador | Especial | Disparo | 40 | 1.5 s |
| 33 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |
| 44 | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| 55 | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| 66 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 77 | Fuego Sagrado | Fuego | Físico | Embestida | 100 | 2.5 s |
| 88 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 99 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |

**Por MT/MO (35)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 251 Celebi

Psíquico/Planta · Pokémon Viajetiempo

**Habilidad — Cura Natural**: Cada 8 s se cura los problemas de estado.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 1 | Cascabel Cura | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Drenadoras | Planta | Estado | Área | — | 6.0 s |
| 1 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |
| 10 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 20 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 30 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |
| 40 | Relevo | Normal | Estado | Mejora propia | — | 10.0 s |
| 50 | Canto Mortal | Normal | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (27)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 252 Treecko

Planta · Pokémon Geco Bosque

**Habilidad — Espesura**: Con menos de 1/3 de vida sus ataques de tipo Planta pegan ×1,5.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 6 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 11 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 16 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 21 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 26 | Megaagotar | Planta | Especial | Disparo | 40 | 1.5 s |
| 31 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 36 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 41 | Detección | Lucha | Estado | Defensa | — | 8.0 s |
| 46 | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 253 Grovyle

Planta · Pokémon Geco Bosque

**Habilidad — Espesura**: Con menos de 1/3 de vida sus ataques de tipo Planta pegan ×1,5.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 16 | Corte Furia | Bicho | Físico | Golpe | 40 | 1.1 s |
| 17 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 23 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 29 | Hoja Aguda | Planta | Físico | Embestida | 90 | 2.3 s |
| 35 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 41 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 47 | Detección | Lucha | Estado | Defensa | — | 8.0 s |
| 53 | Falso Tortazo | Normal | Físico | Golpe | 40 | 1.1 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 254 Sceptile

Planta · Pokémon Monte

**Habilidad — Espesura**: Con menos de 1/3 de vida sus ataques de tipo Planta pegan ×1,5.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 16 | Corte Furia | Bicho | Físico | Golpe | 40 | 1.1 s |
| 17 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 23 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 29 | Hoja Aguda | Planta | Físico | Embestida | 90 | 2.3 s |
| 35 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 43 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 51 | Detección | Lucha | Estado | Defensa | — | 8.0 s |
| 59 | Falso Tortazo | Normal | Físico | Golpe | 40 | 1.1 s |

**Por MT/MO (29)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 255 Torchic

Fuego · Pokémon Polluelo

**Habilidad — Mar Llamas**: Con menos de 1/3 de vida sus ataques de tipo Fuego pegan ×1,5.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 7 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 10 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 16 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 19 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 25 | Giro Fuego | Fuego | Especial | Área | 35 | 3.0 s |
| 28 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 34 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 37 | Espejo | Volador | Estado | Área | — | 6.0 s |
| 43 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 256 Combusken

Fuego/Lucha · Pokémon Ave Corral

**Habilidad — Mar Llamas**: Con menos de 1/3 de vida sus ataques de tipo Fuego pegan ×1,5.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 1 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 16 | Doble Patada | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| 17 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 21 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 28 | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| 32 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 39 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 43 | Espejo | Volador | Estado | Área | — | 6.0 s |
| 50 | Gancho Alto | Lucha | Físico | Embestida | 85 | 2.2 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 257 Blaziken

Fuego/Lucha · Pokémon Llameante

**Habilidad — Mar Llamas**: Con menos de 1/3 de vida sus ataques de tipo Fuego pegan ×1,5.


**Ataques que puede aprender (14)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 1 | Puño Fuego | Fuego | Físico | Golpe | 75 | 1.6 s |
| 1 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 16 | Doble Patada | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| 17 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 21 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 28 | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| 32 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 36 | Patada Ígnea | Fuego | Físico | Embestida | 85 | 2.2 s |
| 42 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 49 | Espejo | Volador | Estado | Área | — | 6.0 s |
| 59 | Gancho Alto | Lucha | Físico | Embestida | 85 | 2.2 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 258 Mudkip

Agua · Pokémon Pez Lodo

**Habilidad — Torrente**: Con menos de 1/3 de vida sus ataques de tipo Agua pegan ×1,5.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 6 | Bofetón Lodo | Tierra | Especial | Disparo | 20 | 1.1 s |
| 10 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 15 | Venganza | Normal | Físico | Embestida | 60 | 1.9 s |
| 19 | Profecía | Normal | Estado | Área | — | 6.0 s |
| 24 | Chapoteo Lodo | Tierra | Estado | Mejora propia | — | 10.0 s |
| 28 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 33 | Torbellino | Agua | Especial | Disparo | 35 | 1.4 s |
| 37 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 42 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |
| 46 | Esfuerzo | Normal | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 259 Marshtomp

Agua/Tierra · Pokémon Pez Lodo

**Habilidad — Torrente**: Con menos de 1/3 de vida sus ataques de tipo Agua pegan ×1,5.


**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Bofetón Lodo | Tierra | Especial | Disparo | 20 | 1.1 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 15 | Venganza | Normal | Físico | Embestida | 60 | 1.9 s |
| 16 | Disparo Lodo | Tierra | Especial | Disparo | 55 | 1.7 s |
| 20 | Profecía | Normal | Estado | Área | — | 6.0 s |
| 25 | Chapoteo Lodo | Tierra | Estado | Mejora propia | — | 10.0 s |
| 31 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 37 | Agua Lodosa | Agua | Especial | Área | 90 | 4.5 s |
| 42 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 46 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 53 | Esfuerzo | Normal | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 260 Swampert

Agua/Tierra · Pokémon Pez Lodo

**Habilidad — Torrente**: Con menos de 1/3 de vida sus ataques de tipo Agua pegan ×1,5.


**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Bofetón Lodo | Tierra | Especial | Disparo | 20 | 1.1 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 15 | Venganza | Normal | Físico | Embestida | 60 | 1.9 s |
| 16 | Disparo Lodo | Tierra | Especial | Disparo | 55 | 1.7 s |
| 20 | Profecía | Normal | Estado | Área | — | 6.0 s |
| 25 | Chapoteo Lodo | Tierra | Estado | Mejora propia | — | 10.0 s |
| 31 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 39 | Agua Lodosa | Agua | Especial | Área | 90 | 4.5 s |
| 46 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 52 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 61 | Esfuerzo | Normal | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (28)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 261 Poochyena

Siniestro · Pokémon Mordisco

**Habilidad — Fuga**: Esquiva mucho más seguido (recarga del esquive −40%).


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 5 | Aullido | Normal | Estado | Mejora propia | — | 10.0 s |
| 9 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 13 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 17 | Rastreo | Normal | Estado | Área | — | 6.0 s |
| 21 | Rugido | Normal | Estado | Área | — | 6.0 s |
| 25 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 29 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 33 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 37 | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| 41 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 45 | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 262 Mightyena

Siniestro · Pokémon Mordisco

**Habilidad — Intimidación**: Al encarar a un rival lo deja Intimidado (pega menos).


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 1 | Aullido | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 17 | Rastreo | Normal | Estado | Área | — | 6.0 s |
| 22 | Rugido | Normal | Estado | Área | — | 6.0 s |
| 27 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 32 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 37 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 42 | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| 47 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 52 | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 263 Zigzagoon

Normal · Pokémon Mapachito

**Habilidad — Recogida**: Si gana una pelea, a veces encuentra una Poción (tu equipo).


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 5 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 9 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 13 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 17 | Rastreo | Normal | Estado | Área | — | 6.0 s |
| 21 | Chapoteo Lodo | Tierra | Estado | Mejora propia | — | 10.0 s |
| 25 | Pin Misil | Bicho | Físico | Disparo | 25 | 4.5 s |
| 29 | Antojo | Normal | Físico | Golpe | 60 | 1.4 s |
| 33 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |
| 37 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 41 | Tambor | Normal | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 264 Linoone

Normal · Pokémon Lanzado

**Habilidad — Recogida**: Si gana una pelea, a veces encuentra una Poción (tu equipo).


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 13 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 17 | Rastreo | Normal | Estado | Área | — | 6.0 s |
| 23 | Chapoteo Lodo | Tierra | Estado | Mejora propia | — | 10.0 s |
| 29 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 35 | Antojo | Normal | Físico | Golpe | 60 | 1.4 s |
| 41 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 47 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 53 | Tambor | Normal | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (28)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 265 Wurmple

Bicho · Pokémon Gusano

**Habilidad — Polvo Escudo**: La mitad de las veces no le entra un problema de estado.


**Ataques que puede aprender (3)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Disparo Demora | Bicho | Estado | Disparo | — | 2.5 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 5 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |

### 266 Silcoon

Bicho · Pokémon Capullo

**Habilidad — Mudar**: Cada 4 s se saca de encima los problemas de estado.


**Ataques que puede aprender (1)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |

### 267 Beautifly

Bicho/Volador · Pokémon Mariposa

**Habilidad — Enjambre**: Con menos de 1/3 de vida sus ataques de tipo Bicho pegan ×1,5.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 13 | Tornado | Volador | Especial | Disparo | 40 | 1.5 s |
| 17 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 20 | Sol Matinal | Normal | Estado | Mejora propia | — | 10.0 s |
| 24 | Megaagotar | Planta | Especial | Disparo | 40 | 1.5 s |
| 27 | Remolino | Volador | Estado | Zona | — | 9.0 s |
| 31 | Atracción | Normal | Estado | Área | — | 6.0 s |
| 34 | Viento Plata | Bicho | Especial | Disparo | 60 | 1.8 s |
| 38 | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 268 Cascoon

Bicho · Pokémon Capullo

**Habilidad — Mudar**: Cada 4 s se saca de encima los problemas de estado.


**Ataques que puede aprender (1)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |

### 269 Dustox

Bicho/Veneno · Pokémon Polilla Ven.

**Habilidad — Polvo Escudo**: La mitad de las veces no le entra un problema de estado.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 13 | Tornado | Volador | Especial | Disparo | 40 | 1.5 s |
| 17 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 20 | Luz Lunar | Hada | Estado | Mejora propia | — | 10.0 s |
| 24 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 27 | Remolino | Volador | Estado | Zona | — | 9.0 s |
| 31 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 34 | Viento Plata | Bicho | Especial | Disparo | 60 | 1.8 s |
| 38 | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 270 Lotad

Agua/Planta · Pokémon Lenteja Agua

**Habilidad — Nado Rápido**: Mojado (agua, suelo mojado o empapado) se mueve un 40% más rápido.

**Habilidad — Cura Lluvia**: Mojado se cura un 3% por segundo.


**Ataques que puede aprender (7)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 3 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 7 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 13 | Adaptación | Normal | Estado | Área | — | 6.0 s |
| 21 | Neblina | Hielo | Estado | Mejora propia | — | 10.0 s |
| 31 | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| 43 | Megaagotar | Planta | Especial | Disparo | 40 | 1.5 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 271 Lombre

Agua/Planta · Pokémon Alegre

**Habilidad — Nado Rápido**: Mojado (agua, suelo mojado o empapado) se mueve un 40% más rápido.

**Habilidad — Cura Lluvia**: Mojado se cura un 3% por segundo.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 3 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 7 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 13 | Adaptación | Normal | Estado | Área | — | 6.0 s |
| 19 | Sorpresa | Normal | Físico | Embestida | 40 | 1.6 s |
| 25 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 31 | Hidrochorro | Agua | Especial | Área | 15 | 6.0 s |
| 37 | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| 43 | Alboroto | Normal | Especial | Disparo | 90 | 2.4 s |
| 49 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (27)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 272 Ludicolo

Agua/Planta · Pokémon Optimista

**Habilidad — Nado Rápido**: Mojado (agua, suelo mojado o empapado) se mueve un 40% más rápido.

**Habilidad — Cura Lluvia**: Mojado se cura un 3% por segundo.


**Ataques que puede aprender (4)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 1 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Adaptación | Normal | Estado | Área | — | 6.0 s |

**Por MT/MO (29)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 273 Seedot

Planta · Pokémon Bellota

**Habilidad — Clorofila**: De día se mueve un 30% más rápido.

**Habilidad — Madrugar**: Dormido, se despierta solo al segundo.


**Ataques que puede aprender (7)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Venganza | Normal | Físico | Embestida | 60 | 1.9 s |
| 3 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 7 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 13 | Adaptación | Normal | Estado | Área | — | 6.0 s |
| 21 | Fotosíntesis | Planta | Estado | Mejora propia | — | 10.0 s |
| 31 | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| 43 | Explosión | Normal | Físico | Área | 250 | 9.2 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 274 Nuzleaf

Planta/Siniestro · Pokémon Astuto

**Habilidad — Clorofila**: De día se mueve un 30% más rápido.

**Habilidad — Madrugar**: Dormido, se despierta solo al segundo.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 3 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 7 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 13 | Adaptación | Normal | Estado | Área | — | 6.0 s |
| 19 | Sorpresa | Normal | Físico | Embestida | 40 | 1.6 s |
| 25 | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| 31 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 37 | Viento Cortante | Normal | Especial | Área | 80 | 4.3 s |
| 43 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 49 | Paranormal | Psíquico | Especial | Disparo | 80 | 2.1 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 275 Shiftry

Planta/Siniestro · Pokémon Malvado

**Habilidad — Clorofila**: De día se mueve un 30% más rápido.


**Ataques que puede aprender (4)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 1 | Adaptación | Normal | Estado | Área | — | 6.0 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 276 Taillow

Normal/Volador · Pokémon Pequebuche

**Habilidad — Agallas**: Con un problema de estado sus ataques físicos pegan ×1,5.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 4 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 8 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 13 | Ataque Ala | Volador | Físico | Embestida | 60 | 1.9 s |
| 19 | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| 26 | Esfuerzo | Normal | Físico | Golpe | 60 | 1.4 s |
| 34 | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| 43 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (16)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 277 Swellow

Normal/Volador · Pokémon Buche

**Habilidad — Agallas**: Con un problema de estado sus ataques físicos pegan ×1,5.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 13 | Ataque Ala | Volador | Físico | Embestida | 60 | 1.9 s |
| 19 | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| 28 | Esfuerzo | Normal | Físico | Golpe | 60 | 1.4 s |
| 38 | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| 49 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (17)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 278 Wingull

Agua/Volador · Pokémon Gaviota

**Habilidad — Vista Lince**: No lo desorientan y sus disparos pegan +10%.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 7 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 13 | Ataque Ala | Volador | Físico | Embestida | 60 | 1.9 s |
| 21 | Neblina | Hielo | Estado | Mejora propia | — | 10.0 s |
| 31 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 43 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 55 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 279 Pelipper

Agua/Volador · Pokémon Ave Agua

**Habilidad — Vista Lince**: No lo desorientan y sus disparos pegan +10%.

**Habilidad — Llovizna**: Llueve a su alrededor: los rivales cerca quedan empapados.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 1 | Hidrochorro | Agua | Especial | Área | 15 | 6.0 s |
| 1 | Ataque Ala | Volador | Físico | Embestida | 60 | 1.9 s |
| 7 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 21 | Neblina | Hielo | Estado | Mejora propia | — | 10.0 s |
| 25 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 33 | Reserva | Normal | Estado | Mejora propia | — | 10.0 s |
| 33 | Tragar | Normal | Estado | Mejora propia | — | 10.0 s |
| 47 | Escupir | Normal | Especial | Disparo | 60 | 1.8 s |
| 61 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 280 Ralts

Psíquico/Hada · Pokémon Sensible

**Habilidad — Sincronía**: Los problemas de estado que le ponen se los devuelve al que se los puso.

**Habilidad — Calco**: Copia la habilidad del primer rival que encara.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 6 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 11 | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| 16 | Teletransporte | Psíquico | Estado | Embestida | — | 3.0 s |
| 21 | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 26 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 31 | Sellar | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 36 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |
| 41 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 46 | Comesueños | Psíquico | Especial | Disparo | 100 | 7.0 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 281 Kirlia

Psíquico/Hada · Pokémon Sensorio

**Habilidad — Sincronía**: Los problemas de estado que le ponen se los devuelve al que se los puso.

**Habilidad — Calco**: Copia la habilidad del primer rival que encara.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 1 | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Hoja Mágica | Planta | Especial | Disparo | 60 | 1.8 s |
| 1 | Teletransporte | Psíquico | Estado | Embestida | — | 3.0 s |
| 21 | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 26 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 33 | Sellar | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 40 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |
| 47 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 54 | Comesueños | Psíquico | Especial | Disparo | 100 | 7.0 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 282 Gardevoir

Psíquico/Hada · Pokémon Envolvente

**Habilidad — Sincronía**: Los problemas de estado que le ponen se los devuelve al que se los puso.

**Habilidad — Calco**: Copia la habilidad del primer rival que encara.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 1 | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Teletransporte | Psíquico | Estado | Embestida | — | 3.0 s |
| 21 | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 26 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 33 | Sellar | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 42 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |
| 51 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 60 | Comesueños | Psíquico | Especial | Disparo | 100 | 7.0 s |

**Por MT/MO (27)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 283 Surskit

Bicho/Agua · Pokémon Zapatero

**Habilidad — Nado Rápido**: Mojado (agua, suelo mojado o empapado) se mueve un 40% más rápido.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 7 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 13 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 19 | Hidrochorro | Agua | Especial | Área | 15 | 6.0 s |
| 25 | Rayo Burbuja | Agua | Especial | Disparo | 30 | 3.0 s |
| 31 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 37 | Niebla | Hielo | Estado | Mejora propia | — | 10.0 s |
| 37 | Neblina | Hielo | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 284 Masquerain

Bicho/Volador · Pokémon Globocular

**Habilidad — Intimidación**: Al encarar a un rival lo deja Intimidado (pega menos).


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 1 | Hidrochorro | Agua | Especial | Área | 15 | 6.0 s |
| 26 | Tornado | Volador | Especial | Disparo | 40 | 1.5 s |
| 33 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 40 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 47 | Viento Plata | Bicho | Especial | Disparo | 60 | 1.8 s |
| 53 | Remolino | Volador | Estado | Zona | — | 9.0 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 285 Shroomish

Planta · Pokémon Hongo

**Habilidad — Efecto Espora**: Al que le pega cuerpo a cuerpo le pone veneno, parálisis o sueño (30%).


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 4 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 7 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 10 | Drenadoras | Planta | Estado | Área | — | 6.0 s |
| 16 | Megaagotar | Planta | Especial | Disparo | 40 | 1.5 s |
| 22 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 28 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 36 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 45 | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| 54 | Espora | Planta | Estado | Zona | — | 11.0 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 286 Breloom

Planta/Lucha · Pokémon Hongo

**Habilidad — Efecto Espora**: Al que le pega cuerpo a cuerpo le pone veneno, parálisis o sueño (30%).


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 1 | Drenadoras | Planta | Estado | Área | — | 6.0 s |
| 1 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 16 | Megaagotar | Planta | Especial | Disparo | 40 | 1.5 s |
| 22 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 23 | Ultrapuño | Lucha | Físico | Embestida | 40 | 1.6 s |
| 28 | Contraataque | Lucha | Físico | Golpe | 60 | 1.4 s |
| 36 | Gancho Alto | Lucha | Físico | Embestida | 85 | 2.2 s |
| 45 | Telépata | Normal | Estado | Área | — | 6.0 s |
| 54 | Puño Dinámico | Lucha | Físico | Embestida | 100 | 2.5 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 287 Slakoth

Normal · Pokémon Gandul

**Habilidad — Ausente**: Por ahora sin efecto (en los juegos ataca un turno sí y otro no).


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Bostezo | Normal | Estado | Disparo | — | 9.0 s |
| 7 | Otra Vez | Normal | Estado | Área | — | 6.0 s |
| 13 | Relajo | Normal | Estado | Mejora propia | — | 10.0 s |
| 19 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 25 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 31 | Antojo | Normal | Físico | Golpe | 60 | 1.4 s |
| 37 | Contraataque | Lucha | Físico | Golpe | 60 | 1.4 s |
| 43 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |

**Por MT/MO (29)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 288 Vigoroth

Normal · Pokémon Mono Feroz

**Habilidad — Espíritu Vital**: No lo duermen.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Otra Vez | Normal | Estado | Área | — | 6.0 s |
| 1 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Alboroto | Normal | Especial | Disparo | 90 | 2.4 s |
| 19 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 25 | Aguante | Normal | Estado | Defensa | — | 8.0 s |
| 31 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 37 | Contraataque | Lucha | Físico | Golpe | 60 | 1.4 s |
| 43 | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| 49 | Inversión | Lucha | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (32)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 289 Slaking

Normal · Pokémon Holgazán

**Habilidad — Ausente**: Por ahora sin efecto (en los juegos ataca un turno sí y otro no).


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Otra Vez | Normal | Estado | Área | — | 6.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Relajo | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Bostezo | Normal | Estado | Disparo | — | 9.0 s |
| 19 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 25 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 31 | Antojo | Normal | Físico | Golpe | 60 | 1.4 s |
| 36 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 37 | Contraataque | Lucha | Físico | Golpe | 60 | 1.4 s |
| 43 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |

**Por MT/MO (33)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 290 Nincada

Bicho/Tierra · Pokémon Aprendiz

**Habilidad — Ojo Compuesto**: Sus ataques con estado lo ponen un 30% más seguido.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 5 | Chupavidas | Bicho | Físico | Golpe | 80 | 3.0 s |
| 9 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 14 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 19 | Telépata | Normal | Estado | Área | — | 6.0 s |
| 25 | Falso Tortazo | Normal | Físico | Golpe | 40 | 1.1 s |
| 31 | Bofetón Lodo | Tierra | Especial | Disparo | 20 | 1.1 s |
| 38 | Garra Metal | Acero | Físico | Golpe | 50 | 1.3 s |
| 45 | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 291 Ninjask

Bicho/Volador · Pokémon Ninja

**Habilidad — Impulso**: Siempre un 15% más rápido.


**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 1 | Chupavidas | Bicho | Físico | Golpe | 80 | 3.0 s |
| 1 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 14 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 19 | Telépata | Normal | Estado | Área | — | 6.0 s |
| 20 | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| 20 | Corte Furia | Bicho | Físico | Golpe | 40 | 1.1 s |
| 20 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 25 | Danza Espada | Normal | Estado | Mejora propia | — | 10.0 s |
| 31 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 38 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 45 | Relevo | Normal | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 292 Shedinja

Bicho/Fantasma · Pokémon Muda

**Habilidad — Superguarda**: Por ahora sin efecto (en los juegos solo le hacen daño los súper eficaces).


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 5 | Chupavidas | Bicho | Físico | Golpe | 80 | 3.0 s |
| 9 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 14 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 19 | Telépata | Normal | Estado | Área | — | 6.0 s |
| 25 | Rencor | Fantasma | Estado | Área | — | 6.0 s |
| 31 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 38 | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| 45 | Rabia | Fantasma | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 293 Whismur

Normal · Pokémon Susurro

**Habilidad — Insonorizar**: No le afectan los sonidos: no lo duermen con Canto ni lo desorientan con Supersónico.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 5 | Alboroto | Normal | Especial | Disparo | 90 | 2.4 s |
| 11 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 15 | Aullido | Normal | Estado | Mejora propia | — | 10.0 s |
| 21 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 25 | Pisotón | Normal | Físico | Golpe | 65 | 1.2 s |
| 31 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 35 | Rugido | Normal | Estado | Área | — | 6.0 s |
| 41 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 41 | Sonámbulo | Normal | Estado | Mejora propia | — | 10.0 s |
| 45 | Vozarrón | Normal | Especial | Área | 90 | 4.5 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 294 Loudred

Normal · Pokémon Chillón

**Habilidad — Insonorizar**: No le afectan los sonidos: no lo duermen con Canto ni lo desorientan con Supersónico.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 1 | Aullido | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Alboroto | Normal | Especial | Disparo | 90 | 2.4 s |
| 23 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 29 | Pisotón | Normal | Físico | Golpe | 65 | 1.2 s |
| 37 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 43 | Rugido | Normal | Estado | Área | — | 6.0 s |
| 51 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 51 | Sonámbulo | Normal | Estado | Mejora propia | — | 10.0 s |
| 57 | Vozarrón | Normal | Especial | Área | 90 | 4.5 s |

**Por MT/MO (28)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 295 Exploud

Normal · Pokémon Escandaloso

**Habilidad — Insonorizar**: No le afectan los sonidos: no lo duermen con Canto ni lo desorientan con Supersónico.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 1 | Aullido | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Alboroto | Normal | Especial | Disparo | 90 | 2.4 s |
| 23 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 29 | Pisotón | Normal | Físico | Golpe | 65 | 1.2 s |
| 37 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 40 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| 45 | Rugido | Normal | Estado | Área | — | 6.0 s |
| 55 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 55 | Sonámbulo | Normal | Estado | Mejora propia | — | 10.0 s |
| 63 | Vozarrón | Normal | Especial | Área | 90 | 4.5 s |

**Por MT/MO (29)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 296 Makuhita

Lucha · Pokémon Valiente

**Habilidad — Sebo**: El fuego y el hielo le hacen la mitad.

**Habilidad — Agallas**: Con un problema de estado sus ataques físicos pegan ×1,5.


**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 4 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 10 | Empujón | Lucha | Físico | Golpe | 15 | 0.8 s |
| 13 | Llave Vital | Lucha | Físico | Golpe | 70 | 1.5 s |
| 19 | Sorpresa | Normal | Físico | Embestida | 40 | 1.6 s |
| 22 | Remolino | Volador | Estado | Zona | — | 9.0 s |
| 28 | Desarme | Siniestro | Físico | Golpe | 65 | 1.4 s |
| 31 | Estímulo | Normal | Físico | Golpe | 70 | 1.5 s |
| 37 | Tambor | Normal | Estado | Mejora propia | — | 10.0 s |
| 40 | Aguante | Normal | Estado | Defensa | — | 8.0 s |
| 46 | Sísmico | Lucha | Físico | Embestida+combo | 70 | 7.0 s |
| 49 | Inversión | Lucha | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 297 Hariyama

Lucha · Pokémon Empuje

**Habilidad — Sebo**: El fuego y el hielo le hacen la mitad.

**Habilidad — Agallas**: Con un problema de estado sus ataques físicos pegan ×1,5.


**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Empujón | Lucha | Físico | Golpe | 15 | 0.8 s |
| 1 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 1 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 13 | Llave Vital | Lucha | Físico | Golpe | 70 | 1.5 s |
| 19 | Sorpresa | Normal | Físico | Embestida | 40 | 1.6 s |
| 22 | Remolino | Volador | Estado | Zona | — | 9.0 s |
| 29 | Desarme | Siniestro | Físico | Golpe | 65 | 1.4 s |
| 33 | Estímulo | Normal | Físico | Golpe | 70 | 1.5 s |
| 40 | Tambor | Normal | Estado | Mejora propia | — | 10.0 s |
| 44 | Aguante | Normal | Estado | Defensa | — | 8.0 s |
| 51 | Sísmico | Lucha | Físico | Embestida+combo | 70 | 7.0 s |
| 55 | Inversión | Lucha | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 298 Azurill

Normal/Hada · Pokémon A Topos

**Habilidad — Sebo**: El fuego y el hielo le hacen la mitad.

**Habilidad — Potencia**: Sus golpes cuerpo a cuerpo pegan +50%.


**Ataques que puede aprender (6)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Salpicadura | Normal | Estado | Embestida | — | 1.5 s |
| 3 | Encanto | Hada | Estado | Área | — | 6.0 s |
| 6 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 10 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 15 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 21 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 299 Nosepass

Roca · Pokémon Brújula

**Habilidad — Robustez**: Con la vida llena, un golpe que lo debilitaría lo deja con 1 de vida.

**Habilidad — Imán**: Sus ataques pegan +30% a los de tipo Acero.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 7 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 13 | Lanzarrocas | Roca | Físico | Disparo | 50 | 1.6 s |
| 16 | Bloqueo | Normal | Estado | Área | — | 6.0 s |
| 22 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 28 | Avalancha | Roca | Físico | Área | 75 | 4.2 s |
| 31 | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| 37 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 43 | Electrocañón | Eléctrico | Especial | Disparo | 120 | 2.9 s |
| 46 | Fijar Blanco | Normal | Estado | Disparo | — | 8.0 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 300 Skitty

Normal · Pokémon Gatito

**Habilidad — Gran Encanto**: Al que le pega cuerpo a cuerpo lo deja Intimidado (30%).


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 3 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 7 | Atracción | Normal | Estado | Área | — | 6.0 s |
| 13 | Canto | Normal | Estado | Zona | — | 12.0 s |
| 15 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 19 | Ayuda | Normal | Estado | Mejora propia | — | 10.0 s |
| 25 | Encanto | Hada | Estado | Área | — | 6.0 s |
| 27 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 31 | Antojo | Normal | Físico | Golpe | 60 | 1.4 s |
| 37 | Cascabel Cura | Normal | Estado | Mejora propia | — | 10.0 s |
| 39 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 301 Delcatty

Normal · Pokémon Cursi

**Habilidad — Gran Encanto**: Al que le pega cuerpo a cuerpo lo deja Intimidado (30%).


**Ataques que puede aprender (4)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Atracción | Normal | Estado | Área | — | 6.0 s |
| 1 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Canto | Normal | Estado | Zona | — | 12.0 s |

**Por MT/MO (28)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 302 Sableye

Siniestro/Fantasma · Pokémon Oscuridad

**Habilidad — Vista Lince**: No lo desorientan y sus disparos pegan +10%.


**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 5 | Profecía | Normal | Estado | Área | — | 6.0 s |
| 9 | Tinieblas | Fantasma | Especial | Disparo | 60 | 1.8 s |
| 13 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 17 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 21 | Sorpresa | Normal | Físico | Embestida | 40 | 1.6 s |
| 25 | Detección | Lucha | Estado | Defensa | — | 8.0 s |
| 29 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 33 | Desarme | Siniestro | Físico | Golpe | 65 | 1.4 s |
| 37 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 41 | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| 45 | Mal de Ojo | Normal | Estado | Área | — | 6.0 s |

**Por MT/MO (29)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 303 Mawile

Acero/Hada · Pokémon Tramposo

**Habilidad — Corte Fuerte**: No lo intimidan.

**Habilidad — Intimidación**: Al encarar a un rival lo deja Intimidado (pega menos).


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 6 | Llanto Falso | Siniestro | Estado | Área | — | 6.0 s |
| 11 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 16 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 21 | Agarre | Normal | Físico | Golpe | 55 | 1.3 s |
| 26 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 31 | Relevo | Normal | Estado | Mejora propia | — | 10.0 s |
| 36 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 41 | Defensa Férrea | Acero | Estado | Mejora propia | — | 10.0 s |
| 46 | Escupir | Normal | Especial | Disparo | 60 | 1.8 s |
| 46 | Reserva | Normal | Estado | Mejora propia | — | 10.0 s |
| 46 | Tragar | Normal | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 304 Aron

Acero/Roca · Pokémon Coraza Férrea

**Habilidad — Robustez**: Con la vida llena, un golpe que lo debilitaría lo deja con 1 de vida.

**Habilidad — Cabeza Roca**: Sus embestidas pegan +25%.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 4 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 7 | Bofetón Lodo | Tierra | Especial | Disparo | 20 | 1.1 s |
| 10 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 13 | Garra Metal | Acero | Físico | Golpe | 50 | 1.3 s |
| 17 | Defensa Férrea | Acero | Estado | Mejora propia | — | 10.0 s |
| 21 | Rugido | Normal | Estado | Área | — | 6.0 s |
| 25 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 29 | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| 34 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 39 | Eco Metálico | Acero | Estado | Área | — | 6.0 s |
| 44 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 305 Lairon

Acero/Roca · Pokémon Coraza Férrea

**Habilidad — Robustez**: Con la vida llena, un golpe que lo debilitaría lo deja con 1 de vida.

**Habilidad — Cabeza Roca**: Sus embestidas pegan +25%.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 1 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 1 | Bofetón Lodo | Tierra | Especial | Disparo | 20 | 1.1 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 13 | Garra Metal | Acero | Físico | Golpe | 50 | 1.3 s |
| 17 | Defensa Férrea | Acero | Estado | Mejora propia | — | 10.0 s |
| 21 | Rugido | Normal | Estado | Área | — | 6.0 s |
| 25 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 29 | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| 37 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 45 | Eco Metálico | Acero | Estado | Área | — | 6.0 s |
| 53 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 306 Aggron

Acero/Roca · Pokémon Coraza Férrea

**Habilidad — Robustez**: Con la vida llena, un golpe que lo debilitaría lo deja con 1 de vida.

**Habilidad — Cabeza Roca**: Sus embestidas pegan +25%.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 1 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 1 | Bofetón Lodo | Tierra | Especial | Disparo | 20 | 1.1 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 13 | Garra Metal | Acero | Físico | Golpe | 50 | 1.3 s |
| 17 | Defensa Férrea | Acero | Estado | Mejora propia | — | 10.0 s |
| 21 | Rugido | Normal | Estado | Área | — | 6.0 s |
| 25 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 29 | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| 37 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 50 | Eco Metálico | Acero | Estado | Área | — | 6.0 s |
| 63 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (37)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 307 Meditite

Lucha/Psíquico · Pokémon Meditador

**Habilidad — Energía Pura**: Sus golpes cuerpo a cuerpo pegan +50%.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Venganza | Normal | Físico | Embestida | 60 | 1.9 s |
| 4 | Meditación | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 9 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 12 | Detección | Lucha | Estado | Defensa | — | 8.0 s |
| 17 | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| 20 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 25 | Telépata | Normal | Estado | Área | — | 6.0 s |
| 28 | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 33 | Patada Salto Alta | Lucha | Físico | Embestida | 130 | 2.9 s |
| 36 | Autosugestión | Normal | Estado | Área | — | 6.0 s |
| 41 | Inversión | Lucha | Físico | Golpe | 60 | 1.4 s |
| 44 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 308 Medicham

Lucha/Psíquico · Pokémon Meditador

**Habilidad — Energía Pura**: Sus golpes cuerpo a cuerpo pegan +50%.


**Ataques que puede aprender (15)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Venganza | Normal | Físico | Embestida | 60 | 1.9 s |
| 1 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 1 | Detección | Lucha | Estado | Defensa | — | 8.0 s |
| 1 | Puño Fuego | Fuego | Físico | Golpe | 75 | 1.6 s |
| 1 | Puño Hielo | Hielo | Físico | Golpe | 75 | 1.6 s |
| 1 | Meditación | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 1 | Puño Trueno | Eléctrico | Físico | Golpe | 75 | 1.4 s |
| 17 | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| 20 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 25 | Telépata | Normal | Estado | Área | — | 6.0 s |
| 28 | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 33 | Patada Salto Alta | Lucha | Físico | Embestida | 130 | 2.9 s |
| 36 | Autosugestión | Normal | Estado | Área | — | 6.0 s |
| 47 | Inversión | Lucha | Físico | Golpe | 60 | 1.4 s |
| 56 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 309 Electrike

Eléctrico · Pokémon Calambre

**Habilidad — Electricidad Estática**: Al que le pega cuerpo a cuerpo lo paraliza (30%).

**Habilidad — Pararrayos**: Atrae los rayos: los ataques Eléctricos no le hacen nada y le suben los suyos.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 4 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 9 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 12 | Aullido | Normal | Estado | Mejora propia | — | 10.0 s |
| 17 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 20 | Chispa | Eléctrico | Físico | Embestida | 65 | 6.0 s |
| 25 | Rastreo | Normal | Estado | Área | — | 6.0 s |
| 28 | Rugido | Normal | Estado | Área | — | 6.0 s |
| 33 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 36 | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| 41 | Carga | Eléctrico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 310 Manectric

Eléctrico · Pokémon Descarga

**Habilidad — Electricidad Estática**: Al que le pega cuerpo a cuerpo lo paraliza (30%).

**Habilidad — Pararrayos**: Atrae los rayos: los ataques Eléctricos no le hacen nada y le suben los suyos.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Aullido | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 17 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 20 | Chispa | Eléctrico | Físico | Embestida | 65 | 6.0 s |
| 25 | Rastreo | Normal | Estado | Área | — | 6.0 s |
| 31 | Rugido | Normal | Estado | Área | — | 6.0 s |
| 39 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 45 | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| 53 | Carga | Eléctrico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 311 Plusle

Eléctrico · Pokémon Ánimo

**Habilidad — Más**: Sus disparos pegan +20%.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 4 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 10 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 13 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 19 | Chispa | Eléctrico | Físico | Embestida | 65 | 6.0 s |
| 22 | Otra Vez | Normal | Estado | Área | — | 6.0 s |
| 28 | Llanto Falso | Siniestro | Estado | Área | — | 6.0 s |
| 31 | Carga | Eléctrico | Estado | Mejora propia | — | 10.0 s |
| 37 | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| 40 | Relevo | Normal | Estado | Mejora propia | — | 10.0 s |
| 47 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (17)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 312 Minun

Eléctrico · Pokémon Ánimo

**Habilidad — Menos**: Sus disparos pegan +20%.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 4 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 10 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 13 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 19 | Chispa | Eléctrico | Físico | Embestida | 65 | 6.0 s |
| 22 | Otra Vez | Normal | Estado | Área | — | 6.0 s |
| 28 | Encanto | Hada | Estado | Área | — | 6.0 s |
| 31 | Carga | Eléctrico | Estado | Mejora propia | — | 10.0 s |
| 37 | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| 40 | Relevo | Normal | Estado | Mejora propia | — | 10.0 s |
| 47 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (17)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 313 Volbeat

Bicho · Pokémon Luciérnaga

**Habilidad — Iluminación**: Brilla: sus golpes a veces dejan Expuesto al rival (20%).

**Habilidad — Enjambre**: Con menos de 1/3 de vida sus ataques de tipo Bicho pegan ×1,5.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 5 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 9 | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| 13 | Luz Lunar | Hada | Estado | Mejora propia | — | 10.0 s |
| 17 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 21 | Luminicola | Bicho | Estado | Mejora propia | — | 10.0 s |
| 25 | Rayo Señal | Bicho | Especial | Disparo | 75 | 2.1 s |
| 29 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 33 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 37 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 314 Illumise

Bicho · Pokémon Luciérnaga

**Habilidad — Despiste**: No lo intimidan ni lo desorientan.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 5 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 9 | Encanto | Hada | Estado | Área | — | 6.0 s |
| 13 | Luz Lunar | Hada | Estado | Mejora propia | — | 10.0 s |
| 17 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 21 | Deseo | Normal | Estado | Mejora propia | — | 10.0 s |
| 25 | Otra Vez | Normal | Estado | Área | — | 6.0 s |
| 29 | Camelo | Siniestro | Estado | Disparo | — | 6.0 s |
| 33 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 37 | Antojo | Normal | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 315 Roselia

Planta/Veneno · Pokémon Espina

**Habilidad — Cura Natural**: Cada 8 s se cura los problemas de estado.

**Habilidad — Punto Tóxico**: Al que le pega cuerpo a cuerpo lo envenena (30%).


**Ataques que puede aprender (15)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 5 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 9 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 13 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 17 | Megaagotar | Planta | Especial | Disparo | 40 | 1.5 s |
| 21 | Drenadoras | Planta | Estado | Área | — | 6.0 s |
| 25 | Hoja Mágica | Planta | Especial | Disparo | 60 | 1.8 s |
| 29 | Silbato | Planta | Estado | Disparo | — | 6.0 s |
| 33 | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| 37 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 41 | Arraigo | Planta | Estado | Mejora propia | — | 10.0 s |
| 45 | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| 49 | Danza Pétalo | Planta | Especial | Área | 120 | 5.5 s |
| 53 | Aromaterapia | Planta | Estado | Mejora propia | — | 10.0 s |
| 57 | Fotosíntesis | Planta | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 316 Gulpin

Veneno · Pokémon Estómago

**Habilidad — Lodo Líquido**: El que le roba vida (Absorber, Chupavidas...) en vez de curarse se lastima.

**Habilidad — Viscosidad**: Casi no lo empujan.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 6 | Bostezo | Normal | Estado | Disparo | — | 9.0 s |
| 9 | Gas Venenoso | Veneno | Estado | Zona | — | 5.0 s |
| 14 | Residuos | Veneno | Especial | Disparo | 65 | 2.2 s |
| 17 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 23 | Otra Vez | Normal | Estado | Área | — | 6.0 s |
| 28 | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| 34 | Escupir | Normal | Especial | Disparo | 60 | 1.8 s |
| 34 | Reserva | Normal | Estado | Mejora propia | — | 10.0 s |
| 34 | Tragar | Normal | Estado | Mejora propia | — | 10.0 s |
| 39 | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 317 Swalot

Veneno · Pokémon Bolsa Veneno

**Habilidad — Lodo Líquido**: El que le roba vida (Absorber, Chupavidas...) en vez de curarse se lastima.

**Habilidad — Viscosidad**: Casi no lo empujan.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gas Venenoso | Veneno | Estado | Zona | — | 5.0 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Residuos | Veneno | Especial | Disparo | 65 | 2.2 s |
| 1 | Bostezo | Normal | Estado | Disparo | — | 9.0 s |
| 17 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 23 | Otra Vez | Normal | Estado | Área | — | 6.0 s |
| 26 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 31 | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| 40 | Escupir | Normal | Especial | Disparo | 60 | 1.8 s |
| 40 | Reserva | Normal | Estado | Mejora propia | — | 10.0 s |
| 40 | Tragar | Normal | Estado | Mejora propia | — | 10.0 s |
| 48 | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 318 Carvanha

Agua/Siniestro · Pokémon Feroz

**Habilidad — Piel Tosca**: Al que le pega cuerpo a cuerpo le devuelve un 12% del daño.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 7 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 13 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 16 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 22 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 28 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 31 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 37 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 43 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 319 Sharpedo

Agua/Siniestro · Pokémon Voraz

**Habilidad — Piel Tosca**: Al que le pega cuerpo a cuerpo le devuelve un 12% del daño.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 1 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 16 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 22 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 28 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 33 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 38 | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| 43 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 48 | Cabezazo | Normal | Físico | Embestida | 130 | 2.9 s |
| 53 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (27)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 320 Wailmer

Agua · Pokémon Ballenabola

**Habilidad — Velo Agua**: No lo queman.

**Habilidad — Despiste**: No lo intimidan ni lo desorientan.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Salpicadura | Normal | Estado | Embestida | — | 1.5 s |
| 5 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 10 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 14 | Rodar | Roca | Físico | Embestida | 30 | 2.0 s |
| 19 | Torbellino | Agua | Especial | Disparo | 35 | 1.4 s |
| 23 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 28 | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| 32 | Neblina | Hielo | Estado | Mejora propia | — | 10.0 s |
| 37 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 41 | Salpicar | Agua | Especial | Área | 150 | 6.3 s |
| 46 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 50 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 321 Wailord

Agua · Pokémon Ballenaflot

**Habilidad — Velo Agua**: No lo queman.

**Habilidad — Despiste**: No lo intimidan ni lo desorientan.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Rodar | Roca | Físico | Embestida | 30 | 2.0 s |
| 1 | Salpicadura | Normal | Estado | Embestida | — | 1.5 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 19 | Torbellino | Agua | Especial | Disparo | 35 | 1.4 s |
| 23 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 28 | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| 32 | Neblina | Hielo | Estado | Mejora propia | — | 10.0 s |
| 37 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 44 | Salpicar | Agua | Especial | Área | 150 | 6.3 s |
| 52 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 59 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 322 Numel

Fuego/Tierra · Pokémon Torpe

**Habilidad — Despiste**: No lo intimidan ni lo desorientan.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 11 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 19 | Magnitud | Tierra | Físico | Área | 60 | 3.7 s |
| 25 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 29 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 31 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 35 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 41 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| 49 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 323 Camerupt

Fuego/Tierra · Pokémon Erupción

**Habilidad — Escudo Magma**: No lo congelan.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Magnitud | Tierra | Físico | Área | 60 | 3.7 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 25 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 29 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 31 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 33 | Avalancha | Roca | Físico | Área | 75 | 4.2 s |
| 37 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 45 | Estallido | Fuego | Especial | Área | 150 | 6.3 s |
| 55 | Fisura | Tierra | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 324 Torkoal

Fuego · Pokémon Carbón

**Habilidad — Humo Blanco**: No le bajan nada: no lo intimidan, exponen ni ralentizan.

**Habilidad — Sequía**: Sus golpes a veces queman (10%).


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 4 | Polución | Veneno | Especial | Disparo | 30 | 1.3 s |
| 7 | Maldición | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 14 | Pantalla de Humo | Normal | Estado | Zona | — | 9.0 s |
| 17 | Giro Fuego | Fuego | Especial | Área | 35 | 3.0 s |
| 20 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 27 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 30 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| 33 | Defensa Férrea | Acero | Estado | Mejora propia | — | 10.0 s |
| 40 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 43 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |
| 46 | Onda Ígnea | Fuego | Especial | Área | 95 | 4.7 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 325 Spoink

Psíquico · Pokémon Saltarín

**Habilidad — Sebo**: El fuego y el hielo le hacen la mitad.

**Habilidad — Ritmo Propio**: No lo desorientan.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Salpicadura | Normal | Estado | Embestida | — | 1.5 s |
| 7 | Psicoonda | Psíquico | Especial | Disparo | 60 | 1.8 s |
| 10 | Rastreo | Normal | Estado | Área | — | 6.0 s |
| 16 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 19 | Autosugestión | Normal | Estado | Área | — | 6.0 s |
| 25 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 28 | Capa Mágica | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 34 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 37 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 37 | Ronquido | Normal | Especial | Disparo | 50 | 1.6 s |
| 43 | Bote | Volador | Físico | Embestida | 85 | 2.2 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 326 Grumpig

Psíquico · Pokémon Manipulador

**Habilidad — Sebo**: El fuego y el hielo le hacen la mitad.

**Habilidad — Ritmo Propio**: No lo desorientan.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Rastreo | Normal | Estado | Área | — | 6.0 s |
| 1 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 1 | Psicoonda | Psíquico | Especial | Disparo | 60 | 1.8 s |
| 1 | Salpicadura | Normal | Estado | Embestida | — | 1.5 s |
| 19 | Autosugestión | Normal | Estado | Área | — | 6.0 s |
| 25 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 28 | Capa Mágica | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 37 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 43 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 43 | Ronquido | Normal | Especial | Disparo | 50 | 1.6 s |
| 55 | Bote | Volador | Físico | Embestida | 85 | 2.2 s |

**Por MT/MO (27)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 327 Spinda

Normal · Pokémon Panda Topos

**Habilidad — Ritmo Propio**: No lo desorientan.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 5 | Alboroto | Normal | Especial | Disparo | 90 | 2.4 s |
| 12 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 16 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 23 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 27 | Puño Mareo | Normal | Físico | Golpe | 70 | 1.5 s |
| 34 | Danza Caos | Normal | Estado | Disparo | — | 6.0 s |
| 38 | Autosugestión | Normal | Estado | Área | — | 6.0 s |
| 45 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |
| 49 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |
| 56 | Saña | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (28)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 328 Trapinch

Tierra · Pokémon Hormiga León

**Habilidad — Corte Fuerte**: No lo intimidan.

**Habilidad — Trampa Arena**: Los rivales cerca suyo quedan ralentizados.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 9 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 17 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 25 | Bucle Arena | Tierra | Físico | Golpe | 35 | 1.1 s |
| 33 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 41 | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| 49 | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| 57 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 329 Vibrava

Tierra/Dragón · Pokémon Vibrante

**Habilidad — Levitación**: Flota: los ataques de Tierra no le hacen nada.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 1 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 1 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 1 | Bucle Arena | Tierra | Físico | Golpe | 35 | 1.1 s |
| 33 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 35 | Dragoaliento | Dragón | Especial | Disparo | 60 | 1.8 s |
| 41 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 49 | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| 57 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 330 Flygon

Tierra/Dragón · Pokémon Místico

**Habilidad — Levitación**: Flota: los ataques de Tierra no le hacen nada.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 1 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 1 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 1 | Bucle Arena | Tierra | Físico | Golpe | 35 | 1.1 s |
| 33 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 35 | Dragoaliento | Dragón | Especial | Disparo | 60 | 1.8 s |
| 41 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 53 | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| 65 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 331 Cacnea

Planta · Pokémon Cactus

**Habilidad — Velo Arena**: Un 12% de los golpes no le entran.


**Ataques que puede aprender (14)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 5 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 9 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 13 | Drenadoras | Planta | Estado | Área | — | 6.0 s |
| 17 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 21 | Pin Misil | Bicho | Físico | Disparo | 25 | 4.5 s |
| 25 | Arraigo | Planta | Estado | Mejora propia | — | 10.0 s |
| 29 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 33 | Púas | Tierra | Estado | Mejora propia | — | 10.0 s |
| 37 | Brazo Pincho | Planta | Físico | Golpe | 60 | 1.4 s |
| 41 | Esporagodón | Planta | Estado | Área | — | 6.0 s |
| 45 | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| 49 | Mismo Destino | Fantasma | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 332 Cacturne

Planta/Siniestro · Pokémon Espantajo

**Habilidad — Velo Arena**: Un 12% de los golpes no le entran.


**Ataques que puede aprender (15)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 1 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 1 | Desquite | Lucha | Físico | Golpe | 60 | 1.4 s |
| 13 | Drenadoras | Planta | Estado | Área | — | 6.0 s |
| 17 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 21 | Pin Misil | Bicho | Físico | Disparo | 25 | 4.5 s |
| 25 | Arraigo | Planta | Estado | Mejora propia | — | 10.0 s |
| 29 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 35 | Púas | Tierra | Estado | Mejora propia | — | 10.0 s |
| 41 | Brazo Pincho | Planta | Físico | Golpe | 60 | 1.4 s |
| 47 | Esporagodón | Planta | Estado | Área | — | 6.0 s |
| 53 | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| 59 | Mismo Destino | Fantasma | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (20)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 333 Swablu

Normal/Volador · Pokémon Ave Algodón

**Habilidad — Cura Natural**: Cada 8 s se cura los problemas de estado.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 8 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 11 | Canto | Normal | Estado | Zona | — | 12.0 s |
| 18 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 21 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 28 | Neblina | Hielo | Estado | Mejora propia | — | 10.0 s |
| 31 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 38 | Espejo | Volador | Estado | Área | — | 6.0 s |
| 41 | Alivio | Normal | Estado | Mejora propia | — | 10.0 s |
| 48 | Canto Mortal | Normal | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 334 Altaria

Dragón/Volador · Pokémon Cantor

**Habilidad — Cura Natural**: Cada 8 s se cura los problemas de estado.


**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 1 | Canto | Normal | Estado | Zona | — | 12.0 s |
| 18 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 21 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 28 | Neblina | Hielo | Estado | Mejora propia | — | 10.0 s |
| 31 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 35 | Dragoaliento | Dragón | Especial | Disparo | 60 | 1.8 s |
| 40 | Danza Dragón | Dragón | Estado | Mejora propia | — | 10.0 s |
| 45 | Alivio | Normal | Estado | Mejora propia | — | 10.0 s |
| 54 | Canto Mortal | Normal | Estado | Mejora propia | — | 10.0 s |
| 59 | Ataque Aéreo | Volador | Físico | Embestida | 140 | 3.0 s |

**Por MT/MO (27)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 335 Zangoose

Normal · Pokémon Gato Hurón

**Habilidad — Inmunidad**: No lo envenenan.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 4 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 7 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 10 | Danza Espada | Normal | Estado | Mejora propia | — | 10.0 s |
| 13 | Corte Furia | Bicho | Físico | Golpe | 40 | 1.1 s |
| 19 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 25 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 31 | Garra Brutal | Normal | Físico | Golpe | 75 | 1.6 s |
| 37 | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| 46 | Detección | Lucha | Estado | Defensa | — | 8.0 s |
| 55 | Falso Tortazo | Normal | Físico | Golpe | 40 | 1.1 s |

**Por MT/MO (33)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 336 Seviper

Veneno · Pokémon Colmillos

**Habilidad — Mudar**: Cada 4 s se saca de encima los problemas de estado.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 7 | Lengüetazo | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 10 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 16 | Cola Veneno | Veneno | Físico | Golpe | 50 | 1.3 s |
| 19 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 25 | Deslumbrar | Normal | Estado | Canalizado | — | 9.0 s |
| 28 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 34 | Colmillo Veneno | Veneno | Físico | Golpe | 50 | 1.3 s |
| 37 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 43 | Niebla | Hielo | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 337 Lunatone

Roca/Psíquico · Pokémon Meteorito

**Habilidad — Levitación**: Flota: los ataques de Tierra no le hacen nada.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 7 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 13 | Lanzarrocas | Roca | Físico | Disparo | 50 | 1.6 s |
| 19 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 25 | Psicoonda | Psíquico | Especial | Disparo | 60 | 1.8 s |
| 31 | Masa Cósmica | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 37 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 43 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |
| 49 | Explosión | Normal | Físico | Área | 250 | 9.2 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 338 Solrock

Roca/Psíquico · Pokémon Meteorito

**Habilidad — Levitación**: Flota: los ataques de Tierra no le hacen nada.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 7 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 13 | Lanzarrocas | Roca | Físico | Disparo | 50 | 1.6 s |
| 19 | Giro Fuego | Fuego | Especial | Área | 35 | 3.0 s |
| 25 | Psicoonda | Psíquico | Especial | Disparo | 60 | 1.8 s |
| 31 | Masa Cósmica | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 37 | Avalancha | Roca | Físico | Área | 75 | 4.2 s |
| 43 | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| 49 | Explosión | Normal | Físico | Área | 250 | 9.2 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 339 Barboach

Agua/Tierra · Pokémon Bigotudo

**Habilidad — Despiste**: No lo intimidan ni lo desorientan.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Bofetón Lodo | Tierra | Especial | Disparo | 20 | 1.1 s |
| 6 | Chapoteo Lodo | Tierra | Estado | Mejora propia | — | 10.0 s |
| 6 | Hidrochorro | Agua | Especial | Área | 15 | 6.0 s |
| 11 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 16 | Magnitud | Tierra | Físico | Área | 60 | 3.7 s |
| 21 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 26 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 26 | Ronquido | Normal | Especial | Disparo | 50 | 1.6 s |
| 31 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 36 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |
| 41 | Fisura | Tierra | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 340 Whiscash

Agua/Tierra · Pokémon Bigotudo

**Habilidad — Despiste**: No lo intimidan ni lo desorientan.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Bofetón Lodo | Tierra | Especial | Disparo | 20 | 1.1 s |
| 1 | Chapoteo Lodo | Tierra | Estado | Mejora propia | — | 10.0 s |
| 1 | Cosquillas | Normal | Estado | Área | — | 6.0 s |
| 1 | Hidrochorro | Agua | Especial | Área | 15 | 6.0 s |
| 11 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 16 | Magnitud | Tierra | Físico | Área | 60 | 3.7 s |
| 21 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 26 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 26 | Ronquido | Normal | Especial | Disparo | 50 | 1.6 s |
| 36 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 46 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |
| 56 | Fisura | Tierra | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 341 Corphish

Agua · Pokémon Rufián

**Habilidad — Corte Fuerte**: No lo intimidan.

**Habilidad — Caparazón**: Lo cubre su caparazón: recibe 15% menos de frente.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 7 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 10 | Agarre | Normal | Físico | Golpe | 55 | 1.3 s |
| 13 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 19 | Rayo Burbuja | Agua | Especial | Disparo | 30 | 3.0 s |
| 22 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 25 | Desarme | Siniestro | Físico | Golpe | 65 | 1.4 s |
| 31 | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| 34 | Martillazo | Agua | Físico | Embestida | 100 | 2.5 s |
| 37 | Danza Espada | Normal | Estado | Mejora propia | — | 10.0 s |
| 43 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 46 | Guillotina | Normal | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 342 Crawdaunt

Agua/Siniestro · Pokémon Granuja

**Habilidad — Corte Fuerte**: No lo intimidan.

**Habilidad — Caparazón**: Lo cubre su caparazón: recibe 15% menos de frente.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Agarre | Normal | Físico | Golpe | 55 | 1.3 s |
| 19 | Rayo Burbuja | Agua | Especial | Disparo | 30 | 3.0 s |
| 22 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 25 | Desarme | Siniestro | Físico | Golpe | 65 | 1.4 s |
| 33 | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| 38 | Martillazo | Agua | Físico | Embestida | 100 | 2.5 s |
| 43 | Danza Espada | Normal | Estado | Mejora propia | — | 10.0 s |
| 51 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 56 | Guillotina | Normal | Físico | Golpe | 60 | 1.4 s |

**Por MT/MO (28)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 343 Baltoy

Tierra/Psíquico · Pokémon Muñeca Barro

**Habilidad — Levitación**: Flota: los ataques de Tierra no le hacen nada.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 3 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 5 | Giro Rápido | Normal | Físico | Embestida | 50 | 7.0 s |
| 7 | Bofetón Lodo | Tierra | Especial | Disparo | 20 | 1.1 s |
| 11 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 15 | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| 19 | Autodestrucción | Normal | Físico | Área | 130 | 20.0 s |
| 25 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 31 | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| 37 | Masa Cósmica | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 45 | Explosión | Normal | Físico | Área | 250 | 9.2 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 344 Claydol

Tierra/Psíquico · Pokémon Muñeca Barro

**Habilidad — Levitación**: Flota: los ataques de Tierra no le hacen nada.


**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 1 | Giro Rápido | Normal | Físico | Embestida | 50 | 7.0 s |
| 1 | Teletransporte | Psíquico | Estado | Embestida | — | 3.0 s |
| 7 | Bofetón Lodo | Tierra | Especial | Disparo | 20 | 1.1 s |
| 11 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 15 | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| 19 | Autodestrucción | Normal | Físico | Área | 130 | 20.0 s |
| 25 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 31 | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| 36 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| 42 | Masa Cósmica | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 55 | Explosión | Normal | Físico | Área | 250 | 9.2 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 345 Lileep

Roca/Planta · Pokémon Lirio de Mar

**Habilidad — Ventosas**: Se agarra al suelo: casi no lo empujan.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 8 | Restricción | Normal | Físico | Látigo | 15 | 5.0 s |
| 15 | Ácido | Veneno | Especial | Disparo | 40 | 1.5 s |
| 22 | Arraigo | Planta | Estado | Mejora propia | — | 10.0 s |
| 29 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 36 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 43 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 50 | Escupir | Normal | Especial | Disparo | 60 | 1.8 s |
| 50 | Reserva | Normal | Estado | Mejora propia | — | 10.0 s |
| 50 | Tragar | Normal | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (16)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 346 Cradily

Roca/Planta · Pokémon Percebe

**Habilidad — Ventosas**: Se agarra al suelo: casi no lo empujan.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ácido | Veneno | Especial | Disparo | 40 | 1.5 s |
| 1 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 1 | Restricción | Normal | Físico | Látigo | 15 | 5.0 s |
| 1 | Arraigo | Planta | Estado | Mejora propia | — | 10.0 s |
| 29 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 36 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 48 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 60 | Escupir | Normal | Especial | Disparo | 60 | 1.8 s |
| 60 | Reserva | Normal | Estado | Mejora propia | — | 10.0 s |
| 60 | Tragar | Normal | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 347 Anorith

Roca/Bicho · Pokémon Camarón

**Habilidad — Armadura Batalla**: Su armadura lo cubre: recibe 15% menos de frente.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 7 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 13 | Chapoteo Lodo | Tierra | Estado | Mejora propia | — | 10.0 s |
| 19 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 25 | Garra Metal | Acero | Físico | Golpe | 50 | 1.3 s |
| 31 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 37 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 43 | Corte Furia | Bicho | Físico | Golpe | 40 | 1.1 s |
| 49 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 55 | Pedrada | Roca | Físico | Golpe | 25 | 0.9 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 348 Armaldo

Roca/Bicho · Pokémon Armadura

**Habilidad — Armadura Batalla**: Su armadura lo cubre: recibe 15% menos de frente.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 1 | Chapoteo Lodo | Tierra | Estado | Mejora propia | — | 10.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 25 | Garra Metal | Acero | Físico | Golpe | 50 | 1.3 s |
| 31 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 37 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 46 | Corte Furia | Bicho | Físico | Golpe | 40 | 1.1 s |
| 55 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 64 | Pedrada | Roca | Físico | Golpe | 25 | 0.9 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 349 Feebas

Agua · Pokémon Pez

**Habilidad — Nado Rápido**: Mojado (agua, suelo mojado o empapado) se mueve un 40% más rápido.

**Habilidad — Despiste**: No lo intimidan ni lo desorientan.


**Ataques que puede aprender (3)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Salpicadura | Normal | Estado | Embestida | — | 1.5 s |
| 15 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 30 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 350 Milotic

Agua · Pokémon Tierno

**Habilidad — Escama Especial**: Con un problema de estado recibe 30% menos.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 5 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 10 | Hidrochorro | Agua | Especial | Área | 15 | 6.0 s |
| 15 | Alivio | Normal | Estado | Mejora propia | — | 10.0 s |
| 20 | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| 25 | Ciclón | Dragón | Especial | Área | 40 | 6.0 s |
| 30 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |
| 35 | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| 40 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |
| 45 | Atracción | Normal | Estado | Área | — | 6.0 s |
| 50 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 351 Castform

Normal · Pokémon Clima

**Habilidad — Predicción**: No lo empapan ni lo congelan.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 10 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 10 | Nieve Polvo | Hielo | Especial | Área | 40 | 3.2 s |
| 10 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 20 | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| 20 | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| 20 | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| 30 | Meteorobola | Normal | Especial | Disparo | 50 | 1.6 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 352 Kecleon

Normal · Pokémon Camaleónico

**Habilidad — Cambio Color**: Por ahora sin efecto (en los juegos cambia al tipo que le pega).


**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 1 | Lengüetazo | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 1 | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| 4 | Atadura | Normal | Físico | Látigo | 15 | 3.0 s |
| 7 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 12 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 17 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 24 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 31 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 40 | Sustituto | Normal | Estado | Mejora propia | — | 10.0 s |
| 49 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |

**Por MT/MO (35)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 353 Shuppet

Fantasma · Pokémon Títere

**Habilidad — Insomnio**: No lo duermen.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Desarme | Siniestro | Físico | Golpe | 65 | 1.4 s |
| 8 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 13 | Tinieblas | Fantasma | Especial | Disparo | 60 | 1.8 s |
| 20 | Maldición | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 25 | Rencor | Fantasma | Estado | Área | — | 6.0 s |
| 32 | Fuego Fatuo | Fuego | Estado | Disparo | — | 6.0 s |
| 37 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 44 | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| 49 | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| 56 | Rabia | Fantasma | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 354 Banette

Fantasma · Pokémon Marioneta

**Habilidad — Insomnio**: No lo duermen.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Maldición | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 1 | Desarme | Siniestro | Físico | Golpe | 65 | 1.4 s |
| 1 | Tinieblas | Fantasma | Especial | Disparo | 60 | 1.8 s |
| 1 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 25 | Rencor | Fantasma | Estado | Área | — | 6.0 s |
| 32 | Fuego Fatuo | Fuego | Estado | Disparo | — | 6.0 s |
| 39 | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 48 | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| 55 | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| 64 | Rabia | Fantasma | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 355 Duskull

Fantasma · Pokémon Réquiem

**Habilidad — Levitación**: Flota: los ataques de Tierra no le hacen nada.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Tinieblas | Fantasma | Especial | Disparo | 60 | 1.8 s |
| 5 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 12 | Profecía | Normal | Estado | Área | — | 6.0 s |
| 16 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 23 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 27 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 34 | Maldición | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 38 | Fuego Fatuo | Fuego | Estado | Disparo | — | 6.0 s |
| 45 | Mal de Ojo | Normal | Estado | Área | — | 6.0 s |
| 49 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 356 Dusclops

Fantasma · Pokémon Atrayente

**Habilidad — Presión**: Cada golpe suyo le suma 0,3 s a las recargas del rival.


**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Atadura | Normal | Físico | Látigo | 15 | 3.0 s |
| 1 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Tinieblas | Fantasma | Especial | Disparo | 60 | 1.8 s |
| 12 | Profecía | Normal | Estado | Área | — | 6.0 s |
| 16 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 23 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 27 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 34 | Maldición | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 37 | Puño Sombra | Fantasma | Físico | Golpe | 60 | 1.4 s |
| 41 | Fuego Fatuo | Fuego | Estado | Disparo | — | 6.0 s |
| 51 | Mal de Ojo | Normal | Estado | Área | — | 6.0 s |
| 58 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |

**Por MT/MO (29)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 357 Tropius

Planta/Volador · Pokémon Fruto

**Habilidad — Clorofila**: De día se mueve un 30% más rápido.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Tornado | Volador | Especial | Disparo | 40 | 1.5 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 7 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 11 | Hoja Afilada | Planta | Físico | Disparo | 55 | 1.7 s |
| 17 | Pisotón | Normal | Físico | Golpe | 65 | 1.2 s |
| 21 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 27 | Remolino | Volador | Estado | Zona | — | 9.0 s |
| 31 | Hoja Mágica | Planta | Especial | Disparo | 60 | 1.8 s |
| 37 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 41 | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| 47 | Fotosíntesis | Planta | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Semilladora | Planta | Físico | Golpe | 25 | 0.9 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 358 Chimecho

Psíquico · Pokémon Sonido Aire

**Habilidad — Levitación**: Flota: los ataques de Tierra no le hacen nada.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 6 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 9 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 14 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 17 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 22 | Alboroto | Normal | Especial | Disparo | 90 | 2.4 s |
| 25 | Bostezo | Normal | Estado | Disparo | — | 9.0 s |
| 30 | Psicoonda | Psíquico | Especial | Disparo | 60 | 1.8 s |
| 33 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |
| 38 | Cascabel Cura | Normal | Estado | Mejora propia | — | 10.0 s |
| 41 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 46 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 359 Absol

Siniestro · Pokémon Catástrofe

**Habilidad — Presión**: Cada golpe suyo le suma 0,3 s a las recargas del rival.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 5 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 9 | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| 13 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 17 | Viento Cortante | Normal | Especial | Área | 80 | 4.3 s |
| 21 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 26 | Danza Espada | Normal | Estado | Mejora propia | — | 10.0 s |
| 31 | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| 36 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 41 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |
| 46 | Canto Mortal | Normal | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (35)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Ladrón | Siniestro | Físico | Golpe | 60 | 1.4 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 360 Wynaut

Psíquico · Pokémon Radiante

**Habilidad — Sombra Trampa**: Los rivales cerca suyo quedan ralentizados.


**Ataques que puede aprender (7)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Encanto | Hada | Estado | Área | — | 6.0 s |
| 1 | Otra Vez | Normal | Estado | Área | — | 6.0 s |
| 1 | Salpicadura | Normal | Estado | Embestida | — | 1.5 s |
| 15 | Contraataque | Lucha | Físico | Golpe | 60 | 1.4 s |
| 15 | Mismo Destino | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 15 | Manto Espejo | Psíquico | Especial | Disparo | 60 | 1.8 s |
| 15 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |

### 361 Snorunt

Hielo · Pokémon Gorro Nieve

**Habilidad — Fuerza Mental**: No sufre el stagger de los golpes: puede contestar enseguida.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Nieve Polvo | Hielo | Especial | Área | 40 | 3.2 s |
| 7 | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| 10 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 16 | Viento Hielo | Hielo | Especial | Disparo | 55 | 1.7 s |
| 19 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 25 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 28 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 34 | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| 37 | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| 43 | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 362 Glalie

Hielo · Pokémon Cara

**Habilidad — Fuerza Mental**: No sufre el stagger de los golpes: puede contestar enseguida.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 1 | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Nieve Polvo | Hielo | Especial | Área | 40 | 3.2 s |
| 16 | Viento Hielo | Hielo | Especial | Disparo | 55 | 1.7 s |
| 19 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 25 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 28 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 34 | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| 42 | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| 53 | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| 61 | Frío Polar | Hielo | Especial | Disparo | 60 | 1.8 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 363 Spheal

Hielo/Agua · Pokémon Aplauso

**Habilidad — Sebo**: El fuego y el hielo le hacen la mitad.


**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Nieve Polvo | Hielo | Especial | Área | 40 | 3.2 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 7 | Otra Vez | Normal | Estado | Área | — | 6.0 s |
| 13 | Bola Hielo | Hielo | Físico | Golpe | 30 | 1.0 s |
| 19 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 25 | Rayo Aurora | Hielo | Especial | Disparo | 65 | 1.9 s |
| 31 | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| 37 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 37 | Ronquido | Normal | Especial | Disparo | 50 | 1.6 s |
| 43 | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| 49 | Frío Polar | Hielo | Especial | Disparo | 60 | 1.8 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 364 Sealeo

Hielo/Agua · Pokémon Rodabola

**Habilidad — Sebo**: El fuego y el hielo le hacen la mitad.


**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Nieve Polvo | Hielo | Especial | Área | 40 | 3.2 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 7 | Otra Vez | Normal | Estado | Área | — | 6.0 s |
| 13 | Bola Hielo | Hielo | Físico | Golpe | 30 | 1.0 s |
| 19 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 25 | Rayo Aurora | Hielo | Especial | Disparo | 65 | 1.9 s |
| 31 | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| 39 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 39 | Ronquido | Normal | Especial | Disparo | 50 | 1.6 s |
| 47 | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| 55 | Frío Polar | Hielo | Especial | Disparo | 60 | 1.8 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 365 Walrein

Hielo/Agua · Pokémon Rompehielo

**Habilidad — Sebo**: El fuego y el hielo le hacen la mitad.


**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Nieve Polvo | Hielo | Especial | Área | 40 | 3.2 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 7 | Otra Vez | Normal | Estado | Área | — | 6.0 s |
| 13 | Bola Hielo | Hielo | Físico | Golpe | 30 | 1.0 s |
| 19 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 25 | Rayo Aurora | Hielo | Especial | Disparo | 65 | 1.9 s |
| 31 | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| 39 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 39 | Ronquido | Normal | Especial | Disparo | 50 | 1.6 s |
| 50 | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| 61 | Frío Polar | Hielo | Especial | Disparo | 60 | 1.8 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 366 Clamperl

Agua · Pokémon Bivalvo

**Habilidad — Caparazón**: Lo cubre su caparazón: recibe 15% menos de frente.


**Ataques que puede aprender (4)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Tenaza | Agua | Físico | Embestida+combo | 35 | 6.0 s |
| 1 | Defensa Férrea | Acero | Estado | Mejora propia | — | 10.0 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 1 | Torbellino | Agua | Especial | Disparo | 35 | 1.4 s |

**Por MT/MO (18)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 367 Huntail

Agua · Pokémon Abisal

**Habilidad — Nado Rápido**: Mojado (agua, suelo mojado o empapado) se mueve un 40% más rápido.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Torbellino | Agua | Especial | Disparo | 35 | 1.4 s |
| 8 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 15 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 22 | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| 29 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 36 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 43 | Relevo | Normal | Estado | Mejora propia | — | 10.0 s |
| 50 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (21)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 368 Gorebyss

Agua · Pokémon Mar del Sur

**Habilidad — Nado Rápido**: Mojado (agua, suelo mojado o empapado) se mueve un 40% más rápido.


**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Torbellino | Agua | Especial | Disparo | 35 | 1.4 s |
| 8 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 15 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 22 | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| 29 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 36 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 43 | Relevo | Normal | Estado | Mejora propia | — | 10.0 s |
| 50 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 369 Relicanth

Agua/Roca · Pokémon Longevo

**Habilidad — Nado Rápido**: Mojado (agua, suelo mojado o empapado) se mueve un 40% más rápido.

**Habilidad — Cabeza Roca**: Sus embestidas pegan +25%.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 8 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 15 | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| 22 | Bostezo | Normal | Estado | Disparo | — | 9.0 s |
| 29 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 36 | Chapoteo Lodo | Tierra | Estado | Mejora propia | — | 10.0 s |
| 43 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 50 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 57 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |
| 64 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

**Por MT/MO (25)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 370 Luvdisc

Agua · Pokémon Cita

**Habilidad — Nado Rápido**: Mojado (agua, suelo mojado o empapado) se mueve un 40% más rápido.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 4 | Encanto | Hada | Estado | Área | — | 6.0 s |
| 12 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 16 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 24 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 28 | Atracción | Normal | Estado | Área | — | 6.0 s |
| 36 | Beso Dulce | Hada | Estado | Disparo | — | 6.0 s |
| 40 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |
| 48 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (19)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 371 Bagon

Dragón · Pokémon Cabeza Roca

**Habilidad — Cabeza Roca**: Sus embestidas pegan +25%.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 5 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 9 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 17 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 21 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 25 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 33 | Dragoaliento | Dragón | Especial | Disparo | 60 | 1.8 s |
| 37 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 41 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 49 | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| 53 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 372 Shelgon

Dragón · Pokémon Resistencia

**Habilidad — Cabeza Roca**: Sus embestidas pegan +25%.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 1 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 21 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 25 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 30 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 38 | Dragoaliento | Dragón | Especial | Disparo | 60 | 1.8 s |
| 47 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 56 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 69 | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| 78 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (22)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 373 Salamence

Dragón/Volador · Pokémon Dragón

**Habilidad — Intimidación**: Al encarar a un rival lo deja Intimidado (pega menos).


**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 1 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 21 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 25 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 30 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 38 | Dragoaliento | Dragón | Especial | Disparo | 60 | 1.8 s |
| 47 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 50 | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| 61 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 79 | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| 93 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

**Por MT/MO (27)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 374 Beldum

Acero/Psíquico · Pokémon Bola Hierro

**Habilidad — Cuerpo Puro**: No le bajan nada: no lo intimidan, exponen ni ralentizan.


**Ataques que puede aprender (1)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |

### 375 Metang

Acero/Psíquico · Pokémon Garra Hierro

**Habilidad — Cuerpo Puro**: No le bajan nada: no lo intimidan, exponen ni ralentizan.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 20 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 20 | Garra Metal | Acero | Físico | Golpe | 50 | 1.3 s |
| 26 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 32 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 38 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 44 | Defensa Férrea | Acero | Estado | Mejora propia | — | 10.0 s |
| 50 | Puño Meteoro | Acero | Físico | Embestida | 90 | 2.3 s |
| 56 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 62 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 376 Metagross

Acero/Psíquico · Pokémon Pata Hierro

**Habilidad — Cuerpo Puro**: No le bajan nada: no lo intimidan, exponen ni ralentizan.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 1 | Garra Metal | Acero | Físico | Golpe | 50 | 1.3 s |
| 1 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 1 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 32 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 38 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 44 | Defensa Férrea | Acero | Estado | Mejora propia | — | 10.0 s |
| 55 | Puño Meteoro | Acero | Físico | Embestida | 90 | 2.3 s |
| 66 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 77 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 377 Regirock

Roca · Pokémon Pico Roca

**Habilidad — Cuerpo Puro**: No le bajan nada: no lo intimidan, exponen ni ralentizan.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Explosión | Normal | Físico | Área | 250 | 9.2 s |
| 9 | Lanzarrocas | Roca | Físico | Disparo | 50 | 1.6 s |
| 17 | Maldición | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 25 | Fuerza Bruta | Lucha | Físico | Embestida | 120 | 2.7 s |
| 33 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 41 | Defensa Férrea | Acero | Estado | Mejora propia | — | 10.0 s |
| 49 | Electrocañón | Eléctrico | Especial | Disparo | 120 | 2.9 s |
| 57 | Fijar Blanco | Normal | Estado | Disparo | — | 8.0 s |
| 65 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 378 Regice

Hielo · Pokémon Iceberg

**Habilidad — Cuerpo Puro**: No le bajan nada: no lo intimidan, exponen ni ralentizan.


**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Explosión | Normal | Físico | Área | 250 | 9.2 s |
| 9 | Viento Hielo | Hielo | Especial | Disparo | 55 | 1.7 s |
| 17 | Maldición | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 25 | Fuerza Bruta | Lucha | Físico | Embestida | 120 | 2.7 s |
| 33 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 41 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 49 | Electrocañón | Eléctrico | Especial | Disparo | 120 | 2.9 s |
| 57 | Fijar Blanco | Normal | Estado | Disparo | — | 8.0 s |
| 65 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

**Por MT/MO (23)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 379 Registeel

Acero · Pokémon Hierro

**Habilidad — Cuerpo Puro**: No le bajan nada: no lo intimidan, exponen ni ralentizan.


**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Explosión | Normal | Físico | Área | 250 | 9.2 s |
| 9 | Garra Metal | Acero | Físico | Golpe | 50 | 1.3 s |
| 17 | Maldición | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 25 | Fuerza Bruta | Lucha | Físico | Embestida | 120 | 2.7 s |
| 33 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 41 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 41 | Defensa Férrea | Acero | Estado | Mejora propia | — | 10.0 s |
| 49 | Electrocañón | Eléctrico | Especial | Disparo | 120 | 2.9 s |
| 57 | Fijar Blanco | Normal | Estado | Disparo | — | 8.0 s |
| 65 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

**Por MT/MO (24)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 380 Latias

Dragón/Psíquico · Pokémon Eón

**Habilidad — Levitación**: Flota: los ataques de Tierra no le hacen nada.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Psicoonda | Psíquico | Especial | Disparo | 60 | 1.8 s |
| 5 | Deseo | Normal | Estado | Mejora propia | — | 10.0 s |
| 10 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 15 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 20 | Dragoaliento | Dragón | Especial | Disparo | 60 | 1.8 s |
| 25 | Hidrochorro | Agua | Especial | Área | 15 | 6.0 s |
| 30 | Alivio | Normal | Estado | Mejora propia | — | 10.0 s |
| 35 | Bola Neblina | Psíquico | Especial | Disparo | 95 | 2.5 s |
| 40 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 45 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |
| 50 | Encanto | Hada | Estado | Área | — | 6.0 s |

**Por MT/MO (37)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 381 Latios

Dragón/Psíquico · Pokémon Eón

**Habilidad — Levitación**: Flota: los ataques de Tierra no le hacen nada.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Psicoonda | Psíquico | Especial | Disparo | 60 | 1.8 s |
| 5 | Legado | Siniestro | Estado | Área | — | 6.0 s |
| 10 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 15 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 20 | Dragoaliento | Dragón | Especial | Disparo | 60 | 1.8 s |
| 25 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 30 | Alivio | Normal | Estado | Mejora propia | — | 10.0 s |
| 35 | Resplandor | Psíquico | Especial | Disparo | 95 | 2.5 s |
| 40 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 45 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |
| 50 | Danza Dragón | Dragón | Estado | Mejora propia | — | 10.0 s |

**Por MT/MO (37)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Atracción | Normal | Estado | Área | — | 6.0 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Ala de Acero | Acero | Físico | Golpe | 70 | 1.5 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 382 Kyogre

Agua · Pokémon Cuenca Mar

**Habilidad — Llovizna**: Llueve a su alrededor: los rivales cerca quedan empapados.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| 5 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 15 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 20 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 30 | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 35 | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| 45 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |
| 50 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 60 | Frío Polar | Hielo | Especial | Disparo | 60 | 1.8 s |
| 65 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |
| 75 | Salpicar | Agua | Especial | Área | 150 | 6.3 s |

**Por MT/MO (29)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Granizo | Hielo | Estado | Mejora propia | — | 10.0 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 383 Groudon

Tierra · Pokémon Continente

**Habilidad — Sequía**: Sus golpes a veces queman (10%).


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Disparo Lodo | Tierra | Especial | Disparo | 55 | 1.7 s |
| 5 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 15 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 20 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 30 | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| 35 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 45 | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| 50 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 60 | Fisura | Tierra | Físico | Golpe | 60 | 1.4 s |
| 65 | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| 75 | Estallido | Fuego | Especial | Área | 150 | 6.3 s |

**Por MT/MO (32)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |

### 384 Rayquaza

Dragón/Volador · Pokémon Cielo

**Habilidad — Bucle Aire**: No lo empapan ni le afecta el clima del suelo (mojado, hielo).


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ciclón | Dragón | Especial | Área | 40 | 6.0 s |
| 5 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 15 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 20 | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| 30 | Danza Dragón | Dragón | Estado | Mejora propia | — | 10.0 s |
| 35 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 45 | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| 50 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 60 | Velocidad Extrema | Normal | Físico | Embestida | 80 | 2.1 s |
| 65 | Enfado | Dragón | Físico | Embestida | 120 | 2.7 s |
| 75 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

**Por MT/MO (36)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Ventisca | Hielo | Especial | Área | 110 | 5.2 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Corpulencia | Lucha | Estado | Mejora propia | — | 10.0 s |
| MT | Buceo | Agua | Físico | Embestida | 80 | 2.1 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Garra Dragón | Dragón | Físico | Embestida | 80 | 2.1 s |
| MT | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |
| MT | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| MT | Vuelo | Volador | Físico | Embestida | 90 | 2.3 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| MT | Sofoco | Fuego | Especial | Disparo | 130 | 3.1 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Rugido | Normal | Estado | Área | — | 6.0 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Surf | Agua | Especial | Área | 90 | 4.5 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| MT | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |

### 385 Jirachi

Acero/Psíquico · Pokémon Deseo

**Habilidad — Dicha**: Sus ataques con estado lo ponen el doble de seguido.


**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 1 | Deseo | Normal | Estado | Mejora propia | — | 10.0 s |
| 5 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 10 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 15 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 20 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 25 | Alivio | Normal | Estado | Mejora propia | — | 10.0 s |
| 35 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |
| 40 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |
| 45 | Masa Cósmica | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 50 | Deseo Oculto | Acero | Especial | Disparo | 140 | 3.3 s |

**Por MT/MO (26)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

### 386 Deoxys

Psíquico · Pokémon ADN

**Habilidad — Presión**: Cada golpe suyo le suma 0,3 s a las recargas del rival.


**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 5 | Tinieblas | Fantasma | Especial | Disparo | 60 | 1.8 s |
| 10 | Teletransporte | Psíquico | Estado | Embestida | — | 3.0 s |
| 15 | Desarme | Siniestro | Físico | Golpe | 65 | 1.4 s |
| 20 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 25 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 30 | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| 35 | Masa Cósmica | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 40 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |
| 45 | Psicoataque | Psíquico | Especial | Disparo | 140 | 3.3 s |
| 50 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

**Por MT/MO (36)**:

| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| MT | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| MT | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| MT | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Corte | Normal | Físico | Golpe | 50 | 1.3 s |
| MT | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Fachada | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Destello | Normal | Estado | Área | — | 6.0 s |
| MT | Puño Certero | Lucha | Físico | Embestida | 150 | 3.2 s |
| MT | Frustración | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |
| MT | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |
| MT | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| MT | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Protección | Normal | Estado | Defensa | — | 8.0 s |
| MT | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| MT | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| MT | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| MT | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| MT | Retribución | Normal | Físico | Golpe | 60 | 1.4 s |
| MT | Golpe Roca | Lucha | Físico | Golpe | 40 | 1.1 s |
| MT | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |
| MT | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| MT | Daño Secreto | Normal | Físico | Golpe | 70 | 1.5 s |
| MT | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| MT | Onda Voltio | Eléctrico | Especial | Disparo | 60 | 1.8 s |
| MT | Intercambio | Psíquico | Estado | Área | — | 6.0 s |
| MT | Robo | Siniestro | Estado | Mejora propia | — | 10.0 s |
| MT | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| MT | Fuerza | Normal | Físico | Embestida | 80 | 2.1 s |
| MT | Día Soleado | Fuego | Estado | Mejora propia | — | 10.0 s |
| MT | Mofa | Siniestro | Estado | Área | — | 6.0 s |
| MT | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| MT | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |
| MT | Tormento | Siniestro | Estado | Área | — | 6.0 s |
| MT | Tóxico | Veneno | Estado | Disparo | — | 6.0 s |
| MT | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |

