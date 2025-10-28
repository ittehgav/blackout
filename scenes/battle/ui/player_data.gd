extends Control

@export var equipment_node:Node2D;

@export var hp_bar:TextureProgressBar;
@export var shield_bar:TextureProgressBar;
@export var player:PlayerFighter;

@export var weapon_panel:PanelContainer;
@export var weapon_container:MarginContainer;
@export var weapon_cd_bg:ProgressBar
@export var weapon_cd_progress:TextureProgressBar;
@export var weapon_cd_timer:Timer;

@export var alternative_weapon_rect:TextureRect;
@export var alternative_weapon_panel:Panel;

@export var module_panel:Panel;
@export var module_progress_bar:TextureProgressBar;
@export var module_cd_timer:Timer;

var module_available:bool =true;

func _ready()->void:
	set_weapon_textures()
	var colors:Dictionary = player_color_scheme();
	var base_color:Color = Index.player_team_color;

	module_progress_bar.texture_progress = ColorCoder.color_code_texture(Entities.player.equipped_module.texture, colors);
	module_progress_bar.tint_under = base_color.lightened(.2) - Color(0, 0, 0, .8);
	module_progress_bar.max_value = module_cd_timer.wait_time;
	
	if not Entities.player.alternative_weapon:
		alternative_weapon_panel.hide();

	refresh_hp_bars()
	update_module_availability();

func update_module_availability()->void:
	module_available = equipment_node.module.check_available()
	if not module_available:
		module_panel.modulate.v = .1;

func _process(_delta: float) -> void:
	if not weapon_cd_timer.is_stopped():
		var progress:float = weapon_cd_timer.wait_time - weapon_cd_timer.time_left
		weapon_cd_bg.value = progress
		weapon_cd_progress.value = progress


	if not module_cd_timer.is_stopped():
		module_panel.modulate.v = .3
		var module_cd_progress:float = module_cd_timer.wait_time - module_cd_timer.time_left;
		module_progress_bar.value = module_cd_progress;

func player_color_scheme()->Dictionary:
	var base_color:Color = Index.player_team_color;
	var colors:= {
		Color.GREEN:base_color,
		Color.BLUE:base_color.darkened(.5)
	}
	return colors;

func set_weapon_textures()->void:
	weapon_cd_progress.max_value = weapon_cd_timer.wait_time;
	weapon_cd_bg.max_value = weapon_cd_timer.wait_time;

	var colors:Dictionary = player_color_scheme();
	var current_weapon:Weapon = equipment_node.weapon.duplicate();

	ColorCoder.color_code_weapon(current_weapon, Entities.player.color_scheme_index)
	
	weapon_cd_progress.texture_over = current_weapon.texture;

	weapon_cd_progress.max_value = weapon_cd_timer.wait_time;
	weapon_cd_bg.max_value = weapon_cd_timer.wait_time;
	
	weapon_cd_progress.texture_progress = ColorCoder.color_code_texture(current_weapon.texture, colors)
	
	var image:Image = current_weapon.texture.get_image()
	
	if image.get_width() > 32:
		image.rotate_90(COUNTERCLOCKWISE);
		weapon_cd_progress.texture_progress = ImageTexture.create_from_image(image);
		weapon_cd_progress.texture_over = ImageTexture.create_from_image(image);
	
	if equipment_node.alternative_weapon:
		var alt_weapon:Weapon = equipment_node.alternative_weapon;
		alternative_weapon_rect.texture = ColorCoder.color_code_texture(alt_weapon.texture, colors);


func _on_weapon_used() -> void:
	weapon_panel.modulate.v = .3;
	weapon_container.add_theme_constant_override("margin_top", -10)
	var tween:Tween = create_tween();
	tween.tween_property(weapon_container, "theme_override_constants/margin_top", 0, .25)


func _on_in_fight_player_status_applied(_source: ActiveFighter, data: Dictionary) -> void:
	if data.type == "stun":
		modulate = Color.PURPLE;



func _on_in_fight_player_status_removed(status_type: String, _data: Dictionary) -> void:
	if status_type == "stun" and not player.stun_stack:
		modulate = Color.WHITE;


func _on_weapon_cd_timeout() -> void:
	weapon_panel.modulate.v = 1;


func _on_module_cd_timeout() -> void:
	if module_available:
		module_panel.modulate.v = 1;


func _on_equipment_weapon_equipped(_weapon: Weapon) -> void:
	set_weapon_textures()

func _module_used() -> void:
	update_module_availability()


func _on_equipment_module_fumbled() -> void:
	Tweens.ui_fade_in(module_panel, .2);



func refresh_hp_bars()->void:
	var max_hp:int = Entities.player_fighter.max_hp;
	hp_bar.max_value = max_hp
	shield_bar.max_value = max_hp
	
	shield_bar.value = Entities.player_fighter.shield;
	hp_bar.value = Entities.player_fighter.hp;


func _on_in_fight_player_damage_blocked(_source: ActiveFighter, _value: float) -> void:
	refresh_hp_bars();
	Tweens.squish_bar(shield_bar);


func _on_in_fight_player_damage_taken(_damage: float, _source:ActiveFighter) -> void:
	refresh_hp_bars()
	
	Tweens.color_blink(hp_bar, Color.RED, .2,  "self_modulate");


func _on_in_fight_player_healing_received(_value: float) -> void:
	refresh_hp_bars();
	
	Tweens.color_blink(hp_bar, Color.GREEN, .2,"self_modulate");



func _on_in_fight_player_shield_gained(_source: ActiveFighter, _value: float) -> void:
	refresh_hp_bars();
	
	shield_bar.scale = Vector2(1.1, 1.5);
	Tweens.stretch_bar(shield_bar)
