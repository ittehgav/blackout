extends Control

@export var player_sample:SpriteSample;

@export var main_weapon_sample:TextureRect;
@export var main_weapon_sample_bg:ColorRect;
@export var main_weapon_tooltip:Tooltip;

@export var alt_weapon_label:Label;
@export var alt_weapon_sample:TextureRect;
@export var alt_weapon_sample_bg:ColorRect;
@export var alt_weapon_tooltip:Tooltip;

@export var module_sample:TextureRect;
@export var module_sample_bg:ColorRect;
@export var module_tooltip:Tooltip;

var current_tween:Tween;
var first_refresh:bool=true;
var first_alt_refresh:bool=true;


func refresh_samples(just_changed:Equipment=null)->void:
	var gear_color:Color = Index.color_schemes[Entities.player.color_scheme_index][1]
	
	var main_weapon_to_sample:Weapon = Entities.player.equipped_weapon;
	main_weapon_sample.texture = main_weapon_to_sample.texture;
	main_weapon_sample.custom_minimum_size = main_weapon_to_sample.texture.get_image().get_size() * 2
	main_weapon_sample.material.set_shader_parameter("base_color", gear_color);
	main_weapon_sample_bg.color = gear_color.lightened(.5)
	
	main_weapon_tooltip.target = main_weapon_to_sample;
	main_weapon_tooltip.setup(first_refresh);
	main_weapon_tooltip.hint.hide()
	
	if Entities.player.alternative_weapon:
		## TODO make alt weapon unequippable
		alt_weapon_label.show();
		alt_weapon_sample.show();
		alt_weapon_sample_bg.show();
		
		var alt_weapon_to_sample:Weapon = Entities.player.alternative_weapon;
		alt_weapon_sample.texture = alt_weapon_to_sample.texture;
		alt_weapon_sample.custom_minimum_size = alt_weapon_to_sample.texture.get_image().get_size() * 2;
		alt_weapon_sample.size = alt_weapon_to_sample.texture.get_image().get_size();
		alt_weapon_sample.material.set_shader_parameter("base_color", gear_color);
		alt_weapon_sample_bg.color = gear_color.lightened(.5);
		
		alt_weapon_tooltip.target = Entities.player.alternative_weapon
		alt_weapon_tooltip.setup(first_alt_refresh);
		alt_weapon_tooltip.hint.hide();
		first_alt_refresh = false
	else:
		alt_weapon_label.hide()
		alt_weapon_sample.hide();
		alt_weapon_sample_bg.hide();
		
	var module_to_sample:Module = Entities.player.equipped_module;
	module_sample.texture = module_to_sample.texture;
	

	module_sample.material.set_shader_parameter("base_color", gear_color);
	module_sample_bg.color = gear_color.lightened(.5)
	
	module_tooltip.target = module_to_sample;
	module_tooltip.setup(first_refresh);
	
	if just_changed and (not current_tween or not current_tween.is_running()):
		var target_sample:TextureRect;
		
		if just_changed == Entities.player.equipped_weapon:
			target_sample = main_weapon_sample;
		elif just_changed == Entities.player.alternative_weapon:
			target_sample = alt_weapon_sample
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

	first_refresh=false;

func _on_inventory_display_extension_shown() -> void:
	hide()

func _on_inventory_display_extension_hidden() -> void:
	show();
