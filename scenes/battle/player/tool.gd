extends Node2D

@export var holder:ActiveFighter;
@export var body:FighterBase;

@export var weapon_cd:Timer;
@export var weapon_node:Weapon;
@export var weapon_sfx:AudioStreamPlayer

func _ready()->void:
	equip_weapon()


func _process(_delta:float)->void:
	if Input.is_action_pressed("use_weapon") and holder.stun_timer.is_stopped():
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
	weapon_sfx.play_sfx_by_key(weapon_node.use_sfx);
	weapon_cd.start()
	var hit:bool = weapon_node.use();
	if hit:
		weapon_sfx.play_hit_sfx_by_key(weapon_node.hit_sfx);

func equip_weapon()->void:
	## for now just auto equips the exported one but it's where it'll do so at the start of battle and
	## where it'll swap them mid-fight
	weapon_cd.wait_time = weapon_node.cooldown;
	ColorCoder.color_code_weapon(weapon_node)
	weapon_node.holder = holder;
	holder.attack = weapon_node.damage;
