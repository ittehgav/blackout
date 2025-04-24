extends TileMapLayer

func _ready()->void:
	if Entities.world_map:
		set_tiles()

func set_tiles()->void:
	var center_tile:Vector2i = Vector2i(Entities.in_map_player.global_position/16);
	for x in range(-16, 16):
		for y in range(-16, 16):
			var cell_position:Vector2 = Vector2(center_tile.x + x, center_tile.y + y)
			var tile:Vector2 = Entities.world_map.tile_map.get_cell_atlas_coords(cell_position);
			set_cell(Vector2(x, y), 0, tile)
