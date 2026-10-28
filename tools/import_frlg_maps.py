"""Mapas reales de FireRed (Pueblo Paleta → Ciudad Plateada) agrandados a la escala del juego.

Uso: python -I -B tools/import_frlg_maps.py <proyecto> [--stats]

Lee los mapas de art_src/pret (layouts + data/maps/<mapa>/map.json con conexiones y puertas) y escribe
data/world/frlg_maps.json, que después convierte en zonas `tools/import_frlg_maps.gd`.

Agrandar (exteriores y Bosque Verde): se insertan "costuras" de 2 celdas (un árbol entero) que cruzan el mapa de
punta a punta doblándose alrededor de lo que no se puede repetir. Una costura es válida si cada empalme nuevo
(entre la celda repetida y la de al lado, también donde la costura dobla) ya existe en algún mapa real de FireRed
(pares de metatiles vecinos de los 365 mapas). Así crecen el pasto, los caminos, el agua y las arboledas, y los
edificios, carteles, saltos y puertas quedan intactos. Cada mapa se agranda por separado; después se ubican según
las conexiones de FireRed alineando los caminos que los unen, y se rellenan los costados con el borde de árboles
del mapa para que todo encaje sin huecos.

Los interiores (casas, Centros, Tiendas, gimnasios, museo, garitas) van 1:1, lejos del mundo. Las puertas (warps)
apuntan a la celda de destino ya agrandada; las copias de una celda de puerta también son puerta.
"""
import json
import os
import struct
import sys

NUM_PRIMARY = 640
SCALE = 1.75  # cuánto se agranda cada eje de los exteriores y el Bosque Verde
SEAM = 2      # alto de cada costura (2 = el período de los árboles)
STEP = 2      # cuánto puede doblar una costura entre una celda y la siguiente

EXTERIORS = {  # mapa de FireRed -> (id de zona, nombre)
    "PalletTown": ("pueblo_paleta", "Pueblo Paleta"),
    "Route1": ("ruta1", "Ruta 1"),
    "ViridianCity": ("ciudad_verde", "Ciudad Verde"),
    "Route22": ("ruta22", "Ruta 22"),
    "Route2": ("ruta2", "Ruta 2"),
    "PewterCity": ("ciudad_plateada", "Ciudad Plateada"),
    # Capítulo 2 (docs/PLAN_CAPITULO_2.md): de Plateada a Celeste. Se agregan al final para no mover nada de lo anterior.
    "Route3": ("ruta3", "Ruta 3"),
    "Route4": ("ruta4", "Ruta 4"),
    "CeruleanCity": ("ciudad_celeste", "Ciudad Celeste"),
    "Route24": ("ruta24", "Ruta 24 (Puente Pepita)"),
    "Route25": ("ruta25", "Ruta 25"),
    # Capítulo 3 (de Celeste a Carmín): Azafrán no se arma (está cerrada en esa parte de la historia), pero se ubica
    # para que la Ruta 6 y Carmín queden donde van; se pasa por la Vía Subterránea.
    "Route5": ("ruta5", "Ruta 5"),
    "SaffronCity": ("ciudad_azafran", "Ciudad Azafrán"),
    "Route6": ("ruta6", "Ruta 6"),
    "VermilionCity": ("ciudad_carmin", "Ciudad Carmín"),
}
# Mapas del capítulo 2 (se agrandaron sin proteger las celdas de objetos; se dejan así para que no cambien).
CHAPTER2_MAPS = {"Route3", "Route4", "CeruleanCity", "Route24", "Route25", "MtMoon_1F", "MtMoon_B1F", "MtMoon_B2F"}
# Mapas que solo sirven para ubicar a sus vecinos: no se arman como zona (queda un hueco con paredes).
PHANTOMS = set()  # (Azafrán fue hueco en el capítulo 3; desde el resto de Kanto es una zona)
# Conexiones de FireRed a versiones especiales de un mapa -> el mapa.
CONNECTION_ALIASES = {"MAP_SAFFRON_CITY_CONNECTION": "SaffronCity"}
# Exteriores del capítulo 1: el corrimiento del mundo se calcula solo con ellos (así las zonas viejas no se mueven).
FIRST_EXTERIORS = ["PalletTown", "Route1", "ViridianCity", "Route22", "Route2", "PewterCity"]
# Mapas que salen de costado de la columna principal y empalman con su borde (no con el del mapa sin relleno):
# raíz de la rama -> (lado, mapas de la rama).
BRANCHES = {"Route22": ("left", ["Route22"]),
            "Route3": ("right", ["Route3", "Route4", "CeruleanCity", "Route24", "Route25", "Route5", "SaffronCity",
                                 "Route6", "VermilionCity"])}
