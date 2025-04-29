extends Control

@export var player_sample:SpriteSample;

@export var weapon_sample:TextureRect;
@export var weapon_sample_bg:ColorRect;

@export var module_sample:TextureRect;
@export var module_sample_bg:ColorRect;

	
func refresh_samples()->void:
	var gear_color = Index.color_schemes[Entities.player.color_scheme_index][1]
	
	var weapon_to_sample:Weapon = Entities.player.equipped_weapon;
	weapon_sample.texture = weapon_to_sample.texture;
	weapon_sample.custom_minimum_size = weapon_to_sample.texture.get_image().get_size() * 2
	weapon_sample.material.set_shader_parameter("base_color", gear_color);
	weapon_sample_bg.color = gear_color.lightened(.5)
	
	var module_to_sample = Entities.player.equipped_module;
	module_sample.texture = module_to_sample.texture;
	module_sample.custom_minimum_size = module_to_sample.texture.get_image().get_size() * 2
	module_sample.material.set_shader_parameter("base_color", gear_color);
	module_sample_bg.color = gear_color.lightened(.5)
	
	
	
	
