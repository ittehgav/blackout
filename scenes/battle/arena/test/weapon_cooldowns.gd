extends PanelContainer

@export var equipment:EquipmentControl

@export var main_weapon_cd_timer:Timer;
@export var alt_weapon_cd_timer:Timer;

@export var cooldown_bar:TextureProgressBar;
@export var alt_cooldown_bar:TextureProgressBar;

var displaying_weapon:Weapon;
var displaying_alt_weapon:Weapon;

func _ready() -> void:
	display_weapon(Entities.player.equipped_weapon)
	display_alt_weapon(Entities.player.alternative_weapon)
	
	cooldown_bar.max_value = main_weapon_cd_timer.wait_time;
	alt_cooldown_bar.max_value = alt_weapon_cd_timer.wait_time;
	
func _process(_delta:float)->void:
	cooldown_bar.value = main_weapon_cd_timer.wait_time - main_weapon_cd_timer.time_left;
	alt_cooldown_bar.value = alt_weapon_cd_timer.wait_time - alt_weapon_cd_timer.time_left;

func display_weapon(target:Weapon)->void:
	displaying_weapon = target;
	load_weapon_to_bar(target, cooldown_bar);

func display_alt_weapon(target:Weapon)->void:
	displaying_alt_weapon = target;
	load_weapon_to_bar(target, alt_cooldown_bar, true);

func load_weapon_to_bar(weapon:Weapon, bar:TextureProgressBar, alt:bool=false)->void:
	var weapon_texture:Texture;
	if weapon.active_texture:
		weapon_texture = weapon.item_texture;
	else:
		weapon_texture = weapon.texture

	bar.texture_under = weapon_texture;
	bar.texture_progress = weapon_texture;
	
	var target_size:Vector2 = weapon_texture.get_size();
	if not alt:
		target_size *= 2
	
	bar.custom_minimum_size = target_size;
	bar.size = target_size;
	
	bar.tint_progress = weapon.get_mirror_color();

func _on_equipment_weapon_changed() -> void:
	display_weapon(equipment.equipped_weapon);
	display_alt_weapon(equipment.alt_weapon)

	cooldown_bar.max_value = main_weapon_cd_timer.wait_time;
	alt_cooldown_bar.max_value = alt_weapon_cd_timer.wait_time;

	check_weapon_disabled();
	
func check_weapon_disabled()->void:
	if equipment.equipped_weapon.check_disabled():
		cooldown_bar.modulate.a = .5;
		cooldown_bar.modulate.v = .5;
	else:
		cooldown_bar.modulate = Color.WHITE;
	
	if equipment.alt_weapon:
		if equipment.alt_weapon.check_disabled():
			alt_cooldown_bar.modulate.a = .5;
			alt_cooldown_bar.modulate.v = .5;
		else:
			alt_cooldown_bar.modulate = Color.WHITE