MAIN_COLUMN = ["PewterCity", "Route2", "ViridianCity", "Route1", "PalletTown"]  # apilados de norte a sur
STRETCHED = {"ViridianForest": ("bosque_verde", "Bosque Verde")}
INTERIORS = {
    "PalletTown_PlayersHouse_1F": ("casa_jugador", "Tu casa"),
    "PalletTown_PlayersHouse_2F": ("casa_jugador_2p", "Tu casa (planta alta)"),
    "PalletTown_RivalsHouse": ("casa_rival", "Casa de tu rival"),
    "PalletTown_ProfessorOaksLab": ("laboratorio_oak", "Laboratorio del Prof. Oak"),
    "ViridianCity_PokemonCenter_1F": ("ciudad_verde_centro", "Centro Pokémon de Ciudad Verde"),
    "ViridianCity_Mart": ("ciudad_verde_tienda", "Tienda de Ciudad Verde"),
    "ViridianCity_Gym": ("ciudad_verde_gimnasio", "Gimnasio de Ciudad Verde"),
    "ViridianCity_School": ("ciudad_verde_escuela", "Escuela de Entrenadores"),
    "ViridianCity_House": ("ciudad_verde_casa", "Casa de Ciudad Verde"),
    "Route22_NorthEntrance": ("ruta22_garita", "Garita de la Ruta 22"),
    "Route2_ViridianForest_SouthEntrance": ("ruta2_garita_sur", "Entrada sur del Bosque Verde"),
    "Route2_ViridianForest_NorthEntrance": ("ruta2_garita_norte", "Entrada norte del Bosque Verde"),
    "Route2_House": ("ruta2_casa", "Casa de la Ruta 2"),
    "Route2_EastBuilding": ("ruta2_edificio", "Edificio de la Ruta 2"),
    "PewterCity_Museum_1F": ("museo", "Museo de Ciencias"),
    "PewterCity_Museum_2F": ("museo_2p", "Museo de Ciencias (planta alta)"),
    "PewterCity_Gym": ("ciudad_plateada_gimnasio", "Gimnasio de Ciudad Plateada"),
    "PewterCity_Mart": ("ciudad_plateada_tienda", "Tienda de Ciudad Plateada"),
    "PewterCity_House1": ("ciudad_plateada_casa1", "Casa de Ciudad Plateada"),
    "PewterCity_House2": ("ciudad_plateada_casa2", "Casa de Ciudad Plateada"),
    "PewterCity_PokemonCenter_1F": ("ciudad_plateada_centro", "Centro Pokémon de Ciudad Plateada"),
}
# Cuevas (agrandadas como el Bosque Verde; lejos del mundo, después de los interiores del capítulo 1).
CAVES = {
    "MtMoon_1F": ("mt_moon", "Mt. Moon"),
    "MtMoon_B1F": ("mt_moon_s1", "Mt. Moon (sótano 1)"),
    "MtMoon_B2F": ("mt_moon_s2", "Mt. Moon (sótano 2)"),
}
INTERIORS_2 = {
    "Route4_PokemonCenter_1F": ("ruta4_centro", "Centro Pokémon de la Ruta 4"),
    "CeruleanCity_PokemonCenter_1F": ("ciudad_celeste_centro", "Centro Pokémon de Ciudad Celeste"),
    "CeruleanCity_Mart": ("ciudad_celeste_tienda", "Tienda de Ciudad Celeste"),
    "CeruleanCity_Gym": ("ciudad_celeste_gimnasio", "Gimnasio de Ciudad Celeste"),
    "CeruleanCity_BikeShop": ("ciudad_celeste_bicis", "Tienda de bicicletas"),
    "CeruleanCity_House1": ("ciudad_celeste_casa1", "Casa de Ciudad Celeste"),
    "CeruleanCity_House2": ("ciudad_celeste_casa_robada", "Casa robada"),
    "CeruleanCity_House3": ("ciudad_celeste_casa3", "Casa de Ciudad Celeste"),
    "CeruleanCity_House4": ("ciudad_celeste_casa4", "Casa de Ciudad Celeste"),
    "CeruleanCity_House5": ("ciudad_celeste_casa5", "Casa de Ciudad Celeste"),
    "Route25_SeaCottage": ("casa_bill", "Casa de Bill"),
}
INTERIORS_3 = {
    "Route5_PokemonDayCare": ("ruta5_guarderia", "Guardería Pokémon"),
    "Route5_SouthEntrance": ("ruta5_garita", "Garita de la Ruta 5"),
    "UndergroundPath_NorthEntrance": ("via_subterranea_norte", "Vía Subterránea (entrada norte)"),
    "UndergroundPath_NorthSouthTunnel": ("via_subterranea", "Vía Subterránea"),
    "UndergroundPath_SouthEntrance": ("via_subterranea_sur", "Vía Subterránea (entrada sur)"),
    "Route6_NorthEntrance": ("ruta6_garita", "Garita de la Ruta 6"),
    "VermilionCity_PokemonCenter_1F": ("ciudad_carmin_centro", "Centro Pokémon de Ciudad Carmín"),
    "VermilionCity_Mart": ("ciudad_carmin_tienda", "Tienda de Ciudad Carmín"),
    "VermilionCity_PokemonFanClub": ("club_fans", "Club de Fans de Pokémon"),
    "VermilionCity_Gym": ("ciudad_carmin_gimnasio", "Gimnasio de Ciudad Carmín"),
    "VermilionCity_House1": ("ciudad_carmin_casa1", "Casa de Ciudad Carmín"),
    "VermilionCity_House2": ("ciudad_carmin_casa2", "Casa de Ciudad Carmín"),
    "VermilionCity_House3": ("ciudad_carmin_casa3", "Casa de Ciudad Carmín"),
    "SSAnne_Exterior": ("ss_anne_muelle", "Muelle del S.S. Anne"),
    "SSAnne_1F_Corridor": ("ss_anne_1p", "S.S. Anne (planta 1)"),
    "SSAnne_2F_Corridor": ("ss_anne_2p", "S.S. Anne (planta 2)"),
    "SSAnne_3F_Corridor": ("ss_anne_3p", "S.S. Anne (planta 3)"),
    "SSAnne_B1F_Corridor": ("ss_anne_s1", "S.S. Anne (sótano)"),
    "SSAnne_Deck": ("ss_anne_cubierta", "Cubierta del S.S. Anne"),
    "SSAnne_Kitchen": ("ss_anne_cocina", "Cocina del S.S. Anne"),
    "SSAnne_CaptainsOffice": ("ss_anne_capitan", "Camarote del capitán"),
}
for _f, _n in (("1F", 7), ("2F", 6), ("B1F", 5)):
    for _i in range(1, _n + 1):
        _pre = {"1F": "ss_anne_1p", "2F": "ss_anne_2p", "B1F": "ss_anne_s1"}[_f]
        _name = {"1F": "planta 1", "2F": "planta 2", "B1F": "sótano"}[_f]
        INTERIORS_3["SSAnne_%s_Room%d" % (_f, _i)] = ("%s_camarote%d" % (_pre, _i), "Camarote del S.S. Anne (%s)" % _name)
# Plantilla de salvajes de FireRed (encounters/plantillas_frlg.json); las zonas sin plantilla no tienen salvajes.
TEMPLATES = {"PalletTown": "pallet_town", "Route1": "route1", "ViridianCity": "viridian_city", "Route22": "route22",
             "Route2": "route2", "PewterCity": "pewter_city", "ViridianForest": "viridian_forest",
             "Route3": "route3", "Route4": "route4", "CeruleanCity": "cerulean_city", "Route24": "route24",
             "Route25": "route25", "MtMoon_1F": "mt_moon_1f", "MtMoon_B1F": "mt_moon_b1f", "MtMoon_B2F": "mt_moon_b2f",
             "Route5": "route5", "Route6": "route6", "VermilionCity": "vermilion_city"}
# Objetos de FireRed que son objetos del entorno del juego (scenes/world/objects/); NPC, carteles y objetos no.
OBJECTS = {"OBJ_EVENT_GFX_CUT_TREE": "res://scenes/world/objects/cut_tree.tscn",
           "OBJ_EVENT_GFX_ROCK_SMASH_ROCK": "res://scenes/world/objects/rock_smash_rock.tscn",
           "OBJ_EVENT_GFX_PUSHABLE_BOULDER": "res://scenes/world/objects/strength_boulder.tscn"}
# --- Resto de Kanto (2026-10-28, "hasta terminar la historia") -------------------------------------------------
# Exteriores nuevos: se ubican en una segunda pasada (PLACE_ORDER), después de todo lo anterior, así nada se mueve.
EXTERIORS_4 = {
    "Route9": ("ruta9", "Ruta 9"), "Route10": ("ruta10", "Ruta 10"), "LavenderTown": ("pueblo_lavanda", "Pueblo Lavanda"),
    "Route8": ("ruta8", "Ruta 8"), "Route7": ("ruta7", "Ruta 7"), "CeladonCity": ("ciudad_azulona", "Ciudad Azulona"),
    "Route16": ("ruta16", "Ruta 16"), "Route17": ("ruta17", "Ruta 17 (Ruta Bici)"), "Route18": ("ruta18", "Ruta 18"),
    "FuchsiaCity": ("ciudad_fucsia", "Ciudad Fucsia"), "Route12": ("ruta12", "Ruta 12"), "Route13": ("ruta13", "Ruta 13"),
    "Route14": ("ruta14", "Ruta 14"), "Route15": ("ruta15", "Ruta 15"), "Route11": ("ruta11", "Ruta 11"),
    "Route19": ("ruta19", "Ruta 19"), "Route20": ("ruta20", "Ruta 20"), "CinnabarIsland": ("isla_canela", "Isla Canela"),
    "Route21_South": ("ruta21_sur", "Ruta 21 (sur)"), "Route21_North": ("ruta21_norte", "Ruta 21 (norte)"),
    "Route23": ("ruta23", "Ruta 23"), "IndigoPlateau_Exterior": ("meseta_anil", "Meseta Añil"),
}
# (mapa nuevo, mapa ya ubicado del que sale): el orden importa (cada uno se alinea con su "padre"; las conexiones que
# cierran un círculo, como Ruta 8–Azafrán o Ruta 21–Paleta, empalman como pueden).
PLACE_ORDER = [("Route9", "CeruleanCity"), ("Route10", "Route9"), ("LavenderTown", "Route10"), ("Route8", "LavenderTown"),
               ("Route7", "SaffronCity"), ("CeladonCity", "Route7"), ("Route16", "CeladonCity"), ("Route17", "Route16"),
               ("Route18", "Route17"), ("FuchsiaCity", "Route18"), ("Route12", "LavenderTown"), ("Route13", "Route12"),
               ("Route14", "Route13"), ("Route15", "Route14"), ("Route11", "VermilionCity"), ("Route19", "FuchsiaCity"),
               ("Route20", "Route19"), ("CinnabarIsland", "Route20"), ("Route21_South", "CinnabarIsland"),
               ("Route21_North", "Route21_South"), ("Route23", "Route22"), ("IndigoPlateau_Exterior", "Route23")]
