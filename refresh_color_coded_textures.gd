@tool
extends Node

@export var all_fighter_bases:Array[PackedScene]

@export var value: int:
	set(v):
		value = v
		generate_textures()

func generate_textures()->void:
	## RUNS AS TOOL ONLY
	for scene:PackedScene in all_fighter_bases:
		var base:FighterBase = scene.instantiate();
		assert(base.hue_shifter);
		
		base.hue_shifter.target_texture = base.texture;
		base.hue_shifter.base_name = base.name.to_snake_case();
		base.hue_shifter.generate_color_coded_sprites();
	
	
