extends Node
class_name WeaponControl

## easier to keep the signals in the equipment node
@export var sfx:AudioStreamPlayer;
@export var equipment:EquipmentControl;

var weapon:Weapon;
var alternative_weapon:Weapon;

@export var weapon_cd:Timer;
@export var alt_weapon_cd:Timer;
@export var freeze_frame_timer:Timer;

var holding_continuous:bool=false

func _ready()->void:
	await equipment.holder.ready
	var player:Player = get_tree().get_first_node_in_group("player")
	var equipped_weapon:Weapon = load_weapon(player.equipped_weapon);

	equip_weapon(equipped_weapon)
	refresh_weapon_cooldown();
	
	var alt_weapon:Weapon = player.alternative_weapon;
	if alt_weapon:
		alternative_weapon = load_weapon(alt_weapon);
		alternative_weapon.hide();
		alternative_weapon.set_process(false)
		refresh_alt_weapon_cooldown()
		
func load_weapon(target:Weapon)->Weapon:
	var new_weapon:Weapon = target.duplicate(DUPLICATE_USE_INSTANTIATION)
	new_weapon.scale = Vector2(2, 2)
	new_weapon.animation_player.animation_finished.connect(equipment.weapon_animation_finished.bind(new_weapon))
	if new_weapon.status:
		new_weapon.status.source = equipment.holder;
	
	new_weapon.use_parent_material = true;
	for p:CanvasItem in new_weapon.projections:
		p.hide()
	check_active_texture(new_weapon);
	equipment.add_child(new_weapon)
	new_weapon.modulate = new_weapon.get_mirror_color();
	
	if new_weapon.ammo_type:
		new_weapon.ammo_consumed.connect(equipment.ammo_consumed.emit)
		new_weapon.ammo_ran_out.connect(equipment.ammo_ran_out.emit);

	if new_weapon.projectile:
		new_weapon.projectile.setup(equipment.holder)
	
	new_weapon.hit.connect(equipment.weapon_hit.emit)
	
	
		
	return new_weapon


func _process(_delta:float)->void:
	if Input.is_action_just_pressed("use_weapon") and not equipment.holder.stunned:
		use_weapon_command()
	elif Input.is_action_just_pressed("weapon_alt") and not equipment.holder.stunned:
		use_weapon_command(true);
	elif Input.is_action_just_released("use_weapon") and holding_continuous:
		release_weapon_command()
	if Input.is_action_just_pressed("switch_weapon") and alternative_weapon and not holding_continuous:
		switch_weapon();


func use_weapon_command(alt:bool=false)->void:
	## using alt in a weapon that doesn't have an alt use
	## just makes it fire the regular attack
	if weapon_cd.is_stopped() and not weapon.check_disabled():
		equipment.holder.hit_targets.clear();
		if not weapon.continuous:
			
			use_weapon(alt)
			weapon_cd.start() ## alt uses may have different cooldown?
		else:
			## for ticker weapon hits the hit_targets will be
			## cleared in the weapon's script
			weapon.start();
			holding_continuous = true
			equipment.continuous_weapon_started.emit()
	elif weapon.check_disabled():
		equipment.weapon_fumbled.emit()


func release_weapon_command()->void:
	weapon.release()
	equipment.continuous_weapon_released.emit();
	weapon_cd.start()
	holding_continuous = false


func use_weapon(alt:bool)->void:
	print("uwe?")
	if weapon.pending_impact:
		## to make sure all hits get in with high atk speeds
		## right now catches all animation overlaps
		weapon.impact()
		
	weapon.use(alt)
	play_weapon_vfx()
	equipment.weapon_used.emit()


func weapon_hit()->void:
	match weapon.hit_feedback:
		"freeze_frame":
			Engine.time_scale = 0
			freeze_frame_timer.start()
		"screen_shake":
			Tweens.camera_shake(Entities.player_fighter)

