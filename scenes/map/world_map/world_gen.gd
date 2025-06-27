extends Node2D

@export var world_map:WorldMap

@export var noise_texture:NoiseTexture2D;
@onready var noise:Noise = noise_texture.noise;

const cell_size = 16;
const entity_spawn_range = 6144;
const quarter_tile_map_size = Vector2(entity_spawn_range/cell_size, entity_spawn_range/cell_size)

const small_prop_amounts = entity_spawn_range/100;
const large_prop_amounts = entity_spawn_range/200;
const settlement_amount = entity_spawn_range/50;

const thugs_amount = entity_spawn_range/75;
const travelling_traders_amount = entity_spawn_range/200;

@export var small_prop_textures:Array[Texture];
var small_prop_sprites:Array[Sprite2D];

@export var large_prop_textures:Array[Texture];
var large_prop_sprites:Array[Sprite2D]

@export var tile_colors:Array[Color];

@export var quadrant_1:WorldMapQuadrant; ## top-left
@export var quadrant_2:WorldMapQuadrant; ## top-right
@export var quadrant_3:WorldMapQuadrant; ## bottom-left
@export var quadrant_4:WorldMapQuadrant; ## bottom-right

@export var all_quadrants:Array[WorldMapQuadrant];

## keep track of those for shifting
var top_left_quadrant:WorldMapQuadrant;
var bottom_right_quadrant:WorldMapQuadrant

var settlement_positions:Array[Vector2];
var large_prop_positions:Array[Vector2]
var small_prop_positions:Array[Vector2];

const noise_roll_breakpoints = {
	-.5:Vector2(0, 0),## grass 1
	-.4:Vector2(0, 1),## grass 2
	-.3:Vector2(1, 0),## grass 3
	-.2:Vector2(1, 1),## grass 4
	-.1:Vector2(0, 2),## sand/grass 1
	0.0:Vector2(0, 2),## sand/grass 2
	.1:Vector2(0, 3),## sand/grass 3
	.2:Vector2(1, 2),## sand/grass 4
	.3:Vector2(2, 0), ## mud
	.4:Vector2(2, 1),## 2
	.5:Vector2(3, 0),## 3
	1.0:Vector2(3, 1)##4
}

var new_game:bool=true;

func load_game(data:Dictionary)->void:
	## RUNS BEFORE WORLD MAP ENTERS TREE
	new_game = false;
	noise_texture.noise = FastNoiseLite.new();
	noise = noise_texture.noise
	noise.seed =  data.world.seed;
	
	
	for settlement_name:String in data.settlements.keys():
		var s:Dictionary = data.settlements[settlement_name];
		var settlement:Settlement = Index[s.type.to_lower() + "_scene"].instantiate();
		world_map.all_settlements[settlement_name] = settlement

		
		settlement.name = settlement_name;
		
		settlement.refresh_events();
		
		for unit_data:Dictionary in s.recruits:
			var unit:FighterUnit = LoadSystem.load_fighter_unit(unit_data);
			settlement.available_recruits.append(unit);

		
		LoadSystem.load_inventory(settlement.inventory, s.inventory);
		
		var target_position:Vector2 = LoadSystem.load_vector2(s.global_position)
		var quadrant:WorldMapQuadrant = Entities.world_map.quadrant_for_global_position(target_position)
		quadrant.add_child(settlement);
		settlement.global_position = target_position;
		ColorCoder.color_code_settlement(settlement)
		
	
		
	for settlement_name:String in world_map.all_settlements.keys():
		var settlement_data:Dictionary = data.settlements[settlement_name];
		var settlement:Settlement = world_map.all_settlements[settlement_name];
		
		for neighbor_name:String in settlement_data.neighbor_names:
			settlement.neighbors.append(world_map.all_settlements[neighbor_name])

	for i in 4:
		var fog_data:Array = data.world.fog[i];
		var quadrant:WorldMapQuadrant = all_quadrants[i];
		quadrant.load_fog(fog_data)
		
func _ready() -> void:
	generate_quadrants();
	if new_game:
		noise_texture.noise = FastNoiseLite.new();
		noise = noise_texture.noise;
		noise.seed = randi();
		## only settlements persist right now
		generate_settlements();

	
	## parties and props are randomized every time the player opens the game
	generate_props();
	generate_parties();

