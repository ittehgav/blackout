extends Control

@export var player_sample:SpriteSample;

@export var weapon_sample:TextureRect;
@export var weapon_sample_bg:ColorRect;

@export var module_sample:TextureRect;
@export var module_sample_bg:ColorRect;

var current_tween:Tween;
	
func refresh_samples(just_changed:Equipment=null)->void:
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
	
	if just_changed and (not current_tween or not current_tween.is_running()):
		var target_sample:TextureRect;
		
		if just_changed is Weapon:
			target_sample = weapon_sample;
		elif just_changed is Module:
			target_sample = module_sample

		var original_color:Color = target_sample.material.get_shader_parameter("base_color");
		target_sample.material.set_shader_parameter("base_color", Color.WHITE)
		
		var bg:ColorRect = target_sample.get_node("bg");
		var original_alpha:float = bg.modulate.a
		bg.modulate = Color.WHITE

		
		const tween_duration = .5
		current_tween = create_tween();

		current_tween.tween_property(target_sample.material, "shader_parameter/base_color", original_color, tween_duration)
		current_tween.parallel().tween_property(bg, "modulate:a", original_alpha, tween_duration)

func _on_inventory_display_extension_shown() -> void:
	hide()

func _on_inventory_display_extension_hidden() -> void:
	show();
