extends Control

@export var player_sample:SpriteSample;

@export var weapon_sample:TextureRect;
@export var weapon_sample_bg:ColorRect;

@export var module_sample:TextureRect;
@export var module_sample_bg:ColorRect;


	
func refresh_samples(animate_weapon:bool=false, animate_module:bool=false)->void:
	var gear_color:Color = Index.color_schemes[Entities.player.color_scheme_index][1]
	
	var weapon_to_sample:Weapon = Entities.player.equipped_weapon;
	weapon_sample.texture = weapon_to_sample.texture;
	weapon_sample.custom_minimum_size = weapon_to_sample.texture.get_image().get_size() * 2
	weapon_sample.material.set_shader_parameter("base_color", gear_color);
	weapon_sample_bg.color = gear_color.lightened(.5)
	
	var module_to_sample:Module = Entities.player.equipped_module;
	module_sample.texture = module_to_sample.texture;
	module_sample.custom_minimum_size = module_to_sample.texture.get_image().get_size() * 2
	module_sample.material.set_shader_parameter("base_color", gear_color);
	module_sample_bg.color = gear_color.lightened(.5)
	
	if animate_weapon:
		weapon_sample.modulate.a = .5
		var original_size:Vector2 = weapon_sample.custom_minimum_size;
		weapon_sample.custom_minimum_size = original_size * 1.5;
		var tween:Tween = create_tween();
		tween.tween_property(weapon_sample, "custom_minimum_size", original_size, .5)
		tween.parallel().tween_property(weapon_sample, "modulate:a", 1, .5)
	
	


func _on_inventory_display_extension_shown() -> void:
	hide()

func _on_inventory_display_extension_hidden() -> void:
	show();