func generate_quadrants()->void:
	quadrant_1.position -= Vector2(quarter_tile_map_size.x*cell_size, quarter_tile_map_size.y*cell_size);
	quadrant_2.position.y -= quarter_tile_map_size.y*cell_size
	quadrant_3.position.x -= quarter_tile_map_size.x*cell_size
	
	for q:WorldMapQuadrant in all_quadrants:
		var width:float = quarter_tile_map_size.x
		var height:float = quarter_tile_map_size.y;
		var points:Array = noise_roll_breakpoints.keys();
		for x:int in width:
			for y:int in height:
				var cell_coords:Vector2 = Vector2(x, y);
				var roll_coords:Vector2 = Vector2(x, y);
				
				if q != quadrant_4:
					match q:
						quadrant_1:
							roll_coords -= Vector2(width, height);
						quadrant_2:
							roll_coords.y -= height
						quadrant_3:
							roll_coords.x -= width;
				var roll:float = noise.get_noise_2dv(roll_coords);

				for point:float in points:
					if roll < point:
						q.tile_map.set_cell(cell_coords,0, noise_roll_breakpoints[point])
						break;
	
func generate_party(leader_scene:PackedScene, party_positions:Array[Vector2])->NpcMapParty:
	var leader:NpcLeader = leader_scene.instantiate();
	var party:NpcMapParty = Index.npc_map_party_scene.instantiate();
	
	leader.color_scheme_index = randi_range(0, len(Index.color_schemes) - 1);
	while leader.color_scheme_index == Entities.player.color_scheme_index:
		leader.color_scheme_index = randi_range(0, len(Index.color_schemes) - 1);
	
	party.leader = leader;
	
	var vehicle:Vehicle = Index.vehicle_scenes.pick_random().instantiate()
	vehicle.party = party;
	party.vehicle = vehicle
	var party_position:Vector2 = random_quadrant_position();
	while position_taken(party_position, [party_positions]):
		party_position = random_quadrant_position();
	
	leader.generate(party_position.distance_to(Vector2.ZERO));
	party.add_child(leader);
	party.add_child(vehicle);
	
	var adjusted:Array = adjust_to_quadrants(party_position);
	party.position = adjusted[0];
	
	var quadrant:WorldMapQuadrant = self["quadrant_" + str(adjusted[1])];
	quadrant.add_child(party)
	
	party.material.set_shader_parameter("color", leader.outline_color)
	
	return party
	
	
func generate_parties()->void:
	var party_positions:Array[Vector2]

	for i:int in thugs_amount:
		generate_party(Index.thugs_scene, party_positions)
		
	for i:int in travelling_traders_amount:
		generate_party(Index.travelling_trader_scene, party_positions);

func generate_props()->void:
	for texture:Texture in small_prop_textures:
		var sprite:Sprite2D = Sprite2D.new();
		sprite.texture = texture;
		ColorCoder.color_code_prop(sprite);
		sprite.scale = Vector2(2, 2);
		sprite.z_index += 1
		small_prop_sprites.append(sprite);
		
	for prop:Sprite2D in small_prop_sprites:
		for i in small_prop_amounts:
			set_prop(prop, 50, true)
	
	for texture:Texture in large_prop_textures:
		var sprite:Sprite2D = Sprite2D.new();
		sprite.z_index += 1
		sprite.texture = texture;
		ColorCoder.color_code_prop(sprite);
		sprite.scale = Vector2(2, 2);
		large_prop_sprites.append(sprite)
	
	for prop:Sprite2D in large_prop_sprites:
		for i in large_prop_amounts:
			set_prop(prop, 200);

func set_prop(which:Sprite2D, min_gap:float=30, small:bool=false)->void:
	var prop:Sprite2D = which.duplicate();

	
	var taken_positions_arrays:Array[Array] = [settlement_positions, large_prop_positions];
	if small:
		taken_positions_arrays.append(small_prop_positions)

	var target_position: = random_quadrant_position();
	while position_taken(target_position, taken_positions_arrays, min_gap):
		target_position = random_quadrant_position();
	
	if small:
		small_prop_positions.append(target_position);
	else:
		large_prop_positions.append(target_position)
	
	## adjusts the props' positions to the quadrant and adds them to the tree
	var adjust:Array = adjust_to_quadrants(target_position)
	prop.position = adjust[0];
	var quadrant_n:int = adjust[1]

	prop.modulate = get_spot_tile_color(adjust[0], quadrant_n);
	self["quadrant_" + str(quadrant_n)].add_child(prop)

		
