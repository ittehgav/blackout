@tool
extends Node

@export var refresh:bool:
	set(value):
		refresh = false;
		refresh_modifiers()
@export var modifiers_index_path:String;

@export var accessory_mods:Node;
@export var module_mods:Node;
@export var weapon_mods:Node;

func refresh_modifiers()->void:
	var root:= get_tree().edited_scene_root
	for type:String in ["accessory", "module", "weapon"]:
		var dir:String = modifiers_index_path  + type + "/";
		for tier:String in ["t1", "t2", "t3"]:
			var tier_node:Node = get_node(type+"/"+tier);
			for c:Node in tier_node.get_children():
				c.queue_free()

			var tier_dir:String = dir + tier;
			var access:DirAccess = DirAccess.open(tier_dir)
			
			for filename:String in access.get_files():
				var mod_scene:PackedScene = load(tier_dir+"/"+filename);
				var mod_name:String = mod_scene.get_state().get_node_name(0)
				var mod:ItemModifier = mod_scene.instantiate();
	
				
				tier_node.add_child(mod);
				mod.name = mod_name

				mod.owner = root;
			
			
	
	
