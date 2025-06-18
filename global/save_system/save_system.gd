extends Node



func save_data()->void:
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
	var save_data:String = JSON.stringify(save_file);
	var file:FileAccess = FileAccess.open("user://savegame.json", FileAccess.WRITE);
	file.store_line(save_data)
	
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
		"world_map_position":Entities.in_map_player.global_position,
		
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
		"minute" : world.current_minute,
		"hour" : world.current_hour,
		"day" : world.current_day,
		"month" : world.current_month
	};
	return data
	
func store_settlement_data(settlement:Settlement)->Dictionary:
	var data:Dictionary = {
		"global_position":settlement.global_position,
		"inventory":store_inventory_data(settlement.inventory),
		"recruits":[]
	}
	for r:FighterUnit in settlement.available_recruits:
		data.recruits.append(store_unit_data(r))
	
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
		"stack_size":item.stack_size
	}
	return data;
	
func raw_file_name(node:Node, prefix:String = "")->String:
	var path:String = node.get_scene_file_path();
	var raw_name:String = path.split("/")[-1].split(".tscn")[0];
	return prefix + raw_name
