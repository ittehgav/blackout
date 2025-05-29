extends Node2D

@export var world_map:WorldMap

@export var noise_texture:NoiseTexture2D;
@onready var noise:Noise = noise_texture.noise;

const cell_size = 16;
const entity_spawn_range = 4096;
const quarter_tile_map_size = Vector2(entity_spawn_range/cell_size, entity_spawn_range/cell_size)
const entity_padding = 50;

const small_prop_amounts = entity_spawn_range/50;
const large_prop_amounts = entity_spawn_range/100;
const settlement_amount = entity_spawn_range/50;

const thugs_amount = entity_spawn_range/100;
const travelling_traders_amount = entity_spawn_range/100;

@export var small_prop_textures:Array[Texture];
var small_prop_sprites:Array[Sprite2D];

@export var large_prop_textures:Array[Texture];
var large_prop_sprites:Array[Sprite2D]

@export var tile_colors:Array[Color];

@export var quadrant_1:WorldMapQuadrant; ## top-left
@export var quadrant_2:WorldMapQuadrant; ## top-right
@export var quadrant_3:WorldMapQuadrant; ## bottom-left
@export var quadrant_4:WorldMapQuadrant; ## bottom-right

@onready var all_quadrants:Array[WorldMapQuadrant] = [quadrant_1, quadrant_2, quadrant_3, quadrant_4];

## keep track of those for shifting
var top_left_quadrant:WorldMapQuadrant;
var bottom_right_quadrant:WorldMapQuadrant

var settlement_positions:Array[Vector2];
var large_prop_positions:Array[Vector2]
var small_prop_positions:Array[Vector2];

const noise_roll_breakpoints = [
	-.5, ## dark mud
	-.2, ## sand
	.0 ## light mud
	## up to .6 - grass
]


func _ready() -> void:
	noise_texture.noise = FastNoiseLite.new();
	noise = noise_texture.noise;
	noise.seed = randi();

	quadrant_1.position -= Vector2(quarter_tile_map_size.x*cell_size, quarter_tile_map_size.y*cell_size);
	quadrant_2.position.y -= quarter_tile_map_size.y*cell_size
	quadrant_3.position.x -= quarter_tile_map_size.x*cell_size
	
	for q:WorldMapQuadrant in all_quadrants:
		var width:float = quarter_tile_map_size.x
		var height:float = quarter_tile_map_size.y;
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
				if roll < noise_roll_breakpoints[0]:
					q.tile_map.set_cell(cell_coords, 0, Vector2.ONE);
				elif roll < noise_roll_breakpoints[1]:
					q.tile_map.set_cell(cell_coords, 0, Vector2.ZERO);
				elif roll < noise_roll_breakpoints[2]:
					q.tile_map.set_cell(cell_coords, 0, Vector2.RIGHT)
				else:
					q.tile_map.set_cell(cell_coords, 0, Vector2.DOWN)
	
	generate_settlements();
	generate_props();
	generate_parties();

func generate_party(leader_scene:PackedScene, party_positions:Array[Vector2])->NpcMapParty:
	var leader:NpcLeader = leader_scene.instantiate();
	var party:NpcMapParty = Index.npc_map_party_scene.instantiate();
	
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
	
	return party
	
	
func generate_parties()->void:
	var party_positions:Array[Vector2]
	var party:NpcMapParty;
	for i:int in thugs_amount:
		party = generate_party(Index.thugs_scene, party_positions)
	party.global_position = Vector2.ZERO
		
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
		
	if noise_roll < noise_roll_breakpoints[0]:
		return tile_colors[0]
	elif noise_roll < noise_roll_breakpoints[1]:
		return tile_colors[2]
	elif noise_roll < noise_roll_breakpoints[2]:
		return tile_colors[1]
	else:
		return tile_colors[3]

func position_taken(to_check:Vector2, position_arrays:Array[Array], min_gap:float = 200)->bool:
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
		ColorCoder.color_code_settlement(settlement, get_spot_tile_color(settlement.position, quadrant_n));
		self["quadrant_" + str(quadrant_n)].add_child(settlement);
		
		world_map.day_passed.connect(settlement.daily_reset)
		all_settlements.append(settlement)
		world_map.all_settlements[settlement.name] = settlement

	set_neighbors(all_settlements);

func set_neighbors(settlements:Array[Settlement])->void:
	for s:Settlement in settlements:
		var distances:Dictionary = {};
		var highest_distance:float = 0;
		for to_check:Settlement in settlements:
			if to_check != s:
				var distance:float = s.global_position.distance_to(to_check.global_position);
				
				if not len(distances.keys()) == 5:
					distances[distance] = to_check;
					if distance > highest_distance:
						highest_distance = distance;
				elif distance < highest_distance:
					distances.erase(highest_distance);
					distances[distance] = to_check;
					
					highest_distance = distances.keys().max();
		var keys:Array = distances.keys();
		keys.sort()
		for d:float in keys:
			s.neighbors.append(distances[d]);
			
func random_quadrant_position()->Vector2:
	## range = x/y size of quadrant * -1 -- x/y size = anywhere within the 4 quadrants
	const x_range = quarter_tile_map_size.x * cell_size;
	const y_range = quarter_tile_map_size.y * cell_size;
	
	var x_roll:int = randi_range(-x_range + entity_padding, x_range - entity_padding);
	var y_roll:int = randi_range(-y_range + entity_padding, y_range - entity_padding);
	
	return Vector2(x_roll,y_roll);
