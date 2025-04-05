extends Control

@export var hp_bar:TextureProgressBar;
@export var player:InFightPlayer;

@export var weapon_container:MarginContainer;
@export var weapon_cd_bg:ProgressBar
@export var weapon_cd:TextureProgressBar;
@export var weapon_cd_timer:Timer;

func _ready():
	await Entities.arena.ready;
	var over := {
		Color.BLUE: Color.BLACK - Color(0, 0, 0, .4),
		Color.GREEN: Color.BLACK - Color(0, 0, 0, .4),
	}
	weapon_cd.texture_over = ColorCoder.color_code_texture(Entities.player.equipped_weapon.texture, over)
	
	var base_color:Color = Color.RED;
	var progress:= {
		Color.GREEN:base_color,
		Color.BLUE:base_color.darkened(.5)
	}
	weapon_cd.texture_progress = ColorCoder.color_code_texture(Entities.player.equipped_weapon.texture, progress)
	weapon_cd.max_value = weapon_cd_timer.wait_time;
	weapon_cd_bg.max_value = weapon_cd_timer.wait_time;
	hp_bar.max_value = player.max_hp;

func _process(delta: float) -> void:
	var weapon_cd_progress:float = weapon_cd_timer.wait_time - weapon_cd_timer.time_left
	weapon_cd_bg.value = weapon_cd_progress
	weapon_cd.value = weapon_cd_progress
	hp_bar.value = player.hp;
	


func _on_weapon_used() -> void:
	weapon_container.add_theme_constant_override("margin_top", -10)
	var tween = create_tween();
	tween.tween_property(weapon_container, "theme_override_constants/margin_top", 0, .25)
