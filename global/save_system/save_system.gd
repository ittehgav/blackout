extends Node



func save_data(file_path:String)->void:
	var save_file:Dictionary[String, Dictionary]={
		"world":{},
		"player":{},
		"settlements":{}
	};
	## send these functions to the scripts of the scenes themselves?
	save_file.world = store_world_data();
	save_file.player = store_player_data();

	
	for settlement:Settlement in get_tree().get_nodes_in_group("all_settlements"):
		save_file.settlements[settlement.name] = store_settlement_data(settlement)
		
	var to_save:String = JSON.stringify(save_file);
	var file:FileAccess = FileAccess.open(file_path, FileAccess.WRITE);
	file.store_string(to_save)
	
func store_player_data()->Dictionary:
	var player:Player = Entities.player;
	var equipped_weapon_index:int;
	var alt_weapon_index:int;
	if not player.alternative_weapon:
		alt_weapon_index = -1;
	var i: = 0;
	for weapon:Weapon in player.inventory.weapons:
		if weapon == player.equipped_weapon:
			equipped_weapon_index = i;
		elif player.alternative_weapon and weapon == player.alternative_weapon:
			alt_weapon_index = i;
		i += 1
	
	var equipped_module_index:int;
	
	i = 0;
	for m:Module in player.inventory.modules:
		if m == player.equipped_module:
			equipped_module_index = i;
		i += 1;
	
	var data:Dictionary = {
		"world_map_position":Entities.player_map_party.global_position,
		
		"name":player.name,
		"color_sceme_index":player.color_scheme_index,
		## for now you're just forced to assign all stat points right after battle
		## so they never need to be saved
		"leadership_level":player.leadership_level,
		"leadership_exp":player.leadership_exp,
		
		"combat_level":player.combat_level,
		"combat_exp":player.combat_exp,
	
		"morale":player.morale,
		"memos":[],
		## TODO for now just reset these at runtime since memos are still too raw of a concept
		
		
		
		## TODO verify this works consistently
		"equipped_weapon_index":equipped_weapon_index,
		"alt_weapon_index":alt_weapon_index,
		"equipped_module_index":equipped_module_index,
		
		"inventory":store_inventory_data(player.inventory),
		"roster":store_roster_data(player.roster),
		
		"combat_stats":store_combat_stats(player.combat_stats)
	}
	return data

func store_roster_data(roster:Roster)->Array:
	var data:Array[Dictionary];
	for unit:FighterUnit in roster.units:
		data.append(store_unit_data(unit))
	return data
	
func store_world_data()->Dictionary:
	var world:WorldMap = Entities.world_map;
	var data:Dictionary = {
		"seed":world.quadrants.noise_texture.noise.seed,
		"play_time" : Time.get_unix_time_from_system() - world.session_start_time + world.play_time_acm,
		"minute" : world.current_minute,
		"hour" : world.current_hour,
		"day" : world.current_day,
		"month" : world.current_month,
		"fog":store_fog_data()
	};
	return data

func store_fog_data()->Array:
	var data:Array[Array];
	var quadrants:WorldMapPlane = Entities.world_map.quadrants;

	var x_center: = quadrants.quarter_tile_map_size.x;
	var y_center: = quadrants.quarter_tile_map_size.y;
	

	const coords_indexes:PackedVector2Array = [
		Vector2(0, 0),
		Vector2(0, 1),
		Vector2(1, 0),
		Vector2(1, 1)
	]
	
	for quadrant:WorldMapQuadrant in quadrants.all_quadrants:
		var current_streak:int=0;
		var current_type:int=coords_indexes.find(quadrant.fog_tile_map.get_cell_atlas_coords(Vector2.ZERO));
		var rle_array:Array[Array];
		for y:int in quadrants.quarter_tile_map_size.y:
			for x:int in quadrants.quarter_tile_map_size.x:
				var coords:Vector2i = quadrant.fog_tile_map.get_cell_atlas_coords(Vector2i(x, y));
				var type:int = coords_indexes.find(coords);
				if current_type != type:
					rle_array.append([current_type, current_streak]);
					current_streak = 0;
					current_type = type;
					
				current_streak += 1;
		rle_array.append([current_type, current_streak]);
		data.append(rle_array);
	return data


func store_settlement_data(settlement:Settlement)->Dictionary:
	var data:Dictionary = {
		"type":settlement.settlement_type_name,
		"global_position":settlement.global_position,
		"inventory":store_inventory_data(settlement.inventory),
		"recruits":[],
		"neighbor_names":[]
	}
	for r:FighterUnit in settlement.available_recruits:
		data.recruits.append(store_unit_data(r))
	
	for n:Settlement in settlement.neighbors:
		data.neighbor_names.append(n.name)
	return data
	
func store_unit_data(unit:FighterUnit)->Dictionary:
	var data:Dictionary = {
		"base_filename":raw_file_name(unit.base),
		"level":unit.level,
		"exp":unit.experience,
		## non-modifier stats are all derived from levels
		"modifier_stats":store_combat_stats(unit.modifier_stats)
	};
	
	return data;

func store_combat_stats(stats:CombatStats)->Dictionary:
	var data:Dictionary = {};
	for s:String in Index.all_combat_stats:
		data[s] = stats[s];
	
	return data

func store_inventory_data(inventory:Inventory)->Dictionary:
	var data:Dictionary = {
		## other resources will be stored by the containers/stacks of resourecs
		"money":0,
		
		"containers":[],
		"weapons":[],
		"modules":[]
	}
	for item in inventory.items:
		if item is ResourceContainer:
			if item.storage:
				data.containers.append(store_item_data(item, "storage/"));
			else:
				data.containers.append(store_item_data(item));
		elif item is Weapon:
			data.weapons.append(store_item_data(item))
		elif item is Module:
			data.modules.append(store_item_data(item))
	
	return data
	
func store_item_data(item:Item, prefix:String="")->Dictionary:
	var data:Dictionary = {
		"filename":raw_file_name(item, prefix),
		"inventory_position":item.inventory_position,
		"stack_size":item.stack_size
	}
	return data;
	
func raw_file_name(node:Node, prefix:String = "")->String:
	var path:String = node.get_scene_file_path();
	var raw_name:String = path.split("/")[-1].split(".tscn")[0];
	return prefix + raw_name

func delete_file(path:String)->void:
	var file:FileAccess = FileAccess.open(path, FileAccess.WRITE);
	file.store_string("")