# Mapas que cierran un círculo: se agrandan justo hasta llenar el espacio entre dos zonas ya ubicadas.
# mapa -> (eje, zona de un lado, zona del otro lado[, mapa con el que se reparte el espacio]).
FIT = {"Route8": ("x", "SaffronCity", "LavenderTown"), "Route11": ("x", "VermilionCity", "Route12"),
       "Route15": ("x", "FuchsiaCity", "Route14"), "Route21_North": ("y", "PalletTown", "CinnabarIsland", "Route21_South")}
# Zonas grandes de salvajes lejos del mundo, agrandadas como el Bosque Verde.
STRETCHED_4 = {"SafariZone_Center": ("zona_safari", "Zona Safari (centro)"),
               "SafariZone_East": ("zona_safari_este", "Zona Safari (este)"),
               "SafariZone_North": ("zona_safari_norte", "Zona Safari (norte)"),
               "SafariZone_West": ("zona_safari_oeste", "Zona Safari (oeste)")}
CAVES_4 = {
    "RockTunnel_1F": ("tunel_roca", "Túnel Roca"), "RockTunnel_B1F": ("tunel_roca_s1", "Túnel Roca (sótano)"),
    "DiglettsCave_B1F": ("cueva_diglett", "Cueva Diglett"), "PowerPlant": ("central_electrica", "Central Eléctrica"),
    "SeafoamIslands_1F": ("islas_espuma", "Islas Espuma"), "SeafoamIslands_B1F": ("islas_espuma_s1", "Islas Espuma (sótano 1)"),
    "SeafoamIslands_B2F": ("islas_espuma_s2", "Islas Espuma (sótano 2)"),
    "SeafoamIslands_B3F": ("islas_espuma_s3", "Islas Espuma (sótano 3)"),
    "SeafoamIslands_B4F": ("islas_espuma_s4", "Islas Espuma (sótano 4)"),
    "VictoryRoad_1F": ("calle_victoria_1p", "Calle Victoria (planta 1)"),
    "VictoryRoad_2F": ("calle_victoria_2p", "Calle Victoria (planta 2)"),
    "VictoryRoad_3F": ("calle_victoria_3p", "Calle Victoria (planta 3)"),
}
# Interiores 1:1 con salvajes en el suelo (fantasmas de la Torre, la Mansión).
WILD_INTERIORS_4 = {}
for _i in range(1, 8):
    WILD_INTERIORS_4["PokemonTower_%dF" % _i] = ("torre_pokemon_%dp" % _i, "Torre Pokémon (planta %d)" % _i)
for _f, _id, _n in (("1F", "1p", "planta 1"), ("2F", "2p", "planta 2"), ("3F", "3p", "planta 3"), ("B1F", "s1", "sótano")):
    WILD_INTERIORS_4["PokemonMansion_" + _f] = ("mansion_pokemon_" + _id, "Mansión Pokémon (%s)" % _n)
