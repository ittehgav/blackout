extends TileMapLayer

@export var light:DirectionalLight2D

func _ready()->void:
	if Entities.world_map:
		set_tiles()
	else:
		for x in range(-128, 128):
			for y in range(-128, 128):
				set_cell(Vector2i(x, y), 0, Vector2.ZERO)
		get_parent().team_1.modulate.v = .5;
		get_parent().team_2.modulate.v = .5


func set_tiles()->void:
	var points:Dictionary = Entities.world_map.quadrants.noise_roll_breakpoints;
	var breakpoints:Array = points.keys();
	
	const x_range = 156;
	const y_range = 156;
	

	var noise:Noise = Entities.world_map.quadrants.noise;
	var center_tile:Vector2i = Vector2i(Entities.player_map_party.global_position/16);
	for x in range(-x_range, x_range):
		for y in range(-y_range, y_range):
			var cell_coords:Vector2i = Vector2i(center_tile.x, center_tile.y)
			var noise_roll:float = noise.get_noise_2d(cell_coords.x + x, cell_coords.y + y);
			for point:float in breakpoints:
				if noise_roll < point:
					set_cell(Vector2(x, y),0, points[point])
					break;
		


			
	var hour:int = Entities.world_map.current_hour;
	if hour <= 3 or hour >= 21:
		## late night hours
		light.color = Color.MIDNIGHT_BLUE - Color(0, 0, 0, .5);
	elif hour <= 6 or hour >= 18:
		light.color = Color.DARK_ORANGE - Color(0, 0, 0, .5);
	elif hour >= 12: ## and < 18
		light.color = Color.YELLOW- Color.from_hsv(0, 0, .1, .5)
		get_parent().team_1.modulate.v = .7
		get_parent().team_2.modulate.v = .7
		
	
