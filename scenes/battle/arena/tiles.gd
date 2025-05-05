extends TileMapLayer

func _ready()->void:
	if Entities.world_map:
		set_tiles()
	else:
		get_parent().team_1.modulate.v = .5;
		get_parent().team_2.modulate.v = .5


func set_tiles()->void:
	var center_tile:Vector2i = Vector2i(Entities.in_map_player.global_position/16);
	for x in range(-16, 16):
		for y in range(-16, 16):
			var cell_position:Vector2 = Vector2(center_tile.x + x, center_tile.y + y)
			var tile:Vector2 = Entities.world_map.tile_map.get_cell_atlas_coords(cell_position);
			set_cell(Vector2(x, y), 0, tile)
		
	var hour:int = Entities.world_map.current_hour;
	if hour <= 3 or hour >= 21:
		modulate.v = .11
	elif hour <= 6 or hour >= 18:
		modulate.v = .5

		
	