INTERIORS_4 = {
    "Route10_PokemonCenter_1F": ("ruta10_centro", "Centro Pokémon de la Ruta 10"),
    "LavenderTown_PokemonCenter_1F": ("pueblo_lavanda_centro", "Centro Pokémon de Pueblo Lavanda"),
    "LavenderTown_Mart": ("pueblo_lavanda_tienda", "Tienda de Pueblo Lavanda"),
    "LavenderTown_VolunteerPokemonHouse": ("casa_voluntarios", "Casa de Voluntarios Pokémon"),
    "LavenderTown_House1": ("pueblo_lavanda_casa1", "Casa de Pueblo Lavanda"),
    "LavenderTown_House2": ("pueblo_lavanda_casa2", "Casa de Pueblo Lavanda"),
    "Route8_WestEntrance": ("ruta8_garita", "Garita de la Ruta 8"),
    "Route7_EastEntrance": ("ruta7_garita", "Garita de la Ruta 7"),
    "UndergroundPath_EastEntrance": ("via_subterranea_este", "Vía Subterránea (entrada este)"),
    "UndergroundPath_EastWestTunnel": ("via_subterranea_eo", "Vía Subterránea (este–oeste)"),
    "UndergroundPath_WestEntrance": ("via_subterranea_oeste", "Vía Subterránea (entrada oeste)"),
    "CeladonCity_PokemonCenter_1F": ("ciudad_azulona_centro", "Centro Pokémon de Ciudad Azulona"),
    "CeladonCity_Gym": ("ciudad_azulona_gimnasio", "Gimnasio de Ciudad Azulona"),
    "CeladonCity_GameCorner": ("ciudad_azulona_casino", "Casino de Azulona"),
    "CeladonCity_GameCorner_PrizeRoom": ("ciudad_azulona_premios", "Sala de premios del Casino"),
    "CeladonCity_Hotel": ("ciudad_azulona_hotel", "Hotel de Azulona"),
    "CeladonCity_Restaurant": ("ciudad_azulona_restaurante", "Restaurante de Azulona"),
    "CeladonCity_House1": ("ciudad_azulona_casa1", "Casa de Ciudad Azulona"),
    "CeladonCity_DepartmentStore_Roof": ("ciudad_azulona_almacen_azotea", "Gran Almacén de Azulona (azotea)"),
    "CeladonCity_Condominiums_Roof": ("ciudad_azulona_mansion_azotea", "Mansión Azulona (azotea)"),
    "CeladonCity_Condominiums_RoofRoom": ("ciudad_azulona_mansion_cuarto", "Mansión Azulona (cuarto de la azotea)"),
    "SaffronCity_PokemonCenter_1F": ("ciudad_azafran_centro", "Centro Pokémon de Ciudad Azafrán"),
    "SaffronCity_Mart": ("ciudad_azafran_tienda", "Tienda de Ciudad Azafrán"),
    "SaffronCity_Gym": ("ciudad_azafran_gimnasio", "Gimnasio de Ciudad Azafrán"),
    "SaffronCity_Dojo": ("dojo_karate", "Dojo Karate"),
    "SaffronCity_House": ("ciudad_azafran_casa", "Casa de Ciudad Azafrán"),
    "SaffronCity_CopycatsHouse_1F": ("casa_imitadora", "Casa de la Imitadora"),
    "SaffronCity_CopycatsHouse_2F": ("casa_imitadora_2p", "Casa de la Imitadora (planta alta)"),
    "SaffronCity_MrPsychicsHouse": ("casa_sr_psiquico", "Casa del Sr. Psíquico"),
    "SaffronCity_PokemonTrainerFanClub": ("club_entrenadores", "Club de Fans de Entrenadores"),
    "Route11_EastEntrance_1F": ("ruta11_garita", "Garita de la Ruta 11"),
    "Route11_EastEntrance_2F": ("ruta11_garita_2p", "Garita de la Ruta 11 (planta alta)"),
    "DiglettsCave_NorthEntrance": ("cueva_diglett_norte", "Cueva Diglett (entrada norte)"),
    "DiglettsCave_SouthEntrance": ("cueva_diglett_sur", "Cueva Diglett (entrada sur)"),
    "Route12_NorthEntrance_1F": ("ruta12_garita", "Garita de la Ruta 12"),
    "Route12_NorthEntrance_2F": ("ruta12_garita_2p", "Garita de la Ruta 12 (planta alta)"),
    "Route12_FishingHouse": ("casa_pescador", "Casa del Pescador"),
    "Route15_WestEntrance_1F": ("ruta15_garita", "Garita de la Ruta 15"),
    "Route15_WestEntrance_2F": ("ruta15_garita_2p", "Garita de la Ruta 15 (planta alta)"),
    "Route16_NorthEntrance_1F": ("ruta16_garita", "Garita de la Ruta 16"),
    "Route16_NorthEntrance_2F": ("ruta16_garita_2p", "Garita de la Ruta 16 (planta alta)"),
    "Route16_House": ("ruta16_casa", "Casa de la Ruta 16"),
    "Route18_EastEntrance_1F": ("ruta18_garita", "Garita de la Ruta 18"),
    "Route18_EastEntrance_2F": ("ruta18_garita_2p", "Garita de la Ruta 18 (planta alta)"),
    "FuchsiaCity_PokemonCenter_1F": ("ciudad_fucsia_centro", "Centro Pokémon de Ciudad Fucsia"),
    "FuchsiaCity_Mart": ("ciudad_fucsia_tienda", "Tienda de Ciudad Fucsia"),
    "FuchsiaCity_Gym": ("ciudad_fucsia_gimnasio", "Gimnasio de Ciudad Fucsia"),
    "FuchsiaCity_SafariZone_Entrance": ("ciudad_fucsia_safari", "Entrada de la Zona Safari"),
    "FuchsiaCity_SafariZone_Office": ("ciudad_fucsia_safari_oficina", "Oficina de la Zona Safari"),
    "FuchsiaCity_WardensHouse": ("casa_guarda", "Casa del Guarda"),
    "FuchsiaCity_House1": ("ciudad_fucsia_casa1", "Casa de Ciudad Fucsia"),
    "FuchsiaCity_House2": ("ciudad_fucsia_casa2", "Casa de Ciudad Fucsia"),
    "FuchsiaCity_House3": ("ciudad_fucsia_casa3", "Casa de Ciudad Fucsia"),
    "SafariZone_Center_RestHouse": ("zona_safari_descanso", "Zona Safari (casa de descanso)"),
    "SafariZone_East_RestHouse": ("zona_safari_este_descanso", "Zona Safari (casa de descanso del este)"),
    "SafariZone_North_RestHouse": ("zona_safari_norte_descanso", "Zona Safari (casa de descanso del norte)"),
    "SafariZone_West_RestHouse": ("zona_safari_oeste_descanso", "Zona Safari (casa de descanso del oeste)"),
    "SafariZone_SecretHouse": ("zona_safari_casa_secreta", "Zona Safari (casa secreta)"),
    "CinnabarIsland_PokemonCenter_1F": ("isla_canela_centro", "Centro Pokémon de Isla Canela"),
    "CinnabarIsland_Mart": ("isla_canela_tienda", "Tienda de Isla Canela"),
    "CinnabarIsland_Gym": ("isla_canela_gimnasio", "Gimnasio de Isla Canela"),
    "CinnabarIsland_PokemonLab_Entrance": ("isla_canela_lab", "Laboratorio Pokémon"),
    "CinnabarIsland_PokemonLab_Lounge": ("isla_canela_lab_sala", "Laboratorio Pokémon (sala)"),
    "CinnabarIsland_PokemonLab_ResearchRoom": ("isla_canela_lab_investigacion", "Laboratorio Pokémon (investigación)"),
    "CinnabarIsland_PokemonLab_ExperimentRoom": ("isla_canela_lab_experimentos", "Laboratorio Pokémon (experimentos)"),
    "IndigoPlateau_PokemonCenter_1F": ("meseta_anil_centro", "Centro Pokémon de la Meseta Añil"),
    "PokemonLeague_LoreleisRoom": ("liga_lorelei", "Sala de Lorelei"),
    "PokemonLeague_BrunosRoom": ("liga_bruno", "Sala de Bruno"),
    "PokemonLeague_AgathasRoom": ("liga_agatha", "Sala de Agatha"),
    "PokemonLeague_LancesRoom": ("liga_lance", "Sala de Lance"),
    "PokemonLeague_ChampionsRoom": ("liga_campeon", "Sala del Campeón"),
    "PokemonLeague_HallOfFame": ("liga_hall", "Hall de la Fama"),
}
for _i in range(1, 6):
    INTERIORS_4["CeladonCity_DepartmentStore_%dF" % _i] = ("ciudad_azulona_almacen_%dp" % _i,
                                                           "Gran Almacén de Azulona (planta %d)" % _i)
for _i in range(1, 4):
    INTERIORS_4["CeladonCity_Condominiums_%dF" % _i] = ("ciudad_azulona_mansion_%dp" % _i, "Mansión Azulona (planta %d)" % _i)
for _i in range(1, 5):
    INTERIORS_4["RocketHideout_B%dF" % _i] = ("escondite_rocket_s%d" % _i, "Escondite Rocket (sótano %d)" % _i)
for _i in range(1, 12):
    INTERIORS_4["SilphCo_%dF" % _i] = ("silph_%dp" % _i, "Silph S.A. (planta %d)" % _i)


def snake(name):
    """RockTunnel_1F -> rock_tunnel_1f (así se llaman las plantillas de salvajes de FireRed)."""
    out = ""
    for i, ch in enumerate(name):
        if ch.isupper() and i and name[i - 1].islower():
            out += "_"
        out += ch.lower()
    return out

SPAWN = ("PalletTown", 6, 9)  # frente a tu casa (celda del mapa original)
INTERIOR_GAP = 24             # celdas libres entre interiores (y entre el mundo y los interiores)
INTERIOR_ROW = 220            # ancho de cada fila de interiores
# Categorías del catálogo que nunca se repiten al agrandar (los edificios no crecen y no se duplican carteles).
KEEP = {"edificios", "otros_edificios", "otros_puertas", "carteles", "otros_carteles", "escaleras",
        "otros_escaleras", "adornos"}
NO_COPY = set()  # metatiles de esas categorías (lo llena main con el catálogo)
WATER = set()  # metatiles de agua (catálogo): nunca son suelo de relleno en los mapas nuevos


def const_of(name):
    """PalletTown_PlayersHouse_1F -> MAP_PALLET_TOWN_PLAYERS_HOUSE_1F."""
    out = ""
    for i, ch in enumerate(name):
        if ch.isupper() and i and name[i - 1].islower():
            out += "_"
        out += ch.upper()
    return "MAP_" + out


