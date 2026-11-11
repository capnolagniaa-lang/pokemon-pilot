"""Datos de las "Salas por piezas" del Modo Desafío (los lee tools/build_piece_rooms.py): por bioma, cómo se lee el
plano de sus marcos, sus ESCENAS (qué va con qué), sus SALAS (tema = lista de escenas, la primera es la protagonista) y
cómo se reparte el decorado suelto. Ver la sección 10 de docs/PROPUESTA_ROGUELIKE.md (10.9: de dónde sale cada escena).

Escena: {"anchor": "orilla" | "borde" | "arena", "members": [[pieza, dx, dy, azar px], ...]} (px desde el ancla; la
primera es la protagonista; en las de orilla +x = hacia el líquido, en las de borde +x = hacia el centro de la sala).
Decorado: (pieza, cantidad, regla) con regla "linea" (justo en la orilla), "liquido" (cerca del agua o la lava),
"pared" (pegado a la pared), "roca" (cerca de la pared, algo en el resto) o "suelto" (en cualquier lado, poco en el centro).
color: el `auto_color` del marco (el mismo que va en pinturas.json). lava: el líquido del marco es lava (no se pisa).
trail: el marco tiene un sendero al medio: no se pone nada sólido encima.
"""

BIOMES = {
    "costa": {
        "color": {"hue": [30, 65], "min_s": 0.2, "min_v": 120, "part": 0.6, "water": True, "foam": True},
        "deep": 5,
        "scenes": {
            "naufragio": {"anchor": "orilla", "members": [
                ["naufragio", 0, 0, 0], ["ancla", 78, 34, 6], ["mastil", -96, 30, 8], ["barril", 64, -34, 5], ["barril", 84, -22, 5],
                ["cajas", -84, -30, 6], ["tablas", 30, 52, 8], ["tablas", -46, 58, 8], ["madera", 108, 52, 8], ["barril", -116, 4, 6]]},
            "campamento": {"anchor": "orilla", "members": [
                ["bote", 0, 0, 0], ["remo", 14, 26, 4], ["red_pesca", -78, -34, 6], ["fogata", -50, 30, 5], ["canasta", -92, 16, 5],
                ["cajas", -124, -16, 6], ["madera", -30, 44, 5], ["tronco", -70, 62, 8]]},
            "palmeral": {"anchor": "borde", "members": [
                ["palmera", 0, 0, 5], ["palmera_inclinada", 44, 22, 8], ["palmera_baja", -38, 26, 8], ["palmera", 86, -4, 8],
                ["cocos", 16, 34, 6], ["cocos", -22, 44, 6], ["pasto_duna", 30, 8, 8], ["pasto_duna", -14, 14, 8],
                ["pasto_duna", 62, 30, 8], ["pasto_duna", -50, 6, 8]]},
            "poza_a": {"anchor": "arena", "members": [
                ["poza_a", 0, 0, 0], ["roca_percebes", -70, -8, 6], ["roca_chica", 58, -30, 6], ["coral", 44, 40, 6], ["estrella", -30, 40, 5],
                ["concha", 62, 12, 5], ["cangrejo", -52, 28, 6], ["piedritas", 20, -44, 6]]},
            "poza_b": {"anchor": "arena", "members": [
                ["poza_b", 0, 0, 0], ["roca_percebes", 74, -10, 6], ["roca_chica", -64, 26, 6], ["coral", -50, -34, 6], ["estrella", 40, 44, 5],
                ["concha", -20, 48, 5], ["cangrejo", 60, 34, 6], ["piedritas", -70, -6, 6]]},
            "laguna": {"anchor": "arena", "members": [
                ["laguna", 0, 0, 0], ["roca_chica", 76, 16, 6], ["coral", -66, 22, 6], ["roca_chica", -58, -34, 6], ["estrella", 30, 52, 5],
                ["concha", -30, 54, 5], ["piedritas", 64, -36, 6]]},
            "rocas": {"anchor": "borde", "members": [
                ["roca_grande", 0, 0, 0], ["roca_percebes", 54, 26, 6], ["roca_chica", -44, 22, 6], ["roca_chica", 22, 46, 6],
                ["piedritas", -20, 44, 6], ["piedritas", 80, 46, 6], ["algas", 40, 52, 6]]},
            "rocas_orilla": {"anchor": "orilla", "members": [
                ["roca_percebes", 0, 0, 0], ["roca_chica", 48, 20, 6], ["roca_chica", -40, 18, 6], ["coral", 30, -24, 6],
                ["piedritas", 10, 34, 6], ["algas", 60, 40, 6]]},
            "charco": {"anchor": "arena", "members": [
                ["charco", 0, 0, 0], ["roca_chica", 40, -14, 5], ["concha", -36, 20, 5], ["estrella", 26, 30, 5]]},
        },
        "rooms": {
            "sala_costa_p1": ("La caleta del pescador", "marco_costa_mar_der", 11, ["campamento", "palmeral", "palmeral", "rocas_orilla", "rocas", "charco"]),
            "sala_costa_p2": ("El naufragio", "marco_costa_mar_izq", 23, ["naufragio", "rocas_orilla", "palmeral", "rocas", "charco", "palmeral"]),
            "sala_costa_p3": ("Las pozas de marea", "marco_costa_ensenada", 37, ["poza_a", "poza_b", "laguna", "rocas_orilla", "palmeral", "rocas"]),
        },
        "decor": [("linea_marea", 7, "linea"), ("concha", 12, "liquido"), ("estrella", 6, "liquido"), ("algas", 7, "liquido"),
                  ("cangrejo", 4, "liquido"), ("pasto_duna", 14, "pared"), ("piedritas", 8, "roca"), ("madera", 4, "liquido")],
    },
    "volcan": {
        "color": {"hue": [20, 62], "min_s": 0.15, "max_s": 0.8, "min_v": 120, "part": 0.6, "water": False},
        "lava": True,
        "scenes": {
            "osario": {"anchor": "arena", "members": [
                ["esqueleto", 0, 0, 0], ["craneo", 96, 30, 6], ["huesos", -54, 40, 8], ["huesos", 30, 52, 8], ["huesos", 96, -18, 8],
                ["roca_chica", -86, -8, 6], ["ceniza", -30, -40, 8]]},
            "fumarolas": {"anchor": "borde", "members": [
                ["fumarola", 0, 0, 0], ["fumarola", 70, 30, 6], ["fumarola", -62, 34, 6], ["azufre", 12, 40, 6], ["azufre", 66, 52, 6],
                ["azufre", -30, 54, 6], ["ceniza", 96, 22, 8], ["roca_chica", 100, 48, 6]]},
            "quemados": {"anchor": "borde", "members": [
                ["arbol_quemado", 0, 0, 0], ["arbol_quemado", 50, 24, 8], ["tronco_carbon", -44, 36, 8], ["brasas", 22, 42, 6],
                ["brasas", -12, 54, 6], ["ceniza", 76, 46, 8], ["arbol_quemado", -80, 10, 8]]},
            "forja": {"anchor": "borde", "members": [
                ["horno", 0, 0, 0], ["yunque", 84, 44, 6], ["carbon", -76, 36, 6], ["carbon", -104, 52, 6], ["tronco_carbon", 30, 66, 8],
                ["brasas", 22, 34, 6], ["cristal_fuego", 110, 10, 8]]},
            "rocas_lava": {"anchor": "orilla", "members": [
                ["roca", 0, 0, 0], ["cristal_fuego", 50, 12, 6], ["roca_chica", -40, 24, 6], ["obsidiana", 20, -44, 6],
                ["brasas", 54, 38, 6], ["losa", 80, 30, 8], ["losa", 104, 14, 8]]},
            "desprendimiento": {"anchor": "borde", "members": [
                ["roca_grande", 0, 0, 0], ["roca", 60, 28, 6], ["roca_chica", -46, 28, 6], ["roca_chica", 26, 52, 6],
                ["ceniza", -22, 48, 8], ["obsidiana", 100, 12, 8]]},
        },
        "rooms": {
            "sala_volcan_p1": ("El osario", "marco_volcan_lava_der", 41, ["osario", "rocas_lava", "fumarolas", "quemados", "desprendimiento", "rocas_lava", "quemados"]),
            "sala_volcan_p2": ("La forja", "marco_volcan_lava_izq", 53, ["forja", "rocas_lava", "desprendimiento", "quemados", "fumarolas", "osario", "rocas_lava"]),
            "sala_volcan_p3": ("Las fumarolas", "marco_volcan_pozos", 67, ["fumarolas", "fumarolas", "osario", "rocas_lava", "quemados", "desprendimiento"]),
        },
        "decor": [("brasas", 8, "liquido"), ("azufre", 6, "liquido"), ("ceniza", 12, "pared"), ("huesos", 6, "suelto"), ("losa", 6, "roca")],
    },
    "bosque": {
        "color": {"hue": [25, 150], "min_s": 0.25, "min_v": 70, "part": 0.6, "water": True, "foam": True},
        "deep": 4, "trail": True,
        "scenes": {
            "campamento": {"anchor": "arena", "members": [
                ["fogata", 0, 0, 0], ["carpa", -96, -44, 6], ["asiento", 48, 28, 5], ["asiento", -50, 40, 5], ["lena", 90, -30, 6],
                ["tocon", 96, 22, 6], ["hongos", -100, 10, 8]]},
            "ruinas": {"anchor": "borde", "members": [
                ["arco_ruina", 0, 0, 0], ["columna_rota", 96, 24, 5], ["columna_rota", -92, 26, 5], ["estatua", 30, 70, 6],
                ["columna_rota", 130, 26, 5], ["helecho", -30, 50, 8], ["hongos", 100, 54, 8], ["helecho", 60, 48, 8]]},
            "arboleda": {"anchor": "borde", "members": [
                ["arbol", 0, 0, 5], ["arbol_b", 58, 26, 8], ["arbol", -54, 32, 8], ["arbusto", 22, 54, 6], ["helecho", -20, 60, 8],
                ["hongos", 64, 60, 8], ["helecho", 96, 42, 8], ["arbusto", -90, 54, 8]]},
            "estanque": {"anchor": "arena", "members": [
                ["estanque", 0, 0, 0], ["juncos", -66, -22, 6], ["juncos", 60, -32, 6], ["juncos", 44, 48, 6], ["roca_chica", -60, 32, 6],
                ["tronco_caido", 86, 34, 8], ["flores", -30, 60, 8]]},
            "santuario": {"anchor": "borde", "members": [
                ["altar", 0, 0, 0], ["farol_piedra", -62, 30, 4], ["farol_piedra", 62, 30, 4], ["flores", 0, 46, 5], ["estatua", -100, 12, 6],
                ["flores", -30, 54, 6], ["helecho", 86, 16, 8]]},
            "talado": {"anchor": "borde", "members": [
                ["tocon_hacha", 0, 0, 0], ["tocon", 48, 22, 6], ["tocon", -44, 26, 6], ["lena", 76, -8, 6], ["tronco_caido", 12, 54, 8],
                ["hongos", -70, 44, 8]]},
            "rocas": {"anchor": "borde", "members": [
                ["roca_grande", 0, 0, 0], ["roca_chica", 50, 24, 6], ["roca_chica", -40, 28, 6], ["helecho", 20, 46, 8], ["hongos", -64, 40, 8],
                ["arbusto", 86, 30, 8]]},
            "rocas_arroyo": {"anchor": "orilla", "members": [
                ["roca_grande", 0, 0, 0], ["juncos", 44, 10, 6], ["roca_chica", -40, 26, 6], ["juncos", 30, 44, 6], ["tronco_caido", -30, -40, 8],
                ["flores", -70, 20, 8]]},
        },
        "rooms": {
            "sala_bosque_p1": ("El campamento", "marco_bosque_claro", 71, ["campamento", "arboleda", "arboleda", "talado", "rocas", "estanque"]),
            "sala_bosque_p2": ("Las ruinas", "marco_bosque_arroyo_der", 83, ["ruinas", "rocas_arroyo", "arboleda", "estanque", "rocas", "arboleda"]),
            "sala_bosque_p3": ("El santuario", "marco_bosque_arroyo_izq", 97, ["santuario", "rocas_arroyo", "arboleda", "talado", "arboleda", "rocas"]),
        },
        "decor": [("flores", 14, "suelto"), ("helecho", 12, "pared"), ("hongos", 8, "pared"), ("juncos", 6, "linea"), ("arbusto", 5, "pared")],
    },
    "cueva": {
        "color": {"hue": [15, 50], "min_s": 0.25, "min_v": 80, "part": 0.6, "water": True, "foam": True},
        "deep": 4,
        "scenes": {
            "mina": {"anchor": "arena", "members": [
                ["vagoneta", 84, -4, 0], ["via", -72, 0, 0], ["via", -40, 0, 0], ["via", -8, 0, 0], ["via", 24, 0, 0], ["via", 56, 0, 0],
                ["via", 88, 0, 0], ["tope", 128, -2, 0], ["mineral", 60, 44, 6], ["farol", -84, -34, 6], ["cajas", -116, 22, 6]]},
            "apuntalado": {"anchor": "borde", "members": [
                ["viga", 0, 0, 0], ["cajas", 66, 32, 6], ["herramientas", -54, 32, 6], ["farol", 96, 12, 6], ["mineral", -96, 26, 6],
                ["piedritas", 30, 50, 8]]},
            "veta": {"anchor": "borde", "members": [
                ["cristal_grande", 0, 0, 0], ["cristal_chico", 50, 24, 6], ["cristal_violeta", -60, 18, 6], ["cristal_chico", -22, 44, 6],
                ["esquirlas", 30, 46, 8], ["esquirlas", -70, 48, 8], ["esquirlas", 84, 40, 8]]},
            "estalagmitas": {"anchor": "borde", "members": [
                ["estalagmitas", 0, 0, 0], ["estalagmita", 54, 28, 6], ["estalagmita", -46, 24, 6], ["roca_chica", 22, 48, 6],
                ["piedritas", -30, 46, 8], ["piedritas", 80, 48, 8]]},
            "excavacion": {"anchor": "arena", "members": [
                ["fosil", 0, 0, 0], ["andamio", -112, -22, 6], ["herramientas", 90, 36, 6], ["cajas", 124, -12, 6], ["farol", -44, 48, 6],
                ["piedritas", 30, 50, 8]]},
            "hongos_agua": {"anchor": "orilla", "members": [
                ["roca_grande", 0, 0, 0], ["hongos", 44, 20, 6], ["hongos", -30, 40, 6], ["cristal_chico", 20, -40, 6], ["roca_chica", -44, 20, 6],
                ["hongos", 60, 44, 6], ["hongos", 10, 54, 6]]},
        },
        "rooms": {
            "sala_cueva_p1": ("La mina vieja", "marco_cueva_galeria", 101, ["mina", "apuntalado", "veta", "estalagmitas", "estalagmitas", "veta", "apuntalado"]),
            "sala_cueva_p2": ("La excavación", "marco_cueva_lago_izq", 113, ["excavacion", "hongos_agua", "veta", "estalagmitas", "apuntalado", "estalagmitas", "veta"]),
            "sala_cueva_p3": ("La veta de cristal", "marco_cueva_lago_der", 127, ["veta", "veta", "hongos_agua", "estalagmitas", "mina", "apuntalado", "estalagmitas"]),
        },
        "decor": [("piedritas", 14, "roca"), ("hongos", 8, "liquido"), ("esquirlas", 8, "pared"), ("hongos", 5, "pared")],
    },
    "hielo": {
        "color": {"any_hue": True, "min_s": 0.0, "min_v": 200, "part": 0.6, "water": True},
        "deep": 6,
        "scenes": {
            "cabana": {"anchor": "borde", "members": [
                ["cabana", 0, 0, 0], ["lena", 112, 36, 6], ["pozo", -124, 36, 6], ["trineo", 50, 74, 8], ["tocon", 150, 60, 6],
                ["nieve", -50, 60, 8], ["nieve", 130, 20, 8]]},
            "pinar": {"anchor": "borde", "members": [
                ["pino", 0, 0, 5], ["pino", 54, 26, 8], ["pino_chico", -44, 30, 8], ["pino_chico", 90, 44, 8], ["nieve", 20, 48, 8],
                ["nieve", -70, 50, 8], ["tocon", -90, 20, 8]]},
            "cristales": {"anchor": "orilla", "members": [
                ["cristal_grande", 0, 0, 0], ["cristal_chico", 48, 24, 6], ["cristal_chico", -40, 26, 6], ["roca_chica", 12, -34, 6],
                ["nieve", -70, 10, 8]]},
            "pesca": {"anchor": "orilla", "members": [
                ["pesca", 0, 0, 0], ["agujero", 44, 8, 4], ["tronco", -54, 26, 6], ["brasero", -34, -32, 6], ["lena", -90, 4, 6]]},
            "ruinas": {"anchor": "arena", "members": [
                ["estatua", 0, 0, 0], ["columna", -84, 18, 4], ["columna", 84, 18, 4], ["columna", -140, 44, 4], ["columna", 140, 44, 4],
                ["brasero", -44, 56, 4], ["brasero", 44, 56, 4]]},
            "ventisquero": {"anchor": "borde", "members": [
                ["roca_grande", 0, 0, 0], ["roca_chica", 54, 26, 6], ["roca_chica", -44, 26, 6], ["nieve", 20, 50, 8], ["nieve", 90, 44, 8],
                ["cristal_chico", -80, 44, 8]]},
        },
        "rooms": {
            "sala_hielo_p1": ("La cabaña", "marco_hielo_claro", 131, ["cabana", "pinar", "pinar", "ventisquero", "ruinas", "ventisquero", "pinar"]),
            "sala_hielo_p2": ("El lago helado", "marco_hielo_lago_der", 149, ["pesca", "cristales", "cristales", "pinar", "ventisquero", "pinar"]),
            "sala_hielo_p3": ("Las ruinas heladas", "marco_hielo_lago_izq", 157, ["ruinas", "cristales", "pinar", "ventisquero", "pesca", "pinar", "cristales"]),
        },
        "decor": [("nieve", 22, "pared"), ("nieve", 10, "suelto"), ("tocon", 3, "roca"), ("cristal_chico", 4, "linea")],
    },
    "cementerio": {
        "color": {"any_hue": True, "min_s": 0.0, "min_v": 110, "part": 0.6, "water": False},
        "trail": True,
        "scenes": {
            "hilera": {"anchor": "arena", "members": [
                ["lapida", -20, 0, 2], ["lapida_cruz", 20, 0, 2], ["lapida", -60, 0, 2], ["lapida_rota", 60, 0, 2], ["lapida_cruz", 100, 0, 2],
                ["flores", -60, 18, 3], ["flores", 20, 18, 3], ["velas", -20, 20, 3], ["hojas", 70, 22, 6]]},
            "parcela": {"anchor": "borde", "members": [
                ["lapida", -26, 0, 2], ["lapida_cruz", 26, 0, 2], ["reja", -50, -26, 0], ["reja", 0, -26, 0], ["reja", 50, -26, 0],
                ["farol", 92, -8, 4], ["flores", -26, 18, 3], ["velas", 26, 20, 3]]},
            "mausoleo": {"anchor": "borde", "members": [
                ["mausoleo", 0, 0, 0], ["angel", -80, 34, 4], ["angel", 80, 34, 4], ["velas", -20, 50, 4], ["velas", 20, 50, 4],
                ["farol", -120, 10, 6]]},
            "arbol_viejo": {"anchor": "arena", "members": [
                ["arbol_viejo", 0, 0, 0], ["calabaza", -56, 30, 6], ["calabaza", 46, 38, 6], ["hojas", -30, 46, 8], ["hojas", 20, 54, 8],
                ["lapida_rota", 90, 12, 6], ["hojas", 76, 44, 8]]},
            "capilla": {"anchor": "arena", "members": [
                ["altar", 0, -40, 0], ["banco", -44, 4, 2], ["banco", 44, 4, 2], ["banco", -44, 40, 2], ["banco", 44, 40, 2],
                ["campana", 104, -30, 6], ["velas", -40, -40, 4], ["velas", 40, -40, 4]]},
            "fosa": {"anchor": "borde", "members": [
                ["fosa", 0, 0, 0], ["ataud", 70, 12, 6], ["lapida", -56, -10, 4], ["hojas", 20, 40, 8], ["velas", -50, 14, 4]]},
            "secos": {"anchor": "borde", "members": [
                ["arbol_seco", 0, 0, 5], ["arbol_seco", 54, 26, 8], ["lapida_rota", -44, 28, 6], ["calabaza", 22, 48, 6],
                ["hojas", -20, 50, 8], ["hojas", 80, 50, 8]]},
        },
        "rooms": {
            "sala_cementerio_p1": ("Las hileras", "marco_cementerio_sendero", 163, ["hilera", "hilera", "hilera", "parcela", "secos", "fosa"]),
            "sala_cementerio_p2": ("El árbol viejo", "marco_cementerio_cantero", 179, ["arbol_viejo", "hilera", "mausoleo", "parcela", "secos", "hilera"]),
            "sala_cementerio_p3": ("La capilla", "marco_cementerio_prado", 191, ["capilla", "mausoleo", "hilera", "fosa", "secos", "hilera"]),
        },
        "decor": [("hojas", 16, "suelto"), ("flores", 6, "suelto"), ("velas", 5, "roca"), ("calabaza", 4, "pared")],
    },
}
