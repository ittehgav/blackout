extends Leader

class_name NpcLeader;

@export_enum("thugs", "travelling_trader") var party_type:String;

@export var dialogue:DialogueResource;
@export var leader_unit:FighterUnit

@export_color_no_alpha var outline_color:Color;


func generate(distance:float)->void:
	## generic map parties will be generated based on 
	## world conditions such as region and the player's level
	
	## probably make this reusable for other generic map parties
	match party_type:
		"travelling_trader":
			inventory.generate_storages();
			for i in randi_range(1, distance/1500):
				var item:Item = (Index.rarity_1_item_scenes + Index.rarity_2_item_scenes + Index.rarity_3_item_scenes).pick_random().instantiate();
				inventory.add_item(item);
			for r:String in Index.all_resources:
				inventory[r] = randi_range(1, distance/50) * 2
			inventory.refresh_resource_counts("", 0, false);
		"thugs":
			var total_items:int;
			var r2_chance:float;
			var r3_chance:float;
			if distance < 2000:
				total_items = 1
				r2_chance = .1
				r3_chance = .01;
			elif distance < 4000:
				total_items = randi_range(1, 2)
				r2_chance = .18
				r3_chance = .05;
			elif distance < 6000:
				total_items = randi_range(1, 4);
				r2_chance = .25;
				r3_chance = .25;
			else:
				total_items = randi_range(1, 7);
				r2_chance = .35;
				r3_chance = .4;
			
			for i in total_items:
				var item:Item;
				var roll:float = randf_range(0, 1);
				if roll < r3_chance:
					item = Index.rarity_3_item_scenes.pick_random().instantiate();
				elif roll < r2_chance:
					item = Index.rarity_2_item_scenes.pick_random().instantiate();
				else:
					item = Index.rarity_1_item_scenes.pick_random().instantiate();
				inventory.add_item(item);
	
	var max_level:int = distance/500;
	if max_level < 1:
		max_level = 1;
	var min_level:int = max_level/3
	if min_level < 1:
		min_level = 1;


	var leader_base:FighterBase = Index.evolved_fighter_base_scenes.pick_random().instantiate();
	leader_unit.level = min(5, randi_range(min_level, max_level + 2));
	leader_unit.base = leader_base
	leader_unit.add_child(leader_base);
	roster.add_unit(leader_unit)
	if not is_inside_tree():
		leader_unit.update_stats()


	var party_size: = randi_range(int(distance/800), int(distance/400));
	for i:int in party_size:
		var level:int = randi_range(min_level, max_level);
		var bases:Array[PackedScene] = Index.basic_fighter_base_scenes;
		if level >= 10:
			bases.append_array(Index.evolved_fighter_base_scenes);
		
		var unit_base:FighterBase = bases.pick_random().instantiate();
		var new_unit:FighterUnit = Index.fighter_unit_scene.instantiate();
		
		new_unit.level = level

		new_unit.add_child(unit_base)
		new_unit.base = unit_base;
		new_unit.update_stats();
		
		roster.add_unit(new_unit)
