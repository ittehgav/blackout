extends TileMapLayer

@export var map_entities_node:Node2D

@export var world_map:WorldMap;
@export var fog_layer:TileMapLayer;
@export var off_sight_layer:TileMapLayer;

@export var refresh_fog_timer:Timer;

## generic stuff just goes into this pool to spawn

const cell_size = 16
const entity_spawn_range = 5000;


@export var noise_height_texture:NoiseTexture2D;
var noise:Noise;

@export_subgroup("props")
@export var small_props_node:Node2D;
@export var props_node:Node2D;
@export var small_prop_textures:Array[Texture];
var small_prop_sprites:Array[Sprite2D];

@export var prop_textures:Array[Texture];
var prop_sprites:Array[Sprite2D]

@export var tile_colors:Array[Color];

var settlement_positions:Array[Vector2];
var large_prop_positions:Array[Vector2]
var small_prop_positions:Array[Vector2];
#
#func _ready()->void:
	#await world_map.ready
	#tile_set.tile_size = Vector2(cell_size, cell_size)
	#set_tiles()
#
	#generate_settlements();
	#set_props()
	#set_small_props()
	##generate_parties();
	#update_fog()
	#Entities.world_map.day_passed.emit()

func set_tiles()->void:
	noise = noise_height_texture.noise
	var width:float = entity_spawn_range/cell_size
	var height:float = entity_spawn_range/cell_size
	
	for x:int in width:
		for y:int in height:
			var cell_coords:Vector2 = Vector2(x-width/2, y-height/2);
			fog_layer.set_cell(cell_coords, 0, Vector2.ZERO);
			off_sight_layer.set_cell(cell_coords, 0, Vector2.ZERO);
			
			var roll:float = noise.get_noise_2d(x - width/2, y - height/2);

			if roll < -.6:
				set_cell(cell_coords, 0, Vector2.ONE);
			elif roll < 0:
				set_cell(cell_coords, 0, Vector2.ZERO);
			elif roll < .2 :
				set_cell(cell_coords, 0, Vector2.RIGHT)
			else:
				set_cell(cell_coords, 0, Vector2.DOWN)

func generate_settlements()->void:
	var alternatives:Array[PackedScene] = [Index.farm_scene, Index.scrapyard_scene, Index.factory_scene];
	var taken_names:Array[String]
	var all_settlements:Array[Settlement]=[];
	for i in 30:
		var settlement_name:String = NameDatabase.generate_name();
		while settlement_name in taken_names:
			settlement_name = NameDatabase.generate_name();
		taken_names.append(settlement_name)

		var settlement:Settlement = alternatives.pick_random().instantiate();
		settlement.initiate_inventory();
		
		var location:Vector2 = Vector2(randi_range(-entity_spawn_range/2, entity_spawn_range/2),\
								randi_range(-entity_spawn_range/2, entity_spawn_range/2));

		while position_taken(location, [settlement_positions]):
			location = Vector2(randi_range(-entity_spawn_range/2, entity_spawn_range/2),\
								randi_range(-entity_spawn_range/2, entity_spawn_range/2))

		settlement_positions.append(location);
		settlement.position = location;
		settlement.name = settlement_name;
		
		world_map.day_passed.connect(settlement.daily_reset)
		all_settlements.append(settlement);
		map_entities_node.add_child(settlement);
		world_map.all_settlements[settlement.name] = settlement;

	set_neighbors(all_settlements);
	
func set_neighbors(settlements:Array[Settlement])->void:
	for s:Settlement in settlements:
		var distances:Dictionary = {};
		var highest_distance:float = 0;
		for to_check:Settlement in settlements:
			if to_check != s:
				var distance:float = s.position.distance_to(to_check.position);
				
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

func set_small_props()->void:
	for texture in small_prop_textures:
		var sprite:Sprite2D = Sprite2D.new();
		sprite.texture = texture;
		ColorCoder.color_code_prop(sprite);
		sprite.scale = Vector2(2, 2)
		small_prop_sprites.append(sprite)
		
	const prop_amounts = entity_spawn_range/100;
	for prop in small_prop_sprites:
		for i in prop_amounts:
			set_prop(prop, 50, true)

