extends Node2D

class_name EquipmentControl;
## giving these class names because they'll be used 
## for fetching very specific stuff from the global scope


signal weapon_changed

signal weapon_used;
signal weapon_fumbled
signal weapon_hit
## propagates from the weapon nodes so it's easier to connect them via editor

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


@export var holder:ActiveFighter;
@export var body:FighterBase;

var equipped_weapon:Weapon;
var alt_weapon:Weapon;

@export var hitbox_anchor:Node2D;
@export var freeze_frame_timer:Timer;
@export var attack_slow_timer:Timer;

@export var weapon_anchor:Node2D;
@export var right_hand:Sprite2D;
@export var left_hand:Sprite2D;



func _physics_process(_delta: float) -> void:
	hitbox_anchor.rotation = global_position.angle_to_point(get_global_mouse_position())


func _on_weapon_used() -> void:
	holder.action_force = .4;
	attack_slow_timer.start()



func _on_freeze_frame_control_timeout() -> void:
	## may be used by weapons and modules?
	Engine.time_scale = 1;


func _on_weapon_equipped(weapon: Weapon) -> void:
	## just to encapsulate the weapon to the other script some more
	## and leave this as more of a signal emitter and anchor for the weapon sprite
	equipped_weapon = weapon;
	
	weapon.attach_hands(right_hand, left_hand)

	
	weapon_anchor.rotation = 0;
	if weapon.size_x > 2 and weapon.size_y > 2:
		weapon_anchor.scale = Vector2.ONE
		right_hand.scale = Vector2.ONE;
		left_hand.scale = Vector2.ONE
		
	else:
		weapon_anchor.scale = Vector2(2, 2)
		right_hand.scale = Vector2(.5, .5)
		left_hand.scale = Vector2(.5, .5)


func refresh_weapon_cooldowns()->void:
	weapon_control.refresh_weapon_cooldown(weapon_control.weapon);
	if weapon_control.alternative_weapon:
		weapon_control.refresh_weapon_cooldown(weapon_control.alternative_weapon);


func weapon_animation_finished(anim_name:String, source:Weapon)->void:
	source.animation_player.play("RESET")
	
	var atk_key:String = source.get_animation_key("attack")
	var walk_key:String = source.get_animation_key("walk")
	var idle_key:String = source.get_animation_key("idle")
	
	if anim_name == atk_key:
		if holder.moving:
			source.animation_player.play(walk_key)
		else:
			source.animation_player.play(idle_key)

	source.display.weapon_animation_finished(anim_name)

	# set_process_input(not_attacking())

func not_attacking()->bool:
	## will return true when in knockback frame i spose
	var atk_key:String = equipped_weapon.get_animation_key("attack");
	
	var current:String = equipped_weapon.animation_player.current_animation
	
	return current != atk_key;


	
func _on_player_fighter_started_moving() -> void:
	if not_attacking():
		var walk_key:String = equipped_weapon.get_animation_key("walk")
		equipped_weapon.animation_player.play(walk_key)


func _on_player_fighter_stopped_moving() -> void:
	if not_attacking():
		var idle_key:String = equipped_weapon.get_animation_key("idle")
		equipped_weapon.animation_player.play(idle_key)

func _on_attack_slow_timeout() -> void:
	## controls player attack slowdown
	holder.action_force = 1;
