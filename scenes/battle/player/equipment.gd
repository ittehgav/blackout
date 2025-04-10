extends Node2D

signal used;

@export var holder:ActiveFighter;
@export var body:FighterBase;

@export var weapon_cd:Timer;
@export var weapon_node:Weapon;
@export var weapon_sfx:AudioStreamPlayer
@export var alternative_weapon:Weapon;

@export var module_node:Module;
@export var module_cd:Timer;



var current_float_tween:Tween;

func _ready():
	var equipped_weapon:Weapon = Entities.player.equipped_weapon.duplicate()
	add_child(equipped_weapon);
	equip_weapon(equipped_weapon)
	
	ColorCoder.color_code_weapon(equipped_weapon, Entities.player.color_scheme_index)
	var alternative_weapon:Weapon  = Entities.player.alternative_weapon;
	if alternative_weapon:
		ColorCoder.color_code_weapon(equipped_weapon, Entities.player.color_scheme_index)
		add_child(alternative_weapon.duplicate());
		alternative_weapon.hide();
	
	module_node = Entities.player.equipped_module;
	module_cd.wait_time = module_node.cooldown;
	

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
	if Input.is_action_just_pressed("use_module"):
		module_input();
		
		
func module_input():
	if module_cd.is_stopped():
		module_node.use();
		module_cd.start();



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
	
func switch_weapon()->void:
	var current_weapon = weapon_node;
	
	equip_weapon(alternative_weapon);
	alternative_weapon = current_weapon;
		

func equip_weapon(weapon:Weapon)->void:
	## for now just auto equips the exported one but it's where it'll do so at the start of battle and
	## where it'll swap them mid-fight
	## both weapons will be children of thsi node
	weapon_node = weapon;
	weapon_cd.wait_time = weapon_node.cooldown;
	
	weapon_node.holder = holder;
	holder.attack = weapon_node.damage;