class Sets:
    def __init__(self, root):
        self.manifest = json.load(open(os.path.join(root, "art", "pret", "tiles", "manifest.json")))
        sys.path.insert(0, os.path.join(root, "tools"))
        import pret_import as P
        self.headers = P.parse_headers(os.path.join(root, "art_src", "pret"))

    def gid(self, pn, sn, mt):
        setn, local = (pn, mt) if mt < NUM_PRIMARY else (sn, mt - NUM_PRIMARY)
        info = self.manifest[setn]
        if local >= info["count"] or info["empty"][local]:
            return -1
        return info["base"] + local


def read_layouts(root, sets):
    pret = os.path.join(root, "art_src", "pret")
    out = {}
    for l in json.load(open(os.path.join(pret, "data", "layouts", "layouts.json")))["layouts"]:
        if not l or l.get("primary_tileset") not in sets.headers or l.get("secondary_tileset") not in sets.headers:
            continue
        pn, sn = sets.headers[l["primary_tileset"]]["name"], sets.headers[l["secondary_tileset"]]["name"]
        if pn not in sets.manifest or sn not in sets.manifest:
            continue

        def grid(path, n):
            p = os.path.join(pret, path)
            if not os.path.exists(p):
                return None
            vals = struct.unpack("<%dH" % n, open(p, "rb").read()[:n * 2])
            return [(sets.gid(pn, sn, v & 0x3FF), (v >> 10) & 3) for v in vals]
        w, h = l["width"], l["height"]
        out[l["id"]] = {"name": l["name"], "w": w, "h": h, "cells": grid(l["blockdata_filepath"], w * h),
                        "border": grid(l["border_filepath"], l.get("border_width", 2) * l.get("border_height", 2)),
                        "bw": l.get("border_width", 2)}
    return out


def pairs_of(layouts):
    """Pares de metatiles vecinos en todos los mapas reales: horizontales (izq, der) y verticales (arriba, abajo)."""
    hp, vp = set(), set()
    for l in layouts.values():
        w, c = l["w"], l["cells"]
        if not c:
            continue
        for i, (g, _) in enumerate(c):
            if g < 0:
                continue
            if (i + 1) % w and c[i + 1][0] >= 0:
                hp.add((g, c[i + 1][0]))
            if i + w < len(c) and c[i + w][0] >= 0:
                vp.add((g, c[i + w][0]))
    return hp, vp


# --- Grillas: filas de celdas (metatile, colisión, x original, y original, es copia) ----------------------

def grid_of(lay):
    w = lay["w"]
    return [[(g, col, x, y, False) for x, (g, col) in enumerate(lay["cells"][y * w:(y + 1) * w])]
            for y in range(lay["h"])]


def transpose(grid):
    return [list(col) for col in zip(*grid)]


def fillers(grid, vp, hp, n=3, exclude=frozenset()):
    """Suelo de relleno del mapa: los metatiles transitables más comunes que empalman consigo mismos (salvo
    `exclude`: en los mapas nuevos, el agua, que si no corta muelles y puentes)."""
    count = {}
    for row in grid:
        for c in row:
            if c[0] >= 0 and not c[1] and c[0] not in exclude and (c[0], c[0]) in vp and (c[0], c[0]) in hp:
                count[c[0]] = count.get(c[0], 0) + 1
    return [g for g, _ in sorted(count.items(), key=lambda kv: -kv[1])[:n]]


def insert_seam(grid, vp, hp, target, fill_ids, keep_cells=frozenset(), no_seam=frozenset(), p=SEAM):
    """Inserta una costura horizontal de SEAM filas (agrega filas). Devuelve la grilla nueva o None si no hay
    ninguna válida. Programación dinámica columna por columna; el estado es (s, relleno): el bloque nuevo ocupa
    las filas [s, s+SEAM) y es una copia de las SEAM filas de arriba o suelo de relleno del mapa."""
    h, w = len(grid), len(grid[0])
    INF = float("inf")

    def new(x, st, y):  # celda y de la columna x con la costura del estado st
        s, fill = st
        if y < s:
            return grid[y][x]
        if y < s + p:
            return fill[y - s]
        return grid[y - p][x]

    states = []
    for x in range(w):
        v = []
        for s in range(1, h):
            above, below = grid[s - 1][x], grid[s][x]
            if (above[2], above[3]) in no_seam or (below[2], below[3]) in no_seam:
                continue  # ni copia ni relleno pegado a un paso que tapa un objeto
            opts = []
            if s >= p:
                opts.append((tuple(grid[s - p + i][x][:4] + (True,) for i in range(p)), 0.0))
            for g in fill_ids:
                opts.append((tuple((g, 0, -1, -1, True) for _ in range(p)), 0.35))
            for fill, extra in opts:
                if extra == 0 and any(c[0] in NO_COPY or (c[2], c[3]) in keep_cells for c in fill):
                    continue
                seq = [above] + list(fill) + [below]
                if any(c[0] < 0 for c in seq) or any((seq[i][0], seq[i + 1][0]) not in vp for i in range(len(seq) - 1)):
                    continue
                # repetir lo que ya es copia cuesta más (así se reparte y no queda una franja repetida)
                again = 0.25 * sum(1 for i in range(s - p, s) if grid[i][x][4]) if extra == 0 else 0.0
                v.append(((s, fill), 0.04 * abs(s - target) + extra + again))
        states.append(v)
    cost = [dict() for _ in range(w)]
    back = [dict() for _ in range(w)]
    for st, c in states[0]:
        cost[0][st] = c
    for x in range(1, w):
        prev = {}
        for st, c in cost[x - 1].items():
            prev.setdefault(st[0], []).append((st, c))
        for st2, c2 in states[x]:
            s2 = st2[0]
            best, arg = INF, None
            for s1 in range(s2 - STEP, s2 + STEP + 1):
                for st1, c1 in prev.get(s1, ()):
                    total = c1 + 0.3 * abs(s2 - s1) + (0.05 if st1[1] != st2[1] else 0.0)
                    if total >= best:
                        continue
                    if all((new(x - 1, st1, y)[0], new(x, st2, y)[0]) in hp
                           for y in range(min(s1, s2), max(s1, s2) + p)):
                        best, arg = total, st1
            if arg is not None:
                cost[x][st2] = best + c2
                back[x][st2] = arg
    if not cost[w - 1]:
        return None
    st = min(cost[w - 1], key=cost[w - 1].get)
    seam = [None] * w
    for x in range(w - 1, -1, -1):
        seam[x] = st
        if x:
            st = back[x][st]
    return [[new(x, seam[x], y) for x in range(w)] for y in range(h + p)]


def stretch(grid, vp, hp, scale, label="", keep_cells=frozenset(), no_seam=frozenset(), goals=None,
            fill_exclude=frozenset()):
    """Agranda la grilla en los dos ejes con costuras hasta `scale` (o hasta donde se pueda). `goals`: {eje: medida
    exacta} (0 = ancho, 1 = alto) para los mapas que cierran un círculo; ahí la última costura puede ser de 1."""
    fill_ids = fillers(grid, vp, hp, exclude=fill_exclude)
    for axis in (1, 0):  # 1 = filas (alto), 0 = columnas (ancho)
        g = grid if axis == 1 else transpose(grid)
        v, hh = (vp, hp) if axis == 1 else (hp, vp)
        exact = goals is not None and axis in goals
        goal = goals[axis] if exact else round(len(g) * scale)
        k = 0
        while len(g) + SEAM <= goal or (exact and len(g) < goal):
            target = ((k * 0.618034) % 1.0) * len(g)
            k += 1
            n = insert_seam(g, v, hh, target, fill_ids, keep_cells, no_seam, SEAM if len(g) + SEAM <= goal else 1)
            if n is None:
                print("  %s: sin más costuras en %s (%d de %d)" % (label, "alto" if axis else "ancho", len(g), goal))
                break
            g = n
        grid = g if axis == 1 else transpose(g)
    return grid


