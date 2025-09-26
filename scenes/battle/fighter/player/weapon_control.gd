extends Node

class_name WeaponControl

## easier to keep the signals in the equipment node
@export var equipment:EquipmentControl
@export var sfx:AudioStreamPlayer;

var weapon:Weapon;
var alternative_weapon:Weapon;

@export var weapon_cd:Timer;
@export var alt_weapon_cd:Timer;
@export var freeze_frame_timer:Timer;

func _ready()->void:
	await equipment.holder.ready

	var equipped_weapon:Weapon = Entities.player.equipped_weapon.duplicate(DUPLICATE_USE_INSTANTIATION)
	equipped_weapon.use_parent_material = true
	check_active_texture(equipped_weapon);
	equipment.add_child(equipped_weapon);
	equip_weapon(equipped_weapon)
	if equipped_weapon.projectile:
		equipped_weapon.projectile.setup(equipment.holder)
		
	equipped_weapon.ammo_consumed.connect(equipment.ammo_consumed.emit)
		
	refresh_weapon_cooldown();
	var alt_weapon:Weapon = Entities.player.alternative_weapon;
	if alt_weapon:
		set_alt_weapon(alt_weapon);
		refresh_alt_weapon_cooldwon()
	


func _process(_delta:float)->void:
	if Input.is_action_just_pressed("use_weapon") and not equipment.holder.stunned:
		use_weapon_command()
	elif Input.is_action_just_pressed("weapon_alt") and not equipment.holder.stunned:
		use_weapon_command(true);
	if Input.is_action_just_pressed("switch_weapon") and alternative_weapon:
		switch_weapon();


func use_weapon_command(alt:bool=false)->void:
	## using alt in a weapon that doesn't have an alt use
	## just makes it fire the regular attack
	if weapon_cd.is_stopped() and not weapon.check_disabled():
		use_weapon(alt)
		weapon_cd.start() ## alt uses may have different cooldown?


func use_weapon(alt:bool)->void:
	equipment.holder.hit_targets.clear();
	weapon.use(alt)
	play_weapon_vfx()
	equipment.weapon_used.emit()


func weapon_hit()->void:
	match weapon.hit_feedback:
		"freeze_frame":
			Engine.time_scale = 0
			freeze_frame_timer.start()

func _on_weapon_cd_timeout() -> void:
	## so you can just hold the attack button
	## may not be doable for all weapons?
	if Input.is_action_pressed("use_weapon") and weapon_cd.is_stopped():
		use_weapon_command();
	elif Input.is_action_pressed("weapon_alt") and weapon_cd.is_stopped():
		use_weapon_command(true)


func check_active_texture(target:Weapon)->void:
	if target.active_texture:
		target.item_texture = target.texture
		target.texture = target.active_texture;

func set_alt_weapon(target:Weapon)->void:
	alternative_weapon = target.duplicate(DUPLICATE_USE_INSTANTIATION);
	if alternative_weapon.projectile:
		alternative_weapon.projectile.setup(equipment.holder);
		
	check_active_texture(alternative_weapon)
	equipment.add_child(alternative_weapon);
	alternative_weapon.set_process(false);
	alternative_weapon.hide();
	alternative_weapon.use_parent_material = true
	alternative_weapon.ammo_consumed.connect(equipment.ammo_consumed.emit)
	
	
func equip_weapon(to_equip:Weapon, from_switch:bool=false)->void:
	## decouple the refreshing one of these days?
	to_equip.show()
	weapon = to_equip;
	
	if weapon.hit_scan:
		weapon.hit_scan.reparent(equipment)
	to_equip.hit.connect(weapon_hit)
	
	

	var modifier:ItemModifier = weapon.applied_modifier
	if modifier and modifier.stat_modifiers:
		for stat:String in Index.all_combat_stats:
			if modifier.stat_modifiers[stat]:
				## feels like it's not this simple?
				equipment.holder.in_battle_stat_modifiers[stat] += modifier.stat_modifiers[stat];
				equipment.holder.stat_changed.emit(stat)
	weapon.equipped.emit()
	if not from_switch:
		## gotta emit this signal after changing the alternative_weapon property
		equipment.weapon_equipped.emit(weapon);
		
		
func switch_weapon()->void:
	var current_weapon:Weapon = weapon;
	current_weapon.hide()
	current_weapon.hit.disconnect(weapon_hit);
	if weapon.hit_scan:
		current_weapon.hit_scan.reparent(current_weapon)


	var modifier:ItemModifier = current_weapon.applied_modifier
	if modifier and modifier.stat_modifiers:
		for stat:String in Index.all_combat_stats:
			equipment.holder.in_battle_stat_modifiers[stat] -= modifier.stat_modifiers[stat];
	
	current_weapon.unequipped.emit();
	
	equip_weapon(alternative_weapon, true);
	
	var alt_weapon_cd_left:float = 0;
	var main_weapon_cd_left:float = 0;
	
	if not weapon_cd.is_stopped():
		main_weapon_cd_left = weapon_cd.time_left;
	if not alt_weapon_cd.is_stopped():
		alt_weapon_cd_left = alt_weapon_cd.time_left;

	
	alternative_weapon = current_weapon;
	equipment.alt_weapon  = alternative_weapon; ## sending these to equipment node to make accessing cleaner

	
	refresh_weapon_cooldown(alt_weapon_cd_left);
	refresh_alt_weapon_cooldwon(main_weapon_cd_left)

	## weapon variable is already equipped weapon as this is emmtied
	equipment.weapon_unequipped.emit(alternative_weapon)
	equipment.weapon_equipped.emit(weapon);
	equipment.weapon_changed.emit();
	

func play_weapon_vfx()->void:
	match weapon.use_feedback:
		"camera_lunge":
			Tweens.camera_lunge(Entities.player_fighter);
		"camera_recoil":
			Tweens.camera_recoil(Entities.player_fighter)


func refresh_weapon_cooldown(time_left:float=0.0)->void:
	weapon_cd.wait_time = weapon.cooldown - (weapon.cooldown/10)*equipment.holder.agility
	if time_left:
		var true_wait_time:float = weapon_cd.wait_time; 
		weapon_cd.start(time_left)
		weapon_cd.timeout.connect(weapon_cd.set_wait_time.bind(true_wait_time))


func refresh_alt_weapon_cooldwon(time_left:float=0.0)->void:
	alt_weapon_cd.wait_time = alternative_weapon.cooldown - (alternative_weapon.cooldown/10) * equipment.holder.agility
	if time_left:
		var true_wait_time:float = alt_weapon_cd.wait_time; 
		alt_weapon_cd.start(time_left);
		weapon_cd.timeout.connect(alt_weapon_cd.set_wait_time.bind(true_wait_time))
