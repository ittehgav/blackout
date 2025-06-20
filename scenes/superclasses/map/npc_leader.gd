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
			inventory.sort_items();
		"thugs":
			var total_items:int;
			var r2_chance:float;
			var r3_chance:float;
			if distance < 2000:
				total_items = randi_range(1, 2);
				r2_chance = .18
				r3_chance = .02;
			elif distance < 4000:
				total_items = randi_range(2, 4);
				r2_chance = .25;
				r3_chance = .5;
			else:
				total_items = randi_range(3, 7);
				r2_chance = .4;
				r3_chance = .3;
			
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

	var max_level:int = distance/80;
	if max_level < 1:
		max_level = 1;
	var min_level:int = max_level/2
	if min_level < 1:
		min_level = 1;


	var leader_base:FighterBase = Index.random_fighter_base()
	leader_unit.level = randi_range(min_level, max_level + 2);
	leader_unit.base = leader_base
	leader_unit.add_child(leader_base);
	if not is_inside_tree():
		leader_unit.update_stats()


	var party_size: = int(distance/100);
	for i:int in party_size:
		var unit_base:FighterBase = Index.random_fighter_base();
		var new_unit:FighterUnit = Index.fighter_unit_scene.instantiate();
		new_unit.level = randi_range(min_level, max_level);
		new_unit.add_child(unit_base)
		new_unit.base = unit_base;
		
		roster.add_unit(new_unit)
