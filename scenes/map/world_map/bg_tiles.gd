extends TileMapLayer

@export var world_map:WorldMap;

@export var farm_scene:PackedScene;
@export var scrapyard_scene:PackedScene;
@export var factory_scene:PackedScene;


@export var noise_height_texture:NoiseTexture2D;
var noise:Noise;

@export_subgroup("props")
@export var small_props_node:Node2D;
@export var props_node:Node2D;
@export var small_prop_textures:Array[Texture];
var small_prop_sprites:Array[Sprite2D];

@export var prop_textures:Array[Texture];
var prop_sprites:Array[Sprite2D]


var taken_positions:Array[Vector2]

@export var tile_colors:Array[Color];

const map_size = 5000;

func _ready()->void:
	await world_map.ready
	set_tiles()

	generate_settlements();
	set_props()
	set_small_props()
	

func set_tiles():
	noise = noise_height_texture.noise
	var width = map_size/16;
	var height = map_size/16
	for x in width * 2:
		for y in height * 2:
			var roll:float = noise.get_noise_2d(x - width, y - height);

			if roll < -.6:
				set_cell(Vector2(x-width, y-height), 0, Vector2.ONE);
			elif roll < 0:
				set_cell(Vector2(x-width, y-height), 0, Vector2.ZERO);
			elif roll < .2 :
				set_cell(Vector2(x-width, y-height), 0, Vector2.RIGHT)
			else:
				set_cell(Vector2(x-width, y-height), 0, Vector2.DOWN)

func generate_settlements()->void:
	const spawn_range = 2000;
	var taken_positions:Array[Vector2] = [Entities.in_map_player.position]
	var alternatives:Array[PackedScene] = [farm_scene, scrapyard_scene, factory_scene];
	
	var all_settlements:Array[Settlement]=[];
	for i in 20:
		var settlement_name:String = NameDatabase.generate_name();
		var settlement:Settlement = alternatives.pick_random().instantiate();
		
		var location:Vector2 = Vector2(randi_range(0, spawn_range), randi_range(0, spawn_range));
		while position_taken(location, taken_positions):
			location = Vector2(randi_range(0, spawn_range), randi_range(0, spawn_range));
		taken_positions.append(location)
		settlement.position = location;
		settlement.name = settlement_name;
		world_map.day_passed.connect(settlement.daily_reset)
		all_settlements.append(settlement);
		world_map.add_child(settlement);
	set_neighbors(all_settlements);
	
func set_neighbors(settlements:Array[Settlement]):
	for s:Settlement in settlements:
		var distances = {};
		var highest_distance = 0;
		for to_check:Settlement in settlements:
			if to_check != s:
				var distance = s.position.distance_to(to_check.position);
				
				if not len(distances.keys()) == 5:
					distances[distance] = to_check;
					if distance > highest_distance:
						highest_distance = distance;
				elif distance < highest_distance:
					distances.erase(highest_distance);
					distances[distance] = to_check;
					
					highest_distance = distances.keys().max();
		var keys = distances.keys();
		keys.sort()
		for d in keys:
			s.neighbors.append(distances[d]);

func set_small_props():
	for texture in small_prop_textures:
		var sprite = Sprite2D.new();
		sprite.texture = texture;
		ColorCoder.color_code_prop(sprite);
		sprite.scale = Vector2(2, 2)
		small_prop_sprites.append(sprite)
		
	var taken_positions:Array[Vector2] = [];
	const prop_amounts = 100;
	for prop in small_prop_sprites:
		for i in prop_amounts:
			set_prop(prop, taken_positions, 10, true)

func set_props():
	for texture in prop_textures:
		var sprite = Sprite2D.new();
		sprite.texture = texture;
		ColorCoder.color_code_prop(sprite, true)
		sprite.scale = Vector2(2, 2);
		prop_sprites.append(sprite);
	
	var taken_positions:Array[Vector2] = [];
	const prop_amounts = 30;
	for prop in prop_sprites:
		for i in prop_amounts:
			set_prop(prop, taken_positions);


func set_prop(which:Sprite2D, taken_positions:Array[Vector2], min_gap:float=30, small=false)->void:
	var prop = which.duplicate();
	var x_roll = randi_range(map_size * -1, map_size);
	var y_roll = randi_range(map_size*-1, map_size );
	var target_position = Vector2(x_roll,  y_roll)
	while position_taken(target_position, taken_positions, min_gap):
		x_roll = randi_range(map_size * -1, map_size);
		y_roll = randi_range(map_size*-1, map_size );
		target_position = Vector2(x_roll,  y_roll)
	
	taken_positions.append(target_position);
	
	prop.position = target_position;
	var grid_position = prop.position/16;
	var noise_roll = noise.get_noise_2d(grid_position.x, grid_position.y)
	
	if noise_roll < -.6:
		prop.modulate = tile_colors[0]
	elif noise_roll < 0:
		prop.modulate = tile_colors[1]
	elif noise_roll < .2 :
		prop.modulate = tile_colors[2]
	else:
		prop.modulate = tile_colors[3]
	
	
	
	
	if not small:
		props_node.add_child(prop);
	else:
		small_props_node.add_child(prop);

func position_taken(to_check:Vector2, taken_positions:Array[Vector2], min_gap:float = 30)->bool:
	for p in taken_positions:
		if to_check.distance_to(p)< min_gap:
			return true;
	return false;
