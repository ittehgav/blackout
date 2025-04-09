extends Node2D

signal used;

@export var holder:ActiveFighter;
@export var body:FighterBase;

@export var weapon_cd:Timer;
@export var weapon_node:Weapon;
@export var weapon_sfx:AudioStreamPlayer

var current_float_tween:Tween;



func _process(_delta:float)->void:
	if Input.is_action_pressed("use_weapon") and not holder.stunned:
		weapon_input();
	const angle_adjust = 30;
	look_at(get_global_mouse_position())
	if body.flip_h:
		rotation_degrees += 180 - angle_adjust;
		scale.x = -1;
	else:
		rotation_degrees += angle_adjust;
		scale.x = 1


func weapon_input()->void:
	if weapon_cd.is_stopped():
		use_weapon()
		

func use_weapon()->void:
	weapon_sfx.play_sfx(weapon_node.use_sfx);
	weapon_cd.start()
	used.emit()
	var hit:bool = weapon_node.use();
	if hit:
		weapon_sfx.play_hit_sfx(weapon_node.hit_sfx);

func equip_weapon(weapon:Weapon)->void:
	## for now just auto equips the exported one but it's where it'll do so at the start of battle and
	## where it'll swap them mid-fight
	## both weapons will be children of thsi node
	weapon_node = weapon;
	weapon_cd.wait_time = weapon_node.cooldown;
	ColorCoder.color_code_weapon(weapon_node, Entities.player.color_scheme_index)
	weapon_node.holder = holder;
	holder.attack = weapon_node.damage;
