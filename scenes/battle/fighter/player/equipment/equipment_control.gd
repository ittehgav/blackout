extends Node2D

class_name EquipmentControl;
## giving these class names because they'll be used 
## for fetching very specific stuff from the global scope

signal weapon_changed

signal weapon_used;
signal weapon_fumbled
signal weapon_hit
## propagates from the weapon nodes so i can connect them via editor

signal continuous_weapon_started;
signal continuous_weapon_released;

signal weapon_equipped(weapon:Weapon);
signal weapon_unequipped(weapon:Weapon)

signal ammo_consumed(ammo_type:String, amount:int);
signal ammo_ran_out(ammo_type:String)

signal module_used
signal module_fumbled

signal continuous_module_started;
signal continuous_module_released;

@export var weapon_control:WeaponControl
@export var module_control:ModuleControl;
## right now just to be able to access the 
## variables in that script from global scope


@export var holder:ActiveFighter;
@export var body:FighterBase;

var equipped_weapon:Weapon;
var alt_weapon:Weapon;

@export var freeze_frame_timer:Timer;


func _process(_delta:float)->void:
	look_at(get_global_mouse_position())
	## some weapons may not rotate with the cursor

func _on_freeze_frame_control_timeout() -> void:
	## may be used by weapons and modules?
	Engine.time_scale = 1;


func _on_weapon_equipped(weapon: Weapon) -> void:
	## just to encapsulate the weapon to the other script some more
	## and leave this as more of a signal emitter and anchor for the weapon sprite
	equipped_weapon = weapon;


func refresh_weapon_cooldowns()->void:
	weapon_control.refresh_weapon_cooldown();
	var player:Player = get_tree().get_first_node_in_group("player")
	if player.alternative_weapon:
		weapon_control.refresh_alt_weapon_cooldown()