func get_spot_tile_color(from:Vector2, quadrant_n:int=0)->Color:
	var noise_roll:float;
	if quadrant_n:
		var roll_coords:Vector2 = from/cell_size;
		match quadrant_n:
			1:
				roll_coords -= quarter_tile_map_size
			2:
				roll_coords.y -= quarter_tile_map_size.y;
			3:
				roll_coords.x -= quarter_tile_map_size.x;
		noise_roll = noise.get_noise_2dv(roll_coords)
	else:
		noise_roll = noise.get_noise_2d(from.x/cell_size, from.y/cell_size)
		
	if noise_roll < .2:
		return tile_colors[0]
	elif noise_roll < .3:
		return tile_colors[2]
	else:
		return tile_colors[1]


func position_taken(to_check:Vector2, position_arrays:Array[Array], min_gap:float = 100)->bool:
	for a:Array[Vector2] in position_arrays:
		for p:Vector2 in a:
			if to_check.distance_to(p) < min_gap:
				return true;
	return false;
	

func adjust_to_quadrants(target_position:Vector2)->Array[Variant]:
	var final_position:Vector2 = target_position;
	var quadrant_n:int=4;
	## CORRECTS THE OFFSET BECAUSE THE POSITIONS
	## ARE INITIALLY CALCULATED BASED ON THE CENTER OF THE WORLD MAP
	if target_position.x < 0 and target_position.y < 0:
		## Q1 = top left
		final_position += quarter_tile_map_size * cell_size;
		quadrant_n = 1;
	elif target_position.y < 0:
		## Q2 = top right
		final_position.y += quarter_tile_map_size.y * cell_size
		quadrant_n = 2;
	elif target_position.x < 0:
		## Q3 = bottom left
		final_position.x += quarter_tile_map_size.x * cell_size
		quadrant_n = 3;
	return [final_position, quadrant_n];


func generate_settlements()->void:
	var alternatives:Array[PackedScene] = [Index.farm_scene, Index.scrapyard_scene, Index.factory_scene];
	var taken_names:Array[String];
	var all_settlements:Array[Settlement];
	
	for i in settlement_amount:
		var settlement_name:String = NameDatabase.generate_name();
		while settlement_name in taken_names:
			settlement_name = NameDatabase.generate_name();
		taken_names.append(settlement_name)
		
		var settlement:Settlement = alternatives.pick_random().instantiate();
		settlement.initiate_inventory();
		settlement.name = settlement_name;
		
		var target_position:Vector2 = random_quadrant_position();
		while position_taken(target_position, [settlement_positions]):
			target_position = random_quadrant_position();
			
		settlement_positions.append(target_position)
		
		var adjust:Array = adjust_to_quadrants(target_position);
		settlement.position = adjust[0];
		var quadrant_n:int = adjust[1];
		ColorCoder.color_code_settlement(settlement);
		self["quadrant_" + str(quadrant_n)].add_child(settlement);
		
		
		all_settlements.append(settlement)
		world_map.all_settlements[settlement.name] = settlement

	set_neighbors(all_settlements);
	for s:Settlement in all_settlements:
		## needs to be done after neighbords are set
		s.daily_reset();


func sort_by_distance(target_1:Settlement, target_2:Settlement)->bool:
	return target_1.global_position.distance_to(current_origin) < target_2.global_position.distance_to(current_origin)
	
var current_origin:Vector2;
func set_neighbors(settlements:Array[Settlement])->void:
	for s:Settlement in settlements:
		current_origin = s.global_position
		var to_check:Array[Settlement] = settlements.duplicate()
		to_check.sort_custom(sort_by_distance)
		s.neighbors = [
			## to_check[0] will be the settlement itself
			to_check[1],
			to_check[2],
			to_check[3]
		]
		
			
func random_quadrant_position()->Vector2:
	## range = x/y size of quadrant * -1 -- x/y size = anywhere within the 4 quadrants
	const x_range = quarter_tile_map_size.x * cell_size;
	const y_range = quarter_tile_map_size.y * cell_size;
	
	var x_roll:int = randi_range(-x_range, x_range);
	var y_roll:int = randi_range(-y_range, y_range);
	
	return Vector2(x_roll,y_roll);