func play_weapon_vfx()->void:
	match weapon.use_feedback:
		"camera_lunge":
			Tweens.camera_lunge(Entities.player_fighter);
		"camera_recoil":
			Tweens.camera_recoil(Entities.player_fighter)

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


	
func equip_weapon(to_equip:Weapon, from_switch:bool=false)->void:
	## decouple the refreshing one of these days?
	to_equip.show()
	weapon = to_equip;
	
	if weapon.hit_scan:
		weapon.hit_scan.reparent(equipment)
		weapon.hit_scan.show()
	to_equip.hit.connect(weapon_hit)
	
	for p:CanvasItem in to_equip.projections:
		p.show()

	var modifier:ItemModifier = weapon.applied_modifier
	if modifier and modifier.stat_modifiers:
		for stat:String in Index.all_combat_stats:
			if modifier.stat_modifiers[stat]:
				## feels like it's not this simple?
				equipment.holder.stat_modifiers[stat] += modifier.stat_modifiers[stat];
				equipment.holder.stat_changed.emit(stat)

	if modifier and modifier.stat_multipliers:
		for stat:String in Index.all_combat_stats:
			if modifier.stat_multipliers[stat]:
				## feels like it's not this simple?
				equipment.holder.stat_multipliers[stat] += modifier.stat_multipliers[stat];
				equipment.holder.stat_changed.emit(stat)

	weapon.equipped.emit()
	if not from_switch:
		## gotta emit this signal after changing the alternative_weapon property
		equipment.weapon_equipped.emit(weapon);
		
		
func switch_weapon()->void:
	var current_weapon:Weapon = weapon;
	current_weapon.hide()

	
	for p:CanvasItem in current_weapon.projections:
		p.hide()
	if weapon.hit_scan:
		current_weapon.hit_scan.reparent(equipment)
	if weapon.alt_hit_scan:
		current_weapon.alt_hit_scan.reparent(equipment)


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

	
	refresh_weapon_cooldown(alt_weapon_cd_left, true);
	refresh_alt_weapon_cooldown(main_weapon_cd_left, true)

	## weapon variable is already equipped weapon as this is emmtied
	equipment.weapon_unequipped.emit(alternative_weapon)
	equipment.weapon_equipped.emit(weapon);
	equipment.weapon_changed.emit();
	



func refresh_weapon_cooldown(time_left:float=0.0, from_switch:bool=false)->void:
	## BUG not working properly with agility change statuses
	var new_wait_time:float = weapon.cooldown - Scaling.agility_cooldown_reduction(weapon.cooldown, equipment.holder.agility) 
	if from_switch:
		if time_left:
			## gets here from switching weapons
			weapon_cd.stop()
			weapon_cd.start(time_left)
			weapon_cd.timeout.connect(weapon_cd.set_wait_time.bind(new_wait_time), CONNECT_ONE_SHOT)
		else:
			weapon_cd.wait_time = new_wait_time

	elif not weapon_cd.is_stopped():
		time_left = weapon_cd.time_left
		
		var current_wait_time:float = weapon_cd.wait_time;
		var frac:float = new_wait_time/current_wait_time;
		var new_time_left:float = current_wait_time * frac
		weapon_cd.start(new_time_left);
		weapon_cd.timeout.connect(weapon_cd.set_wait_time.bind(new_wait_time), CONNECT_ONE_SHOT);
	else:
		weapon_cd.wait_time = new_wait_time
	

func refresh_alt_weapon_cooldown(time_left:float=0.0, from_switch:bool=false)->void:
	var new_wait_time:float = alternative_weapon.cooldown - Scaling.agility_cooldown_reduction(alternative_weapon.cooldown, equipment.holder.agility)
	if from_switch:
		if time_left:
			## gets here from switching weapons
			alt_weapon_cd.stop()
			alt_weapon_cd.start(time_left)
			alt_weapon_cd.timeout.connect(alt_weapon_cd.set_wait_time.bind(new_wait_time), CONNECT_ONE_SHOT)
		else:
			alt_weapon_cd.wait_time = new_wait_time

	elif not alt_weapon_cd.is_stopped():
		time_left = alt_weapon_cd.time_left
		
		var current_wait_time:float = alt_weapon_cd.wait_time;
		var frac:float = new_wait_time/current_wait_time;
		var new_time_left:float = current_wait_time * frac
		alt_weapon_cd.start(new_time_left);
		alt_weapon_cd.timeout.connect(alt_weapon_cd.set_wait_time.bind(new_wait_time), CONNECT_ONE_SHOT);
	else:
		alt_weapon_cd.wait_time = new_wait_time
