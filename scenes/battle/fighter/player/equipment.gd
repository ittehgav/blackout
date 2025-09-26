extends Node2D

class_name EquipmentControl;
## giving these class names because they'll be used 
## for fetching very specific stuff from the global scope

signal weapon_changed
signal weapon_used;

signal continuous_weapon_started;
signal continuous_weapon_released;

signal weapon_equipped(weapon:Weapon);
signal weapon_unequipped(weapon:Weapon)

signal ammo_consumed(ammo_type:String, amount:int);

signal module_used
signal module_fumbled

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
	## some weapons may not rotate with the cursor?
	if body.flip_h:
		rotation_degrees += 180 - equipped_weapon.angle_adjust;
		scale.x = -1;
	else:
		rotation_degrees += equipped_weapon.angle_adjust;
		scale.x = 1


func _on_freeze_frame_control_timeout() -> void:
	## may be used by weapons and modules?
	Engine.time_scale = 1;


func _on_weapon_equipped(weapon: Weapon) -> void:
	## just to encapsulate the weapon to the other script some more
	## and leave this as more of a signal emitter and anchor for the weapon sprite
	equipped_weapon = weapon;
