extends Node2D

signal weapon_used;
signal weapon_equipped(weapon:Weapon);
signal module_used

@export var holder:ActiveFighter;
@export var body:FighterBase;

@export var hit_scan_shape:CollisionShape2D;

var weapon:Weapon;
@export var weapon_cd:Timer;
@export var weapon_sfx:SfxPlayer;

@export var alternative_weapon:Weapon;

var module:Module;
@export var module_cd:Timer;
@export var module_sfx:SfxPlayer

@export var freeze_frame_timer:Timer;


var current_float_tween:Tween;

func _ready()->void:
	var equipped_weapon:Weapon = Entities.player.equipped_weapon.duplicate()
	add_child(equipped_weapon);
	equip_weapon(equipped_weapon)
	
	ColorCoder.color_code_weapon(equipped_weapon, Entities.player.color_scheme_index)
	var alt_weapon:Weapon = Entities.player.alternative_weapon;
	if alt_weapon:
		alternative_weapon = alt_weapon.duplicate();
		ColorCoder.color_code_weapon(alternative_weapon, Entities.player.color_scheme_index)
		add_child(alternative_weapon);
		alternative_weapon.hide();
	
	module = Entities.player.equipped_module;
	module_cd.wait_time = module.cooldown;
	

func _process(_delta:float)->void:
	if Input.is_action_pressed("use_weapon") and not holder.stunned:
		weapon_input();
	look_at(get_global_mouse_position())
	if body.flip_h:
		rotation_degrees += 180 - weapon.angle_adjust;
		scale.x = -1;
	else:
		rotation_degrees += weapon.angle_adjust;
		scale.x = 1

	if Input.is_action_just_pressed("use_module"):
		module_input();
		
	if Input.is_action_just_pressed("switch_weapon") and alternative_weapon and ("active" not in weapon or not weapon.active):
		switch_weapon();
	
	if Input.is_action_just_pressed("weapon_alt") and "alt_use" in weapon:
		## for now it's fine but maybe some alt uses will send the weapon to cooldown?
		weapon.alt_use();



func module_input()->void:
	if module_cd.is_stopped():
		module_sfx.play_sound_by_key(module.sfx_key)
		module.use();
		module_cd.start();
		module_used.emit();



func weapon_input()->void:
	if weapon_cd.is_stopped():
		use_weapon()
		

func use_weapon()->void:
	if weapon.use_sfx:
		weapon_sfx.play_weapon_sfx(weapon.use_sfx);

	play_weapon_vfx()
	if not "not_continuous" in weapon:
		weapon_cd.start()
	else:
		weapon.effect_finished.connect(weapon_cd.start, ConnectFlags.CONNECT_ONE_SHOT);
	
	var hit:bool = weapon.use();
	if hit:
		if "hit_vfx" in weapon:
			play_weapon_hit_vfx();
		weapon_sfx.play_hit_sfx(weapon.hit_sfx);
	weapon_used.emit()

func play_weapon_vfx()->void:
	for key:String in weapon.use_vfx:
		match key:
			"swing":
				Tweens.swing_tween(weapon);
			"arc":
				Tweens.arc_vfx(weapon.arc);
			"camera_lunge":
				Tweens.camera_lunge(Entities.in_fight_player)
			"gun_recoil":
				Tweens.gun_recoil(weapon)
			"shake":
				Tweens.weapon_shake(weapon);
			"grow":
				Tweens.weapon_grow(weapon);

func play_weapon_hit_vfx()->void:
	for vfx:String in weapon.hit_vfx:
		match vfx:
			"freeze_camera":
				Engine.time_scale = 0
				freeze_frame_timer.start()

func switch_weapon()->void:
	var current_weapon:Weapon = weapon;
	current_weapon.hide()
	equip_weapon(alternative_weapon);
	alternative_weapon = current_weapon;
	
	weapon_equipped.emit(weapon);
	current_weapon.unequipped.emit();
	weapon.equipped.emit()
	
func equip_weapon(to_equip:Weapon)->void:
	## for now just auto equips the exported one but it's where it'll do so at the start of battle and
	## where it'll swap them mid-fight
	## both weapons will be children of thsi node
		
	to_equip.show()
	weapon = to_equip;
	
	if "aoe_radius" in weapon:
		hit_scan_shape.shape = CircleShape2D.new();
		hit_scan_shape.shape.radius = weapon.aoe_radius;
		
	holder.hit_scan.follow_cursor = false;
	hit_scan_shape.position = Vector2.ZERO;
	holder.hit_scan.position = Vector2.ZERO;
	if "hit_scan_offset" in weapon:
		if weapon.hit_scan_offset is Vector2:
			hit_scan_shape.position = weapon.hit_scan_offset;
		elif weapon.hit_scan_offset == "follow_cursor":
			holder.hit_scan.follow_cursor = true;

	
	var remaining_time_left:float = weapon_cd.time_left;
	weapon_cd.wait_time = weapon.cooldown;
	if remaining_time_left:
		weapon_cd.start(remaining_time_left)
		weapon_cd.timeout.connect(readjust_wait_time, ConnectFlags.CONNECT_ONE_SHOT);
	else:
		weapon_cd.stop();
		
	holder.attack = weapon.damage;
	
func readjust_wait_time()->void:
	weapon_cd.wait_time = weapon.cooldown;


func _on_freeze_frame_control_timeout() -> void:
	Engine.time_scale = 1;
