# Pokémon: kits y ataques que aprenden

> **Generado** por `tools/build_pokemon_docs.gd` (2026-10-28). No editar a mano: cambiar los kits/learnsets y volver a
> correr la herramienta. Kits: `docs/PLAN_IDENTIDAD_COMBATE.md` · salvajes por zona: `docs/SALVAJES_LISTADO.md`.

**386 especies** · kit propio: 86 · kit heredado de su preevolución: 69 · sin kit: 231 · aparecen hoy en el juego: 135.

Teclas del kit: Clic izq. · Clic der. · Q · R (el de más recarga) + Espacio (esquive, igual para todos). Los ataques
del learnset se equipan desde la ficha del Pokémon (Esc → Equipo). "Sin kit" = pelea con 4 ataques de su learnset y
sin mecánica de firma.

## Índice

| N.º | Pokémon | Tipos | Kit | Estilo | Firma | ¿En el juego? |
|---|---|---|---|---|---|---|
| 001 | [Bulbasaur](#001-bulbasaur) | Planta/Veneno | propio | control | — | sí |
| 002 | [Ivysaur](#002-ivysaur) | Planta/Veneno | heredado de Bulbasaur | control | — | sí |
| 003 | [Venusaur](#003-venusaur) | Planta/Veneno | heredado de Bulbasaur | control | — | sí |
| 004 | [Charmander](#004-charmander) | Fuego | propio | bruiser | Calor | sí |
| 005 | [Charmeleon](#005-charmeleon) | Fuego | heredado de Charmander | bruiser | Calor | sí |
| 006 | [Charizard](#006-charizard) | Fuego/Volador | propio | bruiser | Calor | sí |
| 007 | [Squirtle](#007-squirtle) | Agua | propio | tanque | Presión | sí |
| 008 | [Wartortle](#008-wartortle) | Agua | heredado de Squirtle | tanque | Presión | sí |
| 009 | [Blastoise](#009-blastoise) | Agua | heredado de Squirtle | tanque | Presión | sí |
| 010 | [Caterpie](#010-caterpie) | Bicho | propio | control | Seda | sí |
| 011 | [Metapod](#011-metapod) | Bicho | propio | tanque | Capullo | sí |
| 012 | [Butterfree](#012-butterfree) | Bicho/Volador | propio | control | Alas de Polvo | sí |
| 013 | [Weedle](#013-weedle) | Bicho/Veneno | propio | asesino | Aguijón Venenoso | sí |
| 014 | [Kakuna](#014-kakuna) | Bicho/Veneno | propio | tanque | Capullo Venenoso | sí |
| 015 | [Beedrill](#015-beedrill) | Bicho/Veneno | propio | asesino | Aguijón Letal | sí |
| 016 | [Pidgey](#016-pidgey) | Normal/Volador | propio | hostigador | Aliento | sí |
| 017 | [Pidgeotto](#017-pidgeotto) | Normal/Volador | heredado de Pidgey | hostigador | Aliento | sí |
| 018 | [Pidgeot](#018-pidgeot) | Normal/Volador | heredado de Pidgey | hostigador | Aliento | sí |
| 019 | [Rattata](#019-rattata) | Normal | propio | asesino | Instinto | sí |
| 020 | [Raticate](#020-raticate) | Normal | heredado de Rattata | asesino | Instinto | sí |
| 021 | [Spearow](#021-spearow) | Normal/Volador | propio | asesino | Furia | sí |
| 022 | [Fearow](#022-fearow) | Normal/Volador | heredado de Spearow | asesino | Furia | sí |
| 023 | [Ekans](#023-ekans) | Veneno | propio | control | Enroscarse | sí |
| 024 | [Arbok](#024-arbok) | Veneno | heredado de Ekans | control | Enroscarse | sí |
| 025 | [Pikachu](#025-pikachu) | Eléctrico | propio | velocista | Estática | sí |
| 026 | [Raichu](#026-raichu) | Eléctrico | propio | bruiser | Toma de Tierra | sí |
| 027 | [Sandshrew](#027-sandshrew) | Tierra | propio | control | Velo Arena | sí |
| 028 | [Sandslash](#028-sandslash) | Tierra | heredado de Sandshrew | control | Velo Arena | sí |
| 029 | [Nidoran♀](#029-nidoran) | Veneno | propio | bruiser | Púas Venenosas | sí |
| 030 | [Nidorina](#030-nidorina) | Veneno | heredado de Nidoran♀ | bruiser | Púas Venenosas | sí |
| 031 | [Nidoqueen](#031-nidoqueen) | Veneno/Tierra | heredado de Nidoran♀ | bruiser | Púas Venenosas | sí |
| 032 | [Nidoran♂](#032-nidoran) | Veneno | propio | asesino | Oído Fino | sí |
| 033 | [Nidorino](#033-nidorino) | Veneno | heredado de Nidoran♂ | asesino | Oído Fino | sí |
| 034 | [Nidoking](#034-nidoking) | Veneno/Tierra | heredado de Nidoran♂ | asesino | Oído Fino | sí |
| 035 | [Clefairy](#035-clefairy) | Hada | propio | caotico | Luz de Luna | sí |
| 036 | [Clefable](#036-clefable) | Hada | heredado de Clefairy | caotico | Luz de Luna |  |
| 037 | [Vulpix](#037-vulpix) | Fuego | propio | desgaste | Rescoldo | sí |
| 038 | [Ninetales](#038-ninetales) | Fuego | heredado de Vulpix | desgaste | Rescoldo | sí |
| 039 | [Jigglypuff](#039-jigglypuff) | Normal/Hada | propio | control | Inflado y Marcador | sí |
| 040 | [Wigglytuff](#040-wigglytuff) | Normal/Hada | heredado de Jigglypuff | control | Inflado y Marcador | sí |
| 041 | [Zubat](#041-zubat) | Veneno/Volador | propio | hostigador | Ecolocalización | sí |
| 042 | [Golbat](#042-golbat) | Veneno/Volador | heredado de Zubat | hostigador | Ecolocalización | sí |
| 043 | [Oddish](#043-oddish) | Planta/Veneno | propio | desgaste | Esporas | sí |
| 044 | [Gloom](#044-gloom) | Planta/Veneno | heredado de Oddish | desgaste | Esporas | sí |
| 045 | [Vileplume](#045-vileplume) | Planta/Veneno | heredado de Oddish | desgaste | Esporas | sí |
| 046 | [Paras](#046-paras) | Bicho/Planta | propio | control | — | sí |
| 047 | [Parasect](#047-parasect) | Bicho/Planta | heredado de Paras | control | — | sí |
| 048 | [Venonat](#048-venonat) | Bicho/Veneno | propio | control | Ojos Compuestos | sí |
| 049 | [Venomoth](#049-venomoth) | Bicho/Veneno | heredado de Venonat | control | Ojos Compuestos | sí |
| 050 | [Diglett](#050-diglett) | Tierra | propio | hostigador | Bajo Tierra | sí |
| 051 | [Dugtrio](#051-dugtrio) | Tierra | heredado de Diglett | hostigador | Bajo Tierra | sí |
| 052 | [Meowth](#052-meowth) | Normal | propio | asesino | Día de Pago | sí |
| 053 | [Persian](#053-persian) | Normal | heredado de Meowth | asesino | Día de Pago | sí |
| 054 | [Psyduck](#054-psyduck) | Agua | propio | caotico | Jaqueca | sí |
| 055 | [Golduck](#055-golduck) | Agua | heredado de Psyduck | caotico | Jaqueca | sí |
| 056 | [Mankey](#056-mankey) | Lucha | propio | bruiser | Rabia | sí |
| 057 | [Primeape](#057-primeape) | Lucha | heredado de Mankey | bruiser | Rabia | sí |
| 058 | [Growlithe](#058-growlithe) | Fuego | propio | perseguidor | Rastreo | sí |
| 059 | [Arcanine](#059-arcanine) | Fuego | heredado de Growlithe | perseguidor | Rastreo | sí |
| 060 | [Poliwag](#060-poliwag) | Agua | propio | velocista | Deslizamiento | sí |
| 061 | [Poliwhirl](#061-poliwhirl) | Agua | heredado de Poliwag | velocista | Deslizamiento | sí |
| 062 | [Poliwrath](#062-poliwrath) | Agua/Lucha | heredado de Poliwag | velocista | Deslizamiento |  |
| 063 | [Abra](#063-abra) | Psíquico | propio | velocista | Sueño Vigilante | sí |
| 064 | [Kadabra](#064-kadabra) | Psíquico | propio | control | Mente Rápida | sí |
| 065 | [Alakazam](#065-alakazam) | Psíquico | heredado de Kadabra | control | Mente Rápida | sí |
| 066 | [Machop](#066-machop) | Lucha | propio | bruiser | Incansable | sí |
| 067 | [Machoke](#067-machoke) | Lucha | heredado de Machop | bruiser | Incansable | sí |
| 068 | [Machamp](#068-machamp) | Lucha | heredado de Machop | bruiser | Incansable | sí |
| 069 | [Bellsprout](#069-bellsprout) | Planta/Veneno | propio | control | — | sí |
| 070 | [Weepinbell](#070-weepinbell) | Planta/Veneno | heredado de Bellsprout | control | — | sí |
| 071 | [Victreebel](#071-victreebel) | Planta/Veneno | heredado de Bellsprout | control | — | sí |
| 072 | [Tentacool](#072-tentacool) | Agua/Veneno | propio | control | Cuerpo de Agua | sí |
| 073 | [Tentacruel](#073-tentacruel) | Agua/Veneno | heredado de Tentacool | control | Cuerpo de Agua | sí |
| 074 | [Geodude](#074-geodude) | Roca/Tierra | propio | tanque | Impulso | sí |
| 075 | [Graveler](#075-graveler) | Roca/Tierra | heredado de Geodude | tanque | Impulso | sí |
| 076 | [Golem](#076-golem) | Roca/Tierra | heredado de Geodude | tanque | Impulso |  |
| 077 | [Ponyta](#077-ponyta) | Fuego | propio | velocista | Galope | sí |
| 078 | [Rapidash](#078-rapidash) | Fuego | heredado de Ponyta | velocista | Galope | sí |
| 079 | [Slowpoke](#079-slowpoke) | Agua/Psíquico | propio | tanque | Reacción Tardía | sí |
| 080 | [Slowbro](#080-slowbro) | Agua/Psíquico | heredado de Slowpoke | tanque | Reacción Tardía | sí |
| 081 | [Magnemite](#081-magnemite) | Eléctrico/Acero | propio | espaciador | Magnetismo | sí |
| 082 | [Magneton](#082-magneton) | Eléctrico/Acero | heredado de Magnemite | espaciador | Magnetismo | sí |
| 083 | [Farfetch’d](#083-farfetchd) | Normal/Volador | propio | asesino | Puerro | sí |
| 084 | [Doduo](#084-doduo) | Normal/Volador | propio | velocista | Carrera | sí |
| 085 | [Dodrio](#085-dodrio) | Normal/Volador | heredado de Doduo | velocista | Carrera | sí |
| 086 | [Seel](#086-seel) | Agua | propio | tanque | Escarcha | sí |
| 087 | [Dewgong](#087-dewgong) | Agua/Hielo | heredado de Seel | tanque | Escarcha | sí |
| 088 | [Grimer](#088-grimer) | Veneno | propio | tanque | Cuerpo de Lodo | sí |
| 089 | [Muk](#089-muk) | Veneno | heredado de Grimer | tanque | Cuerpo de Lodo | sí |
| 090 | [Shellder](#090-shellder) | Agua | propio | tanque | Concha Bivalva | sí |
| 091 | [Cloyster](#091-cloyster) | Agua/Hielo | heredado de Shellder | tanque | Concha Bivalva | sí |
| 092 | [Gastly](#092-gastly) | Fantasma/Veneno | propio | hostigador | Pesadilla | sí |
| 093 | [Haunter](#093-haunter) | Fantasma/Veneno | heredado de Gastly | hostigador | Pesadilla | sí |
| 094 | [Gengar](#094-gengar) | Fantasma/Veneno | heredado de Gastly | hostigador | Pesadilla | sí |
| 095 | [Onix](#095-onix) | Roca/Tierra | propio | tanque | Coloso | sí |
| 096 | [Drowzee](#096-drowzee) | Psíquico | propio | control | Hipnosis Acumulable | sí |
| 097 | [Hypno](#097-hypno) | Psíquico | heredado de Drowzee | control | Hipnosis Acumulable | sí |
| 098 | [Krabby](#098-krabby) | Agua | propio | bruiser | Pinza |  |
| 099 | [Kingler](#099-kingler) | Agua | heredado de Krabby | bruiser | Pinza | sí |
| 100 | [Voltorb](#100-voltorb) | Eléctrico | propio | hostigador | Camuflaje | sí |
| 101 | [Electrode](#101-electrode) | Eléctrico | heredado de Voltorb | hostigador | Camuflaje | sí |
| 102 | [Exeggcute](#102-exeggcute) | Planta/Psíquico | propio | control | Racimo | sí |
| 103 | [Exeggutor](#103-exeggutor) | Planta/Psíquico | heredado de Exeggcute | control | Racimo | sí |
| 104 | [Cubone](#104-cubone) | Tierra | propio | bruiser | Casco de Hueso | sí |
| 105 | [Marowak](#105-marowak) | Tierra | heredado de Cubone | bruiser | Casco de Hueso | sí |
| 106 | [Hitmonlee](#106-hitmonlee) | Lucha | propio | asesino | Piernas Elásticas | sí |
| 107 | [Hitmonchan](#107-hitmonchan) | Lucha | propio | bruiser | Juego de Pies | sí |
| 108 | [Lickitung](#108-lickitung) | Normal | propio | tanque | Lengua Larga | sí |
| 109 | [Koffing](#109-koffing) | Veneno | propio | control | Gas Inflamable | sí |
| 110 | [Weezing](#110-weezing) | Veneno | heredado de Koffing | control | Gas Inflamable | sí |
| 111 | [Rhyhorn](#111-rhyhorn) | Tierra/Roca | propio | tanque | Piel de Roca | sí |
| 112 | [Rhydon](#112-rhydon) | Tierra/Roca | heredado de Rhyhorn | tanque | Piel de Roca | sí |
| 113 | [Chansey](#113-chansey) | Normal | propio | tanque | Huevo Suerte | sí |
| 114 | [Tangela](#114-tangela) | Planta | propio | control | Maraña | sí |
| 115 | [Kangaskhan](#115-kangaskhan) | Normal | propio | bruiser | Cría | sí |
| 116 | [Horsea](#116-horsea) | Agua | propio | espaciador | Ancla | sí |
| 117 | [Seadra](#117-seadra) | Agua | heredado de Horsea | espaciador | Ancla | sí |
| 118 | [Goldeen](#118-goldeen) | Agua | propio | perseguidor | Cuerno Perforador | sí |
| 119 | [Seaking](#119-seaking) | Agua | heredado de Goldeen | perseguidor | Cuerno Perforador | sí |
| 120 | [Staryu](#120-staryu) | Agua | propio | velocista | Núcleo | sí |
| 121 | [Starmie](#121-starmie) | Agua/Psíquico | propio | control | Núcleo Prisma | sí |
| 122 | [Mr. Mime](#122-mr-mime) | Psíquico/Hada | propio | control | Pantomima | sí |
| 123 | [Scyther](#123-scyther) | Bicho/Volador | propio | asesino | Filo Furioso | sí |
| 124 | [Jynx](#124-jynx) | Hielo/Psíquico | propio | control | Canción de Cuna | sí |
| 125 | [Electabuzz](#125-electabuzz) | Eléctrico | propio | bruiser | Electromotor | sí |
| 126 | [Magmar](#126-magmar) | Fuego | sin kit | — | — |  |
| 127 | [Pinsir](#127-pinsir) | Bicho | sin kit | — | — |  |
| 128 | [Tauros](#128-tauros) | Normal | propio | bruiser | Estampida | sí |
| 129 | [Magikarp](#129-magikarp) | Agua | propio | caotico | Determinación | sí |
| 130 | [Gyarados](#130-gyarados) | Agua/Volador | propio | bruiser | Ira de Dragón | sí |
| 131 | [Lapras](#131-lapras) | Agua/Hielo | propio | tanque | Aliento Helado | sí |
| 132 | [Ditto](#132-ditto) | Normal | propio | caotico | Transformación | sí |
| 133 | [Eevee](#133-eevee) | Normal | propio | adaptativo | Adaptación | sí |
| 134 | [Vaporeon](#134-vaporeon) | Agua | propio | tanque | Absorbe Agua |  |
| 135 | [Jolteon](#135-jolteon) | Eléctrico | propio | velocista | Absorbe Electricidad |  |
| 136 | [Flareon](#136-flareon) | Fuego | propio | bruiser | Absorbe Fuego |  |
| 137 | [Porygon](#137-porygon) | Normal | propio | control | Conversión |  |
| 138 | [Omanyte](#138-omanyte) | Roca/Agua | propio | control | Espiral | sí |
| 139 | [Omastar](#139-omastar) | Roca/Agua | heredado de Omanyte | control | Espiral |  |
| 140 | [Kabuto](#140-kabuto) | Roca/Agua | propio | hostigador | Caparazón Fósil | sí |
| 141 | [Kabutops](#141-kabutops) | Roca/Agua | heredado de Kabuto | hostigador | Caparazón Fósil |  |
| 142 | [Aerodactyl](#142-aerodactyl) | Roca/Volador | propio | asesino | Vuelo Prehistórico | sí |
| 143 | [Snorlax](#143-snorlax) | Normal | propio | tanque | Panza | sí |
| 144 | [Articuno](#144-articuno) | Hielo/Volador | propio | control | Ave Helada | sí |
| 145 | [Zapdos](#145-zapdos) | Eléctrico/Volador | propio | bruiser | Ave Trueno | sí |
| 146 | [Moltres](#146-moltres) | Fuego/Volador | sin kit | — | — |  |
| 147 | [Dratini](#147-dratini) | Dragón | propio | control | Muda |  |
| 148 | [Dragonair](#148-dragonair) | Dragón | heredado de Dratini | control | Muda | sí |
| 149 | [Dragonite](#149-dragonite) | Dragón/Volador | heredado de Dratini | control | Muda | sí |
| 150 | [Mewtwo](#150-mewtwo) | Psíquico | sin kit | — | — |  |
| 151 | [Mew](#151-mew) | Psíquico | sin kit | — | — |  |
| 152 | [Chikorita](#152-chikorita) | Planta | sin kit | — | — |  |
| 153 | [Bayleef](#153-bayleef) | Planta | sin kit | — | — |  |
| 154 | [Meganium](#154-meganium) | Planta | sin kit | — | — |  |
| 155 | [Cyndaquil](#155-cyndaquil) | Fuego | sin kit | — | — |  |
| 156 | [Quilava](#156-quilava) | Fuego | sin kit | — | — |  |
| 157 | [Typhlosion](#157-typhlosion) | Fuego | sin kit | — | — |  |
| 158 | [Totodile](#158-totodile) | Agua | sin kit | — | — |  |
| 159 | [Croconaw](#159-croconaw) | Agua | sin kit | — | — |  |
| 160 | [Feraligatr](#160-feraligatr) | Agua | sin kit | — | — |  |
| 161 | [Sentret](#161-sentret) | Normal | sin kit | — | — |  |
| 162 | [Furret](#162-furret) | Normal | sin kit | — | — |  |
| 163 | [Hoothoot](#163-hoothoot) | Normal/Volador | sin kit | — | — |  |
| 164 | [Noctowl](#164-noctowl) | Normal/Volador | sin kit | — | — |  |
| 165 | [Ledyba](#165-ledyba) | Bicho/Volador | sin kit | — | — |  |
| 166 | [Ledian](#166-ledian) | Bicho/Volador | sin kit | — | — |  |
| 167 | [Spinarak](#167-spinarak) | Bicho/Veneno | sin kit | — | — |  |
| 168 | [Ariados](#168-ariados) | Bicho/Veneno | sin kit | — | — |  |
| 169 | [Crobat](#169-crobat) | Veneno/Volador | heredado de Zubat | hostigador | Ecolocalización |  |
| 170 | [Chinchou](#170-chinchou) | Agua/Eléctrico | sin kit | — | — |  |
| 171 | [Lanturn](#171-lanturn) | Agua/Eléctrico | sin kit | — | — |  |
| 172 | [Pichu](#172-pichu) | Eléctrico | sin kit | — | — |  |
| 173 | [Cleffa](#173-cleffa) | Hada | sin kit | — | — |  |
| 174 | [Igglybuff](#174-igglybuff) | Normal/Hada | sin kit | — | — |  |
| 175 | [Togepi](#175-togepi) | Hada | sin kit | — | — |  |
| 176 | [Togetic](#176-togetic) | Hada/Volador | sin kit | — | — |  |
| 177 | [Natu](#177-natu) | Psíquico/Volador | sin kit | — | — |  |
| 178 | [Xatu](#178-xatu) | Psíquico/Volador | sin kit | — | — |  |
| 179 | [Mareep](#179-mareep) | Eléctrico | sin kit | — | — |  |
| 180 | [Flaaffy](#180-flaaffy) | Eléctrico | sin kit | — | — |  |
| 181 | [Ampharos](#181-ampharos) | Eléctrico | sin kit | — | — |  |
| 182 | [Bellossom](#182-bellossom) | Planta | heredado de Oddish | desgaste | Esporas |  |
| 183 | [Marill](#183-marill) | Agua/Hada | sin kit | — | — |  |
| 184 | [Azumarill](#184-azumarill) | Agua/Hada | sin kit | — | — |  |
| 185 | [Sudowoodo](#185-sudowoodo) | Roca | sin kit | — | — |  |
| 186 | [Politoed](#186-politoed) | Agua | heredado de Poliwag | velocista | Deslizamiento |  |
| 187 | [Hoppip](#187-hoppip) | Planta/Volador | sin kit | — | — |  |
| 188 | [Skiploom](#188-skiploom) | Planta/Volador | sin kit | — | — |  |
| 189 | [Jumpluff](#189-jumpluff) | Planta/Volador | sin kit | — | — |  |
| 190 | [Aipom](#190-aipom) | Normal | sin kit | — | — |  |
| 191 | [Sunkern](#191-sunkern) | Planta | sin kit | — | — |  |
| 192 | [Sunflora](#192-sunflora) | Planta | sin kit | — | — |  |
| 193 | [Yanma](#193-yanma) | Bicho/Volador | sin kit | — | — |  |
| 194 | [Wooper](#194-wooper) | Agua/Tierra | sin kit | — | — |  |
| 195 | [Quagsire](#195-quagsire) | Agua/Tierra | sin kit | — | — |  |
| 196 | [Espeon](#196-espeon) | Psíquico | sin kit | — | — |  |
| 197 | [Umbreon](#197-umbreon) | Siniestro | sin kit | — | — |  |
| 198 | [Murkrow](#198-murkrow) | Siniestro/Volador | sin kit | — | — |  |
| 199 | [Slowking](#199-slowking) | Agua/Psíquico | heredado de Slowpoke | tanque | Reacción Tardía |  |
| 200 | [Misdreavus](#200-misdreavus) | Fantasma | sin kit | — | — |  |
| 201 | [Unown](#201-unown) | Psíquico | sin kit | — | — |  |
| 202 | [Wobbuffet](#202-wobbuffet) | Psíquico | sin kit | — | — |  |
| 203 | [Girafarig](#203-girafarig) | Normal/Psíquico | sin kit | — | — |  |
| 204 | [Pineco](#204-pineco) | Bicho | sin kit | — | — |  |
| 205 | [Forretress](#205-forretress) | Bicho/Acero | sin kit | — | — |  |
| 206 | [Dunsparce](#206-dunsparce) | Normal | sin kit | — | — |  |
| 207 | [Gligar](#207-gligar) | Tierra/Volador | sin kit | — | — |  |
| 208 | [Steelix](#208-steelix) | Acero/Tierra | heredado de Onix | tanque | Coloso |  |
| 209 | [Snubbull](#209-snubbull) | Hada | sin kit | — | — |  |
| 210 | [Granbull](#210-granbull) | Hada | sin kit | — | — |  |
| 211 | [Qwilfish](#211-qwilfish) | Agua/Veneno | sin kit | — | — |  |
| 212 | [Scizor](#212-scizor) | Bicho/Acero | heredado de Scyther | asesino | Filo Furioso |  |
| 213 | [Shuckle](#213-shuckle) | Bicho/Roca | sin kit | — | — |  |
| 214 | [Heracross](#214-heracross) | Bicho/Lucha | sin kit | — | — |  |
| 215 | [Sneasel](#215-sneasel) | Siniestro/Hielo | sin kit | — | — |  |
| 216 | [Teddiursa](#216-teddiursa) | Normal | sin kit | — | — |  |
| 217 | [Ursaring](#217-ursaring) | Normal | sin kit | — | — |  |
| 218 | [Slugma](#218-slugma) | Fuego | sin kit | — | — |  |
| 219 | [Magcargo](#219-magcargo) | Fuego/Roca | sin kit | — | — |  |
| 220 | [Swinub](#220-swinub) | Hielo/Tierra | sin kit | — | — |  |
| 221 | [Piloswine](#221-piloswine) | Hielo/Tierra | sin kit | — | — |  |
| 222 | [Corsola](#222-corsola) | Agua/Roca | sin kit | — | — |  |
| 223 | [Remoraid](#223-remoraid) | Agua | sin kit | — | — |  |
| 224 | [Octillery](#224-octillery) | Agua | sin kit | — | — |  |
| 225 | [Delibird](#225-delibird) | Hielo/Volador | sin kit | — | — |  |
| 226 | [Mantine](#226-mantine) | Agua/Volador | sin kit | — | — |  |
| 227 | [Skarmory](#227-skarmory) | Acero/Volador | sin kit | — | — |  |
| 228 | [Houndour](#228-houndour) | Siniestro/Fuego | sin kit | — | — |  |
| 229 | [Houndoom](#229-houndoom) | Siniestro/Fuego | sin kit | — | — |  |
| 230 | [Kingdra](#230-kingdra) | Agua/Dragón | heredado de Horsea | espaciador | Ancla |  |
| 231 | [Phanpy](#231-phanpy) | Tierra | sin kit | — | — |  |
| 232 | [Donphan](#232-donphan) | Tierra | sin kit | — | — |  |
| 233 | [Porygon2](#233-porygon2) | Normal | heredado de Porygon | control | Conversión |  |
| 234 | [Stantler](#234-stantler) | Normal | sin kit | — | — |  |
| 235 | [Smeargle](#235-smeargle) | Normal | sin kit | — | — |  |
| 236 | [Tyrogue](#236-tyrogue) | Lucha | sin kit | — | — |  |
| 237 | [Hitmontop](#237-hitmontop) | Lucha | sin kit | — | — |  |
| 238 | [Smoochum](#238-smoochum) | Hielo/Psíquico | sin kit | — | — |  |
| 239 | [Elekid](#239-elekid) | Eléctrico | sin kit | — | — |  |
| 240 | [Magby](#240-magby) | Fuego | sin kit | — | — |  |
| 241 | [Miltank](#241-miltank) | Normal | sin kit | — | — |  |
| 242 | [Blissey](#242-blissey) | Normal | heredado de Chansey | tanque | Huevo Suerte |  |
| 243 | [Raikou](#243-raikou) | Eléctrico | sin kit | — | — |  |
| 244 | [Entei](#244-entei) | Fuego | sin kit | — | — |  |
| 245 | [Suicune](#245-suicune) | Agua | sin kit | — | — |  |
| 246 | [Larvitar](#246-larvitar) | Roca/Tierra | sin kit | — | — |  |
| 247 | [Pupitar](#247-pupitar) | Roca/Tierra | sin kit | — | — |  |
| 248 | [Tyranitar](#248-tyranitar) | Roca/Siniestro | sin kit | — | — |  |
| 249 | [Lugia](#249-lugia) | Psíquico/Volador | sin kit | — | — |  |
| 250 | [Ho-Oh](#250-hooh) | Fuego/Volador | sin kit | — | — |  |
| 251 | [Celebi](#251-celebi) | Psíquico/Planta | sin kit | — | — |  |
| 252 | [Treecko](#252-treecko) | Planta | sin kit | — | — |  |
| 253 | [Grovyle](#253-grovyle) | Planta | sin kit | — | — |  |
| 254 | [Sceptile](#254-sceptile) | Planta | sin kit | — | — |  |
| 255 | [Torchic](#255-torchic) | Fuego | sin kit | — | — |  |
| 256 | [Combusken](#256-combusken) | Fuego/Lucha | sin kit | — | — |  |
| 257 | [Blaziken](#257-blaziken) | Fuego/Lucha | sin kit | — | — |  |
| 258 | [Mudkip](#258-mudkip) | Agua | sin kit | — | — |  |
| 259 | [Marshtomp](#259-marshtomp) | Agua/Tierra | sin kit | — | — |  |
| 260 | [Swampert](#260-swampert) | Agua/Tierra | sin kit | — | — |  |
| 261 | [Poochyena](#261-poochyena) | Siniestro | sin kit | — | — |  |
| 262 | [Mightyena](#262-mightyena) | Siniestro | sin kit | — | — |  |
| 263 | [Zigzagoon](#263-zigzagoon) | Normal | sin kit | — | — |  |
| 264 | [Linoone](#264-linoone) | Normal | sin kit | — | — |  |
| 265 | [Wurmple](#265-wurmple) | Bicho | sin kit | — | — |  |
| 266 | [Silcoon](#266-silcoon) | Bicho | sin kit | — | — |  |
| 267 | [Beautifly](#267-beautifly) | Bicho/Volador | sin kit | — | — |  |
| 268 | [Cascoon](#268-cascoon) | Bicho | sin kit | — | — |  |
| 269 | [Dustox](#269-dustox) | Bicho/Veneno | sin kit | — | — |  |
| 270 | [Lotad](#270-lotad) | Agua/Planta | sin kit | — | — |  |
| 271 | [Lombre](#271-lombre) | Agua/Planta | sin kit | — | — |  |
| 272 | [Ludicolo](#272-ludicolo) | Agua/Planta | sin kit | — | — |  |
| 273 | [Seedot](#273-seedot) | Planta | sin kit | — | — |  |
| 274 | [Nuzleaf](#274-nuzleaf) | Planta/Siniestro | sin kit | — | — |  |
| 275 | [Shiftry](#275-shiftry) | Planta/Siniestro | sin kit | — | — |  |
| 276 | [Taillow](#276-taillow) | Normal/Volador | sin kit | — | — |  |
| 277 | [Swellow](#277-swellow) | Normal/Volador | sin kit | — | — |  |
| 278 | [Wingull](#278-wingull) | Agua/Volador | sin kit | — | — |  |
| 279 | [Pelipper](#279-pelipper) | Agua/Volador | sin kit | — | — |  |
| 280 | [Ralts](#280-ralts) | Psíquico/Hada | sin kit | — | — |  |
| 281 | [Kirlia](#281-kirlia) | Psíquico/Hada | sin kit | — | — |  |
| 282 | [Gardevoir](#282-gardevoir) | Psíquico/Hada | sin kit | — | — |  |
| 283 | [Surskit](#283-surskit) | Bicho/Agua | sin kit | — | — |  |
| 284 | [Masquerain](#284-masquerain) | Bicho/Volador | sin kit | — | — |  |
| 285 | [Shroomish](#285-shroomish) | Planta | sin kit | — | — |  |
| 286 | [Breloom](#286-breloom) | Planta/Lucha | sin kit | — | — |  |
| 287 | [Slakoth](#287-slakoth) | Normal | sin kit | — | — |  |
| 288 | [Vigoroth](#288-vigoroth) | Normal | sin kit | — | — |  |
| 289 | [Slaking](#289-slaking) | Normal | sin kit | — | — |  |
| 290 | [Nincada](#290-nincada) | Bicho/Tierra | sin kit | — | — |  |
| 291 | [Ninjask](#291-ninjask) | Bicho/Volador | sin kit | — | — |  |
| 292 | [Shedinja](#292-shedinja) | Bicho/Fantasma | sin kit | — | — |  |
| 293 | [Whismur](#293-whismur) | Normal | sin kit | — | — |  |
| 294 | [Loudred](#294-loudred) | Normal | sin kit | — | — |  |
| 295 | [Exploud](#295-exploud) | Normal | sin kit | — | — |  |
| 296 | [Makuhita](#296-makuhita) | Lucha | sin kit | — | — |  |
| 297 | [Hariyama](#297-hariyama) | Lucha | sin kit | — | — |  |
| 298 | [Azurill](#298-azurill) | Normal/Hada | sin kit | — | — |  |
| 299 | [Nosepass](#299-nosepass) | Roca | sin kit | — | — |  |
| 300 | [Skitty](#300-skitty) | Normal | sin kit | — | — |  |
| 301 | [Delcatty](#301-delcatty) | Normal | sin kit | — | — |  |
| 302 | [Sableye](#302-sableye) | Siniestro/Fantasma | sin kit | — | — |  |
| 303 | [Mawile](#303-mawile) | Acero/Hada | sin kit | — | — |  |
| 304 | [Aron](#304-aron) | Acero/Roca | sin kit | — | — |  |
| 305 | [Lairon](#305-lairon) | Acero/Roca | sin kit | — | — |  |
| 306 | [Aggron](#306-aggron) | Acero/Roca | sin kit | — | — |  |
| 307 | [Meditite](#307-meditite) | Lucha/Psíquico | sin kit | — | — |  |
| 308 | [Medicham](#308-medicham) | Lucha/Psíquico | sin kit | — | — |  |
| 309 | [Electrike](#309-electrike) | Eléctrico | sin kit | — | — |  |
| 310 | [Manectric](#310-manectric) | Eléctrico | sin kit | — | — |  |
| 311 | [Plusle](#311-plusle) | Eléctrico | sin kit | — | — |  |
| 312 | [Minun](#312-minun) | Eléctrico | sin kit | — | — |  |
| 313 | [Volbeat](#313-volbeat) | Bicho | sin kit | — | — |  |
| 314 | [Illumise](#314-illumise) | Bicho | sin kit | — | — |  |
| 315 | [Roselia](#315-roselia) | Planta/Veneno | sin kit | — | — |  |
| 316 | [Gulpin](#316-gulpin) | Veneno | sin kit | — | — |  |
| 317 | [Swalot](#317-swalot) | Veneno | sin kit | — | — |  |
| 318 | [Carvanha](#318-carvanha) | Agua/Siniestro | sin kit | — | — |  |
| 319 | [Sharpedo](#319-sharpedo) | Agua/Siniestro | sin kit | — | — |  |
| 320 | [Wailmer](#320-wailmer) | Agua | sin kit | — | — |  |
| 321 | [Wailord](#321-wailord) | Agua | sin kit | — | — |  |
| 322 | [Numel](#322-numel) | Fuego/Tierra | sin kit | — | — |  |
| 323 | [Camerupt](#323-camerupt) | Fuego/Tierra | sin kit | — | — |  |
| 324 | [Torkoal](#324-torkoal) | Fuego | sin kit | — | — |  |
| 325 | [Spoink](#325-spoink) | Psíquico | sin kit | — | — |  |
| 326 | [Grumpig](#326-grumpig) | Psíquico | sin kit | — | — |  |
| 327 | [Spinda](#327-spinda) | Normal | sin kit | — | — |  |
| 328 | [Trapinch](#328-trapinch) | Tierra | sin kit | — | — |  |
| 329 | [Vibrava](#329-vibrava) | Tierra/Dragón | sin kit | — | — |  |
| 330 | [Flygon](#330-flygon) | Tierra/Dragón | sin kit | — | — |  |
| 331 | [Cacnea](#331-cacnea) | Planta | sin kit | — | — |  |
| 332 | [Cacturne](#332-cacturne) | Planta/Siniestro | sin kit | — | — |  |
| 333 | [Swablu](#333-swablu) | Normal/Volador | sin kit | — | — |  |
| 334 | [Altaria](#334-altaria) | Dragón/Volador | sin kit | — | — |  |
| 335 | [Zangoose](#335-zangoose) | Normal | sin kit | — | — |  |
| 336 | [Seviper](#336-seviper) | Veneno | sin kit | — | — |  |
| 337 | [Lunatone](#337-lunatone) | Roca/Psíquico | sin kit | — | — |  |
| 338 | [Solrock](#338-solrock) | Roca/Psíquico | sin kit | — | — |  |
| 339 | [Barboach](#339-barboach) | Agua/Tierra | sin kit | — | — |  |
| 340 | [Whiscash](#340-whiscash) | Agua/Tierra | sin kit | — | — |  |
| 341 | [Corphish](#341-corphish) | Agua | sin kit | — | — |  |
| 342 | [Crawdaunt](#342-crawdaunt) | Agua/Siniestro | sin kit | — | — |  |
| 343 | [Baltoy](#343-baltoy) | Tierra/Psíquico | sin kit | — | — |  |
| 344 | [Claydol](#344-claydol) | Tierra/Psíquico | sin kit | — | — |  |
| 345 | [Lileep](#345-lileep) | Roca/Planta | sin kit | — | — |  |
| 346 | [Cradily](#346-cradily) | Roca/Planta | sin kit | — | — |  |
| 347 | [Anorith](#347-anorith) | Roca/Bicho | sin kit | — | — |  |
| 348 | [Armaldo](#348-armaldo) | Roca/Bicho | sin kit | — | — |  |
| 349 | [Feebas](#349-feebas) | Agua | sin kit | — | — |  |
| 350 | [Milotic](#350-milotic) | Agua | sin kit | — | — |  |
| 351 | [Castform](#351-castform) | Normal | sin kit | — | — |  |
| 352 | [Kecleon](#352-kecleon) | Normal | sin kit | — | — |  |
| 353 | [Shuppet](#353-shuppet) | Fantasma | sin kit | — | — |  |
| 354 | [Banette](#354-banette) | Fantasma | sin kit | — | — |  |
| 355 | [Duskull](#355-duskull) | Fantasma | sin kit | — | — |  |
| 356 | [Dusclops](#356-dusclops) | Fantasma | sin kit | — | — |  |
| 357 | [Tropius](#357-tropius) | Planta/Volador | sin kit | — | — |  |
| 358 | [Chimecho](#358-chimecho) | Psíquico | sin kit | — | — |  |
| 359 | [Absol](#359-absol) | Siniestro | sin kit | — | — |  |
| 360 | [Wynaut](#360-wynaut) | Psíquico | sin kit | — | — |  |
| 361 | [Snorunt](#361-snorunt) | Hielo | sin kit | — | — |  |
| 362 | [Glalie](#362-glalie) | Hielo | sin kit | — | — |  |
| 363 | [Spheal](#363-spheal) | Hielo/Agua | sin kit | — | — |  |
| 364 | [Sealeo](#364-sealeo) | Hielo/Agua | sin kit | — | — |  |
| 365 | [Walrein](#365-walrein) | Hielo/Agua | sin kit | — | — |  |
| 366 | [Clamperl](#366-clamperl) | Agua | sin kit | — | — |  |
| 367 | [Huntail](#367-huntail) | Agua | sin kit | — | — |  |
| 368 | [Gorebyss](#368-gorebyss) | Agua | sin kit | — | — |  |
| 369 | [Relicanth](#369-relicanth) | Agua/Roca | sin kit | — | — |  |
| 370 | [Luvdisc](#370-luvdisc) | Agua | sin kit | — | — |  |
| 371 | [Bagon](#371-bagon) | Dragón | sin kit | — | — |  |
| 372 | [Shelgon](#372-shelgon) | Dragón | sin kit | — | — |  |
| 373 | [Salamence](#373-salamence) | Dragón/Volador | sin kit | — | — |  |
| 374 | [Beldum](#374-beldum) | Acero/Psíquico | sin kit | — | — |  |
| 375 | [Metang](#375-metang) | Acero/Psíquico | sin kit | — | — |  |
| 376 | [Metagross](#376-metagross) | Acero/Psíquico | sin kit | — | — |  |
| 377 | [Regirock](#377-regirock) | Roca | sin kit | — | — |  |
| 378 | [Regice](#378-regice) | Hielo | sin kit | — | — |  |
| 379 | [Registeel](#379-registeel) | Acero | sin kit | — | — |  |
| 380 | [Latias](#380-latias) | Dragón/Psíquico | sin kit | — | — |  |
| 381 | [Latios](#381-latios) | Dragón/Psíquico | sin kit | — | — |  |
| 382 | [Kyogre](#382-kyogre) | Agua | sin kit | — | — |  |
| 383 | [Groudon](#383-groudon) | Tierra | sin kit | — | — |  |
| 384 | [Rayquaza](#384-rayquaza) | Dragón/Volador | sin kit | — | — |  |
| 385 | [Jirachi](#385-jirachi) | Acero/Psíquico | sin kit | — | — |  |
| 386 | [Deoxys](#386-deoxys) | Psíquico | sin kit | — | — |  |

## Fichas

### 001 Bulbasaur

Planta/Veneno · Pokémon Semilla · **aparece en el juego**

**Kit**: propio, estilo *control* (distancia preferida 60 px).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| Clic der. | Látigo Cepa | Planta | Físico | Látigo | 45 | 4.0 s |
| Q | Síntesis | Planta | Estado | Mejora propia | — | 12.0 s |
| R | Somnífero | Planta | Estado | Zona | — | 12.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Polvo Veneno (kit) | Veneno | Estado | Zona | — | 1.3 s |
| 1 | Látigo Cepa (kit) | Planta | Físico | Látigo | 45 | 4.0 s |
| 3 | Síntesis (kit) | Planta | Estado | Mejora propia | — | 12.0 s |
| 5 | Somnífero (kit) | Planta | Estado | Zona | — | 12.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 4 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 7 | Drenadoras | Planta | Estado | Área | — | 6.0 s |
| 20 | Hoja Afilada | Planta | Físico | Disparo | 55 | 1.7 s |
| 25 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 32 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 39 | Fotosíntesis | Planta | Estado | Mejora propia | — | 10.0 s |
| 46 | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |

### 002 Ivysaur

Planta/Veneno · Pokémon Semilla · **aparece en el juego**

**Kit**: heredado de Bulbasaur, estilo *control* (distancia preferida 60 px).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| Clic der. | Látigo Cepa | Planta | Físico | Látigo | 45 | 4.0 s |
| Q | Síntesis | Planta | Estado | Mejora propia | — | 12.0 s |
| R | Somnífero | Planta | Estado | Zona | — | 12.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Polvo Veneno (kit) | Veneno | Estado | Zona | — | 1.3 s |
| 1 | Látigo Cepa (kit) | Planta | Físico | Látigo | 45 | 4.0 s |
| 3 | Síntesis (kit) | Planta | Estado | Mejora propia | — | 12.0 s |
| 5 | Somnífero (kit) | Planta | Estado | Zona | — | 12.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Drenadoras | Planta | Estado | Área | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 22 | Hoja Afilada | Planta | Físico | Disparo | 55 | 1.7 s |
| 29 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 38 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 47 | Fotosíntesis | Planta | Estado | Mejora propia | — | 10.0 s |
| 56 | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |

### 003 Venusaur

Planta/Veneno · Pokémon Semilla · **aparece en el juego**

**Kit**: heredado de Bulbasaur, estilo *control* (distancia preferida 60 px).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| Clic der. | Látigo Cepa | Planta | Físico | Látigo | 45 | 4.0 s |
| Q | Síntesis | Planta | Estado | Mejora propia | — | 12.0 s |
| R | Somnífero | Planta | Estado | Zona | — | 12.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Polvo Veneno (kit) | Veneno | Estado | Zona | — | 1.3 s |
| 1 | Látigo Cepa (kit) | Planta | Físico | Látigo | 45 | 4.0 s |
| 3 | Síntesis (kit) | Planta | Estado | Mejora propia | — | 12.0 s |
| 5 | Somnífero (kit) | Planta | Estado | Zona | — | 12.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Drenadoras | Planta | Estado | Área | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 22 | Hoja Afilada | Planta | Físico | Disparo | 55 | 1.7 s |
| 29 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 41 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 53 | Fotosíntesis | Planta | Estado | Mejora propia | — | 10.0 s |
| 65 | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |

### 004 Charmander

Fuego · Pokémon Lagartija · **aparece en el juego**

**Kit**: propio, estilo *bruiser* (distancia preferida 40 px).

**Firma — Calor**: Sube al pegar y al recibir daño. Desde 50 sus ataques queman; en 100 entra en Mar Llamas (más daño y áreas, regenera) y después queda Sobrecalentado.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Ascuas | Fuego | Especial | Disparo | 40 | 1.4 s |
| Clic der. | Arañazo | Normal | Físico | Embestida+combo | 40 | 1.1 s |
| Q | Giro Fuego | Fuego | Especial | Zona | 35 | 7.0 s |
| R | Embestida Ígnea | Fuego | Físico | Embestida | 50 | 6.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ascuas (kit) | Fuego | Especial | Disparo | 40 | 1.4 s |
| 1 | Arañazo (kit) | Normal | Físico | Embestida+combo | 40 | 1.1 s |
| 3 | Giro Fuego (kit) | Fuego | Especial | Zona | 35 | 7.0 s |
| 5 | Embestida Ígnea (kit) | Fuego | Físico | Embestida | 50 | 6.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 13 | Garra Metal | Acero | Físico | Golpe | 50 | 1.3 s |
| 19 | Pantalla de Humo | Normal | Estado | Zona | — | 9.0 s |
| 25 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 31 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| 37 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 43 | Furia Dragón | Dragón | Especial | Disparo | 50 | 2.0 s |

### 005 Charmeleon

Fuego · Pokémon Llama · **aparece en el juego**

**Kit**: heredado de Charmander, estilo *bruiser* (distancia preferida 40 px).

**Firma — Calor**: Sube al pegar y al recibir daño. Desde 50 sus ataques queman; en 100 entra en Mar Llamas (más daño y áreas, regenera) y después queda Sobrecalentado.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Ascuas | Fuego | Especial | Disparo | 40 | 1.4 s |
| Clic der. | Arañazo | Normal | Físico | Embestida+combo | 40 | 1.1 s |
| Q | Giro Fuego | Fuego | Especial | Zona | 35 | 7.0 s |
| R | Embestida Ígnea | Fuego | Físico | Embestida | 50 | 6.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ascuas (kit) | Fuego | Especial | Disparo | 40 | 1.4 s |
| 1 | Arañazo (kit) | Normal | Físico | Embestida+combo | 40 | 1.1 s |
| 3 | Giro Fuego (kit) | Fuego | Especial | Zona | 35 | 7.0 s |
| 5 | Embestida Ígnea (kit) | Fuego | Físico | Embestida | 50 | 6.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 13 | Garra Metal | Acero | Físico | Golpe | 50 | 1.3 s |
| 20 | Pantalla de Humo | Normal | Estado | Zona | — | 9.0 s |
| 27 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 34 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |
| 41 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 48 | Furia Dragón | Dragón | Especial | Disparo | 50 | 2.0 s |

### 006 Charizard

Fuego/Volador · Pokémon Llama · **aparece en el juego**

**Kit**: propio, estilo *bruiser* (distancia preferida 45 px).

**Firma — Calor**: Sube al pegar y al recibir. Desde la mitad sus ataques queman; llena, Mar Llamas 6 s (más daño, áreas más grandes, se cura). Después, Sobrecalentado.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Cuchillada | Normal | Físico | Golpe | 70 | 1.2 s |
| Clic der. | Ataque Ala | Volador | Físico | Embestida+combo | 60 | 3.0 s |
| Q | Giro Fuego | Fuego | Especial | Zona | 20 | 6.0 s |
| R | Lanzallamas | Fuego | Especial | Canalizado | 90 | 7.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Cuchillada (kit) | Normal | Físico | Golpe | 70 | 1.2 s |
| 1 | Ataque Ala (kit) | Volador | Físico | Embestida+combo | 60 | 3.0 s |
| 3 | Giro Fuego (kit) | Fuego | Especial | Zona | 20 | 6.0 s |
| 5 | Lanzallamas (kit) | Fuego | Especial | Canalizado | 90 | 7.0 s |
| 1 | Ascuas | Fuego | Especial | Disparo | 40 | 1.5 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Onda Ígnea | Fuego | Especial | Área | 95 | 4.7 s |
| 1 | Garra Metal | Acero | Físico | Golpe | 50 | 1.3 s |
| 1 | Arañazo | Normal | Físico | Embestida | 40 | 1.6 s |
| 20 | Pantalla de Humo | Normal | Estado | Zona | — | 9.0 s |
| 27 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 54 | Furia Dragón | Dragón | Especial | Disparo | 50 | 2.0 s |

### 007 Squirtle

Agua · Pokémon Tortuguita · **aparece en el juego**

**Kit**: propio, estilo *tanque* (distancia preferida 34 px).

**Firma — Presión**: Con Refugio recibe menos y no lo empujan; si le pegan justo al meterse en el caparazón es un parry (anula el golpe y aturde). Lo bloqueado carga la Presión, que el próximo golpe gasta para pegar más.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Placaje | Normal | Físico | Golpe | 40 | 1.0 s |
| Clic der. | Pistola Agua | Agua | Especial | Disparo | 40 | 1.3 s |
| Q | Refugio | Agua | Estado | Mejora propia | — | 4.0 s |
| R | Giro Rápido | Normal | Físico | Embestida | 50 | 7.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje (kit) | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Pistola Agua (kit) | Agua | Especial | Disparo | 40 | 1.3 s |
| 3 | Refugio (kit) | Agua | Estado | Mejora propia | — | 4.0 s |
| 5 | Giro Rápido (kit) | Normal | Físico | Embestida | 50 | 7.0 s |
| 4 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 7 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 18 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 28 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 33 | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| 40 | Cabezazo | Normal | Físico | Embestida | 130 | 2.9 s |
| 47 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

### 008 Wartortle

Agua · Pokémon Tortuga · **aparece en el juego**

**Kit**: heredado de Squirtle, estilo *tanque* (distancia preferida 34 px).

**Firma — Presión**: Con Refugio recibe menos y no lo empujan; si le pegan justo al meterse en el caparazón es un parry (anula el golpe y aturde). Lo bloqueado carga la Presión, que el próximo golpe gasta para pegar más.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Placaje | Normal | Físico | Golpe | 40 | 1.0 s |
| Clic der. | Pistola Agua | Agua | Especial | Disparo | 40 | 1.3 s |
| Q | Refugio | Agua | Estado | Mejora propia | — | 4.0 s |
| R | Giro Rápido | Normal | Físico | Embestida | 50 | 7.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje (kit) | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Pistola Agua (kit) | Agua | Especial | Disparo | 40 | 1.3 s |
| 3 | Refugio (kit) | Agua | Estado | Mejora propia | — | 4.0 s |
| 5 | Giro Rápido (kit) | Normal | Físico | Embestida | 50 | 7.0 s |
| 1 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 19 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 31 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 37 | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| 45 | Cabezazo | Normal | Físico | Embestida | 130 | 2.9 s |
| 53 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

### 009 Blastoise

Agua · Pokémon Armazón · **aparece en el juego**

**Kit**: heredado de Squirtle, estilo *tanque* (distancia preferida 34 px).

**Firma — Presión**: Con Refugio recibe menos y no lo empujan; si le pegan justo al meterse en el caparazón es un parry (anula el golpe y aturde). Lo bloqueado carga la Presión, que el próximo golpe gasta para pegar más.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Placaje | Normal | Físico | Golpe | 40 | 1.0 s |
| Clic der. | Pistola Agua | Agua | Especial | Disparo | 40 | 1.3 s |
| Q | Refugio | Agua | Estado | Mejora propia | — | 4.0 s |
| R | Giro Rápido | Normal | Físico | Embestida | 50 | 7.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje (kit) | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Pistola Agua (kit) | Agua | Especial | Disparo | 40 | 1.3 s |
| 3 | Refugio (kit) | Agua | Estado | Mejora propia | — | 4.0 s |
| 5 | Giro Rápido (kit) | Normal | Físico | Embestida | 50 | 7.0 s |
| 1 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 19 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 31 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 42 | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| 55 | Cabezazo | Normal | Físico | Embestida | 130 | 2.9 s |
| 68 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

### 010 Caterpie

Bicho · Pokémon Gusano · **aparece en el juego**

**Kit**: propio, estilo *control* (distancia preferida 80 px).

**Firma — Seda**: Disparo Demora y Telaraña dejan seda en el rival (hasta 3). Con 3, queda enredado: no se puede mover un rato.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Placaje | Normal | Físico | Golpe | 40 | 1.0 s |
| Clic der. | Disparo Demora | Bicho | Estado | Disparo | — | 2.5 s |
| Q | Telaraña | Bicho | Estado | Zona | — | 6.0 s |
| R | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |

**Ataques que puede aprender (4)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje (kit) | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Disparo Demora (kit) | Bicho | Estado | Disparo | — | 2.5 s |
| 3 | Telaraña (kit) | Bicho | Estado | Zona | — | 6.0 s |
| 5 | Fortaleza (kit) | Normal | Estado | Mejora propia | — | 8.0 s |

### 011 Metapod

Bicho · Pokémon Capullo · **aparece en el juego**

**Kit**: propio, estilo *tanque* (distancia preferida 30 px).

**Firma — Capullo**: Quieto se endurece: con la barra llena recibe la mitad de daño. Moverse la baja rápido.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Placaje | Normal | Físico | Golpe | 40 | 1.0 s |
| Clic der. | Disparo Demora | Bicho | Estado | Disparo | — | 2.5 s |
| Q | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| R | Derribo | Normal | Físico | Embestida | 70 | 6.0 s |

**Ataques que puede aprender (4)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje (kit) | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Disparo Demora (kit) | Bicho | Estado | Disparo | — | 2.5 s |
| 3 | Fortaleza (kit) | Normal | Estado | Mejora propia | — | 8.0 s |
| 5 | Derribo (kit) | Normal | Físico | Embestida | 70 | 6.0 s |

### 012 Butterfree

Bicho/Volador · Pokémon Mariposa · **aparece en el juego**

**Kit**: propio, estilo *control* (distancia preferida 95 px).

**Firma — Alas de Polvo**: Vuela como Pidgey: al esquivar con Aliento se eleva y en el aire no le llegan los golpes cuerpo a cuerpo. El primer ataque desde el aire pega más.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Confusión | Psíquico | Especial | Disparo | 50 | 1.6 s |
| Clic der. | Tornado | Volador | Especial | Disparo | 40 | 1.6 s |
| Q | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| R | Somnífero | Planta | Estado | Zona | — | 12.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Confusión (kit) | Psíquico | Especial | Disparo | 50 | 1.6 s |
| 1 | Tornado (kit) | Volador | Especial | Disparo | 40 | 1.6 s |
| 3 | Paralizador (kit) | Planta | Estado | Zona | — | 6.0 s |
| 5 | Somnífero (kit) | Planta | Estado | Zona | — | 12.0 s |
| 13 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 18 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 23 | Remolino | Volador | Estado | Zona | — | 9.0 s |
| 34 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 40 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 47 | Viento Plata | Bicho | Especial | Disparo | 60 | 1.8 s |

### 013 Weedle

Bicho/Veneno · Pokémon Oruga · **aparece en el juego**

**Kit**: propio, estilo *asesino* (distancia preferida 60 px).

**Firma — Aguijón Venenoso**: Le pega más a lo que está envenenado: +10% por cada stack de Envenenado del rival (hasta +50%).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Picotazo Veneno | Veneno | Físico | Disparo | 15 | 0.7 s |
| Clic der. | Disparo Demora | Bicho | Estado | Disparo | — | 2.5 s |
| Q | Doble Ataque | Bicho | Físico | Embestida+combo | 25 | 3.5 s |
| R | Pin Misil | Bicho | Físico | Disparo | 25 | 6.0 s |

**Ataques que puede aprender (4)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo Veneno (kit) | Veneno | Físico | Disparo | 15 | 0.7 s |
| 1 | Disparo Demora (kit) | Bicho | Estado | Disparo | — | 2.5 s |
| 3 | Doble Ataque (kit) | Bicho | Físico | Embestida+combo | 25 | 3.5 s |
| 5 | Pin Misil (kit) | Bicho | Físico | Disparo | 25 | 6.0 s |

### 014 Kakuna

Bicho/Veneno · Pokémon Capullo · **aparece en el juego**

**Kit**: propio, estilo *tanque* (distancia preferida 30 px).

**Firma — Capullo Venenoso**: Quieto se endurece (hasta la mitad de daño). Endurecido, al que le pega cuerpo a cuerpo lo puede envenenar.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Picotazo Veneno | Veneno | Físico | Disparo | 15 | 0.7 s |
| Clic der. | Disparo Demora | Bicho | Estado | Disparo | — | 2.5 s |
| Q | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| R | Derribo | Normal | Físico | Embestida | 70 | 6.0 s |

**Ataques que puede aprender (4)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo Veneno (kit) | Veneno | Físico | Disparo | 15 | 0.7 s |
| 1 | Disparo Demora (kit) | Bicho | Estado | Disparo | — | 2.5 s |
| 3 | Fortaleza (kit) | Normal | Estado | Mejora propia | — | 8.0 s |
| 5 | Derribo (kit) | Normal | Físico | Embestida | 70 | 6.0 s |

### 015 Beedrill

Bicho/Veneno · Pokémon Abeja Veneno · **aparece en el juego**

**Kit**: propio, estilo *asesino* (distancia preferida 35 px).

**Firma — Aguijón Letal**: Le pega más a lo envenenado: +12% por cada stack de Envenenado del rival (hasta +60%).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| Clic der. | Doble Ataque | Bicho | Físico | Embestida+combo | 30 | 3.0 s |
| Q | Pin Misil | Bicho | Físico | Disparo | 25 | 4.5 s |
| R | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |

**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ataque Furia (kit) | Normal | Físico | Golpe | 18 | 3.0 s |
| 1 | Doble Ataque (kit) | Bicho | Físico | Embestida+combo | 30 | 3.0 s |
| 3 | Pin Misil (kit) | Bicho | Físico | Disparo | 25 | 4.5 s |
| 5 | Agilidad (kit) | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 15 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 25 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 30 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 45 | Esfuerzo | Normal | Físico | Golpe | 60 | 1.4 s |

### 016 Pidgey

Normal/Volador · Pokémon Pajarito · **aparece en el juego**

**Kit**: propio, estilo *hostigador* (distancia preferida 70 px).

**Firma — Aliento**: Esquivar con Aliento lo eleva: en el aire no le pegan golpes cuerpo a cuerpo. El primer ataque desde el aire es un Picado (más daño) y aterriza.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Tornado | Volador | Especial | Disparo | 40 | 1.2 s |
| Clic der. | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| Q | Ataque Rápido | Normal | Físico | Embestida | 40 | 2.6 s |
| R | Remolino | Volador | Estado | Zona | — | 9.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Tornado (kit) | Volador | Especial | Disparo | 40 | 1.2 s |
| 1 | Ataque Arena (kit) | Normal | Estado | Disparo | — | 5.0 s |
| 3 | Ataque Rápido (kit) | Normal | Físico | Embestida | 40 | 2.6 s |
| 5 | Remolino (kit) | Volador | Estado | Zona | — | 9.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 25 | Ataque Ala | Volador | Físico | Embestida | 60 | 1.9 s |
| 31 | Danza Pluma | Volador | Estado | Área | — | 6.0 s |
| 31 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 39 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 47 | Espejo | Volador | Estado | Área | — | 6.0 s |

### 017 Pidgeotto

Normal/Volador · Pokémon Pájaro · **aparece en el juego**

**Kit**: heredado de Pidgey, estilo *hostigador* (distancia preferida 70 px).

**Firma — Aliento**: Esquivar con Aliento lo eleva: en el aire no le pegan golpes cuerpo a cuerpo. El primer ataque desde el aire es un Picado (más daño) y aterriza.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Tornado | Volador | Especial | Disparo | 40 | 1.2 s |
| Clic der. | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| Q | Ataque Rápido | Normal | Físico | Embestida | 40 | 2.6 s |
| R | Remolino | Volador | Estado | Zona | — | 9.0 s |

**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Tornado (kit) | Volador | Especial | Disparo | 40 | 1.2 s |
| 1 | Ataque Arena (kit) | Normal | Estado | Disparo | — | 5.0 s |
| 3 | Ataque Rápido (kit) | Normal | Físico | Embestida | 40 | 2.6 s |
| 5 | Remolino (kit) | Volador | Estado | Zona | — | 9.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 27 | Ataque Ala | Volador | Físico | Embestida | 60 | 1.9 s |
| 34 | Danza Pluma | Volador | Estado | Área | — | 6.0 s |
| 43 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 52 | Espejo | Volador | Estado | Área | — | 6.0 s |

### 018 Pidgeot

Normal/Volador · Pokémon Pájaro · **aparece en el juego**

**Kit**: heredado de Pidgey, estilo *hostigador* (distancia preferida 70 px).

**Firma — Aliento**: Esquivar con Aliento lo eleva: en el aire no le pegan golpes cuerpo a cuerpo. El primer ataque desde el aire es un Picado (más daño) y aterriza.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Tornado | Volador | Especial | Disparo | 40 | 1.2 s |
| Clic der. | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| Q | Ataque Rápido | Normal | Físico | Embestida | 40 | 2.6 s |
| R | Remolino | Volador | Estado | Zona | — | 9.0 s |

**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Tornado (kit) | Volador | Especial | Disparo | 40 | 1.2 s |
| 1 | Ataque Arena (kit) | Normal | Estado | Disparo | — | 5.0 s |
| 3 | Ataque Rápido (kit) | Normal | Físico | Embestida | 40 | 2.6 s |
| 5 | Remolino (kit) | Volador | Estado | Zona | — | 9.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 27 | Ataque Ala | Volador | Físico | Embestida | 60 | 1.9 s |
| 34 | Danza Pluma | Volador | Estado | Área | — | 6.0 s |
| 48 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 62 | Espejo | Volador | Estado | Área | — | 6.0 s |

### 019 Rattata

Normal · Pokémon Ratón · **aparece en el juego**

**Kit**: propio, estilo *asesino* (distancia preferida 20 px).

**Firma — Instinto**: Marca presas (poca vida o con estado): les pega más y puede hacer críticos. Rematar recarga Ataque Rápido.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Mordisco | Siniestro | Físico | Golpe | 60 | 1.0 s |
| Clic der. | Ataque Rápido | Normal | Físico | Embestida | 40 | 4.0 s |
| Q | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| R | Hipercolmillo | Normal | Físico | Golpe | 80 | 10.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco (kit) | Siniestro | Físico | Golpe | 60 | 1.0 s |
| 1 | Ataque Rápido (kit) | Normal | Físico | Embestida | 40 | 4.0 s |
| 3 | Foco Energía (kit) | Normal | Estado | Mejora propia | — | 9.0 s |
| 5 | Hipercolmillo (kit) | Normal | Físico | Golpe | 80 | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 27 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 34 | Superdiente | Normal | Físico | Golpe | 60 | 1.4 s |
| 41 | Esfuerzo | Normal | Físico | Golpe | 60 | 1.4 s |
| 41 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |

### 020 Raticate

Normal · Pokémon Ratón · **aparece en el juego**

**Kit**: heredado de Rattata, estilo *asesino* (distancia preferida 20 px).

**Firma — Instinto**: Marca presas (poca vida o con estado): les pega más y puede hacer críticos. Rematar recarga Ataque Rápido.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Mordisco | Siniestro | Físico | Golpe | 60 | 1.0 s |
| Clic der. | Ataque Rápido | Normal | Físico | Embestida | 40 | 4.0 s |
| Q | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| R | Hipercolmillo | Normal | Físico | Golpe | 80 | 10.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco (kit) | Siniestro | Físico | Golpe | 60 | 1.0 s |
| 1 | Ataque Rápido (kit) | Normal | Físico | Embestida | 40 | 4.0 s |
| 3 | Foco Energía (kit) | Normal | Estado | Mejora propia | — | 9.0 s |
| 5 | Hipercolmillo (kit) | Normal | Físico | Golpe | 80 | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 20 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 30 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 40 | Superdiente | Normal | Físico | Golpe | 60 | 1.4 s |
| 50 | Esfuerzo | Normal | Físico | Golpe | 60 | 1.4 s |

### 021 Spearow

Normal/Volador · Pokémon Pajarito · **aparece en el juego**

**Kit**: propio, estilo *asesino* (distancia preferida 30 px).

**Firma — Furia**: Cada golpe seguido al mismo rival suma una marca (hasta 5): +10% de daño por marca. Si pasan 2 s sin pegarle, o cambia de rival, se pierde.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| Clic der. | Gruñido | Normal | Estado | Área | — | 8.0 s |
| Q | Ataque Furia | Normal | Físico | Golpe | 15 | 4.0 s |
| R | Persecución | Siniestro | Físico | Embestida+combo | 40 | 5.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo (kit) | Volador | Físico | Golpe | 35 | 0.8 s |
| 1 | Gruñido (kit) | Normal | Estado | Área | — | 8.0 s |
| 3 | Ataque Furia (kit) | Normal | Físico | Golpe | 15 | 4.0 s |
| 5 | Persecución (kit) | Siniestro | Físico | Embestida+combo | 40 | 5.0 s |
| 7 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 25 | Golpe Aéreo | Volador | Físico | Golpe | 60 | 1.4 s |
| 25 | Ataque Aéreo | Volador | Físico | Embestida | 140 | 3.0 s |
| 31 | Espejo | Volador | Estado | Área | — | 6.0 s |
| 37 | Pico Taladro | Volador | Físico | Embestida | 80 | 2.1 s |
| 43 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |

### 022 Fearow

Normal/Volador · Pokémon Pico · **aparece en el juego**

**Kit**: heredado de Spearow, estilo *asesino* (distancia preferida 30 px).

**Firma — Furia**: Cada golpe seguido al mismo rival suma una marca (hasta 5): +10% de daño por marca. Si pasan 2 s sin pegarle, o cambia de rival, se pierde.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| Clic der. | Gruñido | Normal | Estado | Área | — | 8.0 s |
| Q | Ataque Furia | Normal | Físico | Golpe | 15 | 4.0 s |
| R | Persecución | Siniestro | Físico | Embestida+combo | 40 | 5.0 s |

**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo (kit) | Volador | Físico | Golpe | 35 | 0.8 s |
| 1 | Gruñido (kit) | Normal | Estado | Área | — | 8.0 s |
| 3 | Ataque Furia (kit) | Normal | Físico | Golpe | 15 | 4.0 s |
| 5 | Persecución (kit) | Siniestro | Físico | Embestida+combo | 40 | 5.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 32 | Espejo | Volador | Estado | Área | — | 6.0 s |
| 40 | Pico Taladro | Volador | Físico | Embestida | 80 | 2.1 s |
| 47 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |

### 023 Ekans

Veneno · Pokémon Serpiente · **aparece en el juego**

**Kit**: propio, estilo *control* (distancia preferida 40 px).

**Firma — Enroscarse**: Quieto 0,8 s se enrosca. El próximo golpe sale como un resorte: +40% de daño y un envión hacia adelante. Moverse lo desenrosca.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| Clic der. | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| Q | Ácido | Veneno | Especial | Zona | 20 | 6.0 s |
| R | Deslumbrar | Normal | Estado | Canalizado | — | 9.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo Veneno (kit) | Veneno | Físico | Golpe | 20 | 0.7 s |
| 1 | Constricción (kit) | Normal | Físico | Látigo | 15 | 4.0 s |
| 3 | Ácido (kit) | Veneno | Especial | Zona | 20 | 6.0 s |
| 5 | Deslumbrar (kit) | Normal | Estado | Canalizado | — | 9.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 13 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 25 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 37 | Escupir | Normal | Especial | Disparo | 60 | 1.8 s |
| 37 | Reserva | Normal | Estado | Mejora propia | — | 10.0 s |
| 37 | Tragar | Normal | Estado | Mejora propia | — | 10.0 s |
| 44 | Niebla | Hielo | Estado | Mejora propia | — | 10.0 s |

### 024 Arbok

Veneno · Pokémon Cobra · **aparece en el juego**

**Kit**: heredado de Ekans, estilo *control* (distancia preferida 40 px).

**Firma — Enroscarse**: Quieto 0,8 s se enrosca. El próximo golpe sale como un resorte: +40% de daño y un envión hacia adelante. Moverse lo desenrosca.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| Clic der. | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| Q | Ácido | Veneno | Especial | Zona | 20 | 6.0 s |
| R | Deslumbrar | Normal | Estado | Canalizado | — | 9.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo Veneno (kit) | Veneno | Físico | Golpe | 20 | 0.7 s |
| 1 | Constricción (kit) | Normal | Físico | Látigo | 15 | 4.0 s |
| 3 | Ácido (kit) | Veneno | Especial | Zona | 20 | 6.0 s |
| 5 | Deslumbrar (kit) | Normal | Estado | Canalizado | — | 9.0 s |
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 28 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 46 | Escupir | Normal | Especial | Disparo | 60 | 1.8 s |
| 46 | Reserva | Normal | Estado | Mejora propia | — | 10.0 s |
| 46 | Tragar | Normal | Estado | Mejora propia | — | 10.0 s |
| 56 | Niebla | Hielo | Estado | Mejora propia | — | 10.0 s |

### 025 Pikachu

Eléctrico · Pokémon Ratón · **aparece en el juego**

**Kit**: propio, estilo *velocista* (distancia preferida 70 px).

**Firma — Estática**: Moverse y esquivar generan cargas (5); quieto las pierde. Rayo gasta todas y pega más. Con las 5, el próximo golpe es una Descarga que paraliza.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Impactrueno | Eléctrico | Especial | Disparo | 40 | 0.8 s |
| Clic der. | Ataque Rápido | Normal | Físico | Embestida | 40 | 2.2 s |
| Q | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| R | Rayo | Eléctrico | Especial | Zona | 90 | 7.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Impactrueno (kit) | Eléctrico | Especial | Disparo | 40 | 0.8 s |
| 1 | Ataque Rápido (kit) | Normal | Físico | Embestida | 40 | 2.2 s |
| 3 | Onda Trueno (kit) | Eléctrico | Estado | Área | — | 6.0 s |
| 5 | Rayo (kit) | Eléctrico | Especial | Zona | 90 | 7.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 6 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 15 | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |
| 20 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 33 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 33 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 41 | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |
| 50 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |

### 026 Raichu

Eléctrico · Pokémon Ratón · **aparece en el juego**

**Kit**: propio, estilo *bruiser* (distancia preferida 45 px).

**Firma — Toma de Tierra**: Jefe. La barra sube al pegar y al recibir; llena, planta la cola 1 s (quieto: castigalo) y suelta una descarga en anillo que deja el suelo chamuscado y electrificado 8 s. Cuerpo ×1,3, casi no lo empujan. A mitad de vida entra en Sobrecarga (+20% de daño) hasta el final.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Puño Trueno | Eléctrico | Físico | Golpe | 75 | 1.4 s |
| Clic der. | Impactrueno Triple | Eléctrico | Especial | Disparo | 40 | 2.0 s |
| Q | Chispa | Eléctrico | Físico | Embestida | 65 | 6.0 s |
| R | Trueno | Eléctrico | Especial | Zona | 90 | 9.0 s |

**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Puño Trueno (kit) | Eléctrico | Físico | Golpe | 75 | 1.4 s |
| 1 | Impactrueno Triple (kit) | Eléctrico | Especial | Disparo | 40 | 2.0 s |
| 3 | Chispa (kit) | Eléctrico | Físico | Embestida | 65 | 6.0 s |
| 5 | Trueno (kit) | Eléctrico | Especial | Zona | 90 | 9.0 s |
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 1 | Impactrueno | Eléctrico | Especial | Disparo | 40 | 1.5 s |
| 1 | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |

### 027 Sandshrew

Tierra · Pokémon Ratón · **aparece en el juego**

**Kit**: propio, estilo *control* (distancia preferida 45 px).

**Firma — Velo Arena**: Al esquivar deja una nube de arena donde estaba, que desorienta a los rivales que la pisan (cada 4 s).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Arañazo | Normal | Físico | Golpe | 40 | 0.9 s |
| Clic der. | Ataque Arena | Tierra | Estado | Canalizado | — | 6.0 s |
| Q | Picotazo Veneno | Veneno | Físico | Disparo | 15 | 1.0 s |
| R | Rizo Defensa | Normal | Estado | Mejora propia | — | 9.0 s |

**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo (kit) | Normal | Físico | Golpe | 40 | 0.9 s |
| 1 | Ataque Arena (kit) | Tierra | Estado | Canalizado | — | 6.0 s |
| 3 | Picotazo Veneno (kit) | Veneno | Físico | Disparo | 15 | 1.0 s |
| 5 | Rizo Defensa (kit) | Normal | Estado | Mejora propia | — | 9.0 s |
| 17 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 30 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 37 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 45 | Bucle Arena | Tierra | Físico | Golpe | 35 | 1.1 s |
| 53 | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |

### 028 Sandslash

Tierra · Pokémon Ratón · **aparece en el juego**

**Kit**: heredado de Sandshrew, estilo *control* (distancia preferida 45 px).

**Firma — Velo Arena**: Al esquivar deja una nube de arena donde estaba, que desorienta a los rivales que la pisan (cada 4 s).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Arañazo | Normal | Físico | Golpe | 40 | 0.9 s |
| Clic der. | Ataque Arena | Tierra | Estado | Canalizado | — | 6.0 s |
| Q | Picotazo Veneno | Veneno | Físico | Disparo | 15 | 1.0 s |
| R | Rizo Defensa | Normal | Estado | Mejora propia | — | 9.0 s |

**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo (kit) | Normal | Físico | Golpe | 40 | 0.9 s |
| 1 | Ataque Arena (kit) | Tierra | Estado | Canalizado | — | 6.0 s |
| 3 | Picotazo Veneno (kit) | Veneno | Físico | Disparo | 15 | 1.0 s |
| 5 | Rizo Defensa (kit) | Normal | Estado | Mejora propia | — | 9.0 s |
| 24 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 33 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 42 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 52 | Bucle Arena | Tierra | Físico | Golpe | 35 | 1.1 s |
| 62 | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |

### 029 Nidoran♀

Veneno · Pokémon Pin Veneno · **aparece en el juego**

**Kit**: propio, estilo *bruiser* (distancia preferida 30 px).

**Firma — Púas Venenosas**: Al que le pega cuerpo a cuerpo le devuelve 10% del daño y puede envenenarlo; con Refuerzo, 20% y veneno seguro. Mordisco pega ×1,5 a lo envenenado.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Arañazo | Normal | Físico | Golpe | 40 | 0.9 s |
| Clic der. | Doble Patada | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| Q | Mordisco | Siniestro | Físico | Golpe | 60 | 3.0 s |
| R | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo (kit) | Normal | Físico | Golpe | 40 | 0.9 s |
| 1 | Doble Patada (kit) | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| 3 | Mordisco (kit) | Siniestro | Físico | Golpe | 60 | 3.0 s |
| 5 | Refuerzo (kit) | Veneno | Estado | Mejora propia | — | 10.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 8 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 17 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 30 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 38 | Camelo | Siniestro | Estado | Disparo | — | 6.0 s |
| 47 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |

### 030 Nidorina

Veneno · Pokémon Pin Veneno · **aparece en el juego**

**Kit**: heredado de Nidoran♀, estilo *bruiser* (distancia preferida 30 px).

**Firma — Púas Venenosas**: Al que le pega cuerpo a cuerpo le devuelve 10% del daño y puede envenenarlo; con Refuerzo, 20% y veneno seguro. Mordisco pega ×1,5 a lo envenenado.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Arañazo | Normal | Físico | Golpe | 40 | 0.9 s |
| Clic der. | Doble Patada | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| Q | Mordisco | Siniestro | Físico | Golpe | 60 | 3.0 s |
| R | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo (kit) | Normal | Físico | Golpe | 40 | 0.9 s |
| 1 | Doble Patada (kit) | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| 3 | Mordisco (kit) | Siniestro | Físico | Golpe | 60 | 3.0 s |
| 5 | Refuerzo (kit) | Veneno | Estado | Mejora propia | — | 10.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 8 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 18 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 34 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 43 | Camelo | Siniestro | Estado | Disparo | — | 6.0 s |
| 53 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |

### 031 Nidoqueen

Veneno/Tierra · Pokémon Taladro · **aparece en el juego**

**Kit**: heredado de Nidoran♀, estilo *bruiser* (distancia preferida 30 px).

**Firma — Púas Venenosas**: Al que le pega cuerpo a cuerpo le devuelve 10% del daño y puede envenenarlo; con Refuerzo, 20% y veneno seguro. Mordisco pega ×1,5 a lo envenenado.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Arañazo | Normal | Físico | Golpe | 40 | 0.9 s |
| Clic der. | Doble Patada | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| Q | Mordisco | Siniestro | Físico | Golpe | 60 | 3.0 s |
| R | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |

**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo (kit) | Normal | Físico | Golpe | 40 | 0.9 s |
| 1 | Doble Patada (kit) | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| 3 | Mordisco (kit) | Siniestro | Físico | Golpe | 60 | 3.0 s |
| 5 | Refuerzo (kit) | Veneno | Estado | Mejora propia | — | 10.0 s |
| 1 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 22 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 43 | Fuerza Bruta | Lucha | Físico | Embestida | 120 | 2.7 s |

### 032 Nidoran♂

Veneno · Pokémon Pin Veneno · **aparece en el juego**

**Kit**: propio, estilo *asesino* (distancia preferida 35 px).

**Firma — Oído Fino**: Esquive perfecto: si esquivás justo antes de que te pegue, se recarga Cornada y el próximo golpe es crítico (×1,5).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| Clic der. | Doble Patada | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| Q | Malicioso | Normal | Estado | Área | — | 8.0 s |
| R | Cornada | Normal | Físico | Embestida | 65 | 6.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo (kit) | Volador | Físico | Golpe | 35 | 0.8 s |
| 1 | Doble Patada (kit) | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| 3 | Malicioso (kit) | Normal | Estado | Área | — | 8.0 s |
| 5 | Cornada (kit) | Normal | Físico | Embestida | 65 | 6.0 s |
| 8 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 17 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 23 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 30 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 38 | Camelo | Siniestro | Estado | Disparo | — | 6.0 s |
| 47 | Perforador | Normal | Físico | Golpe | 60 | 1.4 s |

### 033 Nidorino

Veneno · Pokémon Pin Veneno · **aparece en el juego**

**Kit**: heredado de Nidoran♂, estilo *asesino* (distancia preferida 35 px).

**Firma — Oído Fino**: Esquive perfecto: si esquivás justo antes de que te pegue, se recarga Cornada y el próximo golpe es crítico (×1,5).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| Clic der. | Doble Patada | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| Q | Malicioso | Normal | Estado | Área | — | 8.0 s |
| R | Cornada | Normal | Físico | Embestida | 65 | 6.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo (kit) | Volador | Físico | Golpe | 35 | 0.8 s |
| 1 | Doble Patada (kit) | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| 3 | Malicioso (kit) | Normal | Estado | Área | — | 8.0 s |
| 5 | Cornada (kit) | Normal | Físico | Embestida | 65 | 6.0 s |
| 8 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 18 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 26 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 34 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 43 | Camelo | Siniestro | Estado | Disparo | — | 6.0 s |
| 53 | Perforador | Normal | Físico | Golpe | 60 | 1.4 s |

### 034 Nidoking

Veneno/Tierra · Pokémon Taladro · **aparece en el juego**

**Kit**: heredado de Nidoran♂, estilo *asesino* (distancia preferida 35 px).

**Firma — Oído Fino**: Esquive perfecto: si esquivás justo antes de que te pegue, se recarga Cornada y el próximo golpe es crítico (×1,5).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| Clic der. | Doble Patada | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| Q | Malicioso | Normal | Estado | Área | — | 8.0 s |
| R | Cornada | Normal | Físico | Embestida | 65 | 6.0 s |

**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo (kit) | Volador | Físico | Golpe | 35 | 0.8 s |
| 1 | Doble Patada (kit) | Lucha | Físico | Embestida+combo | 30 | 3.5 s |
| 3 | Malicioso (kit) | Normal | Estado | Área | — | 8.0 s |
| 5 | Cornada (kit) | Normal | Físico | Embestida | 65 | 6.0 s |
| 1 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 1 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |
| 22 | Saña | Normal | Físico | Embestida | 120 | 2.7 s |
| 43 | Megacuerno | Bicho | Físico | Embestida | 120 | 2.7 s |

### 035 Clefairy

Hada · Pokémon Hada · **aparece en el juego**

**Kit**: propio, estilo *caotico* (distancia preferida 45 px).

**Firma — Luz de Luna**: Metrónomo lanza un ataque al azar de cualquier kit del juego. Cada uno carga la luna (3 marcas); con la luna llena, el próximo elige entre los 5 más fuertes.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| Clic der. | Canto | Normal | Estado | Zona | — | 12.0 s |
| Q | Reducción | Normal | Estado | Mejora propia | — | 9.0 s |
| R | Metrónomo | Normal | Estado | Mejora propia | — | 6.0 s |

**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Doble Bofetón (kit) | Normal | Físico | Golpe | 20 | 1.0 s |
| 1 | Canto (kit) | Normal | Estado | Zona | — | 12.0 s |
| 3 | Reducción (kit) | Normal | Estado | Mejora propia | — | 9.0 s |
| 5 | Metrónomo (kit) | Normal | Estado | Mejora propia | — | 6.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 5 | Otra Vez | Normal | Estado | Área | — | 6.0 s |
| 17 | Señuelo | Normal | Estado | Mejora propia | — | 10.0 s |
| 25 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 33 | Masa Cósmica | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 37 | Luz Lunar | Hada | Estado | Mejora propia | — | 10.0 s |
| 41 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 45 | Puño Meteoro | Acero | Físico | Embestida | 90 | 2.3 s |

### 036 Clefable

Hada · Pokémon Hada

**Kit**: heredado de Clefairy, estilo *caotico* (distancia preferida 45 px).

**Firma — Luz de Luna**: Metrónomo lanza un ataque al azar de cualquier kit del juego. Cada uno carga la luna (3 marcas); con la luna llena, el próximo elige entre los 5 más fuertes.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| Clic der. | Canto | Normal | Estado | Zona | — | 12.0 s |
| Q | Reducción | Normal | Estado | Mejora propia | — | 9.0 s |
| R | Metrónomo | Normal | Estado | Mejora propia | — | 6.0 s |

**Ataques que puede aprender (4)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Doble Bofetón (kit) | Normal | Físico | Golpe | 20 | 1.0 s |
| 1 | Canto (kit) | Normal | Estado | Zona | — | 12.0 s |
| 3 | Reducción (kit) | Normal | Estado | Mejora propia | — | 9.0 s |
| 5 | Metrónomo (kit) | Normal | Estado | Mejora propia | — | 6.0 s |

### 037 Vulpix

Fuego · Pokémon Zorro · **aparece en el juego**

**Kit**: propio, estilo *desgaste* (distancia preferida 85 px).

**Firma — Rescoldo**: Sus golpes contra enemigos quemados pegan más y renuevan la quemadura.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Ascuas | Fuego | Especial | Disparo | 40 | 0.9 s |
| Clic der. | Fuego Fatuo | Fuego | Estado | Disparo | — | 5.0 s |
| Q | Rayo Confuso | Siniestro | Estado | Disparo | — | 7.0 s |
| R | Lanzallamas | Fuego | Especial | Canalizado | 90 | 9.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ascuas (kit) | Fuego | Especial | Disparo | 40 | 0.9 s |
| 1 | Fuego Fatuo (kit) | Fuego | Estado | Disparo | — | 5.0 s |
| 3 | Rayo Confuso (kit) | Siniestro | Estado | Disparo | — | 7.0 s |
| 5 | Lanzallamas (kit) | Fuego | Especial | Canalizado | 90 | 9.0 s |
| 5 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 9 | Rugido | Normal | Estado | Área | — | 6.0 s |
| 13 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 25 | Sellar | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 33 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 37 | Rabia | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 41 | Giro Fuego | Fuego | Especial | Área | 35 | 3.0 s |

### 038 Ninetales

Fuego · Pokémon Zorro · **aparece en el juego**

**Kit**: heredado de Vulpix, estilo *desgaste* (distancia preferida 85 px).

**Firma — Rescoldo**: Sus golpes contra enemigos quemados pegan más y renuevan la quemadura.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Ascuas | Fuego | Especial | Disparo | 40 | 0.9 s |
| Clic der. | Fuego Fatuo | Fuego | Estado | Disparo | — | 5.0 s |
| Q | Rayo Confuso | Siniestro | Estado | Disparo | — | 7.0 s |
| R | Lanzallamas | Fuego | Especial | Canalizado | 90 | 9.0 s |

**Ataques que puede aprender (7)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ascuas (kit) | Fuego | Especial | Disparo | 40 | 0.9 s |
| 1 | Fuego Fatuo (kit) | Fuego | Estado | Disparo | — | 5.0 s |
| 3 | Rayo Confuso (kit) | Siniestro | Estado | Disparo | — | 7.0 s |
| 5 | Lanzallamas (kit) | Fuego | Especial | Canalizado | 90 | 9.0 s |
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 45 | Giro Fuego | Fuego | Especial | Área | 35 | 3.0 s |

### 039 Jigglypuff

Normal/Hada · Pokémon Globo · **aparece en el juego**

**Kit**: propio, estilo *control* (distancia preferida 35 px).

**Firma — Inflado y Marcador**: Cada golpe que recibe lo infla (hasta 3: menos empuje). Rodar gasta el inflado (+25% por cada uno). Sus golpes a un dormido le dejan un garabato en la cara (Expuesto).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| Clic der. | Rodar | Roca | Físico | Embestida | 40 | 3.5 s |
| Q | Rizo Defensa | Normal | Estado | Mejora propia | — | 9.0 s |
| R | Canto | Normal | Estado | Zona | — | 12.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Destructor (kit) | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Rodar (kit) | Roca | Físico | Embestida | 40 | 3.5 s |
| 3 | Rizo Defensa (kit) | Normal | Estado | Mejora propia | — | 9.0 s |
| 5 | Canto (kit) | Normal | Estado | Zona | — | 12.0 s |
| 14 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 24 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 29 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 34 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 39 | Mimético | Normal | Estado | Área | — | 6.0 s |
| 44 | Vozarrón | Normal | Especial | Área | 90 | 4.5 s |
| 49 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

### 040 Wigglytuff

Normal/Hada · Pokémon Globo · **aparece en el juego**

**Kit**: heredado de Jigglypuff, estilo *control* (distancia preferida 35 px).

**Firma — Inflado y Marcador**: Cada golpe que recibe lo infla (hasta 3: menos empuje). Rodar gasta el inflado (+25% por cada uno). Sus golpes a un dormido le dejan un garabato en la cara (Expuesto).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| Clic der. | Rodar | Roca | Físico | Embestida | 40 | 3.5 s |
| Q | Rizo Defensa | Normal | Estado | Mejora propia | — | 9.0 s |
| R | Canto | Normal | Estado | Zona | — | 12.0 s |

**Ataques que puede aprender (6)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Destructor (kit) | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Rodar (kit) | Roca | Físico | Embestida | 40 | 3.5 s |
| 3 | Rizo Defensa (kit) | Normal | Estado | Mejora propia | — | 9.0 s |
| 5 | Canto (kit) | Normal | Estado | Zona | — | 12.0 s |
| 1 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 1 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |

### 041 Zubat

Veneno/Volador · Pokémon Murciélago · **aparece en el juego**

**Kit**: propio, estilo *hostigador* (distancia preferida 40 px).

**Firma — Ecolocalización**: Es ciego: no lo desorientan (Ataque Arena, Supersónico, humo...). Contra un rival desorientado, Chupavidas cura el doble.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Chupavidas | Bicho | Físico | Golpe | 30 | 0.8 s |
| Clic der. | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| Q | Ataque Ala | Volador | Físico | Embestida+combo | 40 | 4.0 s |
| R | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Chupavidas (kit) | Bicho | Físico | Golpe | 30 | 0.8 s |
| 1 | Supersónico (kit) | Normal | Estado | Canalizado | — | 6.0 s |
| 3 | Ataque Ala (kit) | Volador | Físico | Embestida+combo | 40 | 4.0 s |
| 5 | Rayo Confuso (kit) | Fantasma | Estado | Disparo | — | 8.0 s |
| 6 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 16 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 31 | Aire Afilado | Volador | Especial | Área | 60 | 3.7 s |
| 36 | Mal de Ojo | Normal | Estado | Área | — | 6.0 s |
| 41 | Colmillo Veneno | Veneno | Físico | Golpe | 50 | 1.3 s |
| 46 | Niebla | Hielo | Estado | Mejora propia | — | 10.0 s |

### 042 Golbat

Veneno/Volador · Pokémon Murciélago · **aparece en el juego**

**Kit**: heredado de Zubat, estilo *hostigador* (distancia preferida 40 px).

**Firma — Ecolocalización**: Es ciego: no lo desorientan (Ataque Arena, Supersónico, humo...). Contra un rival desorientado, Chupavidas cura el doble.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Chupavidas | Bicho | Físico | Golpe | 30 | 0.8 s |
| Clic der. | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| Q | Ataque Ala | Volador | Físico | Embestida+combo | 40 | 4.0 s |
| R | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Chupavidas (kit) | Bicho | Físico | Golpe | 30 | 0.8 s |
| 1 | Supersónico (kit) | Normal | Estado | Canalizado | — | 6.0 s |
| 3 | Ataque Ala (kit) | Volador | Físico | Embestida+combo | 40 | 4.0 s |
| 5 | Rayo Confuso (kit) | Fantasma | Estado | Disparo | — | 8.0 s |
| 1 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 1 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 16 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 35 | Aire Afilado | Volador | Especial | Área | 60 | 3.7 s |
| 42 | Mal de Ojo | Normal | Estado | Área | — | 6.0 s |
| 49 | Colmillo Veneno | Veneno | Físico | Golpe | 50 | 1.3 s |
| 56 | Niebla | Hielo | Estado | Mejora propia | — | 10.0 s |

### 043 Oddish

Planta/Veneno · Pokémon Hierbajo · **aparece en el juego**

**Kit**: propio, estilo *desgaste* (distancia preferida 75 px).

**Firma — Esporas**: Sus ataques dejan esporas en el rival (hasta 5). Florecer las hace florecer: 1+ envenena, 3+ paraliza, 5 duerme, y Oddish se cura por cada una.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| Clic der. | Polvo Veneno | Veneno | Estado | Zona | — | 1.6 s |
| Q | Paralizador | Planta | Estado | Zona | — | 5.0 s |
| R | Florecer | Planta | Estado | Mejora propia | — | 9.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Absorber (kit) | Planta | Especial | Disparo | 20 | 0.9 s |
| 1 | Polvo Veneno (kit) | Veneno | Estado | Zona | — | 1.6 s |
| 3 | Paralizador (kit) | Planta | Estado | Zona | — | 5.0 s |
| 5 | Florecer (kit) | Planta | Estado | Mejora propia | — | 9.0 s |
| 7 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 18 | Somnífero | Planta | Estado | Zona | — | 12.0 s |
| 23 | Ácido | Veneno | Especial | Disparo | 40 | 1.5 s |
| 32 | Luz Lunar | Hada | Estado | Mejora propia | — | 10.0 s |
| 36 | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |
| 39 | Danza Pétalo | Planta | Especial | Área | 120 | 5.5 s |

### 044 Gloom

Planta/Veneno · Pokémon Hierbajo · **aparece en el juego**

**Kit**: heredado de Oddish, estilo *desgaste* (distancia preferida 75 px).

**Firma — Esporas**: Sus ataques dejan esporas en el rival (hasta 5). Florecer las hace florecer: 1+ envenena, 3+ paraliza, 5 duerme, y Oddish se cura por cada una.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| Clic der. | Polvo Veneno | Veneno | Estado | Zona | — | 1.6 s |
| Q | Paralizador | Planta | Estado | Zona | — | 5.0 s |
| R | Florecer | Planta | Estado | Mejora propia | — | 9.0 s |

**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Absorber (kit) | Planta | Especial | Disparo | 20 | 0.9 s |
| 1 | Polvo Veneno (kit) | Veneno | Estado | Zona | — | 1.6 s |
| 3 | Paralizador (kit) | Planta | Estado | Zona | — | 5.0 s |
| 5 | Florecer (kit) | Planta | Estado | Mejora propia | — | 9.0 s |
| 1 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 18 | Somnífero | Planta | Estado | Zona | — | 12.0 s |
| 24 | Ácido | Veneno | Especial | Disparo | 40 | 1.5 s |
| 35 | Luz Lunar | Hada | Estado | Mejora propia | — | 10.0 s |
| 44 | Danza Pétalo | Planta | Especial | Área | 120 | 5.5 s |

### 045 Vileplume

Planta/Veneno · Pokémon Flor · **aparece en el juego**

**Kit**: heredado de Oddish, estilo *desgaste* (distancia preferida 75 px).

**Firma — Esporas**: Sus ataques dejan esporas en el rival (hasta 5). Florecer las hace florecer: 1+ envenena, 3+ paraliza, 5 duerme, y Oddish se cura por cada una.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| Clic der. | Polvo Veneno | Veneno | Estado | Zona | — | 1.6 s |
| Q | Paralizador | Planta | Estado | Zona | — | 5.0 s |
| R | Florecer | Planta | Estado | Mejora propia | — | 9.0 s |

**Ataques que puede aprender (7)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Absorber (kit) | Planta | Especial | Disparo | 20 | 0.9 s |
| 1 | Polvo Veneno (kit) | Veneno | Estado | Zona | — | 1.6 s |
| 3 | Paralizador (kit) | Planta | Estado | Zona | — | 5.0 s |
| 5 | Florecer (kit) | Planta | Estado | Mejora propia | — | 9.0 s |
| 1 | Aromaterapia | Planta | Estado | Mejora propia | — | 10.0 s |
| 1 | Megaagotar | Planta | Especial | Disparo | 40 | 1.5 s |
| 44 | Danza Pétalo | Planta | Especial | Área | 120 | 5.5 s |

### 046 Paras

Bicho/Planta · Pokémon Hongo · **aparece en el juego**

**Kit**: propio, estilo *control* (distancia preferida 55 px).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Arañazo | Normal | Físico | Golpe | 40 | 0.9 s |
| Clic der. | Paralizador | Planta | Estado | Zona | — | 4.0 s |
| Q | Chupavidas | Bicho | Físico | Golpe | 80 | 3.0 s |
| R | Espora | Planta | Estado | Zona | — | 11.0 s |

**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo (kit) | Normal | Físico | Golpe | 40 | 0.9 s |
| 1 | Paralizador (kit) | Planta | Estado | Zona | — | 4.0 s |
| 3 | Chupavidas (kit) | Bicho | Físico | Golpe | 80 | 3.0 s |
| 5 | Espora (kit) | Planta | Estado | Zona | — | 11.0 s |
| 13 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 31 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 37 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 43 | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| 49 | Aromaterapia | Planta | Estado | Mejora propia | — | 10.0 s |

### 047 Parasect

Bicho/Planta · Pokémon Hongo · **aparece en el juego**

**Kit**: heredado de Paras, estilo *control* (distancia preferida 55 px).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Arañazo | Normal | Físico | Golpe | 40 | 0.9 s |
| Clic der. | Paralizador | Planta | Estado | Zona | — | 4.0 s |
| Q | Chupavidas | Bicho | Físico | Golpe | 80 | 3.0 s |
| R | Espora | Planta | Estado | Zona | — | 11.0 s |

**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo (kit) | Normal | Físico | Golpe | 40 | 0.9 s |
| 1 | Paralizador (kit) | Planta | Estado | Zona | — | 4.0 s |
| 3 | Chupavidas (kit) | Bicho | Físico | Golpe | 80 | 3.0 s |
| 5 | Espora (kit) | Planta | Estado | Zona | — | 11.0 s |
| 1 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 35 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 43 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 51 | Gigadrenado | Planta | Especial | Disparo | 75 | 2.1 s |
| 59 | Aromaterapia | Planta | Estado | Mejora propia | — | 10.0 s |

### 048 Venonat

Bicho/Veneno · Pokémon Insecto · **aparece en el juego**

**Kit**: propio, estilo *control* (distancia preferida 60 px).

**Firma — Ojos Compuestos**: No lo desorientan. Psicorrayo pega ×1,5 a lo paralizado (Paralizador lo deja así).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Chupavidas | Bicho | Físico | Golpe | 30 | 0.9 s |
| Clic der. | Psicorrayo | Psíquico | Especial | Disparo | 65 | 1.8 s |
| Q | Paralizador | Planta | Estado | Área | — | 7.0 s |
| R | Somnífero | Planta | Estado | Zona | — | 12.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Chupavidas (kit) | Bicho | Físico | Golpe | 30 | 0.9 s |
| 1 | Psicorrayo (kit) | Psíquico | Especial | Disparo | 65 | 1.8 s |
| 3 | Paralizador (kit) | Planta | Estado | Área | — | 7.0 s |
| 5 | Somnífero (kit) | Planta | Estado | Zona | — | 12.0 s |
| 1 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 1 | Profecía | Normal | Estado | Área | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 9 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 17 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 20 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 41 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |

### 049 Venomoth

Bicho/Veneno · Pokémon Polilla Ven. · **aparece en el juego**

**Kit**: heredado de Venonat, estilo *control* (distancia preferida 60 px).

**Firma — Ojos Compuestos**: No lo desorientan. Psicorrayo pega ×1,5 a lo paralizado (Paralizador lo deja así).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Chupavidas | Bicho | Físico | Golpe | 30 | 0.9 s |
| Clic der. | Psicorrayo | Psíquico | Especial | Disparo | 65 | 1.8 s |
| Q | Paralizador | Planta | Estado | Área | — | 7.0 s |
| R | Somnífero | Planta | Estado | Zona | — | 12.0 s |

**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Chupavidas (kit) | Bicho | Físico | Golpe | 30 | 0.9 s |
| 1 | Psicorrayo (kit) | Psíquico | Especial | Disparo | 65 | 1.8 s |
| 3 | Paralizador (kit) | Planta | Estado | Área | — | 7.0 s |
| 5 | Somnífero (kit) | Planta | Estado | Zona | — | 12.0 s |
| 1 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 1 | Profecía | Normal | Estado | Área | — | 6.0 s |
| 1 | Viento Plata | Bicho | Especial | Disparo | 60 | 1.8 s |
| 1 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 17 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 20 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 31 | Tornado | Volador | Especial | Disparo | 40 | 1.5 s |
| 52 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |

### 050 Diglett

Tierra · Pokémon Topo · **aparece en el juego**

**Kit**: propio, estilo *hostigador* (distancia preferida 35 px).

**Firma — Bajo Tierra**: Cuando le pegan se mete bajo tierra y asoma 70 px más lejos (cada 4 s). Dormido o paralizado no puede.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Arañazo | Normal | Físico | Golpe | 40 | 0.8 s |
| Clic der. | Ataque Arena | Tierra | Estado | Disparo | — | 6.0 s |
| Q | Excavar | Tierra | Físico | Zona | 80 | 6.0 s |
| R | Terremoto | Tierra | Físico | Área | 100 | 9.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo (kit) | Normal | Físico | Golpe | 40 | 0.8 s |
| 1 | Ataque Arena (kit) | Tierra | Estado | Disparo | — | 6.0 s |
| 3 | Excavar (kit) | Tierra | Físico | Zona | 80 | 6.0 s |
| 5 | Terremoto (kit) | Tierra | Físico | Área | 100 | 9.0 s |
| 5 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 9 | Magnitud | Tierra | Físico | Área | 60 | 3.7 s |
| 21 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 25 | Bofetón Lodo | Tierra | Especial | Disparo | 20 | 1.1 s |
| 33 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 49 | Fisura | Tierra | Físico | Golpe | 60 | 1.4 s |

### 051 Dugtrio

Tierra · Pokémon Topo · **aparece en el juego**

**Kit**: heredado de Diglett, estilo *hostigador* (distancia preferida 35 px).

**Firma — Bajo Tierra**: Cuando le pegan se mete bajo tierra y asoma 70 px más lejos (cada 4 s). Dormido o paralizado no puede.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Arañazo | Normal | Físico | Golpe | 40 | 0.8 s |
| Clic der. | Ataque Arena | Tierra | Estado | Disparo | — | 6.0 s |
| Q | Excavar | Tierra | Físico | Zona | 80 | 6.0 s |
| R | Terremoto | Tierra | Físico | Área | 100 | 9.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo (kit) | Normal | Físico | Golpe | 40 | 0.8 s |
| 1 | Ataque Arena (kit) | Tierra | Estado | Disparo | — | 6.0 s |
| 3 | Excavar (kit) | Tierra | Físico | Zona | 80 | 6.0 s |
| 5 | Terremoto (kit) | Tierra | Físico | Área | 100 | 9.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Triataque | Normal | Especial | Disparo | 80 | 2.1 s |
| 9 | Magnitud | Tierra | Físico | Área | 60 | 3.7 s |
| 21 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 25 | Bofetón Lodo | Tierra | Especial | Disparo | 20 | 1.1 s |
| 26 | Bucle Arena | Tierra | Físico | Golpe | 35 | 1.1 s |
| 38 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 64 | Fisura | Tierra | Físico | Golpe | 60 | 1.4 s |

### 052 Meowth

Normal · Pokémon Gato Araña · **aparece en el juego**

**Kit**: propio, estilo *asesino* (distancia preferida 30 px).

**Firma — Día de Pago**: Cada golpe que conecta hace saltar monedas: si es tu Meowth, suman a tu dinero. Cada 4 golpes le bajan 0,5 s todas las recargas.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Arañazo | Normal | Físico | Golpe | 40 | 0.8 s |
| Clic der. | Mordisco | Siniestro | Físico | Golpe | 60 | 2.5 s |
| Q | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| R | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo (kit) | Normal | Físico | Golpe | 40 | 0.8 s |
| 1 | Mordisco (kit) | Siniestro | Físico | Golpe | 60 | 2.5 s |
| 3 | Finta (kit) | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 5 | Golpes Furia (kit) | Normal | Físico | Golpe | 18 | 4.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 18 | Día de Pago | Normal | Físico | Golpe | 40 | 1.1 s |
| 31 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 40 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 43 | Sorpresa | Normal | Físico | Embestida | 40 | 1.6 s |
| 45 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |

### 053 Persian

Normal · Pokémon Gato Fino · **aparece en el juego**

**Kit**: heredado de Meowth, estilo *asesino* (distancia preferida 30 px).

**Firma — Día de Pago**: Cada golpe que conecta hace saltar monedas: si es tu Meowth, suman a tu dinero. Cada 4 golpes le bajan 0,5 s todas las recargas.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Arañazo | Normal | Físico | Golpe | 40 | 0.8 s |
| Clic der. | Mordisco | Siniestro | Físico | Golpe | 60 | 2.5 s |
| Q | Finta | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| R | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo (kit) | Normal | Físico | Golpe | 40 | 0.8 s |
| 1 | Mordisco (kit) | Siniestro | Físico | Golpe | 60 | 2.5 s |
| 3 | Finta (kit) | Siniestro | Físico | Embestida+combo | 40 | 4.0 s |
| 5 | Golpes Furia (kit) | Normal | Físico | Golpe | 18 | 4.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 18 | Día de Pago | Normal | Físico | Golpe | 40 | 1.1 s |
| 34 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 49 | Cuchillada | Normal | Físico | Golpe | 70 | 1.3 s |
| 55 | Sorpresa | Normal | Físico | Embestida | 40 | 1.6 s |
| 61 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |

### 054 Psyduck

Agua · Pokémon Pato · **aparece en el juego**

**Kit**: propio, estilo *caotico* (distancia preferida 65 px).

**Firma — Jaqueca**: Sube al recibir daño y de a poco mientras pelea. Al llenarse estalla una Confusión en área que desorienta.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Pistola Agua | Agua | Especial | Disparo | 40 | 1.2 s |
| Clic der. | Arañazo | Normal | Físico | Golpe | 40 | 1.0 s |
| Q | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| R | Anulación | Normal | Estado | Disparo | — | 9.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Pistola Agua (kit) | Agua | Especial | Disparo | 40 | 1.2 s |
| 1 | Arañazo (kit) | Normal | Físico | Golpe | 40 | 1.0 s |
| 3 | Confusión (kit) | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 5 | Anulación (kit) | Normal | Estado | Disparo | — | 9.0 s |
| 1 | Hidrochorro | Agua | Especial | Área | 15 | 6.0 s |
| 5 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 23 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 31 | Autosugestión | Normal | Estado | Área | — | 6.0 s |
| 40 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 50 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

### 055 Golduck

Agua · Pokémon Pato · **aparece en el juego**

**Kit**: heredado de Psyduck, estilo *caotico* (distancia preferida 65 px).

**Firma — Jaqueca**: Sube al recibir daño y de a poco mientras pelea. Al llenarse estalla una Confusión en área que desorienta.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Pistola Agua | Agua | Especial | Disparo | 40 | 1.2 s |
| Clic der. | Arañazo | Normal | Físico | Golpe | 40 | 1.0 s |
| Q | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| R | Anulación | Normal | Estado | Disparo | — | 9.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Pistola Agua (kit) | Agua | Especial | Disparo | 40 | 1.2 s |
| 1 | Arañazo (kit) | Normal | Físico | Golpe | 40 | 1.0 s |
| 3 | Confusión (kit) | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 5 | Anulación (kit) | Normal | Estado | Disparo | — | 9.0 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 1 | Hidrochorro | Agua | Especial | Área | 15 | 6.0 s |
| 23 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 31 | Autosugestión | Normal | Estado | Área | — | 6.0 s |
| 44 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 58 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

### 056 Mankey

Lucha · Pokémon Mono Cerdo · **aparece en el juego**

**Kit**: propio, estilo *bruiser* (distancia preferida 30 px).

**Firma — Rabia**: Sube al recibir golpes (y un poco al pegar). Llena, Mankey se enfurece 5 s: pega 30% más y corre más rápido.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Arañazo | Normal | Físico | Golpe | 40 | 0.9 s |
| Clic der. | Malicioso | Normal | Estado | Área | — | 8.0 s |
| Q | Patada Baja | Lucha | Físico | Golpe | 50 | 4.0 s |
| R | Golpe Kárate | Lucha | Físico | Embestida+combo | 50 | 5.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo (kit) | Normal | Físico | Golpe | 40 | 0.9 s |
| 1 | Malicioso (kit) | Normal | Estado | Área | — | 8.0 s |
| 3 | Patada Baja (kit) | Lucha | Físico | Golpe | 50 | 4.0 s |
| 5 | Golpe Kárate (kit) | Lucha | Físico | Embestida+combo | 50 | 5.0 s |
| 16 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 21 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 26 | Sísmico | Lucha | Físico | Embestida+combo | 70 | 7.0 s |
| 31 | Tajo Cruzado | Lucha | Físico | Embestida | 100 | 2.5 s |
| 36 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 41 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 46 | Saña | Normal | Físico | Embestida | 120 | 2.7 s |

### 057 Primeape

Lucha · Pokémon Mono Cerdo · **aparece en el juego**

**Kit**: heredado de Mankey, estilo *bruiser* (distancia preferida 30 px).

**Firma — Rabia**: Sube al recibir golpes (y un poco al pegar). Llena, Mankey se enfurece 5 s: pega 30% más y corre más rápido.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Arañazo | Normal | Físico | Golpe | 40 | 0.9 s |
| Clic der. | Malicioso | Normal | Estado | Área | — | 8.0 s |
| Q | Patada Baja | Lucha | Físico | Golpe | 50 | 4.0 s |
| R | Golpe Kárate | Lucha | Físico | Embestida+combo | 50 | 5.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo (kit) | Normal | Físico | Golpe | 40 | 0.9 s |
| 1 | Malicioso (kit) | Normal | Estado | Área | — | 8.0 s |
| 3 | Patada Baja (kit) | Lucha | Físico | Golpe | 50 | 4.0 s |
| 5 | Golpe Kárate (kit) | Lucha | Físico | Embestida+combo | 50 | 5.0 s |
| 1 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 16 | Golpes Furia | Normal | Físico | Golpe | 18 | 4.0 s |
| 21 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 26 | Sísmico | Lucha | Físico | Embestida+combo | 70 | 7.0 s |
| 35 | Tajo Cruzado | Lucha | Físico | Embestida | 100 | 2.5 s |
| 44 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 53 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 62 | Saña | Normal | Físico | Embestida | 120 | 2.7 s |

### 058 Growlithe

Fuego · Pokémon Perrito · **aparece en el juego**

**Kit**: propio, estilo *perseguidor* (distancia preferida 40 px).

**Firma — Rastreo**: Sus golpes marcan al rival 6 s. Contra el marcado corre más rápido y pega más.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Mordisco | Siniestro | Físico | Golpe | 60 | 1.1 s |
| Clic der. | Ascuas | Fuego | Especial | Disparo | 40 | 1.3 s |
| Q | Rugido | Normal | Estado | Área | — | 6.0 s |
| R | Rueda Fuego | Fuego | Físico | Embestida | 60 | 6.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco (kit) | Siniestro | Físico | Golpe | 60 | 1.1 s |
| 1 | Ascuas (kit) | Fuego | Especial | Disparo | 40 | 1.3 s |
| 3 | Rugido (kit) | Normal | Estado | Área | — | 6.0 s |
| 5 | Rueda Fuego (kit) | Fuego | Físico | Embestida | 60 | 6.0 s |
| 13 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 19 | Rastreo | Normal | Estado | Área | — | 6.0 s |
| 25 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 37 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 43 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 49 | Lanzallamas | Fuego | Especial | Disparo | 90 | 2.4 s |

### 059 Arcanine

Fuego · Pokémon Leyenda · **aparece en el juego**

**Kit**: heredado de Growlithe, estilo *perseguidor* (distancia preferida 40 px).

**Firma — Rastreo**: Sus golpes marcan al rival 6 s. Contra el marcado corre más rápido y pega más.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Mordisco | Siniestro | Físico | Golpe | 60 | 1.1 s |
| Clic der. | Ascuas | Fuego | Especial | Disparo | 40 | 1.3 s |
| Q | Rugido | Normal | Estado | Área | — | 6.0 s |
| R | Rueda Fuego | Fuego | Físico | Embestida | 60 | 6.0 s |

**Ataques que puede aprender (6)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco (kit) | Siniestro | Físico | Golpe | 60 | 1.1 s |
| 1 | Ascuas (kit) | Fuego | Especial | Disparo | 40 | 1.3 s |
| 3 | Rugido (kit) | Normal | Estado | Área | — | 6.0 s |
| 5 | Rueda Fuego (kit) | Fuego | Físico | Embestida | 60 | 6.0 s |
| 1 | Rastreo | Normal | Estado | Área | — | 6.0 s |
| 49 | Velocidad Extrema | Normal | Físico | Embestida | 80 | 2.1 s |

### 060 Poliwag

Agua · Pokémon Renacuajo · **aparece en el juego**

**Kit**: propio, estilo *velocista* (distancia preferida 70 px).

**Firma — Deslizamiento**: Sobre el agua o el suelo mojado se mueve más rápido y esquiva el doble de seguido. Danza Lluvia moja el piso alrededor.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Burbuja | Agua | Especial | Disparo | 40 | 3.0 s |
| Clic der. | Pistola Agua | Agua | Especial | Disparo | 40 | 1.4 s |
| Q | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| R | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |

**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja (kit) | Agua | Especial | Disparo | 40 | 3.0 s |
| 1 | Pistola Agua (kit) | Agua | Especial | Disparo | 40 | 1.4 s |
| 3 | Danza Lluvia (kit) | Agua | Estado | Área | — | 7.0 s |
| 5 | Hipnosis (kit) | Psíquico | Estado | Disparo | — | 10.0 s |
| 19 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 31 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 37 | Tambor | Normal | Estado | Mejora propia | — | 10.0 s |
| 43 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

### 061 Poliwhirl

Agua · Pokémon Renacuajo · **aparece en el juego**

**Kit**: heredado de Poliwag, estilo *velocista* (distancia preferida 70 px).

**Firma — Deslizamiento**: Sobre el agua o el suelo mojado se mueve más rápido y esquiva el doble de seguido. Danza Lluvia moja el piso alrededor.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Burbuja | Agua | Especial | Disparo | 40 | 3.0 s |
| Clic der. | Pistola Agua | Agua | Especial | Disparo | 40 | 1.4 s |
| Q | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| R | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |

**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja (kit) | Agua | Especial | Disparo | 40 | 3.0 s |
| 1 | Pistola Agua (kit) | Agua | Especial | Disparo | 40 | 1.4 s |
| 3 | Danza Lluvia (kit) | Agua | Estado | Área | — | 7.0 s |
| 5 | Hipnosis (kit) | Psíquico | Estado | Disparo | — | 10.0 s |
| 19 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 35 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 43 | Tambor | Normal | Estado | Mejora propia | — | 10.0 s |
| 51 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

### 062 Poliwrath

Agua/Lucha · Pokémon Renacuajo

**Kit**: heredado de Poliwag, estilo *velocista* (distancia preferida 70 px).

**Firma — Deslizamiento**: Sobre el agua o el suelo mojado se mueve más rápido y esquiva el doble de seguido. Danza Lluvia moja el piso alrededor.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Burbuja | Agua | Especial | Disparo | 40 | 3.0 s |
| Clic der. | Pistola Agua | Agua | Especial | Disparo | 40 | 1.4 s |
| Q | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| R | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |

**Ataques que puede aprender (7)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja (kit) | Agua | Especial | Disparo | 40 | 3.0 s |
| 1 | Pistola Agua (kit) | Agua | Especial | Disparo | 40 | 1.4 s |
| 3 | Danza Lluvia (kit) | Agua | Estado | Área | — | 7.0 s |
| 5 | Hipnosis (kit) | Psíquico | Estado | Disparo | — | 10.0 s |
| 1 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 1 | Sumisión | Lucha | Físico | Embestida | 80 | 2.1 s |
| 51 | Telépata | Normal | Estado | Área | — | 6.0 s |

### 063 Abra

Psíquico · Pokémon Psi · **aparece en el juego**

**Kit**: propio, estilo *velocista* (distancia preferida 90 px).

**Firma — Sueño Vigilante**: Cuando le pegan se teletransporta solo lejos del atacante (cada 6 s). Dormido o paralizado no se escapa: así se lo atrapa.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Destello Psíquico | Psíquico | Especial | Disparo | 30 | 1.0 s |
| Clic der. | Teletransporte | Psíquico | Estado | Embestida | — | 3.0 s |
| Q | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| R | Teletransporte Lejano | Psíquico | Estado | Embestida | — | 10.0 s |

**Ataques que puede aprender (4)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Destello Psíquico (kit) | Psíquico | Especial | Disparo | 30 | 1.0 s |
| 1 | Teletransporte (kit) | Psíquico | Estado | Embestida | — | 3.0 s |
| 3 | Confusión (kit) | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 5 | Teletransporte Lejano (kit) | Psíquico | Estado | Embestida | — | 10.0 s |

### 064 Kadabra

Psíquico · Pokémon Psi · **aparece en el juego**

**Kit**: propio, estilo *control* (distancia preferida 105 px).

**Firma — Mente Rápida**: Después de Teletransporte, el próximo golpe (2 s) es un Golpe Mental: +50% de daño y desorienta seguro.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Confusión | Psíquico | Especial | Disparo | 50 | 1.3 s |
| Clic der. | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| Q | Kinético | Psíquico | Estado | Área | — | 8.0 s |
| R | Teletransporte | Psíquico | Estado | Embestida | — | 4.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Confusión (kit) | Psíquico | Especial | Disparo | 50 | 1.3 s |
| 1 | Psicorrayo (kit) | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 3 | Kinético (kit) | Psíquico | Estado | Área | — | 8.0 s |
| 5 | Teletransporte (kit) | Psíquico | Estado | Embestida | — | 4.0 s |
| 18 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 23 | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 25 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |
| 30 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |
| 33 | Imitación | Psíquico | Estado | Área | — | 6.0 s |
| 36 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 43 | Truco | Psíquico | Estado | Área | — | 6.0 s |

### 065 Alakazam

Psíquico · Pokémon Psi · **aparece en el juego**

**Kit**: heredado de Kadabra, estilo *control* (distancia preferida 105 px).

**Firma — Mente Rápida**: Después de Teletransporte, el próximo golpe (2 s) es un Golpe Mental: +50% de daño y desorienta seguro.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Confusión | Psíquico | Especial | Disparo | 50 | 1.3 s |
| Clic der. | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| Q | Kinético | Psíquico | Estado | Área | — | 8.0 s |
| R | Teletransporte | Psíquico | Estado | Embestida | — | 4.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Confusión (kit) | Psíquico | Especial | Disparo | 50 | 1.3 s |
| 1 | Psicorrayo (kit) | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 3 | Kinético (kit) | Psíquico | Estado | Área | — | 8.0 s |
| 5 | Teletransporte (kit) | Psíquico | Estado | Embestida | — | 4.0 s |
| 18 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 23 | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 25 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |
| 30 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |
| 33 | Paz Mental | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 36 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 43 | Truco | Psíquico | Estado | Área | — | 6.0 s |

### 066 Machop

Lucha · Pokémon Superpoder · **aparece en el juego**

**Kit**: propio, estilo *bruiser* (distancia preferida 30 px).

**Firma — Incansable**: Cada golpe cuerpo a cuerpo que conecta le baja 0,3 s todas las recargas. No lo pueden ralentizar.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Golpe Kárate | Lucha | Físico | Golpe | 50 | 0.9 s |
| Clic der. | Patada Baja | Lucha | Físico | Golpe | 50 | 3.5 s |
| Q | Malicioso | Normal | Estado | Área | — | 8.0 s |
| R | Sísmico | Lucha | Físico | Embestida+combo | 70 | 7.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Golpe Kárate (kit) | Lucha | Físico | Golpe | 50 | 0.9 s |
| 1 | Patada Baja (kit) | Lucha | Físico | Golpe | 50 | 3.5 s |
| 3 | Malicioso (kit) | Normal | Estado | Área | — | 8.0 s |
| 5 | Sísmico (kit) | Lucha | Físico | Embestida+combo | 70 | 7.0 s |
| 7 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 22 | Profecía | Normal | Estado | Área | — | 6.0 s |
| 25 | Desquite | Lucha | Físico | Golpe | 60 | 1.4 s |
| 31 | Llave Vital | Lucha | Físico | Golpe | 70 | 1.5 s |
| 37 | Sumisión | Lucha | Físico | Embestida | 80 | 2.1 s |
| 40 | Tajo Cruzado | Lucha | Físico | Embestida | 100 | 2.5 s |
| 43 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 49 | Puño Dinámico | Lucha | Físico | Embestida | 100 | 2.5 s |

### 067 Machoke

Lucha · Pokémon Superpoder · **aparece en el juego**

**Kit**: heredado de Machop, estilo *bruiser* (distancia preferida 30 px).

**Firma — Incansable**: Cada golpe cuerpo a cuerpo que conecta le baja 0,3 s todas las recargas. No lo pueden ralentizar.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Golpe Kárate | Lucha | Físico | Golpe | 50 | 0.9 s |
| Clic der. | Patada Baja | Lucha | Físico | Golpe | 50 | 3.5 s |
| Q | Malicioso | Normal | Estado | Área | — | 8.0 s |
| R | Sísmico | Lucha | Físico | Embestida+combo | 70 | 7.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Golpe Kárate (kit) | Lucha | Físico | Golpe | 50 | 0.9 s |
| 1 | Patada Baja (kit) | Lucha | Físico | Golpe | 50 | 3.5 s |
| 3 | Malicioso (kit) | Normal | Estado | Área | — | 8.0 s |
| 5 | Sísmico (kit) | Lucha | Físico | Embestida+combo | 70 | 7.0 s |
| 1 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 22 | Profecía | Normal | Estado | Área | — | 6.0 s |
| 25 | Desquite | Lucha | Físico | Golpe | 60 | 1.4 s |
| 33 | Llave Vital | Lucha | Físico | Golpe | 70 | 1.5 s |
| 41 | Sumisión | Lucha | Físico | Embestida | 80 | 2.1 s |
| 46 | Tajo Cruzado | Lucha | Físico | Embestida | 100 | 2.5 s |
| 51 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 59 | Puño Dinámico | Lucha | Físico | Embestida | 100 | 2.5 s |

### 068 Machamp

Lucha · Pokémon Superpoder · **aparece en el juego**

**Kit**: heredado de Machop, estilo *bruiser* (distancia preferida 30 px).

**Firma — Incansable**: Cada golpe cuerpo a cuerpo que conecta le baja 0,3 s todas las recargas. No lo pueden ralentizar.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Golpe Kárate | Lucha | Físico | Golpe | 50 | 0.9 s |
| Clic der. | Patada Baja | Lucha | Físico | Golpe | 50 | 3.5 s |
| Q | Malicioso | Normal | Estado | Área | — | 8.0 s |
| R | Sísmico | Lucha | Físico | Embestida+combo | 70 | 7.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Golpe Kárate (kit) | Lucha | Físico | Golpe | 50 | 0.9 s |
| 1 | Patada Baja (kit) | Lucha | Físico | Golpe | 50 | 3.5 s |
| 3 | Malicioso (kit) | Normal | Estado | Área | — | 8.0 s |
| 5 | Sísmico (kit) | Lucha | Físico | Embestida+combo | 70 | 7.0 s |
| 1 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 22 | Profecía | Normal | Estado | Área | — | 6.0 s |
| 25 | Desquite | Lucha | Físico | Golpe | 60 | 1.4 s |
| 33 | Llave Vital | Lucha | Físico | Golpe | 70 | 1.5 s |
| 41 | Sumisión | Lucha | Físico | Embestida | 80 | 2.1 s |
| 46 | Tajo Cruzado | Lucha | Físico | Embestida | 100 | 2.5 s |
| 51 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 59 | Puño Dinámico | Lucha | Físico | Embestida | 100 | 2.5 s |

### 069 Bellsprout

Planta/Veneno · Pokémon Flor · **aparece en el juego**

**Kit**: propio, estilo *control* (distancia preferida 60 px).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| Clic der. | Látigo Cepa | Planta | Físico | Látigo | 45 | 4.0 s |
| Q | Arraigo | Planta | Estado | Mejora propia | — | 10.0 s |
| R | Somnífero | Planta | Estado | Zona | — | 12.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Polvo Veneno (kit) | Veneno | Estado | Zona | — | 1.3 s |
| 1 | Látigo Cepa (kit) | Planta | Físico | Látigo | 45 | 4.0 s |
| 3 | Arraigo (kit) | Planta | Estado | Mejora propia | — | 10.0 s |
| 5 | Somnífero (kit) | Planta | Estado | Zona | — | 12.0 s |
| 6 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 11 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 19 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 23 | Ácido | Veneno | Especial | Disparo | 40 | 1.5 s |
| 30 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 37 | Hoja Afilada | Planta | Físico | Disparo | 55 | 1.7 s |
| 45 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |

### 070 Weepinbell

Planta/Veneno · Pokémon Matamoscas · **aparece en el juego**

**Kit**: heredado de Bellsprout, estilo *control* (distancia preferida 60 px).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| Clic der. | Látigo Cepa | Planta | Físico | Látigo | 45 | 4.0 s |
| Q | Arraigo | Planta | Estado | Mejora propia | — | 10.0 s |
| R | Somnífero | Planta | Estado | Zona | — | 12.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Polvo Veneno (kit) | Veneno | Estado | Zona | — | 1.3 s |
| 1 | Látigo Cepa (kit) | Planta | Físico | Látigo | 45 | 4.0 s |
| 3 | Arraigo (kit) | Planta | Estado | Mejora propia | — | 10.0 s |
| 5 | Somnífero (kit) | Planta | Estado | Zona | — | 12.0 s |
| 1 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 19 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 24 | Ácido | Veneno | Especial | Disparo | 40 | 1.5 s |
| 33 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 42 | Hoja Afilada | Planta | Físico | Disparo | 55 | 1.7 s |
| 54 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |

### 071 Victreebel

Planta/Veneno · Pokémon Matamoscas · **aparece en el juego**

**Kit**: heredado de Bellsprout, estilo *control* (distancia preferida 60 px).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| Clic der. | Látigo Cepa | Planta | Físico | Látigo | 45 | 4.0 s |
| Q | Arraigo | Planta | Estado | Mejora propia | — | 10.0 s |
| R | Somnífero | Planta | Estado | Zona | — | 12.0 s |

**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Polvo Veneno (kit) | Veneno | Estado | Zona | — | 1.3 s |
| 1 | Látigo Cepa (kit) | Planta | Físico | Látigo | 45 | 4.0 s |
| 3 | Arraigo (kit) | Planta | Estado | Mejora propia | — | 10.0 s |
| 5 | Somnífero (kit) | Planta | Estado | Zona | — | 12.0 s |
| 1 | Hoja Afilada | Planta | Físico | Disparo | 55 | 1.7 s |
| 1 | Escupir | Normal | Especial | Disparo | 60 | 1.8 s |
| 1 | Reserva | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Tragar | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |

### 072 Tentacool

Agua/Veneno · Pokémon Medusa · **aparece en el juego**

**Kit**: propio, estilo *control* (distancia preferida 60 px).

**Firma — Cuerpo de Agua**: Sobre agua o suelo mojado (o empapado) se cura 2% por segundo; en seco va 10% más lento.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Picotazo Veneno | Veneno | Físico | Látigo | 25 | 0.9 s |
| Clic der. | Restricción | Normal | Físico | Látigo | 15 | 5.0 s |
| Q | Ácido | Veneno | Especial | Zona | 20 | 6.0 s |
| R | Rayo Burbuja | Agua | Especial | Disparo | 30 | 3.0 s |

**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo Veneno (kit) | Veneno | Físico | Látigo | 25 | 0.9 s |
| 1 | Restricción (kit) | Normal | Físico | Látigo | 15 | 5.0 s |
| 3 | Ácido (kit) | Veneno | Especial | Zona | 20 | 6.0 s |
| 5 | Rayo Burbuja (kit) | Agua | Especial | Disparo | 30 | 3.0 s |
| 6 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 30 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 36 | Barrera | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 43 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 49 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

### 073 Tentacruel

Agua/Veneno · Pokémon Medusa · **aparece en el juego**

**Kit**: heredado de Tentacool, estilo *control* (distancia preferida 60 px).

**Firma — Cuerpo de Agua**: Sobre agua o suelo mojado (o empapado) se cura 2% por segundo; en seco va 10% más lento.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Picotazo Veneno | Veneno | Físico | Látigo | 25 | 0.9 s |
| Clic der. | Restricción | Normal | Físico | Látigo | 15 | 5.0 s |
| Q | Ácido | Veneno | Especial | Zona | 20 | 6.0 s |
| R | Rayo Burbuja | Agua | Especial | Disparo | 30 | 3.0 s |

**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo Veneno (kit) | Veneno | Físico | Látigo | 25 | 0.9 s |
| 1 | Restricción (kit) | Normal | Físico | Látigo | 15 | 5.0 s |
| 3 | Ácido (kit) | Veneno | Especial | Zona | 20 | 6.0 s |
| 5 | Rayo Burbuja (kit) | Agua | Especial | Disparo | 30 | 3.0 s |
| 1 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 30 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 38 | Barrera | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 47 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 55 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

### 074 Geodude

Roca/Tierra · Pokémon Roca · **aparece en el juego**

**Kit**: propio, estilo *tanque* (distancia preferida 30 px).

**Firma — Impulso**: Cada Rodar dentro de 3 s del anterior pega +50% (hasta ×2). Con Rizo Defensa activo, Rodar pega el doble.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Placaje | Normal | Físico | Golpe | 40 | 1.1 s |
| Clic der. | Rodar | Roca | Físico | Embestida | 30 | 2.0 s |
| Q | Lanzarrocas | Roca | Físico | Disparo | 50 | 1.6 s |
| R | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje (kit) | Normal | Físico | Golpe | 40 | 1.1 s |
| 1 | Rodar (kit) | Roca | Físico | Embestida | 30 | 2.0 s |
| 3 | Lanzarrocas (kit) | Roca | Físico | Disparo | 50 | 1.6 s |
| 5 | Rizo Defensa (kit) | Normal | Estado | Mejora propia | — | 10.0 s |
| 6 | Chapoteo Lodo | Tierra | Estado | Mejora propia | — | 10.0 s |
| 16 | Magnitud | Tierra | Físico | Área | 60 | 3.7 s |
| 21 | Autodestrucción | Normal | Físico | Área | 130 | 20.0 s |
| 31 | Pedrada | Roca | Físico | Golpe | 25 | 0.9 s |
| 36 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 41 | Explosión | Normal | Físico | Área | 250 | 9.2 s |
| 46 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

### 075 Graveler

Roca/Tierra · Pokémon Roca · **aparece en el juego**

**Kit**: heredado de Geodude, estilo *tanque* (distancia preferida 30 px).

**Firma — Impulso**: Cada Rodar dentro de 3 s del anterior pega +50% (hasta ×2). Con Rizo Defensa activo, Rodar pega el doble.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Placaje | Normal | Físico | Golpe | 40 | 1.1 s |
| Clic der. | Rodar | Roca | Físico | Embestida | 30 | 2.0 s |
| Q | Lanzarrocas | Roca | Físico | Disparo | 50 | 1.6 s |
| R | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje (kit) | Normal | Físico | Golpe | 40 | 1.1 s |
| 1 | Rodar (kit) | Roca | Físico | Embestida | 30 | 2.0 s |
| 3 | Lanzarrocas (kit) | Roca | Físico | Disparo | 50 | 1.6 s |
| 5 | Rizo Defensa (kit) | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Chapoteo Lodo | Tierra | Estado | Mejora propia | — | 10.0 s |
| 16 | Magnitud | Tierra | Físico | Área | 60 | 3.7 s |
| 21 | Autodestrucción | Normal | Físico | Área | 130 | 20.0 s |
| 37 | Pedrada | Roca | Físico | Golpe | 25 | 0.9 s |
| 45 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 53 | Explosión | Normal | Físico | Área | 250 | 9.2 s |
| 62 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

### 076 Golem

Roca/Tierra · Pokémon Megatón

**Kit**: heredado de Geodude, estilo *tanque* (distancia preferida 30 px).

**Firma — Impulso**: Cada Rodar dentro de 3 s del anterior pega +50% (hasta ×2). Con Rizo Defensa activo, Rodar pega el doble.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Placaje | Normal | Físico | Golpe | 40 | 1.1 s |
| Clic der. | Rodar | Roca | Físico | Embestida | 30 | 2.0 s |
| Q | Lanzarrocas | Roca | Físico | Disparo | 50 | 1.6 s |
| R | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje (kit) | Normal | Físico | Golpe | 40 | 1.1 s |
| 1 | Rodar (kit) | Roca | Físico | Embestida | 30 | 2.0 s |
| 3 | Lanzarrocas (kit) | Roca | Físico | Disparo | 50 | 1.6 s |
| 5 | Rizo Defensa (kit) | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Chapoteo Lodo | Tierra | Estado | Mejora propia | — | 10.0 s |
| 16 | Magnitud | Tierra | Físico | Área | 60 | 3.7 s |
| 21 | Autodestrucción | Normal | Físico | Área | 130 | 20.0 s |
| 37 | Pedrada | Roca | Físico | Golpe | 25 | 0.9 s |
| 45 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 53 | Explosión | Normal | Físico | Área | 250 | 9.2 s |
| 62 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

### 077 Ponyta

Fuego · Pokémon Caballo Fuego · **aparece en el juego**

**Kit**: propio, estilo *velocista* (distancia preferida 35 px).

**Firma — Galope**: Correr derecho llena el galope: hasta ×1,4 de velocidad y una estela de fuego que prende el pasto. Sus embestidas pegan hasta +40% galopando. Girar fuerte lo pierde.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Pisotón | Normal | Físico | Golpe | 65 | 1.2 s |
| Clic der. | Ascuas | Fuego | Especial | Disparo | 40 | 1.0 s |
| Q | Giro Fuego | Fuego | Especial | Zona | 15 | 6.0 s |
| R | Derribo | Normal | Físico | Embestida | 90 | 5.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Pisotón (kit) | Normal | Físico | Golpe | 65 | 1.2 s |
| 1 | Ascuas (kit) | Fuego | Especial | Disparo | 40 | 1.0 s |
| 3 | Giro Fuego (kit) | Fuego | Especial | Zona | 15 | 6.0 s |
| 5 | Derribo (kit) | Normal | Físico | Embestida | 90 | 5.0 s |
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 5 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 9 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 38 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 45 | Bote | Volador | Físico | Embestida | 85 | 2.2 s |
| 53 | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |

### 078 Rapidash

Fuego · Pokémon Caballo Fuego · **aparece en el juego**

**Kit**: heredado de Ponyta, estilo *velocista* (distancia preferida 35 px).

**Firma — Galope**: Correr derecho llena el galope: hasta ×1,4 de velocidad y una estela de fuego que prende el pasto. Sus embestidas pegan hasta +40% galopando. Girar fuerte lo pierde.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Pisotón | Normal | Físico | Golpe | 65 | 1.2 s |
| Clic der. | Ascuas | Fuego | Especial | Disparo | 40 | 1.0 s |
| Q | Giro Fuego | Fuego | Especial | Zona | 15 | 6.0 s |
| R | Derribo | Normal | Físico | Embestida | 90 | 5.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Pisotón (kit) | Normal | Físico | Golpe | 65 | 1.2 s |
| 1 | Ascuas (kit) | Fuego | Especial | Disparo | 40 | 1.0 s |
| 3 | Giro Fuego (kit) | Fuego | Especial | Zona | 15 | 6.0 s |
| 5 | Derribo (kit) | Normal | Físico | Embestida | 90 | 5.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 38 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 40 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 50 | Bote | Volador | Físico | Embestida | 85 | 2.2 s |
| 63 | Llamarada | Fuego | Especial | Disparo | 110 | 2.7 s |

### 079 Slowpoke

Agua/Psíquico · Pokémon Atontado · **aparece en el juego**

**Kit**: propio, estilo *tanque* (distancia preferida 50 px).

**Firma — Reacción Tardía**: De cada golpe recibe ahora el 70%; el resto le llega 2 s tarde, salvo que en ese tiempo él conecte un golpe. Bostezo: si el rival sigue con sueño a los 2 s, se duerme.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.4 s |
| Clic der. | Pistola Agua | Agua | Especial | Disparo | 40 | 1.2 s |
| Q | Pesca con Cola | Agua | Físico | Látigo | 20 | 4.0 s |
| R | Bostezo | Normal | Estado | Disparo | — | 9.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Golpe Cabeza (kit) | Normal | Físico | Golpe | 70 | 1.4 s |
| 1 | Pistola Agua (kit) | Agua | Especial | Disparo | 40 | 1.2 s |
| 3 | Pesca con Cola (kit) | Agua | Físico | Látigo | 20 | 4.0 s |
| 5 | Bostezo (kit) | Normal | Estado | Disparo | — | 9.0 s |
| 1 | Maldición | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 6 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 17 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 24 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 36 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 40 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 47 | Autosugestión | Normal | Estado | Área | — | 6.0 s |

### 080 Slowbro

Agua/Psíquico · Pokémon Ermitaño · **aparece en el juego**

**Kit**: heredado de Slowpoke, estilo *tanque* (distancia preferida 50 px).

**Firma — Reacción Tardía**: De cada golpe recibe ahora el 70%; el resto le llega 2 s tarde, salvo que en ese tiempo él conecte un golpe. Bostezo: si el rival sigue con sueño a los 2 s, se duerme.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.4 s |
| Clic der. | Pistola Agua | Agua | Especial | Disparo | 40 | 1.2 s |
| Q | Pesca con Cola | Agua | Físico | Látigo | 20 | 4.0 s |
| R | Bostezo | Normal | Estado | Disparo | — | 9.0 s |

**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Golpe Cabeza (kit) | Normal | Físico | Golpe | 70 | 1.4 s |
| 1 | Pistola Agua (kit) | Agua | Especial | Disparo | 40 | 1.2 s |
| 3 | Pesca con Cola (kit) | Agua | Físico | Látigo | 20 | 4.0 s |
| 5 | Bostezo (kit) | Normal | Estado | Disparo | — | 9.0 s |
| 1 | Maldición | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 17 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 24 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 36 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 37 | Refugio | Agua | Estado | Mejora propia | — | 9.0 s |
| 44 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 55 | Autosugestión | Normal | Estado | Área | — | 6.0 s |

### 081 Magnemite

Eléctrico/Acero · Pokémon Imán · **aparece en el juego**

**Kit**: propio, estilo *espaciador* (distancia preferida 100 px).

**Firma — Magnetismo**: Flota: no lo ralentizan ni lo enraízan. Sus disparos eléctricos atraen un poco al rival en vez de empujarlo, y pega +25% a lo que marcó con Fijar Blanco (Expuesto).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Impactrueno | Eléctrico | Especial | Disparo | 40 | 1.0 s |
| Clic der. | Bomba Sónica | Normal | Especial | Área | 25 | 4.0 s |
| Q | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| R | Fijar Blanco | Normal | Estado | Disparo | — | 8.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Impactrueno (kit) | Eléctrico | Especial | Disparo | 40 | 1.0 s |
| 1 | Bomba Sónica (kit) | Normal | Especial | Área | 25 | 4.0 s |
| 3 | Supersónico (kit) | Normal | Estado | Canalizado | — | 6.0 s |
| 5 | Fijar Blanco (kit) | Normal | Estado | Disparo | — | 8.0 s |
| 1 | Eco Metálico | Acero | Estado | Área | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 21 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 26 | Chispa | Eléctrico | Físico | Embestida | 65 | 6.0 s |
| 38 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 44 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 50 | Electrocañón | Eléctrico | Especial | Disparo | 120 | 2.9 s |

### 082 Magneton

Eléctrico/Acero · Pokémon Imán · **aparece en el juego**

**Kit**: heredado de Magnemite, estilo *espaciador* (distancia preferida 100 px).

**Firma — Magnetismo**: Flota: no lo ralentizan ni lo enraízan. Sus disparos eléctricos atraen un poco al rival en vez de empujarlo, y pega +25% a lo que marcó con Fijar Blanco (Expuesto).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Impactrueno | Eléctrico | Especial | Disparo | 40 | 1.0 s |
| Clic der. | Bomba Sónica | Normal | Especial | Área | 25 | 4.0 s |
| Q | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| R | Fijar Blanco | Normal | Estado | Disparo | — | 8.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Impactrueno (kit) | Eléctrico | Especial | Disparo | 40 | 1.0 s |
| 1 | Bomba Sónica (kit) | Normal | Especial | Área | 25 | 4.0 s |
| 3 | Supersónico (kit) | Normal | Estado | Canalizado | — | 6.0 s |
| 5 | Fijar Blanco (kit) | Normal | Estado | Disparo | — | 8.0 s |
| 1 | Eco Metálico | Acero | Estado | Área | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 21 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 26 | Chispa | Eléctrico | Físico | Embestida | 65 | 6.0 s |
| 44 | Triataque | Normal | Especial | Disparo | 80 | 2.1 s |
| 53 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 62 | Electrocañón | Eléctrico | Especial | Disparo | 120 | 2.9 s |

### 083 Farfetch’d

Normal/Volador · Pokémon Pato Salvaje · **aparece en el juego**

**Kit**: propio, estilo *asesino* (distancia preferida 30 px).

**Firma — Puerro**: Con el puerro, Cuchillada pega ×1,6 a un rival Expuesto (Malicioso lo deja así).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| Clic der. | Malicioso | Normal | Estado | Disparo | — | 6.0 s |
| Q | Danza Espada | Normal | Estado | Mejora propia | — | 10.0 s |
| R | Cuchillada | Normal | Físico | Golpe | 70 | 3.5 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo (kit) | Volador | Físico | Golpe | 35 | 0.8 s |
| 1 | Malicioso (kit) | Normal | Estado | Disparo | — | 6.0 s |
| 3 | Danza Espada (kit) | Normal | Estado | Mejora propia | — | 10.0 s |
| 5 | Cuchillada (kit) | Normal | Físico | Golpe | 70 | 3.5 s |
| 6 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 16 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 21 | Desarme | Siniestro | Físico | Golpe | 65 | 1.4 s |
| 26 | Corte Furia | Bicho | Físico | Golpe | 40 | 1.1 s |
| 36 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 46 | Falso Tortazo | Normal | Físico | Golpe | 40 | 1.1 s |

### 084 Doduo

Normal/Volador · Pokémon Ave Gemela · **aparece en el juego**

**Kit**: propio, estilo *velocista* (distancia preferida 30 px).

**Firma — Carrera**: Correr derecho llena la carrera: hasta ×1,35 de velocidad, y sus embestidas pegan hasta +40%. Girar fuerte la pierde.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| Clic der. | Ataque Furia | Normal | Físico | Golpe | 15 | 2.0 s |
| Q | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| R | Pico Taladro | Volador | Físico | Embestida | 80 | 5.0 s |

**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo (kit) | Volador | Físico | Golpe | 35 | 0.8 s |
| 1 | Ataque Furia (kit) | Normal | Físico | Golpe | 15 | 2.0 s |
| 3 | Agilidad (kit) | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 5 | Pico Taladro (kit) | Volador | Físico | Embestida | 80 | 5.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 9 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 21 | Triataque | Normal | Especial | Disparo | 80 | 2.1 s |
| 25 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 33 | Alboroto | Normal | Especial | Disparo | 90 | 2.4 s |

### 085 Dodrio

Normal/Volador · Pokémon Ave Triple · **aparece en el juego**

**Kit**: heredado de Doduo, estilo *velocista* (distancia preferida 30 px).

**Firma — Carrera**: Correr derecho llena la carrera: hasta ×1,35 de velocidad, y sus embestidas pegan hasta +40%. Girar fuerte la pierde.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| Clic der. | Ataque Furia | Normal | Físico | Golpe | 15 | 2.0 s |
| Q | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| R | Pico Taladro | Volador | Físico | Embestida | 80 | 5.0 s |

**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo (kit) | Volador | Físico | Golpe | 35 | 0.8 s |
| 1 | Ataque Furia (kit) | Normal | Físico | Golpe | 15 | 2.0 s |
| 3 | Agilidad (kit) | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 5 | Pico Taladro (kit) | Volador | Físico | Embestida | 80 | 5.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 21 | Triataque | Normal | Especial | Disparo | 80 | 2.1 s |
| 25 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 38 | Alboroto | Normal | Especial | Disparo | 90 | 2.4 s |

### 086 Seel

Agua · Pokémon León Marino · **aparece en el juego**

**Kit**: propio, estilo *tanque* (distancia preferida 55 px).

**Firma — Escarcha**: Sus ataques de hielo dejan escarcha en el rival (hasta 5). Con 5, se congela.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| Clic der. | Viento Hielo | Hielo | Especial | Disparo | 55 | 2.2 s |
| Q | Rayo Aurora | Hielo | Especial | Disparo | 65 | 2.5 s |
| R | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |

**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Golpe Cabeza (kit) | Normal | Físico | Golpe | 70 | 1.6 s |
| 1 | Viento Hielo (kit) | Hielo | Especial | Disparo | 55 | 2.2 s |
| 3 | Rayo Aurora (kit) | Hielo | Especial | Disparo | 65 | 2.5 s |
| 5 | Descanso (kit) | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 9 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 37 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 41 | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| 49 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |

### 087 Dewgong

Agua/Hielo · Pokémon León Marino · **aparece en el juego**

**Kit**: heredado de Seel, estilo *tanque* (distancia preferida 55 px).

**Firma — Escarcha**: Sus ataques de hielo dejan escarcha en el rival (hasta 5). Con 5, se congela.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| Clic der. | Viento Hielo | Hielo | Especial | Disparo | 55 | 2.2 s |
| Q | Rayo Aurora | Hielo | Especial | Disparo | 65 | 2.5 s |
| R | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Golpe Cabeza (kit) | Normal | Físico | Golpe | 70 | 1.6 s |
| 1 | Viento Hielo (kit) | Hielo | Especial | Disparo | 55 | 2.2 s |
| 3 | Rayo Aurora (kit) | Hielo | Especial | Disparo | 65 | 2.5 s |
| 5 | Descanso (kit) | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Rayo Señal | Bicho | Especial | Disparo | 75 | 2.1 s |
| 34 | Frío Polar | Hielo | Especial | Disparo | 60 | 1.8 s |
| 42 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 51 | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| 64 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |

### 088 Grimer

Veneno · Pokémon Lodo · **aparece en el juego**

**Kit**: propio, estilo *tanque* (distancia preferida 25 px).

**Firma — Cuerpo de Lodo**: No lo ralentizan ni lo envenenan. Al que le pega cuerpo a cuerpo lo deja pegoteado (ralentizado). Derretirse lo vuelve un charco que se desliza dejando lodo tóxico.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Destructor | Normal | Físico | Golpe | 45 | 1.1 s |
| Clic der. | Residuos | Veneno | Especial | Disparo | 65 | 2.2 s |
| Q | Armadura Ácida | Veneno | Estado | Mejora propia | — | 10.0 s |
| R | Derretirse | Veneno | Estado | Embestida | — | 6.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Destructor (kit) | Normal | Físico | Golpe | 45 | 1.1 s |
| 1 | Residuos (kit) | Veneno | Especial | Disparo | 65 | 2.2 s |
| 3 | Armadura Ácida (kit) | Veneno | Estado | Mejora propia | — | 10.0 s |
| 5 | Derretirse (kit) | Veneno | Estado | Embestida | — | 6.0 s |
| 1 | Gas Venenoso | Veneno | Estado | Zona | — | 5.0 s |
| 4 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 8 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 19 | Reducción | Normal | Estado | Mejora propia | — | 9.0 s |
| 26 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 43 | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| 53 | Legado | Siniestro | Estado | Área | — | 6.0 s |

### 089 Muk

Veneno · Pokémon Lodo · **aparece en el juego**

**Kit**: heredado de Grimer, estilo *tanque* (distancia preferida 25 px).

**Firma — Cuerpo de Lodo**: No lo ralentizan ni lo envenenan. Al que le pega cuerpo a cuerpo lo deja pegoteado (ralentizado). Derretirse lo vuelve un charco que se desliza dejando lodo tóxico.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Destructor | Normal | Físico | Golpe | 45 | 1.1 s |
| Clic der. | Residuos | Veneno | Especial | Disparo | 65 | 2.2 s |
| Q | Armadura Ácida | Veneno | Estado | Mejora propia | — | 10.0 s |
| R | Derretirse | Veneno | Estado | Embestida | — | 6.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Destructor (kit) | Normal | Físico | Golpe | 45 | 1.1 s |
| 1 | Residuos (kit) | Veneno | Especial | Disparo | 65 | 2.2 s |
| 3 | Armadura Ácida (kit) | Veneno | Estado | Mejora propia | — | 10.0 s |
| 5 | Derretirse (kit) | Veneno | Estado | Embestida | — | 6.0 s |
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 1 | Gas Venenoso | Veneno | Estado | Zona | — | 5.0 s |
| 8 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 19 | Reducción | Normal | Estado | Mejora propia | — | 9.0 s |
| 26 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 47 | Bomba Lodo | Veneno | Especial | Disparo | 90 | 2.4 s |
| 61 | Legado | Siniestro | Estado | Área | — | 6.0 s |

### 090 Shellder

Agua · Pokémon Bivalvo · **aparece en el juego**

**Kit**: propio, estilo *tanque* (distancia preferida 40 px).

**Firma — Concha Bivalva**: De frente recibe 40% menos de daño; de espaldas, 40% más (la lengua). Hay que rodearlo.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Placaje | Normal | Físico | Golpe | 40 | 1.0 s |
| Clic der. | Carámbano | Hielo | Físico | Disparo | 25 | 1.6 s |
| Q | Refugio | Agua | Estado | Mejora propia | — | 9.0 s |
| R | Tenaza | Agua | Físico | Embestida+combo | 35 | 6.0 s |

**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje (kit) | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Carámbano (kit) | Hielo | Físico | Disparo | 25 | 1.6 s |
| 3 | Refugio (kit) | Agua | Estado | Mejora propia | — | 9.0 s |
| 5 | Tenaza (kit) | Agua | Físico | Embestida+combo | 35 | 6.0 s |
| 15 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 22 | Rayo Aurora | Hielo | Especial | Disparo | 65 | 1.9 s |
| 29 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 36 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 50 | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |

### 091 Cloyster

Agua/Hielo · Pokémon Bivalvo · **aparece en el juego**

**Kit**: heredado de Shellder, estilo *tanque* (distancia preferida 40 px).

**Firma — Concha Bivalva**: De frente recibe 40% menos de daño; de espaldas, 40% más (la lengua). Hay que rodearlo.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Placaje | Normal | Físico | Golpe | 40 | 1.0 s |
| Clic der. | Carámbano | Hielo | Físico | Disparo | 25 | 1.6 s |
| Q | Refugio | Agua | Estado | Mejora propia | — | 9.0 s |
| R | Tenaza | Agua | Físico | Embestida+combo | 35 | 6.0 s |

**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje (kit) | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Carámbano (kit) | Hielo | Físico | Disparo | 25 | 1.6 s |
| 3 | Refugio (kit) | Agua | Estado | Mejora propia | — | 9.0 s |
| 5 | Tenaza (kit) | Agua | Físico | Embestida+combo | 35 | 6.0 s |
| 1 | Rayo Aurora | Hielo | Especial | Disparo | 65 | 1.9 s |
| 1 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 1 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 36 | Púas | Tierra | Estado | Mejora propia | — | 10.0 s |
| 43 | Clavo Cañón | Normal | Físico | Golpe | 20 | 0.9 s |

### 092 Gastly

Fantasma/Veneno · Pokémon Gas · **aparece en el juego**

**Kit**: propio, estilo *hostigador* (distancia preferida 70 px).

**Firma — Pesadilla**: Sus ataques fantasma suman Pavor al rival; con 3, queda paralizado de miedo. Comesueños roba vida.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Lengüetazo | Fantasma | Físico | Golpe | 30 | 0.8 s |
| Clic der. | Tinieblas | Fantasma | Especial | Disparo | 55 | 1.6 s |
| Q | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| R | Comesueños | Psíquico | Especial | Disparo | 100 | 7.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Lengüetazo (kit) | Fantasma | Físico | Golpe | 30 | 0.8 s |
| 1 | Tinieblas (kit) | Fantasma | Especial | Disparo | 55 | 1.6 s |
| 3 | Hipnosis (kit) | Psíquico | Estado | Disparo | — | 10.0 s |
| 5 | Comesueños (kit) | Psíquico | Especial | Disparo | 100 | 7.0 s |
| 8 | Rencor | Fantasma | Estado | Área | — | 6.0 s |
| 13 | Maldición | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 21 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 33 | Mismo Destino | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 36 | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| 41 | Pesadilla | Fantasma | Estado | Área | — | 6.0 s |
| 48 | Mal de Ojo | Normal | Estado | Área | — | 6.0 s |

### 093 Haunter

Fantasma/Veneno · Pokémon Gas · **aparece en el juego**

**Kit**: heredado de Gastly, estilo *hostigador* (distancia preferida 70 px).

**Firma — Pesadilla**: Sus ataques fantasma suman Pavor al rival; con 3, queda paralizado de miedo. Comesueños roba vida.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Lengüetazo | Fantasma | Físico | Golpe | 30 | 0.8 s |
| Clic der. | Tinieblas | Fantasma | Especial | Disparo | 55 | 1.6 s |
| Q | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| R | Comesueños | Psíquico | Especial | Disparo | 100 | 7.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Lengüetazo (kit) | Fantasma | Físico | Golpe | 30 | 0.8 s |
| 1 | Tinieblas (kit) | Fantasma | Especial | Disparo | 55 | 1.6 s |
| 3 | Hipnosis (kit) | Psíquico | Estado | Disparo | — | 10.0 s |
| 5 | Comesueños (kit) | Psíquico | Especial | Disparo | 100 | 7.0 s |
| 1 | Rencor | Fantasma | Estado | Área | — | 6.0 s |
| 13 | Maldición | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 21 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 25 | Puño Sombra | Fantasma | Físico | Golpe | 60 | 1.4 s |
| 39 | Mismo Destino | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 45 | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| 53 | Pesadilla | Fantasma | Estado | Área | — | 6.0 s |
| 64 | Mal de Ojo | Normal | Estado | Área | — | 6.0 s |

### 094 Gengar

Fantasma/Veneno · Pokémon Sombra · **aparece en el juego**

**Kit**: heredado de Gastly, estilo *hostigador* (distancia preferida 70 px).

**Firma — Pesadilla**: Sus ataques fantasma suman Pavor al rival; con 3, queda paralizado de miedo. Comesueños roba vida.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Lengüetazo | Fantasma | Físico | Golpe | 30 | 0.8 s |
| Clic der. | Tinieblas | Fantasma | Especial | Disparo | 55 | 1.6 s |
| Q | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| R | Comesueños | Psíquico | Especial | Disparo | 100 | 7.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Lengüetazo (kit) | Fantasma | Físico | Golpe | 30 | 0.8 s |
| 1 | Tinieblas (kit) | Fantasma | Especial | Disparo | 55 | 1.6 s |
| 3 | Hipnosis (kit) | Psíquico | Estado | Disparo | — | 10.0 s |
| 5 | Comesueños (kit) | Psíquico | Especial | Disparo | 100 | 7.0 s |
| 1 | Rencor | Fantasma | Estado | Área | — | 6.0 s |
| 13 | Maldición | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 21 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 25 | Puño Sombra | Fantasma | Físico | Golpe | 60 | 1.4 s |
| 39 | Mismo Destino | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 45 | Bola Sombra | Fantasma | Especial | Disparo | 80 | 2.1 s |
| 53 | Pesadilla | Fantasma | Estado | Área | — | 6.0 s |
| 64 | Mal de Ojo | Normal | Estado | Área | — | 6.0 s |

### 095 Onix

Roca/Tierra · Pokémon Serpiente Roca · **aparece en el juego**

**Kit**: propio, estilo *tanque* (distancia preferida 70 px).

**Firma — Coloso**: Jefe. Enorme: no lo empujan ni lo tambalean y recibe 25% menos de daño físico. Aplasta lo atrapado: +30% contra lo ralentizado. A mitad de vida ruge (empuja y deja Expuesto) y entra en Furia de Roca hasta el final.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Atadura | Normal | Físico | Látigo | 15 | 3.0 s |
| Clic der. | Lanzarrocas | Roca | Físico | Disparo | 50 | 1.8 s |
| Q | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| R | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |

**Ataques que puede aprender (14)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Atadura (kit) | Normal | Físico | Látigo | 15 | 3.0 s |
| 1 | Lanzarrocas (kit) | Roca | Físico | Disparo | 50 | 1.8 s |
| 3 | Excavar (kit) | Tierra | Físico | Zona | 80 | 8.0 s |
| 5 | Tumba Rocas (kit) | Roca | Físico | Zona | 50 | 9.0 s |
| 1 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 19 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 23 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 30 | Dragoaliento | Dragón | Especial | Disparo | 60 | 1.8 s |
| 34 | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| 41 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 45 | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| 52 | Bucle Arena | Tierra | Físico | Golpe | 35 | 1.1 s |
| 56 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

### 096 Drowzee

Psíquico · Pokémon Hipnosis · **aparece en el juego**

**Kit**: propio, estilo *control* (distancia preferida 60 px).

**Firma — Hipnosis Acumulable**: Cualquier ataque psíquico suyo suma Somnolencia al rival; con 4, se duerme. Comesueños roba vida (perfecto contra dormidos).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| Clic der. | Confusión | Psíquico | Especial | Disparo | 50 | 1.5 s |
| Q | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| R | Comesueños | Psíquico | Especial | Disparo | 100 | 7.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Destructor (kit) | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Confusión (kit) | Psíquico | Especial | Disparo | 50 | 1.5 s |
| 3 | Anulación (kit) | Normal | Estado | Disparo | — | 9.0 s |
| 5 | Comesueños (kit) | Psíquico | Especial | Disparo | 100 | 7.0 s |
| 1 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 17 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 21 | Gas Venenoso | Veneno | Estado | Zona | — | 5.0 s |
| 27 | Meditación | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 31 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 37 | Autosugestión | Normal | Estado | Área | — | 6.0 s |
| 41 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 47 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |

### 097 Hypno

Psíquico · Pokémon Hipnosis · **aparece en el juego**

**Kit**: heredado de Drowzee, estilo *control* (distancia preferida 60 px).

**Firma — Hipnosis Acumulable**: Cualquier ataque psíquico suyo suma Somnolencia al rival; con 4, se duerme. Comesueños roba vida (perfecto contra dormidos).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| Clic der. | Confusión | Psíquico | Especial | Disparo | 50 | 1.5 s |
| Q | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| R | Comesueños | Psíquico | Especial | Disparo | 100 | 7.0 s |

**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Destructor (kit) | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Confusión (kit) | Psíquico | Especial | Disparo | 50 | 1.5 s |
| 3 | Anulación (kit) | Normal | Estado | Disparo | — | 9.0 s |
| 5 | Comesueños (kit) | Psíquico | Especial | Disparo | 100 | 7.0 s |
| 1 | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| 1 | Pesadilla | Fantasma | Estado | Área | — | 6.0 s |
| 17 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 21 | Gas Venenoso | Veneno | Estado | Zona | — | 5.0 s |
| 29 | Meditación | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 35 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 43 | Autosugestión | Normal | Estado | Área | — | 6.0 s |
| 49 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 57 | Premonición | Psíquico | Especial | Disparo | 120 | 2.9 s |

### 098 Krabby

Agua · Pokémon Cangrejo

**Kit**: propio, estilo *bruiser* (distancia preferida 30 px).

**Firma — Pinza**: El caparazón lo cubre de frente (−20%). Martillazo pega ×1,5 a lo ralentizado (Agarre lo deja así).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Agarre | Normal | Físico | Golpe | 55 | 1.0 s |
| Clic der. | Burbuja | Agua | Especial | Disparo | 20 | 1.6 s |
| Q | Fortaleza | Normal | Estado | Mejora propia | — | 10.0 s |
| R | Martillazo | Agua | Físico | Golpe | 90 | 4.5 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Agarre (kit) | Normal | Físico | Golpe | 55 | 1.0 s |
| 1 | Burbuja (kit) | Agua | Especial | Disparo | 20 | 1.6 s |
| 3 | Fortaleza (kit) | Normal | Estado | Mejora propia | — | 10.0 s |
| 5 | Martillazo (kit) | Agua | Físico | Golpe | 90 | 4.5 s |
| 5 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 23 | Disparo Lodo | Tierra | Especial | Disparo | 55 | 1.7 s |
| 27 | Pisotón | Normal | Físico | Golpe | 65 | 1.2 s |
| 34 | Guillotina | Normal | Físico | Golpe | 60 | 1.4 s |
| 38 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 49 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |

### 099 Kingler

Agua · Pokémon Tenaza · **aparece en el juego**

**Kit**: heredado de Krabby, estilo *bruiser* (distancia preferida 30 px).

**Firma — Pinza**: El caparazón lo cubre de frente (−20%). Martillazo pega ×1,5 a lo ralentizado (Agarre lo deja así).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Agarre | Normal | Físico | Golpe | 55 | 1.0 s |
| Clic der. | Burbuja | Agua | Especial | Disparo | 20 | 1.6 s |
| Q | Fortaleza | Normal | Estado | Mejora propia | — | 10.0 s |
| R | Martillazo | Agua | Físico | Golpe | 90 | 4.5 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Agarre (kit) | Normal | Físico | Golpe | 55 | 1.0 s |
| 1 | Burbuja (kit) | Agua | Especial | Disparo | 20 | 1.6 s |
| 3 | Fortaleza (kit) | Normal | Estado | Mejora propia | — | 10.0 s |
| 5 | Martillazo (kit) | Agua | Físico | Golpe | 90 | 4.5 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Garra Metal | Acero | Físico | Golpe | 50 | 1.3 s |
| 23 | Disparo Lodo | Tierra | Especial | Disparo | 55 | 1.7 s |
| 27 | Pisotón | Normal | Físico | Golpe | 65 | 1.2 s |
| 38 | Guillotina | Normal | Físico | Golpe | 60 | 1.4 s |
| 42 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 65 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |

### 100 Voltorb

Eléctrico · Pokémon Bola · **aparece en el juego**

**Kit**: propio, estilo *hostigador* (distancia preferida 35 px).

**Firma — Camuflaje**: Quieto 1,5 s se camufla (casi invisible, como una Poké Ball del mapa): el próximo golpe es crítico (×1,5). Autodestrucción explota en área grande y lo deja con 1 de vida, aturdido 2 s.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Rodar | Roca | Físico | Embestida | 40 | 2.5 s |
| Clic der. | Chispa | Eléctrico | Físico | Golpe | 45 | 1.0 s |
| Q | Bomba Sónica | Normal | Especial | Área | 25 | 4.0 s |
| R | Autodestrucción | Normal | Físico | Área | 130 | 20.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Rodar (kit) | Roca | Físico | Embestida | 40 | 2.5 s |
| 1 | Chispa (kit) | Eléctrico | Físico | Golpe | 45 | 1.0 s |
| 3 | Bomba Sónica (kit) | Normal | Especial | Área | 25 | 4.0 s |
| 5 | Autodestrucción (kit) | Normal | Físico | Área | 130 | 20.0 s |
| 1 | Carga | Eléctrico | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 8 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 37 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 42 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 46 | Explosión | Normal | Físico | Área | 250 | 9.2 s |
| 49 | Manto Espejo | Psíquico | Especial | Disparo | 60 | 1.8 s |

### 101 Electrode

Eléctrico · Pokémon Bola · **aparece en el juego**

**Kit**: heredado de Voltorb, estilo *hostigador* (distancia preferida 35 px).

**Firma — Camuflaje**: Quieto 1,5 s se camufla (casi invisible, como una Poké Ball del mapa): el próximo golpe es crítico (×1,5). Autodestrucción explota en área grande y lo deja con 1 de vida, aturdido 2 s.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Rodar | Roca | Físico | Embestida | 40 | 2.5 s |
| Clic der. | Chispa | Eléctrico | Físico | Golpe | 45 | 1.0 s |
| Q | Bomba Sónica | Normal | Especial | Área | 25 | 4.0 s |
| R | Autodestrucción | Normal | Físico | Área | 130 | 20.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Rodar (kit) | Roca | Físico | Embestida | 40 | 2.5 s |
| 1 | Chispa (kit) | Eléctrico | Físico | Golpe | 45 | 1.0 s |
| 3 | Bomba Sónica (kit) | Normal | Especial | Área | 25 | 4.0 s |
| 5 | Autodestrucción (kit) | Normal | Físico | Área | 130 | 20.0 s |
| 1 | Carga | Eléctrico | Estado | Mejora propia | — | 10.0 s |
| 1 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 41 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 48 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 54 | Explosión | Normal | Físico | Área | 250 | 9.2 s |
| 59 | Manto Espejo | Psíquico | Especial | Disparo | 60 | 1.8 s |

### 102 Exeggcute

Planta/Psíquico · Pokémon Huevo · **aparece en el juego**

**Kit**: propio, estilo *control* (distancia preferida 70 px).

**Firma — Racimo**: Quieto, los seis huevos se apiñan: recibe hasta 40% menos. Moverse los separa.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Bombardeo | Normal | Físico | Disparo | 15 | 1.2 s |
| Clic der. | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| Q | Paralizador | Planta | Estado | Área | — | 7.0 s |
| R | Rayo Solar | Planta | Especial | Disparo | 120 | 8.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Bombardeo (kit) | Normal | Físico | Disparo | 15 | 1.2 s |
| 1 | Hipnosis (kit) | Psíquico | Estado | Disparo | — | 10.0 s |
| 3 | Paralizador (kit) | Planta | Estado | Área | — | 7.0 s |
| 5 | Rayo Solar (kit) | Planta | Especial | Disparo | 120 | 8.0 s |
| 1 | Alboroto | Normal | Especial | Disparo | 90 | 2.4 s |
| 7 | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 13 | Drenadoras | Planta | Estado | Área | — | 6.0 s |
| 19 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 31 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 37 | Somnífero | Planta | Estado | Zona | — | 12.0 s |

### 103 Exeggutor

Planta/Psíquico · Pokémon Coco · **aparece en el juego**

**Kit**: heredado de Exeggcute, estilo *control* (distancia preferida 70 px).

**Firma — Racimo**: Quieto, los seis huevos se apiñan: recibe hasta 40% menos. Moverse los separa.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Bombardeo | Normal | Físico | Disparo | 15 | 1.2 s |
| Clic der. | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |
| Q | Paralizador | Planta | Estado | Área | — | 7.0 s |
| R | Rayo Solar | Planta | Especial | Disparo | 120 | 8.0 s |

**Ataques que puede aprender (7)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Bombardeo (kit) | Normal | Físico | Disparo | 15 | 1.2 s |
| 1 | Hipnosis (kit) | Psíquico | Estado | Disparo | — | 10.0 s |
| 3 | Paralizador (kit) | Planta | Estado | Área | — | 7.0 s |
| 5 | Rayo Solar (kit) | Planta | Especial | Disparo | 120 | 8.0 s |
| 1 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 19 | Pisotón | Normal | Físico | Golpe | 65 | 1.2 s |
| 31 | Bomba Huevo | Normal | Físico | Embestida | 100 | 2.5 s |

### 104 Cubone

Tierra · Pokémon Solitario · **aparece en el juego**

**Kit**: propio, estilo *bruiser* (distancia preferida 35 px).

**Firma — Casco de Hueso**: El cráneo lo protege de frente: recibe 30% menos de lo que le pegan de frente. Hueso Palo pega ×1,5 a lo ralentizado.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Hueso Palo | Tierra | Físico | Golpe | 65 | 1.3 s |
| Clic der. | Huesomerang | Tierra | Físico | Disparo | 50 | 2.0 s |
| Q | Malicioso | Normal | Estado | Disparo | — | 7.0 s |
| R | Golpe | Normal | Físico | Golpe | 60 | 6.0 s |

**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Hueso Palo (kit) | Tierra | Físico | Golpe | 65 | 1.3 s |
| 1 | Huesomerang (kit) | Tierra | Físico | Disparo | 50 | 2.0 s |
| 3 | Malicioso (kit) | Normal | Estado | Disparo | — | 7.0 s |
| 5 | Golpe (kit) | Normal | Físico | Golpe | 60 | 6.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 5 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 13 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 21 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 29 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 33 | Falso Tortazo | Normal | Físico | Golpe | 40 | 1.1 s |
| 37 | Saña | Normal | Físico | Embestida | 120 | 2.7 s |
| 41 | Ataque Óseo | Tierra | Físico | Golpe | 25 | 0.9 s |
| 45 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

### 105 Marowak

Tierra · Pokémon Apilahueso · **aparece en el juego**

**Kit**: heredado de Cubone, estilo *bruiser* (distancia preferida 35 px).

**Firma — Casco de Hueso**: El cráneo lo protege de frente: recibe 30% menos de lo que le pegan de frente. Hueso Palo pega ×1,5 a lo ralentizado.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Hueso Palo | Tierra | Físico | Golpe | 65 | 1.3 s |
| Clic der. | Huesomerang | Tierra | Físico | Disparo | 50 | 2.0 s |
| Q | Malicioso | Normal | Estado | Disparo | — | 7.0 s |
| R | Golpe | Normal | Físico | Golpe | 60 | 6.0 s |

**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Hueso Palo (kit) | Tierra | Físico | Golpe | 65 | 1.3 s |
| 1 | Huesomerang (kit) | Tierra | Físico | Disparo | 50 | 2.0 s |
| 3 | Malicioso (kit) | Normal | Estado | Disparo | — | 7.0 s |
| 5 | Golpe (kit) | Normal | Físico | Golpe | 60 | 6.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 21 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 32 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 39 | Falso Tortazo | Normal | Físico | Golpe | 40 | 1.1 s |
| 46 | Saña | Normal | Físico | Embestida | 120 | 2.7 s |
| 53 | Ataque Óseo | Tierra | Físico | Golpe | 25 | 0.9 s |
| 61 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

### 106 Hitmonlee

Lucha · Pokémon Patada · **aparece en el juego**

**Kit**: propio, estilo *asesino* (distancia preferida 45 px).

**Firma — Piernas Elásticas**: Quieto 0,6 s recoge las piernas. La próxima patada sale como un resorte: +50% de daño y un envión.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Doble Patada | Lucha | Físico | Golpe | 30 | 0.9 s |
| Clic der. | Patada Giro | Lucha | Físico | Área | 60 | 3.0 s |
| Q | Patada Salto | Lucha | Físico | Embestida+combo | 85 | 4.5 s |
| R | Patada Salto Alta | Lucha | Físico | Embestida+combo | 130 | 8.0 s |

**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Doble Patada (kit) | Lucha | Físico | Golpe | 30 | 0.9 s |
| 1 | Patada Giro (kit) | Lucha | Físico | Área | 60 | 3.0 s |
| 3 | Patada Salto (kit) | Lucha | Físico | Embestida+combo | 85 | 4.5 s |
| 5 | Patada Salto Alta (kit) | Lucha | Físico | Embestida+combo | 130 | 8.0 s |
| 1 | Desquite | Lucha | Físico | Golpe | 60 | 1.4 s |
| 6 | Meditación | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 20 | Demolición | Lucha | Físico | Golpe | 75 | 1.6 s |
| 21 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 31 | Telépata | Normal | Estado | Área | — | 6.0 s |
| 36 | Profecía | Normal | Estado | Área | — | 6.0 s |
| 41 | Aguante | Normal | Estado | Defensa | — | 8.0 s |
| 46 | Megapatada | Normal | Físico | Embestida | 120 | 2.7 s |
| 51 | Inversión | Lucha | Físico | Golpe | 60 | 1.4 s |

### 107 Hitmonchan

Lucha · Pokémon Puñetazo · **aparece en el juego**

**Kit**: propio, estilo *bruiser* (distancia preferida 30 px).

**Firma — Juego de Pies**: Esquivar justo cuando le llega un golpe recarga Megapuño y deja el próximo golpe crítico (×1,6).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Ultrapuño | Lucha | Físico | Golpe | 40 | 0.8 s |
| Clic der. | Puño Fuego | Fuego | Físico | Golpe | 75 | 2.5 s |
| Q | Puño Hielo | Hielo | Físico | Golpe | 75 | 2.5 s |
| R | Megapuño | Normal | Físico | Golpe | 80 | 5.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Ultrapuño (kit) | Lucha | Físico | Golpe | 40 | 0.8 s |
| 1 | Puño Fuego (kit) | Fuego | Físico | Golpe | 75 | 2.5 s |
| 3 | Puño Hielo (kit) | Hielo | Físico | Golpe | 75 | 2.5 s |
| 5 | Megapuño (kit) | Normal | Físico | Golpe | 80 | 5.0 s |
| 1 | Puño Cometa | Normal | Físico | Golpe | 18 | 0.8 s |
| 1 | Desquite | Lucha | Físico | Golpe | 60 | 1.4 s |
| 7 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 13 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 26 | Puño Trueno | Eléctrico | Físico | Golpe | 75 | 1.4 s |
| 32 | Gancho Alto | Lucha | Físico | Embestida | 85 | 2.2 s |
| 44 | Detección | Lucha | Estado | Defensa | — | 8.0 s |
| 50 | Contraataque | Lucha | Físico | Golpe | 60 | 1.4 s |

### 108 Lickitung

Normal · Pokémon Lametazo · **aparece en el juego**

**Kit**: propio, estilo *tanque* (distancia preferida 40 px).

**Firma — Lengua Larga**: Sus lengüetazos babean (ralentizan). Golpe pega ×1,4 a lo ralentizado.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Lengüetazo | Fantasma | Físico | Látigo | 30 | 1.0 s |
| Clic der. | Pisotón | Normal | Físico | Golpe | 65 | 1.6 s |
| Q | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| R | Golpe | Normal | Físico | Golpe | 80 | 4.5 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Lengüetazo (kit) | Fantasma | Físico | Látigo | 30 | 1.0 s |
| 1 | Pisotón (kit) | Normal | Físico | Golpe | 65 | 1.6 s |
| 3 | Rizo Defensa (kit) | Normal | Estado | Mejora propia | — | 10.0 s |
| 5 | Golpe (kit) | Normal | Físico | Golpe | 80 | 4.5 s |
| 7 | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| 18 | Desarme | Siniestro | Físico | Golpe | 65 | 1.4 s |
| 29 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 34 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 40 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 45 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 51 | Alivio | Normal | Estado | Mejora propia | — | 10.0 s |

### 109 Koffing

Veneno · Pokémon Gas Venenoso · **aparece en el juego**

**Kit**: propio, estilo *control* (distancia preferida 70 px).

**Firma — Gas Inflamable**: Sus nubes (Gas Venenoso, Pantalla de Humo) se prenden con cualquier fuego. Detonar las hace explotar todas a la vez.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Placaje | Normal | Físico | Golpe | 40 | 1.0 s |
| Clic der. | Gas Venenoso | Veneno | Estado | Zona | — | 5.0 s |
| Q | Pantalla de Humo | Normal | Estado | Zona | — | 8.0 s |
| R | Detonar | Fuego | Especial | Área | 30 | 8.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje (kit) | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Gas Venenoso (kit) | Veneno | Estado | Zona | — | 5.0 s |
| 3 | Pantalla de Humo (kit) | Normal | Estado | Zona | — | 8.0 s |
| 5 | Detonar (kit) | Fuego | Especial | Área | 30 | 8.0 s |
| 9 | Polución | Veneno | Especial | Disparo | 30 | 1.3 s |
| 17 | Autodestrucción | Normal | Físico | Área | 130 | 20.0 s |
| 21 | Residuos | Veneno | Especial | Disparo | 65 | 2.2 s |
| 33 | Niebla | Hielo | Estado | Mejora propia | — | 10.0 s |
| 41 | Explosión | Normal | Físico | Área | 250 | 9.2 s |
| 45 | Mismo Destino | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 49 | Legado | Siniestro | Estado | Área | — | 6.0 s |

### 110 Weezing

Veneno · Pokémon Gas Venenoso · **aparece en el juego**

**Kit**: heredado de Koffing, estilo *control* (distancia preferida 70 px).

**Firma — Gas Inflamable**: Sus nubes (Gas Venenoso, Pantalla de Humo) se prenden con cualquier fuego. Detonar las hace explotar todas a la vez.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Placaje | Normal | Físico | Golpe | 40 | 1.0 s |
| Clic der. | Gas Venenoso | Veneno | Estado | Zona | — | 5.0 s |
| Q | Pantalla de Humo | Normal | Estado | Zona | — | 8.0 s |
| R | Detonar | Fuego | Especial | Área | 30 | 8.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje (kit) | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Gas Venenoso (kit) | Veneno | Estado | Zona | — | 5.0 s |
| 3 | Pantalla de Humo (kit) | Normal | Estado | Zona | — | 8.0 s |
| 5 | Detonar (kit) | Fuego | Especial | Área | 30 | 8.0 s |
| 1 | Autodestrucción | Normal | Físico | Área | 130 | 20.0 s |
| 1 | Polución | Veneno | Especial | Disparo | 30 | 1.3 s |
| 21 | Residuos | Veneno | Especial | Disparo | 65 | 2.2 s |
| 33 | Niebla | Hielo | Estado | Mejora propia | — | 10.0 s |
| 44 | Explosión | Normal | Físico | Área | 250 | 9.2 s |
| 51 | Mismo Destino | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 58 | Legado | Siniestro | Estado | Área | — | 6.0 s |

### 111 Rhyhorn

Tierra/Roca · Pokémon Clavos · **aparece en el juego**

**Kit**: propio, estilo *tanque* (distancia preferida 30 px).

**Firma — Piel de Roca**: Cuerpo de roca: recibe 20% menos de los golpes físicos y casi no lo empujan. Pega ×1,3 a lo ralentizado (Pisotón).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Cornada | Normal | Físico | Golpe | 65 | 1.3 s |
| Clic der. | Pisotón | Tierra | Físico | Área | 65 | 4.0 s |
| Q | Derribo | Normal | Físico | Embestida | 90 | 5.0 s |
| R | Cornataladro | Normal | Físico | Golpe | 80 | 14.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Cornada (kit) | Normal | Físico | Golpe | 65 | 1.3 s |
| 1 | Pisotón (kit) | Tierra | Físico | Área | 65 | 4.0 s |
| 3 | Derribo (kit) | Normal | Físico | Embestida | 90 | 5.0 s |
| 5 | Cornataladro (kit) | Normal | Físico | Golpe | 80 | 14.0 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 15 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 24 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 29 | Pedrada | Roca | Físico | Golpe | 25 | 0.9 s |
| 38 | Perforador | Normal | Físico | Golpe | 60 | 1.4 s |
| 52 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 57 | Megacuerno | Bicho | Físico | Embestida | 120 | 2.7 s |

### 112 Rhydon

Tierra/Roca · Pokémon Taladro · **aparece en el juego**

**Kit**: heredado de Rhyhorn, estilo *tanque* (distancia preferida 30 px).

**Firma — Piel de Roca**: Cuerpo de roca: recibe 20% menos de los golpes físicos y casi no lo empujan. Pega ×1,3 a lo ralentizado (Pisotón).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Cornada | Normal | Físico | Golpe | 65 | 1.3 s |
| Clic der. | Pisotón | Tierra | Físico | Área | 65 | 4.0 s |
| Q | Derribo | Normal | Físico | Embestida | 90 | 5.0 s |
| R | Cornataladro | Normal | Físico | Golpe | 80 | 14.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Cornada (kit) | Normal | Físico | Golpe | 65 | 1.3 s |
| 1 | Pisotón (kit) | Tierra | Físico | Área | 65 | 4.0 s |
| 3 | Derribo (kit) | Normal | Físico | Embestida | 90 | 5.0 s |
| 5 | Cornataladro (kit) | Normal | Físico | Golpe | 80 | 14.0 s |
| 1 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 24 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 29 | Pedrada | Roca | Físico | Golpe | 25 | 0.9 s |
| 38 | Perforador | Normal | Físico | Golpe | 60 | 1.4 s |
| 58 | Terremoto | Tierra | Físico | Área | 100 | 4.9 s |
| 66 | Megacuerno | Bicho | Físico | Embestida | 120 | 2.7 s |

### 113 Chansey

Normal · Pokémon Huevo · **aparece en el juego**

**Kit**: propio, estilo *tanque* (distancia preferida 55 px).

**Firma — Huevo Suerte**: Si pasan 2,5 s sin que le peguen, se cura sola un 2% de la vida por segundo.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| Clic der. | Canto | Normal | Estado | Canalizado | — | 10.0 s |
| Q | Amortiguador | Normal | Estado | Mejora propia | — | 12.0 s |
| R | Bomba Huevo | Normal | Físico | Disparo | 100 | 5.0 s |

**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Destructor (kit) | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Canto (kit) | Normal | Estado | Canalizado | — | 10.0 s |
| 3 | Amortiguador (kit) | Normal | Estado | Mejora propia | — | 12.0 s |
| 5 | Bomba Huevo (kit) | Normal | Físico | Disparo | 100 | 5.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 5 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 9 | Alivio | Normal | Estado | Mejora propia | — | 10.0 s |
| 13 | Ovocuración | Normal | Estado | Mejora propia | — | 10.0 s |
| 17 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 23 | Reducción | Normal | Estado | Mejora propia | — | 9.0 s |
| 41 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 49 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 57 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

### 114 Tangela

Planta · Pokémon Enredadera · **aparece en el juego**

**Kit**: propio, estilo *control* (distancia preferida 55 px).

**Firma — Maraña**: Sus ataques planta enredan al rival; con 3 vueltas de lianas queda enraizado (no se mueve un rato).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Látigo Cepa | Planta | Físico | Látigo | 35 | 1.0 s |
| Clic der. | Absorber | Planta | Especial | Disparo | 30 | 1.5 s |
| Q | Somnífero | Planta | Estado | Disparo | — | 10.0 s |
| R | Atadura | Normal | Físico | Látigo | 40 | 6.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Látigo Cepa (kit) | Planta | Físico | Látigo | 35 | 1.0 s |
| 1 | Absorber (kit) | Planta | Especial | Disparo | 30 | 1.5 s |
| 3 | Somnífero (kit) | Planta | Estado | Disparo | — | 10.0 s |
| 5 | Atadura (kit) | Normal | Físico | Látigo | 40 | 6.0 s |
| 1 | Restricción | Normal | Físico | Látigo | 15 | 5.0 s |
| 1 | Arraigo | Planta | Estado | Mejora propia | — | 10.0 s |
| 13 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 19 | Polvo Veneno | Veneno | Estado | Zona | — | 1.3 s |
| 31 | Megaagotar | Planta | Especial | Disparo | 40 | 1.5 s |
| 37 | Paralizador | Planta | Estado | Zona | — | 6.0 s |
| 40 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 46 | Cosquillas | Normal | Estado | Área | — | 6.0 s |

### 115 Kangaskhan

Normal · Pokémon Maternal · **aparece en el juego**

**Kit**: propio, estilo *bruiser* (distancia preferida 35 px).

**Firma — Cría**: La cría de la bolsa también pega: cada golpe cuerpo a cuerpo que conecta se repite enseguida con un 35% del daño.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Puño Cometa | Normal | Físico | Golpe | 18 | 0.9 s |
| Clic der. | Mordisco | Siniestro | Físico | Golpe | 60 | 1.6 s |
| Q | Látigo | Normal | Estado | Área | — | 7.0 s |
| R | Megapuño | Normal | Físico | Golpe | 80 | 5.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Puño Cometa (kit) | Normal | Físico | Golpe | 18 | 0.9 s |
| 1 | Mordisco (kit) | Siniestro | Físico | Golpe | 60 | 1.6 s |
| 3 | Látigo (kit) | Normal | Estado | Área | — | 7.0 s |
| 5 | Megapuño (kit) | Normal | Físico | Golpe | 80 | 5.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 13 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 19 | Sorpresa | Normal | Físico | Embestida | 40 | 1.6 s |
| 31 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 37 | Aguante | Normal | Estado | Defensa | — | 8.0 s |
| 43 | Puño Mareo | Normal | Físico | Golpe | 70 | 1.5 s |
| 49 | Inversión | Lucha | Físico | Golpe | 60 | 1.4 s |

### 116 Horsea

Agua · Pokémon Dragón · **aparece en el juego**

**Kit**: propio, estilo *espaciador* (distancia preferida 110 px).

**Firma — Ancla**: Quieto 0,5 s se ancla con la cola: sus disparos pegan +30% y no lo empujan. Moverse lo suelta.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Burbuja | Agua | Especial | Disparo | 20 | 0.8 s |
| Clic der. | Pistola Agua | Agua | Especial | Disparo | 40 | 1.2 s |
| Q | Pantalla de Humo | Normal | Estado | Zona | — | 9.0 s |
| R | Chorro a Presión | Agua | Especial | Disparo | 75 | 6.0 s |

**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja (kit) | Agua | Especial | Disparo | 20 | 0.8 s |
| 1 | Pistola Agua (kit) | Agua | Especial | Disparo | 40 | 1.2 s |
| 3 | Pantalla de Humo (kit) | Normal | Estado | Zona | — | 9.0 s |
| 5 | Chorro a Presión (kit) | Agua | Especial | Disparo | 75 | 6.0 s |
| 15 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 29 | Ciclón | Dragón | Especial | Área | 40 | 6.0 s |
| 36 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 43 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |
| 50 | Danza Dragón | Dragón | Estado | Mejora propia | — | 10.0 s |

### 117 Seadra

Agua · Pokémon Dragón · **aparece en el juego**

**Kit**: heredado de Horsea, estilo *espaciador* (distancia preferida 110 px).

**Firma — Ancla**: Quieto 0,5 s se ancla con la cola: sus disparos pegan +30% y no lo empujan. Moverse lo suelta.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Burbuja | Agua | Especial | Disparo | 20 | 0.8 s |
| Clic der. | Pistola Agua | Agua | Especial | Disparo | 40 | 1.2 s |
| Q | Pantalla de Humo | Normal | Estado | Zona | — | 9.0 s |
| R | Chorro a Presión | Agua | Especial | Disparo | 75 | 6.0 s |

**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja (kit) | Agua | Especial | Disparo | 20 | 0.8 s |
| 1 | Pistola Agua (kit) | Agua | Especial | Disparo | 40 | 1.2 s |
| 3 | Pantalla de Humo (kit) | Normal | Estado | Zona | — | 9.0 s |
| 5 | Chorro a Presión (kit) | Agua | Especial | Disparo | 75 | 6.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 29 | Ciclón | Dragón | Especial | Área | 40 | 6.0 s |
| 40 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 51 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |
| 62 | Danza Dragón | Dragón | Estado | Mejora propia | — | 10.0 s |

### 118 Goldeen

Agua · Pokémon Pez Color · **aparece en el juego**

**Kit**: propio, estilo *perseguidor* (distancia preferida 35 px).

**Firma — Cuerno Perforador**: Sus golpes de cuerno (Picotazo, Cornada) atraviesan las defensas: ×1,6 contra Fortaleza, Refugio, Rizo Defensa... Mojado se mueve ×1,3; en seco, ×0,85.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| Clic der. | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| Q | Hidrochorro | Agua | Especial | Área | 15 | 6.0 s |
| R | Cornada | Normal | Físico | Embestida | 65 | 5.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo (kit) | Volador | Físico | Golpe | 35 | 0.8 s |
| 1 | Supersónico (kit) | Normal | Estado | Canalizado | — | 6.0 s |
| 3 | Hidrochorro (kit) | Agua | Especial | Área | 15 | 6.0 s |
| 5 | Cornada (kit) | Normal | Físico | Embestida | 65 | 5.0 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 24 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |
| 29 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 38 | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |
| 43 | Perforador | Normal | Físico | Golpe | 60 | 1.4 s |
| 52 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 57 | Megacuerno | Bicho | Físico | Embestida | 120 | 2.7 s |

### 119 Seaking

Agua · Pokémon Pez Color · **aparece en el juego**

**Kit**: heredado de Goldeen, estilo *perseguidor* (distancia preferida 35 px).

**Firma — Cuerno Perforador**: Sus golpes de cuerno (Picotazo, Cornada) atraviesan las defensas: ×1,6 contra Fortaleza, Refugio, Rizo Defensa... Mojado se mueve ×1,3; en seco, ×0,85.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| Clic der. | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| Q | Hidrochorro | Agua | Especial | Área | 15 | 6.0 s |
| R | Cornada | Normal | Físico | Embestida | 65 | 5.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Picotazo (kit) | Volador | Físico | Golpe | 35 | 0.8 s |
| 1 | Supersónico (kit) | Normal | Estado | Canalizado | — | 6.0 s |
| 3 | Hidrochorro (kit) | Agua | Especial | Área | 15 | 6.0 s |
| 5 | Cornada (kit) | Normal | Físico | Embestida | 65 | 5.0 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 24 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |
| 29 | Ataque Furia | Normal | Físico | Golpe | 18 | 3.0 s |
| 41 | Cascada | Agua | Físico | Embestida | 80 | 2.1 s |
| 49 | Perforador | Normal | Físico | Golpe | 60 | 1.4 s |
| 61 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 69 | Megacuerno | Bicho | Físico | Embestida | 120 | 2.7 s |

### 120 Staryu

Agua · Pokémon Estrella · **aparece en el juego**

**Kit**: propio, estilo *velocista* (distancia preferida 55 px).

**Firma — Núcleo**: Girando (Giro Rápido) desvía los proyectiles. Le pega 20% más a lo Empapado. La barra sube al pegar y al recibir: llena, el núcleo regenera 10% de la vida.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Placaje | Normal | Físico | Golpe | 40 | 0.9 s |
| Clic der. | Pistola Agua | Agua | Especial | Disparo | 40 | 1.0 s |
| Q | Giro Rápido | Normal | Físico | Embestida | 20 | 4.0 s |
| R | Fortaleza | Normal | Estado | Mejora propia | — | 9.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje (kit) | Normal | Físico | Golpe | 40 | 0.9 s |
| 1 | Pistola Agua (kit) | Agua | Especial | Disparo | 40 | 1.0 s |
| 3 | Giro Rápido (kit) | Normal | Físico | Embestida | 20 | 4.0 s |
| 5 | Fortaleza (kit) | Normal | Estado | Mejora propia | — | 9.0 s |
| 15 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |
| 19 | Camuflaje | Normal | Estado | Mejora propia | — | 10.0 s |
| 24 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 28 | Rayo Burbuja | Agua | Especial | Disparo | 30 | 3.0 s |
| 33 | Reducción | Normal | Estado | Mejora propia | — | 9.0 s |
| 37 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 42 | Masa Cósmica | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 46 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |

### 121 Starmie

Agua/Psíquico · Pokémon Misterioso · **aparece en el juego**

**Kit**: propio, estilo *control* (distancia preferida 85 px).

**Firma — Núcleo Prisma**: Jefa. Grande y casi no la empujan. Girando desvía los proyectiles; le pega 25% más a lo Empapado; la barra llena regenera 8% de la vida. A mitad de vida el núcleo brilla: una onda empuja y moja a todos y queda más fuerte y rápida hasta el final.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Hidropulso | Agua | Especial | Disparo | 60 | 1.4 s |
| Clic der. | Rapidez | Normal | Especial | Disparo | 35 | 3.5 s |
| Q | Giro Rápido | Normal | Físico | Embestida | 30 | 3.5 s |
| R | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |

**Ataques que puede aprender (6)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Hidropulso (kit) | Agua | Especial | Disparo | 60 | 1.4 s |
| 1 | Rapidez (kit) | Normal | Especial | Disparo | 35 | 3.5 s |
| 3 | Giro Rápido (kit) | Normal | Físico | Embestida | 30 | 3.5 s |
| 5 | Recuperación (kit) | Normal | Estado | Mejora propia | — | 16.0 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 33 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |

### 122 Mr. Mime

Psíquico/Hada · Pokémon Barrera · **aparece en el juego**

**Kit**: propio, estilo *control* (distancia preferida 60 px).

**Firma — Pantomima**: Después de levantar una Barrera, el próximo golpe sale en 2 s como un Golpe Mental: +50% y desorienta.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Doble Bofetón | Normal | Físico | Golpe | 15 | 1.0 s |
| Clic der. | Confusión | Psíquico | Especial | Disparo | 50 | 1.4 s |
| Q | Barrera | Psíquico | Estado | Defensa | — | 6.0 s |
| R | Psíquico | Psíquico | Especial | Disparo | 90 | 6.0 s |

**Ataques que puede aprender (16)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Doble Bofetón (kit) | Normal | Físico | Golpe | 15 | 1.0 s |
| 1 | Confusión (kit) | Psíquico | Especial | Disparo | 50 | 1.4 s |
| 3 | Barrera (kit) | Psíquico | Estado | Defensa | — | 6.0 s |
| 5 | Psíquico (kit) | Psíquico | Especial | Disparo | 90 | 6.0 s |
| 8 | Sustituto | Normal | Estado | Mejora propia | — | 10.0 s |
| 12 | Meditación | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 19 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 19 | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 22 | Hoja Mágica | Planta | Especial | Disparo | 60 | 1.8 s |
| 26 | Otra Vez | Normal | Estado | Área | — | 6.0 s |
| 29 | Psicorrayo | Psíquico | Especial | Canalizado | 65 | 6.0 s |
| 33 | Reciclaje | Normal | Estado | Mejora propia | — | 10.0 s |
| 36 | Truco | Psíquico | Estado | Área | — | 6.0 s |
| 40 | Imitación | Psíquico | Estado | Área | — | 6.0 s |
| 47 | Relevo | Normal | Estado | Mejora propia | — | 10.0 s |
| 50 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |

### 123 Scyther

Bicho/Volador · Pokémon Mantis · **aparece en el juego**

**Kit**: propio, estilo *asesino* (distancia preferida 30 px).

**Firma — Filo Furioso**: Cada golpe seguido al mismo rival suma una marca (hasta 5): +10% por marca. Si pasan 2,5 s sin pegarle, se pierden.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Corte Furia | Bicho | Físico | Golpe | 25 | 0.8 s |
| Clic der. | Ataque Ala | Volador | Físico | Embestida+combo | 60 | 3.5 s |
| Q | Danza Espada | Normal | Estado | Mejora propia | — | 10.0 s |
| R | Cuchillada | Normal | Físico | Golpe | 70 | 4.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Corte Furia (kit) | Bicho | Físico | Golpe | 25 | 0.8 s |
| 1 | Ataque Ala (kit) | Volador | Físico | Embestida+combo | 60 | 3.5 s |
| 3 | Danza Espada (kit) | Normal | Estado | Mejora propia | — | 10.0 s |
| 5 | Cuchillada (kit) | Normal | Físico | Golpe | 70 | 4.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 6 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 11 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 16 | Falso Tortazo | Normal | Físico | Golpe | 40 | 1.1 s |
| 21 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 41 | Doble Equipo | Normal | Estado | Mejora propia | — | 10.0 s |

### 124 Jynx

Hielo/Psíquico · Pokémon Forma Humana · **aparece en el juego**

**Kit**: propio, estilo *control* (distancia preferida 60 px).

**Firma — Canción de Cuna**: Sus ataques de hielo y psíquicos suman Somnolencia; con 4, el rival se duerme.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Doble Bofetón | Normal | Físico | Golpe | 15 | 1.0 s |
| Clic der. | Polvo Nieve | Hielo | Especial | Disparo | 40 | 1.4 s |
| Q | Beso Amoroso | Normal | Estado | Disparo | — | 10.0 s |
| R | Ventisca | Hielo | Especial | Área | 110 | 8.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Doble Bofetón (kit) | Normal | Físico | Golpe | 15 | 1.0 s |
| 1 | Polvo Nieve (kit) | Hielo | Especial | Disparo | 40 | 1.4 s |
| 3 | Beso Amoroso (kit) | Normal | Estado | Disparo | — | 10.0 s |
| 5 | Ventisca (kit) | Hielo | Especial | Área | 110 | 8.0 s |
| 1 | Lengüetazo | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Nieve Polvo | Hielo | Especial | Área | 40 | 3.2 s |
| 25 | Puño Hielo | Hielo | Físico | Golpe | 75 | 1.6 s |
| 35 | Mal de Ojo | Normal | Estado | Área | — | 6.0 s |
| 41 | Llanto Falso | Siniestro | Estado | Área | — | 6.0 s |
| 51 | Golpe Cuerpo | Normal | Físico | Embestida | 85 | 2.2 s |
| 57 | Canto Mortal | Normal | Estado | Mejora propia | — | 10.0 s |

### 125 Electabuzz

Eléctrico · Pokémon Eléctrico · **aparece en el juego**

**Kit**: propio, estilo *bruiser* (distancia preferida 40 px).

**Firma — Electromotor**: Moverse y esquivar lo cargan (5 marcas); quieto se descarga. Con la barra llena el próximo golpe es una Descarga que paraliza fuerte.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Puño Trueno | Eléctrico | Físico | Golpe | 75 | 1.4 s |
| Clic der. | Impactrueno | Eléctrico | Especial | Disparo | 40 | 1.2 s |
| Q | Patada Baja | Lucha | Físico | Golpe | 50 | 3.0 s |
| R | Trueno | Eléctrico | Especial | Zona | 110 | 9.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Puño Trueno (kit) | Eléctrico | Físico | Golpe | 75 | 1.4 s |
| 1 | Impactrueno (kit) | Eléctrico | Especial | Disparo | 40 | 1.2 s |
| 3 | Patada Baja (kit) | Lucha | Físico | Golpe | 50 | 3.0 s |
| 5 | Trueno (kit) | Eléctrico | Especial | Zona | 110 | 9.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 17 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 25 | Rapidez | Normal | Especial | Disparo | 60 | 1.8 s |
| 36 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 47 | Rayo | Eléctrico | Especial | Disparo | 90 | 2.4 s |

### 126 Magmar

Fuego · Pokémon Escupefuego

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 127 Pinsir

Bicho · Pokémon Escarabajo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 128 Tauros

Normal · Pokémon Toro Bravo · **aparece en el juego**

**Kit**: propio, estilo *bruiser* (distancia preferida 35 px).

**Firma — Estampida**: Cada Derribo dentro de 3 s del anterior pega +40% (hasta ×1,8): una vez que arranca, no para.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Cornada | Normal | Físico | Golpe | 65 | 1.2 s |
| Clic der. | Cara Susto | Normal | Estado | Disparo | — | 7.0 s |
| Q | Derribo | Normal | Físico | Embestida | 80 | 1.8 s |
| R | Hiperrayo | Normal | Especial | Disparo | 150 | 12.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Cornada (kit) | Normal | Físico | Golpe | 65 | 1.2 s |
| 1 | Cara Susto (kit) | Normal | Estado | Disparo | — | 7.0 s |
| 3 | Derribo (kit) | Normal | Físico | Embestida | 80 | 1.8 s |
| 5 | Hiperrayo (kit) | Normal | Especial | Disparo | 150 | 12.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 4 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 19 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 26 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 34 | Descanso | Psíquico | Estado | Mejora propia | — | 14.0 s |
| 43 | Saña | Normal | Físico | Embestida | 120 | 2.7 s |

### 129 Magikarp

Agua · Pokémon Pez · **aparece en el juego**

**Kit**: propio, estilo *caotico* (distancia preferida 30 px).

**Firma — Determinación**: Azote pega más cuanto menos vida tiene (hasta ×3). Cada rival que derriba y sigue en pie le da 20 de EXP extra, para llegar a Gyarados.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Salpicadura | Normal | Estado | Embestida | — | 1.5 s |
| Clic der. | Placaje | Normal | Físico | Golpe | 40 | 1.0 s |
| Q | Azote | Normal | Físico | Golpe | 40 | 2.5 s |
| R | Salpicadura Alta | Normal | Estado | Embestida | — | 6.0 s |

**Ataques que puede aprender (4)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Salpicadura (kit) | Normal | Estado | Embestida | — | 1.5 s |
| 1 | Placaje (kit) | Normal | Físico | Golpe | 40 | 1.0 s |
| 3 | Azote (kit) | Normal | Físico | Golpe | 40 | 2.5 s |
| 5 | Salpicadura Alta (kit) | Normal | Estado | Embestida | — | 6.0 s |

### 130 Gyarados

Agua/Volador · Pokémon Atrocidad · **aparece en el juego**

**Kit**: propio, estilo *bruiser* (distancia preferida 45 px).

**Firma — Ira de Dragón**: Sube al recibir golpes (y un poco al pegar). Llena, Gyarados se enfurece 5 s: pega 30% más y se mueve más rápido.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Mordisco | Siniestro | Físico | Golpe | 60 | 1.1 s |
| Clic der. | Furia Dragón | Dragón | Especial | Disparo | 50 | 2.0 s |
| Q | Ciclón | Dragón | Especial | Área | 40 | 6.0 s |
| R | Hidrobomba | Agua | Especial | Disparo | 110 | 8.0 s |

**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco (kit) | Siniestro | Físico | Golpe | 60 | 1.1 s |
| 1 | Furia Dragón (kit) | Dragón | Especial | Disparo | 50 | 2.0 s |
| 3 | Ciclón (kit) | Dragón | Especial | Área | 40 | 6.0 s |
| 5 | Hidrobomba (kit) | Agua | Especial | Disparo | 110 | 8.0 s |
| 1 | Saña | Normal | Físico | Embestida | 120 | 2.7 s |
| 30 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 45 | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| 50 | Danza Dragón | Dragón | Estado | Mejora propia | — | 10.0 s |
| 55 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

### 131 Lapras

Agua/Hielo · Pokémon Transporte · **aparece en el juego**

**Kit**: propio, estilo *tanque* (distancia preferida 60 px).

**Firma — Aliento Helado**: Sus ataques de hielo dejan escarcha; con 4, el rival se congela.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Golpe Cuerpo | Normal | Físico | Golpe | 85 | 1.6 s |
| Clic der. | Rayo Hielo | Hielo | Especial | Disparo | 90 | 2.4 s |
| Q | Canto | Normal | Estado | Canalizado | — | 10.0 s |
| R | Surf | Agua | Especial | Área | 90 | 7.0 s |

**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Golpe Cuerpo (kit) | Normal | Físico | Golpe | 85 | 1.6 s |
| 1 | Rayo Hielo (kit) | Hielo | Especial | Disparo | 90 | 2.4 s |
| 3 | Canto (kit) | Normal | Estado | Canalizado | — | 10.0 s |
| 5 | Surf (kit) | Agua | Especial | Área | 90 | 7.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 7 | Neblina | Hielo | Estado | Mejora propia | — | 10.0 s |
| 19 | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |
| 25 | Canto Mortal | Normal | Estado | Mejora propia | — | 10.0 s |
| 37 | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| 43 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 49 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |
| 55 | Frío Polar | Hielo | Especial | Disparo | 60 | 1.8 s |

### 132 Ditto

Normal · Pokémon Transformación · **aparece en el juego**

**Kit**: propio, estilo *caotico* (distancia preferida 40 px).

**Firma — Transformación**: Transformación copia los 4 ataques del rival más cercano y pelea con ellos 25 s. Después vuelve a ser Ditto.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Pegote | Normal | Físico | Golpe | 25 | 0.9 s |
| Clic der. | Gel | Normal | Especial | Disparo | 20 | 1.6 s |
| Q | Rebote | Normal | Estado | Embestida | — | 4.0 s |
| R | Transformación | Normal | Estado | Disparo | — | 30.0 s |

**Ataques que puede aprender (4)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Pegote (kit) | Normal | Físico | Golpe | 25 | 0.9 s |
| 1 | Gel (kit) | Normal | Especial | Disparo | 20 | 1.6 s |
| 3 | Rebote (kit) | Normal | Estado | Embestida | — | 4.0 s |
| 5 | Transformación (kit) | Normal | Estado | Disparo | — | 30.0 s |

### 133 Eevee

Normal · Pokémon Evolución · **aparece en el juego**

**Kit**: propio, estilo *adaptativo* (distancia preferida 45 px).

**Firma — Adaptación**: Al recibir un golpe de un tipo, durante 8 s recibe menos daño de ese tipo.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Placaje | Normal | Físico | Golpe | 40 | 0.9 s |
| Clic der. | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| Q | Ataque Rápido | Normal | Físico | Embestida | 40 | 2.5 s |
| R | Derribo | Normal | Físico | Embestida | 90 | 6.0 s |

**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje (kit) | Normal | Físico | Golpe | 40 | 0.9 s |
| 1 | Ataque Arena (kit) | Normal | Estado | Disparo | — | 5.0 s |
| 3 | Ataque Rápido (kit) | Normal | Físico | Embestida | 40 | 2.5 s |
| 5 | Derribo (kit) | Normal | Físico | Embestida | 90 | 6.0 s |
| 1 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 16 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 30 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 36 | Relevo | Normal | Estado | Mejora propia | — | 10.0 s |

### 134 Vaporeon

Agua · Pokémon Burbuja

**Kit**: propio, estilo *tanque* (distancia preferida 50 px).

**Firma — Absorbe Agua**: Sobre agua o suelo mojado (o empapado) se cura un 3% por segundo y se mueve más rápido; en seco va un poco más lento.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Pistola Agua | Agua | Especial | Disparo | 40 | 1.0 s |
| Clic der. | Rayo Aurora | Hielo | Especial | Disparo | 65 | 2.2 s |
| Q | Danza Lluvia | Agua | Estado | Área | — | 10.0 s |
| R | Hidrobomba | Agua | Especial | Disparo | 120 | 7.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Pistola Agua (kit) | Agua | Especial | Disparo | 40 | 1.0 s |
| 1 | Rayo Aurora (kit) | Hielo | Especial | Disparo | 65 | 2.2 s |
| 3 | Danza Lluvia (kit) | Agua | Estado | Área | — | 10.0 s |
| 5 | Hidrobomba (kit) | Agua | Especial | Disparo | 120 | 7.0 s |
| 1 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 8 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 23 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 30 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 42 | Niebla | Hielo | Estado | Mejora propia | — | 10.0 s |
| 47 | Armadura Ácida | Veneno | Estado | Mejora propia | — | 10.0 s |

### 135 Jolteon

Eléctrico · Pokémon Relámpago

**Kit**: propio, estilo *velocista* (distancia preferida 55 px).

**Firma — Absorbe Electricidad**: Moverse y esquivar lo cargan (5 marcas); quieto se descarga. Rayo gasta las cargas. Llena: el próximo golpe es una Descarga.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Impactrueno | Eléctrico | Especial | Disparo | 40 | 0.9 s |
| Clic der. | Doble Patada | Lucha | Físico | Embestida+combo | 30 | 2.5 s |
| Q | Pin Misil | Bicho | Físico | Disparo | 14 | 2.0 s |
| R | Rayo | Eléctrico | Especial | Disparo | 90 | 5.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Impactrueno (kit) | Eléctrico | Especial | Disparo | 40 | 0.9 s |
| 1 | Doble Patada (kit) | Lucha | Físico | Embestida+combo | 30 | 2.5 s |
| 3 | Pin Misil (kit) | Bicho | Físico | Disparo | 14 | 2.0 s |
| 5 | Rayo (kit) | Eléctrico | Especial | Disparo | 90 | 5.0 s |
| 1 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 8 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 23 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 42 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 47 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 52 | Trueno | Eléctrico | Especial | Área | 110 | 5.2 s |

### 136 Flareon

Fuego · Pokémon Llama

**Kit**: propio, estilo *bruiser* (distancia preferida 35 px).

**Firma — Absorbe Fuego**: Sus golpes contra quemados pegan +35% y renuevan la quemadura: el fuego no se apaga mientras lo siga castigando.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Mordisco | Siniestro | Físico | Golpe | 60 | 1.0 s |
| Clic der. | Ascuas | Fuego | Especial | Disparo | 40 | 1.0 s |
| Q | Giro Fuego | Fuego | Especial | Zona | 20 | 6.0 s |
| R | Lanzallamas | Fuego | Especial | Canalizado | 90 | 7.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco (kit) | Siniestro | Físico | Golpe | 60 | 1.0 s |
| 1 | Ascuas (kit) | Fuego | Especial | Disparo | 40 | 1.0 s |
| 3 | Giro Fuego (kit) | Fuego | Especial | Zona | 20 | 6.0 s |
| 5 | Lanzallamas (kit) | Fuego | Especial | Canalizado | 90 | 7.0 s |
| 1 | Refuerzo | Veneno | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 1 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 8 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 23 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 42 | Polución | Veneno | Especial | Disparo | 30 | 1.3 s |
| 47 | Malicioso | Normal | Estado | Área | — | 8.0 s |

### 137 Porygon

Normal · Pokémon Virtual

**Kit**: propio, estilo *control* (distancia preferida 60 px).

**Firma — Conversión**: Se reconvierte: durante 8 s recibe 35% menos del último tipo que le pegó.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Placaje | Normal | Físico | Embestida | 40 | 1.2 s |
| Clic der. | Psicorrayo | Psíquico | Especial | Disparo | 65 | 1.6 s |
| Q | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| R | Triataque | Normal | Especial | Disparo | 80 | 4.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje (kit) | Normal | Físico | Embestida | 40 | 1.2 s |
| 1 | Psicorrayo (kit) | Psíquico | Especial | Disparo | 65 | 1.6 s |
| 3 | Agilidad (kit) | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 5 | Triataque (kit) | Normal | Especial | Disparo | 80 | 4.0 s |
| 1 | Conversión | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Conversión 2 | Normal | Estado | Área | — | 6.0 s |
| 20 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |
| 24 | Afilar | Normal | Estado | Mejora propia | — | 10.0 s |
| 32 | Fijar Blanco | Normal | Estado | Disparo | — | 8.0 s |
| 44 | Reciclaje | Normal | Estado | Mejora propia | — | 10.0 s |
| 48 | Electrocañón | Eléctrico | Especial | Disparo | 120 | 2.9 s |

### 138 Omanyte

Roca/Agua · Pokémon Espiral · **aparece en el juego**

**Kit**: propio, estilo *control* (distancia preferida 50 px).

**Firma — Espiral**: El caparazón en espiral lo cubre de espaldas (−40%). Mojado se mueve más rápido; en seco más lento.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Constricción | Normal | Físico | Látigo | 15 | 1.0 s |
| Clic der. | Pistola Agua | Agua | Especial | Disparo | 40 | 1.2 s |
| Q | Refugio | Agua | Estado | Mejora propia | — | 9.0 s |
| R | Hidrobomba | Agua | Especial | Disparo | 120 | 8.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Constricción (kit) | Normal | Físico | Látigo | 15 | 1.0 s |
| 1 | Pistola Agua (kit) | Agua | Especial | Disparo | 40 | 1.2 s |
| 3 | Refugio (kit) | Agua | Estado | Mejora propia | — | 9.0 s |
| 5 | Hidrobomba (kit) | Agua | Especial | Disparo | 120 | 8.0 s |
| 1 | Restricción | Normal | Físico | Látigo | 15 | 5.0 s |
| 13 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 25 | Disparo Lodo | Tierra | Especial | Disparo | 55 | 1.7 s |
| 31 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 37 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 43 | Cosquillas | Normal | Estado | Área | — | 6.0 s |
| 49 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |

### 139 Omastar

Roca/Agua · Pokémon Espiral

**Kit**: heredado de Omanyte, estilo *control* (distancia preferida 50 px).

**Firma — Espiral**: El caparazón en espiral lo cubre de espaldas (−40%). Mojado se mueve más rápido; en seco más lento.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Constricción | Normal | Físico | Látigo | 15 | 1.0 s |
| Clic der. | Pistola Agua | Agua | Especial | Disparo | 40 | 1.2 s |
| Q | Refugio | Agua | Estado | Mejora propia | — | 9.0 s |
| R | Hidrobomba | Agua | Especial | Disparo | 120 | 8.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Constricción (kit) | Normal | Físico | Látigo | 15 | 1.0 s |
| 1 | Pistola Agua (kit) | Agua | Especial | Disparo | 40 | 1.2 s |
| 3 | Refugio (kit) | Agua | Estado | Mejora propia | — | 9.0 s |
| 5 | Hidrobomba (kit) | Agua | Especial | Disparo | 120 | 8.0 s |
| 1 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 1 | Restricción | Normal | Físico | Látigo | 15 | 5.0 s |
| 25 | Disparo Lodo | Tierra | Especial | Disparo | 55 | 1.7 s |
| 31 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 37 | Protección | Normal | Estado | Defensa | — | 8.0 s |
| 40 | Clavo Cañón | Normal | Físico | Golpe | 20 | 0.9 s |
| 46 | Cosquillas | Normal | Estado | Área | — | 6.0 s |
| 55 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |

### 140 Kabuto

Roca/Agua · Pokémon Armazón · **aparece en el juego**

**Kit**: propio, estilo *hostigador* (distancia preferida 30 px).

**Firma — Caparazón Fósil**: Quieto se endurece: recibe hasta 35% menos. Moverse lo ablanda rápido.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Arañazo | Normal | Físico | Golpe | 40 | 0.8 s |
| Clic der. | Absorber | Planta | Físico | Golpe | 30 | 1.4 s |
| Q | Fortaleza | Normal | Estado | Mejora propia | — | 10.0 s |
| R | Cuchillada | Normal | Físico | Embestida+combo | 70 | 4.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo (kit) | Normal | Físico | Golpe | 40 | 0.8 s |
| 1 | Absorber (kit) | Planta | Físico | Golpe | 30 | 1.4 s |
| 3 | Fortaleza (kit) | Normal | Estado | Mejora propia | — | 10.0 s |
| 5 | Cuchillada (kit) | Normal | Físico | Embestida+combo | 70 | 4.0 s |
| 19 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 25 | Disparo Lodo | Tierra | Especial | Disparo | 55 | 1.7 s |
| 31 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 37 | Aguante | Normal | Estado | Defensa | — | 8.0 s |
| 43 | Eco Metálico | Acero | Estado | Área | — | 6.0 s |
| 49 | Megaagotar | Planta | Especial | Disparo | 40 | 1.5 s |
| 55 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |

### 141 Kabutops

Roca/Agua · Pokémon Armazón

**Kit**: heredado de Kabuto, estilo *hostigador* (distancia preferida 30 px).

**Firma — Caparazón Fósil**: Quieto se endurece: recibe hasta 35% menos. Moverse lo ablanda rápido.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Arañazo | Normal | Físico | Golpe | 40 | 0.8 s |
| Clic der. | Absorber | Planta | Físico | Golpe | 30 | 1.4 s |
| Q | Fortaleza | Normal | Estado | Mejora propia | — | 10.0 s |
| R | Cuchillada | Normal | Físico | Embestida+combo | 70 | 4.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Arañazo (kit) | Normal | Físico | Golpe | 40 | 0.8 s |
| 1 | Absorber (kit) | Planta | Físico | Golpe | 30 | 1.4 s |
| 3 | Fortaleza (kit) | Normal | Estado | Mejora propia | — | 10.0 s |
| 5 | Cuchillada (kit) | Normal | Físico | Embestida+combo | 70 | 4.0 s |
| 1 | Corte Furia | Bicho | Físico | Golpe | 40 | 1.1 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 25 | Disparo Lodo | Tierra | Especial | Disparo | 55 | 1.7 s |
| 31 | Ataque Arena | Normal | Estado | Disparo | — | 5.0 s |
| 37 | Aguante | Normal | Estado | Defensa | — | 8.0 s |
| 46 | Eco Metálico | Acero | Estado | Área | — | 6.0 s |
| 55 | Megaagotar | Planta | Especial | Disparo | 40 | 1.5 s |
| 65 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |

### 142 Aerodactyl

Roca/Volador · Pokémon Fósil · **aparece en el juego**

**Kit**: propio, estilo *asesino* (distancia preferida 40 px).

**Firma — Vuelo Prehistórico**: Al esquivar con Aliento se eleva: en el aire no lo alcanzan los golpes cortos. El primer ataque desde el aire es un Picado (+50%).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Mordisco | Siniestro | Físico | Golpe | 60 | 1.0 s |
| Clic der. | Ataque Ala | Volador | Físico | Embestida+combo | 60 | 3.0 s |
| Q | Supersónico | Normal | Estado | Canalizado | — | 7.0 s |
| R | Avalancha | Roca | Físico | Zona | 75 | 8.0 s |

**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Mordisco (kit) | Siniestro | Físico | Golpe | 60 | 1.0 s |
| 1 | Ataque Ala (kit) | Volador | Físico | Embestida+combo | 60 | 3.0 s |
| 3 | Supersónico (kit) | Normal | Estado | Canalizado | — | 7.0 s |
| 5 | Avalancha (kit) | Roca | Físico | Zona | 75 | 8.0 s |
| 8 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 29 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |
| 36 | Cara Susto | Normal | Estado | Área | — | 6.0 s |
| 43 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |
| 50 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

### 143 Snorlax

Normal · Pokémon Dormir · **aparece en el juego**

**Kit**: propio, estilo *tanque* (distancia preferida 30 px).

**Firma — Panza**: Cuerpo enorme: casi no lo empujan y recibe 20% menos de los golpes físicos. Pega ×1,3 a lo ralentizado.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Golpe Cuerpo | Normal | Físico | Golpe | 85 | 1.6 s |
| Clic der. | Bostezo | Normal | Estado | Disparo | — | 9.0 s |
| Q | Descanso | Psíquico | Estado | Mejora propia | — | 16.0 s |
| R | Hiperrayo | Normal | Especial | Disparo | 150 | 12.0 s |

**Ataques que puede aprender (14)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Golpe Cuerpo (kit) | Normal | Físico | Golpe | 85 | 1.6 s |
| 1 | Bostezo (kit) | Normal | Estado | Disparo | — | 9.0 s |
| 3 | Descanso (kit) | Psíquico | Estado | Mejora propia | — | 16.0 s |
| 5 | Hiperrayo (kit) | Normal | Especial | Disparo | 150 | 12.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 5 | Amnesia | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 9 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 13 | Tambor | Normal | Estado | Mejora propia | — | 10.0 s |
| 17 | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.6 s |
| 29 | Ronquido | Normal | Especial | Disparo | 50 | 1.6 s |
| 37 | Sonámbulo | Normal | Estado | Mejora propia | — | 10.0 s |
| 41 | Bloqueo | Normal | Estado | Área | — | 6.0 s |
| 45 | Antojo | Normal | Físico | Golpe | 60 | 1.4 s |
| 49 | Rodar | Roca | Físico | Embestida | 30 | 2.0 s |

### 144 Articuno

Hielo/Volador · Pokémon Congelar · **aparece en el juego**

**Kit**: propio, estilo *control* (distancia preferida 70 px).

**Firma — Ave Helada**: Legendario: cuerpo grande, casi no lo empujan. A mitad de vida bate las alas una vez (Ventisca alrededor que ralentiza) y queda enfurecido.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Rayo Hielo | Hielo | Especial | Disparo | 90 | 1.8 s |
| Clic der. | Ataque Ala | Volador | Físico | Embestida+combo | 60 | 3.5 s |
| Q | Neblina | Hielo | Estado | Zona | — | 9.0 s |
| R | Ventisca | Hielo | Especial | Zona | 110 | 8.0 s |

**Ataques que puede aprender (10)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Rayo Hielo (kit) | Hielo | Especial | Disparo | 90 | 1.8 s |
| 1 | Ataque Ala (kit) | Volador | Físico | Embestida+combo | 60 | 3.5 s |
| 3 | Neblina (kit) | Hielo | Estado | Zona | — | 9.0 s |
| 5 | Ventisca (kit) | Hielo | Especial | Zona | 110 | 8.0 s |
| 1 | Tornado | Volador | Especial | Disparo | 40 | 1.5 s |
| 1 | Nieve Polvo | Hielo | Especial | Área | 40 | 3.2 s |
| 25 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 37 | Telépata | Normal | Estado | Área | — | 6.0 s |
| 61 | Reflejo | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 85 | Frío Polar | Hielo | Especial | Disparo | 60 | 1.8 s |

### 145 Zapdos

Eléctrico/Volador · Pokémon Eléctrico · **aparece en el juego**

**Kit**: propio, estilo *bruiser* (distancia preferida 60 px).

**Firma — Ave Trueno**: Legendario: cuerpo grande, casi no lo empujan. A mitad de vida suelta una descarga alrededor que paraliza y queda enfurecido.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Impactrueno | Eléctrico | Especial | Disparo | 40 | 1.2 s |
| Clic der. | Pico Taladro | Volador | Físico | Embestida | 80 | 4.0 s |
| Q | Onda Trueno | Eléctrico | Estado | Disparo | — | 8.0 s |
| R | Trueno | Eléctrico | Especial | Zona | 110 | 8.0 s |

**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Impactrueno (kit) | Eléctrico | Especial | Disparo | 40 | 1.2 s |
| 1 | Pico Taladro (kit) | Volador | Físico | Embestida | 80 | 4.0 s |
| 3 | Onda Trueno (kit) | Eléctrico | Estado | Disparo | — | 8.0 s |
| 5 | Trueno (kit) | Eléctrico | Especial | Zona | 110 | 8.0 s |
| 1 | Picotazo | Volador | Físico | Golpe | 35 | 0.8 s |
| 25 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 37 | Detección | Lucha | Estado | Defensa | — | 8.0 s |
| 61 | Carga | Eléctrico | Estado | Mejora propia | — | 10.0 s |
| 73 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |

### 146 Moltres

Fuego/Volador · Pokémon Llama

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 147 Dratini

Dragón · Pokémon Dragón

**Kit**: propio, estilo *control* (distancia preferida 50 px).

**Firma — Muda**: Cada 6 s muda la piel: se saca de encima los problemas de estado (quemado, veneno, parálisis, sueño...).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Atadura | Normal | Físico | Látigo | 20 | 1.2 s |
| Clic der. | Onda Trueno | Eléctrico | Estado | Disparo | — | 8.0 s |
| Q | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| R | Furia Dragón | Dragón | Especial | Disparo | 60 | 4.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Atadura (kit) | Normal | Físico | Látigo | 20 | 1.2 s |
| 1 | Onda Trueno (kit) | Eléctrico | Estado | Disparo | — | 8.0 s |
| 3 | Agilidad (kit) | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 5 | Furia Dragón (kit) | Dragón | Especial | Disparo | 60 | 4.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 15 | Ciclón | Dragón | Especial | Área | 40 | 6.0 s |
| 29 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 43 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 50 | Enfado | Dragón | Físico | Embestida | 120 | 2.7 s |
| 57 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

### 148 Dragonair

Dragón · Pokémon Dragón · **aparece en el juego**

**Kit**: heredado de Dratini, estilo *control* (distancia preferida 50 px).

**Firma — Muda**: Cada 6 s muda la piel: se saca de encima los problemas de estado (quemado, veneno, parálisis, sueño...).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Atadura | Normal | Físico | Látigo | 20 | 1.2 s |
| Clic der. | Onda Trueno | Eléctrico | Estado | Disparo | — | 8.0 s |
| Q | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| R | Furia Dragón | Dragón | Especial | Disparo | 60 | 4.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Atadura (kit) | Normal | Físico | Látigo | 20 | 1.2 s |
| 1 | Onda Trueno (kit) | Eléctrico | Estado | Disparo | — | 8.0 s |
| 3 | Agilidad (kit) | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 5 | Furia Dragón (kit) | Dragón | Especial | Disparo | 60 | 4.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Ciclón | Dragón | Especial | Área | 40 | 6.0 s |
| 1 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 29 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 47 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 56 | Enfado | Dragón | Físico | Embestida | 120 | 2.7 s |
| 65 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

### 149 Dragonite

Dragón/Volador · Pokémon Dragón · **aparece en el juego**

**Kit**: heredado de Dratini, estilo *control* (distancia preferida 50 px).

**Firma — Muda**: Cada 6 s muda la piel: se saca de encima los problemas de estado (quemado, veneno, parálisis, sueño...).

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Atadura | Normal | Físico | Látigo | 20 | 1.2 s |
| Clic der. | Onda Trueno | Eléctrico | Estado | Disparo | — | 8.0 s |
| Q | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| R | Furia Dragón | Dragón | Especial | Disparo | 60 | 4.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Atadura (kit) | Normal | Físico | Látigo | 20 | 1.2 s |
| 1 | Onda Trueno (kit) | Eléctrico | Estado | Disparo | — | 8.0 s |
| 3 | Agilidad (kit) | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 5 | Furia Dragón (kit) | Dragón | Especial | Disparo | 60 | 4.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Ciclón | Dragón | Especial | Área | 40 | 6.0 s |
| 1 | Constricción | Normal | Físico | Látigo | 15 | 4.0 s |
| 29 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 47 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |
| 55 | Ataque Ala | Volador | Físico | Embestida | 60 | 1.9 s |
| 61 | Enfado | Dragón | Físico | Embestida | 120 | 2.7 s |
| 75 | Hiperrayo | Normal | Especial | Disparo | 150 | 3.5 s |

### 150 Mewtwo

Psíquico · Pokémon Genético

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 151 Mew

Psíquico · Pokémon Nueva Especie

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

**Ataques que puede aprender (6)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 10 | Transformación | Normal | Estado | Área | — | 6.0 s |
| 20 | Megapuño | Normal | Físico | Embestida | 80 | 2.1 s |
| 30 | Metrónomo | Normal | Estado | Mejora propia | — | 10.0 s |
| 40 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 50 | Poder Pasado | Roca | Especial | Disparo | 60 | 1.8 s |

### 152 Chikorita

Planta · Pokémon Hoja

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 153 Bayleef

Planta · Pokémon Hoja

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 154 Meganium

Planta · Pokémon Hierba

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 155 Cyndaquil

Fuego · Pokémon Ratón Fuego

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 156 Quilava

Fuego · Pokémon Volcán

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 157 Typhlosion

Fuego · Pokémon Volcán

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 158 Totodile

Agua · Pokémon Fauces

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 159 Croconaw

Agua · Pokémon Fauces

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 160 Feraligatr

Agua · Pokémon Fauces

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 161 Sentret

Normal · Pokémon Explorador

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 162 Furret

Normal · Pokémon Alargado

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 163 Hoothoot

Normal/Volador · Pokémon Búho

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 164 Noctowl

Normal/Volador · Pokémon Búho

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 165 Ledyba

Bicho/Volador · Pokémon 5 Estrellas

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 166 Ledian

Bicho/Volador · Pokémon 5 Estrellas

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 167 Spinarak

Bicho/Veneno · Pokémon Escupesoga

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 168 Ariados

Bicho/Veneno · Pokémon Pata Larga

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 169 Crobat

Veneno/Volador · Pokémon Murciélago

**Kit**: heredado de Zubat, estilo *hostigador* (distancia preferida 40 px).

**Firma — Ecolocalización**: Es ciego: no lo desorientan (Ataque Arena, Supersónico, humo...). Contra un rival desorientado, Chupavidas cura el doble.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Chupavidas | Bicho | Físico | Golpe | 30 | 0.8 s |
| Clic der. | Supersónico | Normal | Estado | Canalizado | — | 6.0 s |
| Q | Ataque Ala | Volador | Físico | Embestida+combo | 40 | 4.0 s |
| R | Rayo Confuso | Fantasma | Estado | Disparo | — | 8.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Chupavidas (kit) | Bicho | Físico | Golpe | 30 | 0.8 s |
| 1 | Supersónico (kit) | Normal | Estado | Canalizado | — | 6.0 s |
| 3 | Ataque Ala (kit) | Volador | Físico | Embestida+combo | 40 | 4.0 s |
| 5 | Rayo Confuso (kit) | Fantasma | Estado | Disparo | — | 8.0 s |
| 1 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 1 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 16 | Mordisco | Siniestro | Físico | Embestida | 60 | 1.9 s |
| 35 | Aire Afilado | Volador | Especial | Área | 60 | 3.7 s |
| 42 | Mal de Ojo | Normal | Estado | Área | — | 6.0 s |
| 49 | Colmillo Veneno | Veneno | Físico | Golpe | 50 | 1.3 s |
| 56 | Niebla | Hielo | Estado | Mejora propia | — | 10.0 s |

### 170 Chinchou

Agua/Eléctrico · Pokémon Rape

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 171 Lanturn

Agua/Eléctrico · Pokémon Luz

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 172 Pichu

Eléctrico · Pokémon Ratoncito

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

**Ataques que puede aprender (5)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Encanto | Hada | Estado | Área | — | 6.0 s |
| 1 | Impactrueno | Eléctrico | Especial | Disparo | 40 | 1.5 s |
| 6 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 8 | Onda Trueno | Eléctrico | Estado | Área | — | 6.0 s |
| 11 | Beso Dulce | Hada | Estado | Disparo | — | 6.0 s |

### 173 Cleffa

Hada · Pokémon Estrella

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

**Ataques que puede aprender (6)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Encanto | Hada | Estado | Área | — | 6.0 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 4 | Otra Vez | Normal | Estado | Área | — | 6.0 s |
| 8 | Canto | Normal | Estado | Zona | — | 12.0 s |
| 13 | Beso Dulce | Hada | Estado | Disparo | — | 6.0 s |
| 17 | Hoja Mágica | Planta | Especial | Disparo | 60 | 1.8 s |

### 174 Igglybuff

Normal/Hada · Pokémon Globo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

**Ataques que puede aprender (5)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Encanto | Hada | Estado | Área | — | 6.0 s |
| 1 | Canto | Normal | Estado | Zona | — | 12.0 s |
| 4 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 9 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| 14 | Beso Dulce | Hada | Estado | Disparo | — | 6.0 s |

### 175 Togepi

Hada · Pokémon Bolaclavos

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 176 Togetic

Hada/Volador · Pokémon Felicidad

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 177 Natu

Psíquico/Volador · Pokémon Pajarito

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 178 Xatu

Psíquico/Volador · Pokémon Místico

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 179 Mareep

Eléctrico · Pokémon Lana

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 180 Flaaffy

Eléctrico · Pokémon Lana

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 181 Ampharos

Eléctrico · Pokémon Luz

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 182 Bellossom

Planta · Pokémon Flor

**Kit**: heredado de Oddish, estilo *desgaste* (distancia preferida 75 px).

**Firma — Esporas**: Sus ataques dejan esporas en el rival (hasta 5). Florecer las hace florecer: 1+ envenena, 3+ paraliza, 5 duerme, y Oddish se cura por cada una.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| Clic der. | Polvo Veneno | Veneno | Estado | Zona | — | 1.6 s |
| Q | Paralizador | Planta | Estado | Zona | — | 5.0 s |
| R | Florecer | Planta | Estado | Mejora propia | — | 9.0 s |

**Ataques que puede aprender (8)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Absorber (kit) | Planta | Especial | Disparo | 20 | 0.9 s |
| 1 | Polvo Veneno (kit) | Veneno | Estado | Zona | — | 1.6 s |
| 3 | Paralizador (kit) | Planta | Estado | Zona | — | 5.0 s |
| 5 | Florecer (kit) | Planta | Estado | Mejora propia | — | 9.0 s |
| 1 | Hoja Mágica | Planta | Especial | Disparo | 60 | 1.8 s |
| 1 | Dulce Aroma | Normal | Estado | Área | — | 6.0 s |
| 44 | Danza Pétalo | Planta | Especial | Área | 120 | 5.5 s |
| 55 | Rayo Solar | Planta | Especial | Disparo | 120 | 2.9 s |

### 183 Marill

Agua/Hada · Pokémon Ratón Agua

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 184 Azumarill

Agua/Hada · Pokémon Conejo Agua

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 185 Sudowoodo

Roca · Pokémon Imitación

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 186 Politoed

Agua · Pokémon Rana

**Kit**: heredado de Poliwag, estilo *velocista* (distancia preferida 70 px).

**Firma — Deslizamiento**: Sobre el agua o el suelo mojado se mueve más rápido y esquiva el doble de seguido. Danza Lluvia moja el piso alrededor.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Burbuja | Agua | Especial | Disparo | 40 | 3.0 s |
| Clic der. | Pistola Agua | Agua | Especial | Disparo | 40 | 1.4 s |
| Q | Danza Lluvia | Agua | Estado | Área | — | 7.0 s |
| R | Hipnosis | Psíquico | Estado | Disparo | — | 10.0 s |

**Ataques que puede aprender (7)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja (kit) | Agua | Especial | Disparo | 40 | 3.0 s |
| 1 | Pistola Agua (kit) | Agua | Especial | Disparo | 40 | 1.4 s |
| 3 | Danza Lluvia (kit) | Agua | Estado | Área | — | 7.0 s |
| 5 | Hipnosis (kit) | Psíquico | Estado | Disparo | — | 10.0 s |
| 1 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 1 | Canto Mortal | Normal | Estado | Mejora propia | — | 10.0 s |
| 51 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |

### 187 Hoppip

Planta/Volador · Pokémon Algadón

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 188 Skiploom

Planta/Volador · Pokémon Algadón

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 189 Jumpluff

Planta/Volador · Pokémon Algadón

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 190 Aipom

Normal · Pokémon Cola Larga

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 191 Sunkern

Planta · Pokémon Semilla

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 192 Sunflora

Planta · Pokémon Sol

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 193 Yanma

Bicho/Volador · Pokémon Ala Clara

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 194 Wooper

Agua/Tierra · Pokémon Pez Agua

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 195 Quagsire

Agua/Tierra · Pokémon Pez Agua

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 196 Espeon

Psíquico · Pokémon Sol

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 197 Umbreon

Siniestro · Pokémon Luz Lunar

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 198 Murkrow

Siniestro/Volador · Pokémon Oscuridad

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 199 Slowking

Agua/Psíquico · Pokémon Regio

**Kit**: heredado de Slowpoke, estilo *tanque* (distancia preferida 50 px).

**Firma — Reacción Tardía**: De cada golpe recibe ahora el 70%; el resto le llega 2 s tarde, salvo que en ese tiempo él conecte un golpe. Bostezo: si el rival sigue con sueño a los 2 s, se duerme.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Golpe Cabeza | Normal | Físico | Golpe | 70 | 1.4 s |
| Clic der. | Pistola Agua | Agua | Especial | Disparo | 40 | 1.2 s |
| Q | Pesca con Cola | Agua | Físico | Látigo | 20 | 4.0 s |
| R | Bostezo | Normal | Estado | Disparo | — | 9.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Golpe Cabeza (kit) | Normal | Físico | Golpe | 70 | 1.4 s |
| 1 | Pistola Agua (kit) | Agua | Especial | Disparo | 40 | 1.2 s |
| 3 | Pesca con Cola (kit) | Agua | Físico | Látigo | 20 | 4.0 s |
| 5 | Bostezo (kit) | Normal | Estado | Disparo | — | 9.0 s |
| 1 | Maldición | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 6 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 17 | Confusión | Psíquico | Especial | Disparo | 50 | 2.0 s |
| 24 | Anulación | Normal | Estado | Disparo | — | 9.0 s |
| 36 | Fanfarronear | Normal | Estado | Disparo | — | 6.0 s |
| 40 | Psíquico | Psíquico | Especial | Disparo | 90 | 2.4 s |
| 47 | Autosugestión | Normal | Estado | Área | — | 6.0 s |

### 200 Misdreavus

Fantasma · Pokémon Chirrido

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 201 Unown

Psíquico · Pokémon Símbolo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

**Ataques que puede aprender (1)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Poder Oculto | Normal | Especial | Disparo | 60 | 1.8 s |

### 202 Wobbuffet

Psíquico · Pokémon Paciente

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

**Ataques que puede aprender (4)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Contraataque | Lucha | Físico | Golpe | 60 | 1.4 s |
| 1 | Mismo Destino | Fantasma | Estado | Mejora propia | — | 10.0 s |
| 1 | Manto Espejo | Psíquico | Especial | Disparo | 60 | 1.8 s |
| 1 | Velo Sagrado | Normal | Estado | Mejora propia | — | 10.0 s |

### 203 Girafarig

Normal/Psíquico · Pokémon Gran Cuello

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 204 Pineco

Bicho · Pokémon Larva

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 205 Forretress

Bicho/Acero · Pokémon Larva

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 206 Dunsparce

Normal · Pokémon Serpiente Tierra

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 207 Gligar

Tierra/Volador · Pokémon Escorpiala

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 208 Steelix

Acero/Tierra · Pokémon Serpiente Férrea

**Kit**: heredado de Onix, estilo *tanque* (distancia preferida 70 px).

**Firma — Coloso**: Jefe. Enorme: no lo empujan ni lo tambalean y recibe 25% menos de daño físico. Aplasta lo atrapado: +30% contra lo ralentizado. A mitad de vida ruge (empuja y deja Expuesto) y entra en Furia de Roca hasta el final.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Atadura | Normal | Físico | Látigo | 15 | 3.0 s |
| Clic der. | Lanzarrocas | Roca | Físico | Disparo | 50 | 1.8 s |
| Q | Excavar | Tierra | Físico | Zona | 80 | 8.0 s |
| R | Tumba Rocas | Roca | Físico | Zona | 50 | 9.0 s |

**Ataques que puede aprender (14)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Atadura (kit) | Normal | Físico | Látigo | 15 | 3.0 s |
| 1 | Lanzarrocas (kit) | Roca | Físico | Disparo | 50 | 1.8 s |
| 3 | Excavar (kit) | Tierra | Físico | Zona | 80 | 8.0 s |
| 5 | Tumba Rocas (kit) | Roca | Físico | Zona | 50 | 9.0 s |
| 1 | Chirrido | Normal | Estado | Área | — | 6.0 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 19 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 23 | Furia | Normal | Físico | Golpe | 20 | 0.9 s |
| 30 | Dragoaliento | Dragón | Especial | Disparo | 60 | 1.8 s |
| 34 | Tormenta de Arena | Roca | Estado | Mejora propia | — | 10.0 s |
| 41 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 45 | Cola Férrea | Acero | Físico | Embestida | 100 | 2.5 s |
| 52 | Triturar | Siniestro | Físico | Embestida | 80 | 2.1 s |
| 56 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

### 209 Snubbull

Hada · Pokémon Hada

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 210 Granbull

Hada · Pokémon Hada

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 211 Qwilfish

Agua/Veneno · Pokémon Globo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 212 Scizor

Bicho/Acero · Pokémon Tenaza

**Kit**: heredado de Scyther, estilo *asesino* (distancia preferida 30 px).

**Firma — Filo Furioso**: Cada golpe seguido al mismo rival suma una marca (hasta 5): +10% por marca. Si pasan 2,5 s sin pegarle, se pierden.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Corte Furia | Bicho | Físico | Golpe | 25 | 0.8 s |
| Clic der. | Ataque Ala | Volador | Físico | Embestida+combo | 60 | 3.5 s |
| Q | Danza Espada | Normal | Estado | Mejora propia | — | 10.0 s |
| R | Cuchillada | Normal | Físico | Golpe | 70 | 4.0 s |

**Ataques que puede aprender (12)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Corte Furia (kit) | Bicho | Físico | Golpe | 25 | 0.8 s |
| 1 | Ataque Ala (kit) | Volador | Físico | Embestida+combo | 60 | 3.5 s |
| 3 | Danza Espada (kit) | Normal | Estado | Mejora propia | — | 10.0 s |
| 5 | Cuchillada (kit) | Normal | Físico | Golpe | 70 | 4.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 1 | Ataque Rápido | Normal | Físico | Embestida | 40 | 1.6 s |
| 6 | Foco Energía | Normal | Estado | Mejora propia | — | 9.0 s |
| 11 | Persecución | Siniestro | Físico | Embestida+combo | 40 | 2.5 s |
| 16 | Falso Tortazo | Normal | Físico | Golpe | 40 | 1.1 s |
| 21 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 26 | Garra Metal | Acero | Físico | Golpe | 50 | 1.3 s |
| 41 | Defensa Férrea | Acero | Estado | Mejora propia | — | 10.0 s |

### 213 Shuckle

Bicho/Roca · Pokémon Moho

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 214 Heracross

Bicho/Lucha · Pokémon Cuerno

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 215 Sneasel

Siniestro/Hielo · Pokémon Garra Filo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 216 Teddiursa

Normal · Pokémon Osito

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 217 Ursaring

Normal · Pokémon Hibernante

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 218 Slugma

Fuego · Pokémon Lava

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 219 Magcargo

Fuego/Roca · Pokémon Lava

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 220 Swinub

Hielo/Tierra · Pokémon Cerdo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 221 Piloswine

Hielo/Tierra · Pokémon Puerco

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 222 Corsola

Agua/Roca · Pokémon Coral

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 223 Remoraid

Agua · Pokémon Reactor

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 224 Octillery

Agua · Pokémon Reactor

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 225 Delibird

Hielo/Volador · Pokémon Reparto

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

**Ataques que puede aprender (1)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Presente | Normal | Físico | Golpe | 60 | 1.4 s |

### 226 Mantine

Agua/Volador · Pokémon Milano

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 227 Skarmory

Acero/Volador · Pokémon Coraza Ave

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 228 Houndour

Siniestro/Fuego · Pokémon Siniestro

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 229 Houndoom

Siniestro/Fuego · Pokémon Siniestro

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 230 Kingdra

Agua/Dragón · Pokémon Dragón

**Kit**: heredado de Horsea, estilo *espaciador* (distancia preferida 110 px).

**Firma — Ancla**: Quieto 0,5 s se ancla con la cola: sus disparos pegan +30% y no lo empujan. Moverse lo suelta.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Burbuja | Agua | Especial | Disparo | 20 | 0.8 s |
| Clic der. | Pistola Agua | Agua | Especial | Disparo | 40 | 1.2 s |
| Q | Pantalla de Humo | Normal | Estado | Zona | — | 9.0 s |
| R | Chorro a Presión | Agua | Especial | Disparo | 75 | 6.0 s |

**Ataques que puede aprender (9)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Burbuja (kit) | Agua | Especial | Disparo | 20 | 0.8 s |
| 1 | Pistola Agua (kit) | Agua | Especial | Disparo | 40 | 1.2 s |
| 3 | Pantalla de Humo (kit) | Normal | Estado | Zona | — | 9.0 s |
| 5 | Chorro a Presión (kit) | Agua | Especial | Disparo | 75 | 6.0 s |
| 1 | Malicioso | Normal | Estado | Área | — | 8.0 s |
| 29 | Ciclón | Dragón | Especial | Área | 40 | 6.0 s |
| 40 | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 51 | Hidrobomba | Agua | Especial | Disparo | 110 | 2.7 s |
| 62 | Danza Dragón | Dragón | Estado | Mejora propia | — | 10.0 s |

### 231 Phanpy

Tierra · Pokémon Narizotas

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 232 Donphan

Tierra · Pokémon Coraza

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 233 Porygon2

Normal · Pokémon Virtual

**Kit**: heredado de Porygon, estilo *control* (distancia preferida 60 px).

**Firma — Conversión**: Se reconvierte: durante 8 s recibe 35% menos del último tipo que le pegó.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Placaje | Normal | Físico | Embestida | 40 | 1.2 s |
| Clic der. | Psicorrayo | Psíquico | Especial | Disparo | 65 | 1.6 s |
| Q | Agilidad | Psíquico | Estado | Mejora propia | — | 10.0 s |
| R | Triataque | Normal | Especial | Disparo | 80 | 4.0 s |

**Ataques que puede aprender (11)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje (kit) | Normal | Físico | Embestida | 40 | 1.2 s |
| 1 | Psicorrayo (kit) | Psíquico | Especial | Disparo | 65 | 1.6 s |
| 3 | Agilidad (kit) | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 5 | Triataque (kit) | Normal | Especial | Disparo | 80 | 4.0 s |
| 1 | Conversión | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Conversión 2 | Normal | Estado | Área | — | 6.0 s |
| 20 | Recuperación | Normal | Estado | Mejora propia | — | 16.0 s |
| 24 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 32 | Fijar Blanco | Normal | Estado | Disparo | — | 8.0 s |
| 44 | Reciclaje | Normal | Estado | Mejora propia | — | 10.0 s |
| 48 | Electrocañón | Eléctrico | Especial | Disparo | 120 | 2.9 s |

### 234 Stantler

Normal · Pokémon Gran Cuerno

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 235 Smeargle

Normal · Pokémon Pintor

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

**Ataques que puede aprender (1)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Esquema | Normal | Estado | Área | — | 6.0 s |

### 236 Tyrogue

Lucha · Pokémon Peleón

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

**Ataques que puede aprender (1)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |

### 237 Hitmontop

Lucha · Pokémon Boca Abajo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 238 Smoochum

Hielo/Psíquico · Pokémon Beso

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 239 Elekid

Eléctrico · Pokémon Eléctrico

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 240 Magby

Fuego · Pokémon Ascuas

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 241 Miltank

Normal · Pokémon Lechera

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 242 Blissey

Normal · Pokémon Felicidad

**Kit**: heredado de Chansey, estilo *tanque* (distancia preferida 55 px).

**Firma — Huevo Suerte**: Si pasan 2,5 s sin que le peguen, se cura sola un 2% de la vida por segundo.

| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| Clic izq. | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |
| Clic der. | Canto | Normal | Estado | Canalizado | — | 10.0 s |
| Q | Amortiguador | Normal | Estado | Mejora propia | — | 12.0 s |
| R | Bomba Huevo | Normal | Físico | Disparo | 100 | 5.0 s |

**Ataques que puede aprender (13)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Destructor (kit) | Normal | Físico | Golpe | 40 | 1.0 s |
| 1 | Canto (kit) | Normal | Estado | Canalizado | — | 10.0 s |
| 3 | Amortiguador (kit) | Normal | Estado | Mejora propia | — | 12.0 s |
| 5 | Bomba Huevo (kit) | Normal | Físico | Disparo | 100 | 5.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 4 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 7 | Alivio | Normal | Estado | Mejora propia | — | 10.0 s |
| 10 | Ovocuración | Normal | Estado | Mejora propia | — | 10.0 s |
| 13 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 18 | Reducción | Normal | Estado | Mejora propia | — | 9.0 s |
| 33 | Rizo Defensa | Normal | Estado | Mejora propia | — | 10.0 s |
| 40 | Pantalla de Luz | Psíquico | Estado | Mejora propia | — | 10.0 s |
| 47 | Doble Filo | Normal | Físico | Embestida | 120 | 2.7 s |

### 243 Raikou

Eléctrico · Pokémon Trueno

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 244 Entei

Fuego · Pokémon Volcán

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 245 Suicune

Agua · Pokémon Aurora

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 246 Larvitar

Roca/Tierra · Pokémon Piel Roca

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 247 Pupitar

Roca/Tierra · Pokémon Caparazón

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 248 Tyranitar

Roca/Siniestro · Pokémon Coraza

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 249 Lugia

Psíquico/Volador · Pokémon Buceo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 250 Ho-Oh

Fuego/Volador · Pokémon Arcoíris

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 251 Celebi

Psíquico/Planta · Pokémon Viajetiempo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 252 Treecko

Planta · Pokémon Geco Bosque

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 253 Grovyle

Planta · Pokémon Geco Bosque

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 254 Sceptile

Planta · Pokémon Monte

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 255 Torchic

Fuego · Pokémon Polluelo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 256 Combusken

Fuego/Lucha · Pokémon Ave Corral

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 257 Blaziken

Fuego/Lucha · Pokémon Llameante

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 258 Mudkip

Agua · Pokémon Pez Lodo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 259 Marshtomp

Agua/Tierra · Pokémon Pez Lodo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 260 Swampert

Agua/Tierra · Pokémon Pez Lodo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 261 Poochyena

Siniestro · Pokémon Mordisco

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 262 Mightyena

Siniestro · Pokémon Mordisco

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 263 Zigzagoon

Normal · Pokémon Mapachito

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 264 Linoone

Normal · Pokémon Lanzado

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 265 Wurmple

Bicho · Pokémon Gusano

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

**Ataques que puede aprender (3)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Disparo Demora | Bicho | Estado | Disparo | — | 2.5 s |
| 1 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 5 | Picotazo Veneno | Veneno | Físico | Golpe | 20 | 0.7 s |

### 266 Silcoon

Bicho · Pokémon Capullo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

**Ataques que puede aprender (1)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |

### 267 Beautifly

Bicho/Volador · Pokémon Mariposa

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 268 Cascoon

Bicho · Pokémon Capullo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

**Ataques que puede aprender (1)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |

### 269 Dustox

Bicho/Veneno · Pokémon Polilla Ven.

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 270 Lotad

Agua/Planta · Pokémon Lenteja Agua

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 271 Lombre

Agua/Planta · Pokémon Alegre

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 272 Ludicolo

Agua/Planta · Pokémon Optimista

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

**Ataques que puede aprender (4)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Absorber | Planta | Especial | Disparo | 20 | 0.9 s |
| 1 | Impresionar | Fantasma | Físico | Golpe | 30 | 1.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Adaptación | Normal | Estado | Área | — | 6.0 s |

### 273 Seedot

Planta · Pokémon Bellota

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 274 Nuzleaf

Planta/Siniestro · Pokémon Astuto

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 275 Shiftry

Planta/Siniestro · Pokémon Malvado

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

**Ataques que puede aprender (4)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Desarrollo | Normal | Estado | Mejora propia | — | 10.0 s |
| 1 | Fortaleza | Normal | Estado | Mejora propia | — | 8.0 s |
| 1 | Adaptación | Normal | Estado | Área | — | 6.0 s |
| 1 | Destructor | Normal | Físico | Golpe | 40 | 1.0 s |

### 276 Taillow

Normal/Volador · Pokémon Pequebuche

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 277 Swellow

Normal/Volador · Pokémon Buche

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 278 Wingull

Agua/Volador · Pokémon Gaviota

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 279 Pelipper

Agua/Volador · Pokémon Ave Agua

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 280 Ralts

Psíquico/Hada · Pokémon Sensible

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 281 Kirlia

Psíquico/Hada · Pokémon Sensorio

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 282 Gardevoir

Psíquico/Hada · Pokémon Envolvente

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 283 Surskit

Bicho/Agua · Pokémon Zapatero

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 284 Masquerain

Bicho/Volador · Pokémon Globocular

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 285 Shroomish

Planta · Pokémon Hongo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 286 Breloom

Planta/Lucha · Pokémon Hongo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 287 Slakoth

Normal · Pokémon Gandul

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 288 Vigoroth

Normal · Pokémon Mono Feroz

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 289 Slaking

Normal · Pokémon Holgazán

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 290 Nincada

Bicho/Tierra · Pokémon Aprendiz

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 291 Ninjask

Bicho/Volador · Pokémon Ninja

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 292 Shedinja

Bicho/Fantasma · Pokémon Muda

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 293 Whismur

Normal · Pokémon Susurro

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 294 Loudred

Normal · Pokémon Chillón

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 295 Exploud

Normal · Pokémon Escandaloso

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 296 Makuhita

Lucha · Pokémon Valiente

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 297 Hariyama

Lucha · Pokémon Empuje

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 298 Azurill

Normal/Hada · Pokémon A Topos

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

**Ataques que puede aprender (6)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Salpicadura | Normal | Estado | Embestida | — | 1.5 s |
| 3 | Encanto | Hada | Estado | Área | — | 6.0 s |
| 6 | Agitacola | Normal | Estado | Área | — | 6.0 s |
| 10 | Burbuja | Agua | Especial | Disparo | 40 | 1.5 s |
| 15 | Atizar | Normal | Físico | Embestida | 80 | 2.1 s |
| 21 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |

### 299 Nosepass

Roca · Pokémon Brújula

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 300 Skitty

Normal · Pokémon Gatito

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 301 Delcatty

Normal · Pokémon Cursi

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

**Ataques que puede aprender (4)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Atracción | Normal | Estado | Área | — | 6.0 s |
| 1 | Doble Bofetón | Normal | Físico | Golpe | 20 | 1.0 s |
| 1 | Gruñido | Normal | Estado | Área | — | 8.0 s |
| 1 | Canto | Normal | Estado | Zona | — | 12.0 s |

### 302 Sableye

Siniestro/Fantasma · Pokémon Oscuridad

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 303 Mawile

Acero/Hada · Pokémon Tramposo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 304 Aron

Acero/Roca · Pokémon Coraza Férrea

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 305 Lairon

Acero/Roca · Pokémon Coraza Férrea

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 306 Aggron

Acero/Roca · Pokémon Coraza Férrea

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 307 Meditite

Lucha/Psíquico · Pokémon Meditador

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 308 Medicham

Lucha/Psíquico · Pokémon Meditador

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 309 Electrike

Eléctrico · Pokémon Calambre

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 310 Manectric

Eléctrico · Pokémon Descarga

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 311 Plusle

Eléctrico · Pokémon Ánimo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 312 Minun

Eléctrico · Pokémon Ánimo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 313 Volbeat

Bicho · Pokémon Luciérnaga

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 314 Illumise

Bicho · Pokémon Luciérnaga

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 315 Roselia

Planta/Veneno · Pokémon Espina

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 316 Gulpin

Veneno · Pokémon Estómago

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 317 Swalot

Veneno · Pokémon Bolsa Veneno

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 318 Carvanha

Agua/Siniestro · Pokémon Feroz

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 319 Sharpedo

Agua/Siniestro · Pokémon Voraz

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 320 Wailmer

Agua · Pokémon Ballenabola

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 321 Wailord

Agua · Pokémon Ballenaflot

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 322 Numel

Fuego/Tierra · Pokémon Torpe

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 323 Camerupt

Fuego/Tierra · Pokémon Erupción

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 324 Torkoal

Fuego · Pokémon Carbón

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 325 Spoink

Psíquico · Pokémon Saltarín

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 326 Grumpig

Psíquico · Pokémon Manipulador

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 327 Spinda

Normal · Pokémon Panda Topos

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 328 Trapinch

Tierra · Pokémon Hormiga León

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 329 Vibrava

Tierra/Dragón · Pokémon Vibrante

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 330 Flygon

Tierra/Dragón · Pokémon Místico

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 331 Cacnea

Planta · Pokémon Cactus

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 332 Cacturne

Planta/Siniestro · Pokémon Espantajo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 333 Swablu

Normal/Volador · Pokémon Ave Algodón

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 334 Altaria

Dragón/Volador · Pokémon Cantor

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 335 Zangoose

Normal · Pokémon Gato Hurón

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 336 Seviper

Veneno · Pokémon Colmillos

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 337 Lunatone

Roca/Psíquico · Pokémon Meteorito

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 338 Solrock

Roca/Psíquico · Pokémon Meteorito

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 339 Barboach

Agua/Tierra · Pokémon Bigotudo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 340 Whiscash

Agua/Tierra · Pokémon Bigotudo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 341 Corphish

Agua · Pokémon Rufián

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 342 Crawdaunt

Agua/Siniestro · Pokémon Granuja

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 343 Baltoy

Tierra/Psíquico · Pokémon Muñeca Barro

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 344 Claydol

Tierra/Psíquico · Pokémon Muñeca Barro

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 345 Lileep

Roca/Planta · Pokémon Lirio de Mar

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 346 Cradily

Roca/Planta · Pokémon Percebe

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 347 Anorith

Roca/Bicho · Pokémon Camarón

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 348 Armaldo

Roca/Bicho · Pokémon Armadura

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 349 Feebas

Agua · Pokémon Pez

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

**Ataques que puede aprender (3)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Salpicadura | Normal | Estado | Embestida | — | 1.5 s |
| 15 | Placaje | Normal | Físico | Embestida | 40 | 1.6 s |
| 30 | Azote | Normal | Físico | Golpe | 40 | 2.5 s |

### 350 Milotic

Agua · Pokémon Tierno

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 351 Castform

Normal · Pokémon Clima

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 352 Kecleon

Normal · Pokémon Camaleónico

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 353 Shuppet

Fantasma · Pokémon Títere

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 354 Banette

Fantasma · Pokémon Marioneta

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 355 Duskull

Fantasma · Pokémon Réquiem

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 356 Dusclops

Fantasma · Pokémon Atrayente

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 357 Tropius

Planta/Volador · Pokémon Fruto

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 358 Chimecho

Psíquico · Pokémon Sonido Aire

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 359 Absol

Siniestro · Pokémon Catástrofe

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 360 Wynaut

Psíquico · Pokémon Radiante

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 362 Glalie

Hielo · Pokémon Cara

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 363 Spheal

Hielo/Agua · Pokémon Aplauso

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 364 Sealeo

Hielo/Agua · Pokémon Rodabola

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 365 Walrein

Hielo/Agua · Pokémon Rompehielo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 366 Clamperl

Agua · Pokémon Bivalvo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

**Ataques que puede aprender (4)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Tenaza | Agua | Físico | Embestida+combo | 35 | 6.0 s |
| 1 | Defensa Férrea | Acero | Estado | Mejora propia | — | 10.0 s |
| 1 | Pistola Agua | Agua | Especial | Disparo | 40 | 1.5 s |
| 1 | Torbellino | Agua | Especial | Disparo | 35 | 1.4 s |

### 367 Huntail

Agua · Pokémon Abisal

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 368 Gorebyss

Agua · Pokémon Mar del Sur

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 369 Relicanth

Agua/Roca · Pokémon Longevo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 370 Luvdisc

Agua · Pokémon Cita

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 371 Bagon

Dragón · Pokémon Cabeza Roca

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 372 Shelgon

Dragón · Pokémon Resistencia

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 373 Salamence

Dragón/Volador · Pokémon Dragón

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 374 Beldum

Acero/Psíquico · Pokémon Bola Hierro

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

**Ataques que puede aprender (1)**:

| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |
|---|---|---|---|---|---|---|
| 1 | Derribo | Normal | Físico | Embestida | 90 | 2.3 s |

### 375 Metang

Acero/Psíquico · Pokémon Garra Hierro

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 376 Metagross

Acero/Psíquico · Pokémon Pata Hierro

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 377 Regirock

Roca · Pokémon Pico Roca

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 378 Regice

Hielo · Pokémon Iceberg

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 379 Registeel

Acero · Pokémon Hierro

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 380 Latias

Dragón/Psíquico · Pokémon Eón

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 381 Latios

Dragón/Psíquico · Pokémon Eón

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 382 Kyogre

Agua · Pokémon Cuenca Mar

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 383 Groudon

Tierra · Pokémon Continente

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 384 Rayquaza

Dragón/Volador · Pokémon Cielo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 385 Jirachi

Acero/Psíquico · Pokémon Deseo

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

### 386 Deoxys

Psíquico · Pokémon ADN

**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).

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

