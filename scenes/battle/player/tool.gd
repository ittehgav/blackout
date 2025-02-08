extends Node2D

@export var holder:ActiveFighter;
@export var body:FighterBase;

@export var weapon_cd:Timer;
@export var weapon_node:Weapon;
@export var weapon_sfx:AudioStreamPlayer

func _ready()->void:
	equip_weapon()

func _input(e:InputEvent)->void:
	if e.is_action_pressed("use_weapon") and holder.stun_timer.is_stopped():
		weapon_input();

func _process(_delta:float)->void:
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
		

func use_weapon():
	weapon_sfx.play_sfx_by_key(weapon_node.sfx);
	weapon_cd.start()
	weapon_node.use();

func equip_weapon()->void:
	## for now just auto equips the exported one but it's where it'll do so at the start of battle and
	## where it'll swap them mid-fight
	weapon_cd.wait_time = weapon_node.cooldown;
	ColorCoder.color_code_weapon(weapon_node)
	weapon_node.holder = holder;
	holder.attack = weapon_node.damage;
	

func weapon_use_held() -> void:
	if Input.is_action_pressed("use_weapon"):
		use_weapon();