def find_cell(grid, ox, oy):
    """Celda nueva (x, y) del original (ox, oy) (la que no es copia)."""
    for y, row in enumerate(grid):
        for x, c in enumerate(row):
            if c[2] == ox and c[3] == oy and not c[4]:
                return x, y
    return None


def opening(lay_a, lay_b, side, offset, prefer_middle=False):
    """Celda del borde de A (original) en el medio del camino que lo une con B, y su par en B.
    Si hay varios caminos en el borde: el más largo (el primero), o con `prefer_middle` el más cercano al centro del
    borde (cuando los dos mapas no crecen igual solo uno queda alineado: mejor el del medio, que suele ser el camino
    principal). Las uniones del capítulo 1 usan la regla vieja para no moverse."""
    vertical = side in ("up", "down")
    if vertical:
        ya, yb = (0, lay_b["h"] - 1) if side == "up" else (lay_a["h"] - 1, 0)
        n, nb = lay_a["w"], lay_b["w"]
    else:
        xa, xb = (0, lay_b["w"] - 1) if side == "left" else (lay_a["w"] - 1, 0)
        n, nb = lay_a["h"], lay_b["h"]
    runs, run = [], []
    for i in range(n):
        j = i - offset
        if vertical:
            ok = 0 <= j < nb and not lay_a["cells"][ya * lay_a["w"] + i][1] and not lay_b["cells"][yb * lay_b["w"] + j][1]
        else:
            ok = 0 <= j < nb and not lay_a["cells"][i * lay_a["w"] + xa][1] and not lay_b["cells"][j * lay_b["w"] + xb][1]
        if ok:
            run.append(i)
        elif run:
            runs.append(run)
            run = []
    if run:
        runs.append(run)
    if not runs:
        return None
    if prefer_middle:
        best = min(runs, key=lambda r: abs((r[0] + r[-1]) / 2 - (n - 1) / 2))
    else:
        best = max(runs, key=len)  # (max devuelve el primero de los más largos, como antes)
    i = best[len(best) // 2]
    if vertical:
        return (i, ya), (i - offset, yb)
    return (xa, i), (xb, i - offset)


def blocked_passage(lay, ox, oy):
    """Celda de un objeto que tapa un paso (árbol cortable, roca) y las celdas libres en línea con ella (su fila y su
    columna, hasta la primera pared): si las costuras no las copian, el paso no se ensancha y el objeto lo sigue
    tapando."""
    w, h = lay["w"], lay["h"]
    out = {(ox, oy)}
    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        x, y = ox + dx, oy + dy
        while 0 <= x < w and 0 <= y < h and not lay["cells"][y * w + x][1]:
            out.add((x, y))
            x, y = x + dx, y + dy
    return out


def place_second(maps, by_const, lay_of, grids, pos, box):
    """Ubica los mapas de PLACE_ORDER, cada uno pegado al borde (con relleno) de su padre y alineando el camino."""
    for b, a in PLACE_ORDER:
        c = next((c for c in maps[a].get("connections") or [] if by_const.get(c["map"]) == b), None)
        if c is None:
            print("  OJO: %s no conecta con %s" % (b, a))
            continue
        side, off = c["direction"], int(c["offset"])
        op = opening(lay_of[a], lay_of[b], side, off, prefer_middle=True)
        ga, gb = grids[a], grids[b]
        ax, ay = pos[a]
        na, nb = (find_cell(ga, *op[0]), find_cell(gb, *op[1])) if op else ((0, 0), (0, 0))
        x0, y0, x1, y1 = box(a)
        if side in ("up", "down"):
            pos[b] = (ax + na[0] - nb[0], y0 - len(gb) if side == "up" else y1)
        else:
            pos[b] = (x0 - len(gb[0]) if side == "left" else x1, ay + na[1] - nb[1])


def pad(cells, rect, inner, name, lay, hp, vp):
    """Rellena lo vacío del rectángulo continuando los bordes del mapa (`inner`) con período 2: los árboles del
    borde siguen enteros y un camino que llega al borde sigue hasta la zona vecina. Donde el borde no se puede
    continuar (un edificio cortado por el borde) va el bloque de borde del mapa (árboles)."""
    x0, y0, x1, y1 = rect
    ix0, iy0, ix1, iy1 = inner

    def src(v, lo, hi):
        if v < lo:
            return lo + (v - lo) % 2
        if v >= hi:
            return hi - 2 + (v - hi + 2) % 2
        return v

    def g(x, y):
        return cells[(x, y)][0]

    def extends(x, y):  # ¿se puede continuar el borde hasta (x, y)?
        sx, sy = src(x, ix0, ix1), src(y, iy0, iy1)
        cx, cy = min(max(x, ix0), ix1 - 1), min(max(y, iy0), iy1 - 1)
        ok = True
        if x < ix0:
            ok = ok and (g(ix0 + 1, cy), g(ix0, cy)) in hp
        elif x >= ix1:
            ok = ok and (g(ix1 - 1, cy), g(ix1 - 2, cy)) in hp
        if y < iy0:
            ok = ok and (g(cx, iy0 + 1), g(cx, iy0)) in vp
        elif y >= iy1:
            ok = ok and (g(cx, iy1 - 1), g(cx, iy1 - 2)) in vp
        return ok and g(sx, sy) >= 0 and g(sx, sy) not in NO_COPY
    b, bw = lay["border"], lay["bw"]
    bh = len(b) // bw
    todo = [(x, y) for y in range(y0, y1) for x in range(x0, x1)
            if not ((x, y) in cells and cells[(x, y)][5] == name)]
    fallback = [(x, y) for (x, y) in todo if not extends(x, y)]
    for (x, y) in todo:
        if (x, y) not in fallback:
            c = cells[(src(x, ix0, ix1), src(y, iy0, iy1))]
            cells[(x, y)] = (c[0], c[1], -1, -1, True, name)
    best, best_score = (0, 0), -1
    for px in range(bw):
        for py in range(bh):
            score = 0
            for (x, y) in fallback:
                v = b[((y + py) % bh) * bw + (x + px) % bw][0]
                for dx, dy, pairs, first in ((1, 0, hp, True), (-1, 0, hp, False), (0, 1, vp, True), (0, -1, vp, False)):
                    n = cells.get((x + dx, y + dy))
                    if n is not None and n[0] >= 0 and n[5] == name:
                        score += ((v, n[0]) if first else (n[0], v)) in pairs
            if score > best_score:
                best, best_score = (px, py), score
    px, py = best
    for (x, y) in fallback:
        v, col = b[((y + py) % bh) * bw + (x + px) % bw]
        cells[(x, y)] = (v, col, -1, -1, True, name)


def main():
    root = sys.argv[1]
    stats = "--stats" in sys.argv
    pret = os.path.join(root, "art_src", "pret")
    sets = Sets(root)
    layouts = read_layouts(root, sets)
    hp, vp = pairs_of(layouts)
    catalog = json.load(open(os.path.join(root, "art", "pret", "tiles", "catalog.json"), encoding="utf8"))
    NO_COPY.update(int(k) for k, v in catalog["categories"].items() if v in KEEP)
    WATER.update(int(k) for k, v in catalog["physics"].items() if v == 1)
    maps = {}
    for name in list(EXTERIORS) + list(STRETCHED) + list(INTERIORS) + list(CAVES) + list(INTERIORS_2) + list(INTERIORS_3) \
            + list(EXTERIORS_4) + list(STRETCHED_4) + list(CAVES_4) + list(WILD_INTERIORS_4) + list(INTERIORS_4):
        maps[name] = json.load(open(os.path.join(pret, "data", "maps", name, "map.json"), encoding="utf8"))
    by_const = {const_of(n): n for n in maps}
    by_const.update(CONNECTION_ALIASES)
    lay_of = {n: layouts[maps[n]["layout"]] for n in maps}

    # --- Exteriores: cada uno agrandado y ubicado según sus conexiones, alineando los caminos ---
    grids = {}
    for n in list(EXTERIORS) + list(STRETCHED) + list(CAVES) + list(EXTERIORS_4) + list(STRETCHED_4) + list(CAVES_4):
        # En los mapas nuevos tampoco se copian las celdas de puerta/escalera (en el capítulo 1 sí se copiaron:
        # se deja así para que esas zonas no cambien).
        keep = frozenset() if n in FIRST_EXTERIORS or n in STRETCHED else             frozenset((w["x"], w["y"]) for w in maps[n].get("warp_events", []))
        no_seam = frozenset() if n in FIRST_EXTERIORS or n in STRETCHED or n in CHAPTER2_MAPS else             frozenset(c for o in maps[n].get("object_events", []) if o.get("graphics_id") in OBJECTS
                      for c in blocked_passage(lay_of[n], o["x"], o["y"]))
        # (ni la celda de un árbol cortable o una roca: si no, el pasillo que tapa queda más ancho y se lo esquiva;
        # desde el capítulo 3, para que lo ya importado no cambie)
        newer = n in EXTERIORS_4 or n in STRETCHED_4 or n in CAVES_4
        grids[n] = stretch(grid_of(lay_of[n]), vp, hp, SCALE, n, keep, no_seam, None, WATER if newer else frozenset())
    pos = {"PalletTown": (0, 0)}
    todo = ["PalletTown"]
    while todo:
        a = todo.pop()
        for c in maps[a].get("connections") or []:
            b = by_const.get(c["map"])
            if b not in EXTERIORS or b in pos:
                continue
            side, off = c["direction"], int(c["offset"])
            op = opening(lay_of[a], lay_of[b], side, off, prefer_middle=b not in FIRST_EXTERIORS)
            ga, gb = grids[a], grids[b]
            ax, ay = pos[a]
            if op is None:
                na, nb = (0, 0), (0, 0)
            else:
                na, nb = find_cell(ga, *op[0]), find_cell(gb, *op[1])
            if side in ("up", "down"):
                by = ay - len(gb) if side == "up" else ay + len(ga)
                pos[b] = (ax + na[0] - nb[0], by)
            else:
                bx = ax - len(gb[0]) if side == "left" else ax + len(ga[0])
                pos[b] = (bx, ay + na[1] - nb[1])
            todo.append(b)
    # Columna principal: todos con el mismo ancho; la Ruta 22 termina donde empieza la columna.
    mx0 = min(pos[n][0] for n in MAIN_COLUMN)
    mx1 = max(pos[n][0] + len(grids[n][0]) for n in MAIN_COLUMN)
    for root_map, (side, members) in BRANCHES.items():
        if side == "left":
            dx = mx0 - (pos[root_map][0] + len(grids[root_map][0]))
        else:
            dx = mx1 - pos[root_map][0]
        for n in members:
            pos[n] = (pos[n][0] + dx, pos[n][1])
    # Segunda pasada: el resto de Kanto, cada uno pegado a su "padre" ya ubicado (a su borde con relleno).
    r22 = (pos["Route22"][0], min(pos["Route22"][1], pos["ViridianCity"][1]), mx0,
           max(pos["Route22"][1] + len(grids["Route22"]), pos["ViridianCity"][1] + len(grids["ViridianCity"])))

    def box(n):
        x, y = pos[n]
        g = grids[n]
        if n in MAIN_COLUMN:
            return (mx0, y, mx1, y + len(g))
        if n == "Route22":
            return r22
        return (x, y, x + len(g[0]), y + len(g))
    for fit_pass in range(2):
        place_second(maps, by_const, lay_of, grids, pos, box)
        if fit_pass == 1:
            break
        # Los que cierran un círculo: medida exacta y otra vez.
        for n, spec in FIT.items():
            axis, a, b = spec[0], spec[1], spec[2]
            ba, bb = box(a), box(b)
            if axis == "x":
                size = (bb[0] - ba[2]) if ba[2] <= bb[0] else (ba[0] - bb[2])
            else:
                size = (bb[1] - ba[3]) if ba[3] <= bb[1] else (ba[1] - bb[3])
            parts = [n] + list(spec[3:])
            for i, m in enumerate(parts):
                share = size // len(parts) + (1 if i < size % len(parts) else 0)
                g = grids[m]
                goals = {0: share} if axis == "x" else {1: share}
                print("  %s: %s exacto %d (antes %d)" % (m, "ancho" if axis == "x" else "alto", share,
                                                         len(g[0]) if axis == "x" else len(g)))
                keep = frozenset((w["x"], w["y"]) for w in maps[m].get("warp_events", []))
                no_seam = frozenset(c for o in maps[m].get("object_events", []) if o.get("graphics_id") in OBJECTS
                                    for c in blocked_passage(lay_of[m], o["x"], o["y"]))
                grids[m] = stretch(grid_of(lay_of[m]), vp, hp, SCALE, m, keep, no_seam, goals, WATER)
    cells, rects, inner = {}, {}, {}
    for n in list(EXTERIORS) + list(EXTERIORS_4):
        x0, y0 = pos[n]
        g = grids[n]
        for y, row in enumerate(g):
            for x, c in enumerate(row):
                cells[(x0 + x, y0 + y)] = c + (n,)
        rects[n] = [x0, y0, x0 + len(g[0]), y0 + len(g)]
        inner[n] = list(rects[n])
    for n in MAIN_COLUMN:
        rects[n] = [mx0, rects[n][1], mx1, rects[n][3]]
    r22, v = rects["Route22"], rects["ViridianCity"]
    rects["Route22"] = [r22[0], min(r22[1], v[1]), mx0, max(r22[3], v[3])]
    for n in EXTERIORS:
        pad(cells, rects[n], inner[n], n, lay_of[n], hp, vp)
    # Encimados de los mapas nuevos con otra zona: se recorta el nuevo por el lado que menos pierde (si la franja
    # recortada tiene algo transitable, avisa).
    order = [m for m, _ in PLACE_ORDER]
    for b in order:
        for a in list(rects):
            if a == b or (a in order and order.index(a) > order.index(b)):
                continue  # se recorta siempre el que se ubicó después
            ra, rb = rects[a], rects[b]
            if not (ra[0] < rb[2] and rb[0] < ra[2] and ra[1] < rb[3] and rb[1] < ra[3]):
                continue
            cuts = {"izq": [ra[2], rb[1], rb[2], rb[3]], "der": [rb[0], rb[1], ra[0], rb[3]],
                    "arriba": [rb[0], ra[3], rb[2], rb[3]], "abajo": [rb[0], rb[1], rb[2], ra[1]]}
            # nunca del lado por donde se conecta con otro mapa (se cortaría el camino)
            joined = {{"left": "izq", "right": "der", "up": "arriba", "down": "abajo"}[c["direction"]]
                      for c in maps[b].get("connections") or [] if by_const.get(c["map"]) in rects}
            best = None
            for side, nr in cuts.items():
                if nr[2] <= nr[0] or nr[3] <= nr[1] or side in joined:
                    continue
                lost = [(x, y) for (x, y), c in cells.items()
                        if c[5] == b and not (nr[0] <= x < nr[2] and nr[1] <= y < nr[3])]
                walk = sum(1 for k in lost if not cells[k][1] and cells[k][0] >= 0
                           and catalog["physics"].get(str(cells[k][0])) != 1)  # (el agua no cuenta: sin Surf no se camina)
                if best is None or (walk, len(lost)) < (best[1], len(best[2])):
                    best = (side, walk, lost, nr)
            if best is None:
                print("  OJO: %s se encima con %s y no se puede recortar" % (b, a))
                continue
            side, walk, lost, nr = best
            print("  %s se encimaba con %s: se recortan %d celdas por %s (%d transitables)" % (b, a, len(lost), side, walk))
            for k in lost:
                del cells[k]
            rects[b] = nr
    # Zonas encimadas (no debería pasar: avisa para revisar la ubicación).
    names = list(rects)
    for i, a in enumerate(names):
        for b in names[i + 1:]:
            ra, rb = rects[a], rects[b]
            if ra[0] < rb[2] and rb[0] < ra[2] and ra[1] < rb[3] and rb[1] < ra[3]:
                print("  OJO: %s y %s se enciman" % (a, b))
    # Corrimiento: que el mundo del capítulo 1 empiece en (0, 0) (lo nuevo puede quedar en coordenadas negativas).
    sx = min(rects[n][0] for n in FIRST_EXTERIORS)
    sy = min(rects[n][1] for n in FIRST_EXTERIORS)
    zones = []
    ext_all = dict(EXTERIORS, **EXTERIORS_4)
    for n in ext_all:
        if n in PHANTOMS:
            continue
        x0, y0, x1, y1 = rects[n]
        zones.append(_zone(n, ext_all[n], [x0 - sx, y0 - sy, x1 - sx, y1 - sy],
                           {(x - sx, y - sy): c for (x, y), c in cells.items() if c[5] == n}, "exterior"))
    local = {}  # mapa -> grilla agrandada (para ubicar puertas): celda local = posición en la grilla + corrimiento
    for z in zones:
        n = z["map"]
        x0, y0 = pos[n]
        local[n] = (grids[n], x0 - sx - z["origin"][0], y0 - sy - z["origin"][1])
    # Interiores, cuevas y bosques van debajo de TODO el mundo (desde el resto de Kanto el mar llega más al sur que
    # Paleta: antes empezaban justo debajo de Paleta y se pisarían). Se movieron: el .gd actualiza sus orígenes.
    bottom = max(z["origin"][1] + z["size"][1] for z in zones)

    # --- Bosque Verde (agrandado) e interiores (1:1), en filas debajo del mundo ---
    ix, iy, row_h = 0, bottom + INTERIOR_GAP, 0
    offworld = list(STRETCHED.items()) + list(INTERIORS.items()) + list(CAVES.items()) + list(INTERIORS_2.items()) \
        + list(INTERIORS_3.items()) + list(STRETCHED_4.items()) + list(CAVES_4.items()) + list(WILD_INTERIORS_4.items()) \
        + list(INTERIORS_4.items())
    for n, info in offworld:
        g = grids[n] if n in grids else grid_of(lay_of[n])
        w, h = len(g[0]), len(g)
        if ix and ix + w > INTERIOR_ROW:
            ix, iy, row_h = 0, iy + row_h + INTERIOR_GAP, 0
        c = {(ix + x, iy + y): cell + (n,) for y, row in enumerate(g) for x, cell in enumerate(row)}
        kind = "exterior" if n in STRETCHED or n in STRETCHED_4 else \
            ("cave" if n in CAVES or n in CAVES_4 or n in WILD_INTERIORS_4 else "interior")
        zones.append(_zone(n, info, [ix, iy, ix + w, iy + h], c, kind))
        local[n] = (g, 0, 0)
        ix += w + INTERIOR_GAP
        row_h = max(row_h, h)

    # --- Puertas ---
    by_map = {z["map"]: z for z in zones}

    def new_cell(n, ox, oy):
        g, dx, dy = local[n]
        c = find_cell(g, ox, oy)
        return [c[0] + dx, c[1] + dy]
    for z in zones:
        n = z["map"]
        g, dx, dy = local[n]
        warps = {}
        for w in maps[n].get("warp_events", []):
            dest = by_const.get(w["dest_map"])
            if dest is None or dest not in by_map:
                continue
            dw = maps[dest]["warp_events"][int(w["dest_warp_id"])]
            warps[(w["x"], w["y"])] = {"to": by_map[dest]["id"], "to_cell": new_cell(dest, dw["x"], dw["y"])}
        for y, row in enumerate(g):  # la celda de puerta y sus copias
            for x, c in enumerate(row):
                wp = warps.get((c[2], c[3]))
                if wp:
                    z["warps"].append(dict(wp, cell=[x + dx, y + dy]))
        new_map = n in EXTERIORS_4 or n in STRETCHED_4 or n in CAVES_4 or n in WILD_INTERIORS_4 or n in INTERIORS_4
        z["template"] = TEMPLATES.get(n, snake(n) if new_map else "")
        z["objects"] = []
        z["npcs"] = []  # personas de FireRed (la historia las usa: data/story/, docs/PLAN_HISTORIA.md)
        for i, o in enumerate(maps[n].get("object_events", [])):
            scene = OBJECTS.get(o.get("graphics_id"))
            c = find_cell(g, o["x"], o["y"])
            if c and scene:
                z["objects"].append({"cell": [c[0] + dx, c[1] + dy], "scene": scene})
            elif c:
                z["npcs"].append({"cell": [c[0] + dx, c[1] + dy], "gfx": o.get("graphics_id", ""), "index": i + 1,
                                  "script": o.get("script", ""), "movement": o.get("movement_type", ""),
                                  "flag": o.get("flag", "0")})
    sz = by_map[SPAWN[0]]
    sp = new_cell(SPAWN[0], SPAWN[1], SPAWN[2])
    out = {"_info": "Generado por tools/import_frlg_maps.py (no editar a mano).", "scale": SCALE,
           "spawn": [sz["origin"][0] + sp[0], sz["origin"][1] + sp[1]], "zones": zones}
    with open(os.path.join(root, "data", "world", "frlg_maps.json"), "w", encoding="utf8", newline="\n") as f:
        json.dump(out, f, ensure_ascii=False)
    if stats:
        for z in zones:
            print("%-26s origen %-12s tamaño %-10s puertas %d" % (z["id"], z["origin"], z["size"], len(z["warps"])))
    print("zonas:", len(zones), "puertas:", sum(len(z["warps"]) for z in zones))


def _zone(name, info, rect, cells, kind):
    x0, y0, x1, y1 = rect
    ids, col = [], []
    for y in range(y0, y1):
        for x in range(x0, x1):
            c = cells.get((x, y))
            ids.append(c[0] if c else -1)
            col.append(c[1] if c else 1)
    return {"id": info[0], "name": info[1], "map": name, "kind": kind, "origin": [x0, y0],
            "size": [x1 - x0, y1 - y0], "cells": ids, "col": col, "warps": []}


if __name__ == "__main__":
    main()
