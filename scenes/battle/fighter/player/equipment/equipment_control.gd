extends Node2D

class_name EquipmentControl;
## giving these class names because they'll be used 
## for fetching very specific stuff from the global scope

## ONLY NODE THAT CONTROLS EQUIPPED WEAPON TRANSFORM/OFFSET


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


func _input(e:InputEvent)->void:
	pass

func _on_weapon_used() -> void:
	pass # Replace with function body.

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


func weapon_animation_finished(anim_name:String, source:Weapon)->void:
	source.animation_player.play("RESET")
	
	var root_key:String = source.animation_root_key;
	var atk_key:String = root_key + "/attack";
	var after_atk_key:String = root_key + "/after_attack"
	if anim_name == atk_key:
		source.animation_player.play(after_atk_key)
	elif anim_name == after_atk_key:
		if holder.velocity:
			source.animation_player.play(root_key+"/walk")
		else:
			source.animation_player.play(root_key+"/idle")

func weapon_is_attacking(weapon:Weapon)->bool:
	var current_key:String = weapon.animation_player.current_animation;
	var atk_key:String = weapon.animation_root_key + "/attack"
	var after_atk_key:String = weapon.animation_root_key + "/after_attack"

	return current_key in [atk_key, after_atk_key]
	
func _on_player_fighter_started_moving() -> void:
	if not weapon_is_attacking(equipped_weapon):
		var walk_key:String = equipped_weapon.animation_root_key + "/walk"
		equipped_weapon.animation_player.play(walk_key)


func _on_player_fighter_stopped_moving() -> void:
	if not weapon_is_attacking(equipped_weapon):
		var idle_key:String = equipped_weapon.animation_root_key + "/idle"
		equipped_weapon.animation_player.play(idle_key)