func set_props()->void:
	for texture in prop_textures:
		var sprite:Sprite2D = Sprite2D.new();
		sprite.texture = texture;
		ColorCoder.color_code_prop(sprite)
		sprite.scale = Vector2(2, 2);
		prop_sprites.append(sprite);
	
	const prop_amounts = entity_spawn_range/300;
	for prop in prop_sprites:
		for i:int in prop_amounts:
			set_prop(prop, 100);


func set_prop(which:Sprite2D, min_gap:float=30, small:bool=false)->void:
	var prop:Sprite2D = which.duplicate();
	var x_roll := randi_range(-entity_spawn_range/2, entity_spawn_range/2);
	var y_roll := randi_range(-entity_spawn_range/2, entity_spawn_range/2);
	var target_position: = Vector2(x_roll,  y_roll)
	
	var taken_positions_arrays:Array[Array] = [settlement_positions, large_prop_positions];
	if small:
		taken_positions_arrays.append(small_prop_positions)
		
	while position_taken(target_position, taken_positions_arrays, min_gap):
		x_roll = randi_range(-entity_spawn_range/2, entity_spawn_range/2);
		y_roll = randi_range(-entity_spawn_range/2, entity_spawn_range/2);
		target_position = Vector2(x_roll,  y_roll)
	
	if small:
		small_prop_positions.append(target_position);
	else:
		large_prop_positions.append(target_position)
		
	prop.position = target_position;
	prop.modulate = get_spot_tile_color(prop.position);
	

	if not small:
		props_node.add_child(prop);
	else:
		small_props_node.add_child(prop);
		
func generate_parties()->void:
	for i:int in 20:
		var leader:NpcLeader = Index.common_leader_scenes.pick_random().instantiate();
		var party:NpcMapParty = Index.npc_map_party_scene.instantiate()
		party.leader = leader;
		var vehicle:Vehicle = Index.vehicle_scenes.pick_random().instantiate();
		
		var party_position:Vector2 = Vector2(randi_range(-entity_spawn_range/2, entity_spawn_range/2),\
								 randi_range(-entity_spawn_range/2, entity_spawn_range/2))
								

		party.position = party_position;
		leader.generate(party_position.distance_to(Vector2.ZERO));
		party.add_child(leader);
		party.add_child(vehicle);
		map_entities_node.add_child(party);


func position_taken(to_check:Vector2, position_arrays:Array[Array], min_gap:float = 200)->bool:
	for a:Array[Vector2] in position_arrays:
		for p:Vector2 in a:
			if to_check.distance_to(p) < min_gap:
				return true;
	return false;
	
func update_fog()->void:
	var player_grid_position:Vector2i = Vector2i(Entities.in_map_player.position/cell_size)
	var grid_radius:float = Entities.player.sight_range/cell_size + 5;
	for x in range(grid_radius * 2):
		for y in range(grid_radius * 2):
			var cell:Vector2i = Vector2i(x - grid_radius, y - grid_radius);
			var distance:float = cell.distance_to(Vector2.ZERO)
			
			var cell_position:Vector2 = cell + player_grid_position;
			
			if distance < grid_radius - 3:
				fog_layer.set_cell(cell_position, 0, Vector2(2, 0))
				off_sight_layer.erase_cell(cell_position)
			else:
				off_sight_layer.set_cell(cell_position, 0, Vector2.ZERO);
				if distance < grid_radius + 1:
					if fog_layer.get_cell_atlas_coords(cell_position) != Vector2i(2, 0):
						fog_layer.set_cell(cell + player_grid_position, 0, Vector2(1,0))

				
func get_spot_tile_color(from:Vector2)->Color:
	var noise_roll:float = noise.get_noise_2d(from.x/cell_size, from.y/cell_size)
	if noise_roll < -.6:
		return tile_colors[0]
	elif noise_roll < 0:
		return tile_colors[2]
	elif noise_roll < .2 :
		return tile_colors[1]
	else:
		return tile_colors[3]


func position_in_fog(p:Vector2)->bool:
	var cell_position:Vector2i = Vector2i(p/cell_size);
	return fog_layer.get_cell_atlas_coords(cell_position) == Vector2i(0, 0)


#func _on_in_map_player_started_moving() -> void:
	#refresh_fog_timer.start()
#
#func _on_in_map_player_stopped_moving() -> void:
	#refresh_fog_timer.stop();
#
#
#
#func _on_refresh_fog_timeout() -> void:
	#update_fog();
