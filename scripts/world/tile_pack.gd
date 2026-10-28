class_name TilePack
extends RefCounted
## Paquete de tiles hechos con IA (docs/COMFYUI.md, tools/tile_pack.py): con el ajuste "tile_pack" prendido,
## reemplaza EN MEMORIA el dibujo del árbol y del pasto alto en el atlas general del TileSet. Los mapas, la colisión y
## los tags no cambian (son los mismos metatiles) y los PNG originales tampoco: apagarlo vuelve a FireRed al instante.
## Árbol de FireRed = 2×3 metatiles (medido en los mapas): copa 14/15 (en la capa de arriba, para pasar por detrás),
## cuerpo 30/31 y base 36/37 (bordes: 38/39). En los bosques se encadenan: 20/21 (bordes 22/23) = la base del de arriba
## con la copa del de abajo, y 28/29 = el cuerpo. El árbol nuevo (arbol.png) mide 32×48: fila 0 copa, 1 cuerpo, 2 base.

const PACK_DIR := "res://art/tile_packs/hgss/"
const GENERAL_BELOW := "res://art/pret/tiles/general_below.png"
const GENERAL_ABOVE := "res://art/pret/tiles/general_above.png"
const GRASS := 1
const TALL_GRASS := 13
## metatile → [columna (0 izq, 1 der), fila del árbol en la capa de abajo (sobre pasto), fila en la capa de arriba];
## -1 = nada.
const TREE_CELLS := {
	14: [0, -1, 0], 15: [1, -1, 0],                                    # copa
	30: [0, 1, -1], 31: [1, 1, -1], 28: [0, 1, -1], 29: [1, 1, -1],     # cuerpo
	36: [0, 2, -1], 37: [1, 2, -1], 38: [0, 2, -1], 39: [1, 2, -1],     # base (último árbol de la fila)
	20: [0, 2, 0], 21: [1, 2, 0], 22: [0, 2, 0], 23: [1, 2, 0],         # bosque: base del de arriba + copa del de abajo
}

## id de la fuente del TileSet → su textura original (para volver).
static var _originals := {}
static var _on := false


static func apply(on: bool) -> void:
	var ts: TileSet = load(ZoneBuilder.TILESET_PATH)
	var below := _source(ts, GENERAL_BELOW)
	var above := _source(ts, GENERAL_ABOVE)
	if below == null or above == null:
		return
	if on == _on and (not on or _originals.has(below)):
		return
	if not on:
		_restore(ts, below)
		_restore(ts, above)
		_on = false
		return
	var tree: Texture2D = load(PACK_DIR + "arbol.png") if ResourceLoader.exists(PACK_DIR + "arbol.png") else null
	var grass_tex: Texture2D = load(PACK_DIR + "pasto_alto.png") if ResourceLoader.exists(PACK_DIR + "pasto_alto.png") else null
	var b_img := _original(ts, below).get_image()
	var a_img := _original(ts, above).get_image()
	b_img.convert(Image.FORMAT_RGBA8)
	a_img.convert(Image.FORMAT_RGBA8)
	var grass := b_img.get_region(_rect(GRASS))
	if tree != null:
		var t := tree.get_image()
		t.convert(Image.FORMAT_RGBA8)
		for id in TREE_CELLS:
			var col: int = TREE_CELLS[id][0]
			var low: int = TREE_CELLS[id][1]
			var high: int = TREE_CELLS[id][2]
			var cell := _rect(id)
			b_img.blit_rect(grass, Rect2i(0, 0, 16, 16), cell.position)
			if low >= 0:
				b_img.blend_rect(t, Rect2i(col * 16, low * 16, 16, 16), cell.position)
			a_img.fill_rect(cell, Color(0, 0, 0, 0))
			if high >= 0:
				a_img.blit_rect(t, Rect2i(col * 16, high * 16, 16, 16), cell.position)
	if grass_tex != null:
		var g := grass_tex.get_image()
		g.convert(Image.FORMAT_RGBA8)
		b_img.blit_rect(g, Rect2i(0, 0, 16, 16), _rect(TALL_GRASS).position)
	below.texture = ImageTexture.create_from_image(b_img)
	above.texture = ImageTexture.create_from_image(a_img)
	_on = true


static func is_on() -> bool:
	return _on


static func _rect(id: int) -> Rect2i:
	return Rect2i((id % 16) * 16, (id / 16) * 16, 16, 16)


static func _source(ts: TileSet, path: String) -> TileSetAtlasSource:
	for i in ts.get_source_count():
		var src := ts.get_source(ts.get_source_id(i)) as TileSetAtlasSource
		if src == null:
			continue
		var tex := _originals.get(src, src.texture) as Texture2D
		if tex != null and tex.resource_path == path:
			return src
	return null


static func _original(_ts: TileSet, src: TileSetAtlasSource) -> Texture2D:
	if not _originals.has(src):
		_originals[src] = src.texture
	return _originals[src]


static func _restore(_ts: TileSet, src: TileSetAtlasSource) -> void:
	if _originals.has(src):
		src.texture = _originals[src]
