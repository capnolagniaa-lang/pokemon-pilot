class_name ShopData
extends Resource
## Una Tienda Pokémon (el mercado): qué vende. La abre el vendedor con la acción `tienda_<id>` (NpcTalk.action);
## la maneja `Mart` (scripts/world/mart.gd). Precios: ItemData.price (se vende a la mitad).

@export var id: String = ""
@export var display_name: String = ""
## Quién atiende (nombre en el diálogo).
@export var clerk: String = "Vendedor"
## Lo que vende, en orden (la lista oficial de FireRed de esa ciudad, con los objetos que hay en el juego).
@export var items: Array[ItemData] = []
