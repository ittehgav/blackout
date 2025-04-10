extends Control

@export var hp_bar:TextureProgressBar;
@export var player:InFightPlayer;

@export var weapon_container:MarginContainer;
@export var weapon_cd_bg:ProgressBar
@export var weapon_cd:TextureProgressBar;
@export var weapon_cd_timer:Timer;

@export var alternative_weapon:TextureRect;

@export var module_progress_bar:TextureProgressBar;
@export var module_cd_timer:Timer;

func _ready()->void:
	await Entities.arena.ready;
	var over := {
		Color.BLUE: Color.BLACK - Color(0, 0, 0, .4),
		Color.GREEN: Color.BLACK - Color(0, 0, 0, .4),
	}
	weapon_cd.texture_over = ColorCoder.color_code_texture(Entities.player.equipped_weapon.texture, over)
	
	var base_color:Color = Index.color_schemes[Entities.player.color_scheme_index][1];
	var colors:= {
		Color.GREEN:base_color,
		Color.BLUE:base_color.darkened(.5)
	}
	weapon_cd.texture_progress = ColorCoder.color_code_texture(Entities.player.equipped_weapon.texture, colors)
	weapon_cd.max_value = weapon_cd_timer.wait_time;
	weapon_cd_bg.max_value = weapon_cd_timer.wait_time;
	
	var alt_weapon:Weapon = Entities.player.alternative_weapon;
	if Entities.player.alternative_weapon:
		alternative_weapon.show();
		alternative_weapon.texture = ColorCoder.color_code_texture(alt_weapon.texture, colors)
	
	module_progress_bar.texture_progress = ColorCoder.color_code_texture(Entities.player.equipped_module.texture, colors);
	module_progress_bar.tint_under = base_color.lightened(.2);
	module_progress_bar.max_value = module_cd_timer.wait_time;

	hp_bar.max_value = player.max_hp;
	
	

func _process(_delta: float) -> void:
	var weapon_cd_progress:float = weapon_cd_timer.wait_time - weapon_cd_timer.time_left
	weapon_cd_bg.value = weapon_cd_progress
	weapon_cd.value = weapon_cd_progress
	
	hp_bar.value = player.hp;
	
	var module_cd_progress:float = module_cd_timer.wait_time - module_cd_timer.time_left;
	module_progress_bar.value = module_cd_progress;
	


func _on_weapon_used() -> void:
	weapon_container.add_theme_constant_override("margin_top", -10)
	var tween:Tween = create_tween();
	tween.tween_property(weapon_container, "theme_override_constants/margin_top", 0, .25)


func _on_in_fight_player_status_applied(_source: ActiveFighter, data: Dictionary) -> void:
	if data.type == "stun":
		modulate = Color.PURPLE;



func _on_in_fight_player_status_removed(status_type: String, _data: Dictionary) -> void:
	if status_type == "stun" and not player.stun_stack:
		modulate = Color.WHITE;
