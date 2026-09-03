@tool
extends Node2D

class_name FighterIndex

@export_tool_button("Refresh Index", "Reload") var refresh_index:= refresh_fighter_bases;


		

## fighter bases are only stored as index references outside of combat
@export var unit_bases_dir:String;
@export var monster_bases_dir:String
@export var boss_bases_dir:String;


## only need this for matching evolutions, no reason to fetch monster bases like this rn
@export var all_unit_bases:Dictionary[String, FighterBase];
@export var all_unit_base_scenes:Dictionary[String, PackedScene];

func refresh_fighter_bases()->void:
	var root:Node = get_tree().edited_scene_root
	all_unit_bases = {};
	all_unit_base_scenes = {}
	for c in get_children():
		if c is FighterBase:
			c.name = "a"
			c.queue_free();


	for dir:String in [unit_bases_dir, monster_bases_dir, boss_bases_dir]:
		var access:DirAccess = DirAccess.open(dir);
		for filename:String in access.get_files():
			var base_scene:PackedScene = load(dir + "/" + filename);
			var true_name:String = base_scene.get_state().get_node_name(0);
			
			var base:FighterBase = base_scene.instantiate();
			base.name = true_name;

			add_child(base);

			base.owner = root
			all_unit_bases[true_name] = base;
			all_unit_base_scenes[true_name] = base_scene;
	
	for key:String in all_unit_bases.keys():
		var base:FighterBase = all_unit_bases[key];

		if "evolution_names" in base:
			var evolutions:Array[FighterBase]
			for ev_name:String in base.evolution_names:
				evolutions.append(all_unit_bases[ev_name]);
			base.evolutions = evolutions;
