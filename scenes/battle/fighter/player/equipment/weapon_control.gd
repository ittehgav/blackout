extends Node
class_name WeaponControl

## easier to keep the signals in the equipment node
@export var sfx:AudioStreamPlayer;
@export var equipment:EquipmentControl;
@export var artifice_control:ArtificeControl
@export var dust:Dust

@export var camera:PlayerCamera;

var weapon:Weapon;
var alternative_weapon:Weapon;

@export var weapon_cd:Timer;
@export var alt_weapon_cd:Timer;
@export var freeze_frame_timer:Timer;

var holding_continuous:bool=false

func _ready()->void:
	await equipment.holder.ready
	var player:Player = Entities.player;
	var equipped_weapon:Weapon = load_weapon(player.equipped_weapon);

	equip_weapon(equipped_weapon)
	refresh_weapon_cooldown(weapon);
	
	var alt_weapon:Weapon = player.alternative_weapon;
	if alt_weapon:
		alternative_weapon = load_weapon(alt_weapon);
		alternative_weapon.hide();
		alternative_weapon.set_process(false)
		refresh_weapon_cooldown(alternative_weapon)


func load_weapon(target:Weapon)->Weapon:
	var new_weapon:Weapon = target.duplicate()
	## was instantiating weapon from node scene path before 
	## dont remember why i changed it in the first place so might 
	## be a source of weapon bugs?/?
	if new_weapon.refinement_level >= 1:
		new_weapon.apply_r1();
	if new_weapon.refinement_level >= 2:
		new_weapon.apply_r2();
	if new_weapon.refinement_level == 3:
		new_weapon.apply_r3()
	
	## duplicate that behave the way i wish
	## duplicate use instantiation worked?
	new_weapon.display.setup(equipment.holder, new_weapon);

	new_weapon.z_index = 1;

	new_weapon.animation_player.animation_finished.connect(equipment.weapon_animation_finished.bind(new_weapon))
	if new_weapon.status:
		new_weapon.status.source = equipment.holder;

	
	new_weapon.use_parent_material = true;
	for p:CanvasItem in new_weapon.projections:
		p.hide()
	check_active_texture(new_weapon);

	equipment.weapon_anchor.add_child(new_weapon)


	new_weapon.self_modulate = new_weapon.get_mirror_color();
	
	if new_weapon.ammo_cost:
		new_weapon.ammo_consumed.connect(equipment.ammo_consumed.emit)
		new_weapon.ammo_ran_out.connect(equipment.ammo_ran_out.emit);

	if new_weapon.projectile:
		new_weapon.projectile.setup(equipment.holder)

	new_weapon.hit.connect(equipment.weapon_hit.emit.bind(new_weapon))
		
	return new_weapon



func _physics_process(_delta:float)->void:
	## disable processing in this node to override mouse click for artifices
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
	if weapon_cd.is_stopped() and not weapon.check_disabled() and not artifice_control.aiming:
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
		## TODO make this send some sort of error code when theres more ways weapons cam fumble
		equipment.weapon_fumbled.emit()


func release_weapon_command()->void:
	weapon.release()
	equipment.continuous_weapon_released.emit();
	weapon_cd.start()
	holding_continuous = false


func use_weapon(alt:bool)->void:
	if weapon.pending_impact:
		## to make sure all hits get in with high atk speeds
		## catches animation overlaps
		weapon.impact()
	
	weapon.use(alt)
	play_weapon_vfx()
	equipment.weapon_used.emit()


func play_feedback(which:WeaponDisplay.PlayerScreenFeedback)->void:
	assert(which != -1);
	const feedback = WeaponDisplay.PlayerScreenFeedback;
	var player_fighter:PlayerFighter = Entities.player_fighter
	
	match which:
		feedback.lunge:
			var dust_direction:Vector2 = Vector2(-1, -.5);
			if player_fighter.global_position.x > player_fighter.get_global_mouse_position().x:
				dust_direction.x = 1
			camera.camera_vfx(PlayerCamera.TransformVFX.lunge, 1)
			dust.dust_animation(dust_direction)

		feedback.recoil:
			var dust_direction:Vector2 = Vector2(-1, -.5);
			if player_fighter.global_position.x < player_fighter.get_global_mouse_position().x:
				dust_direction.x = -1
			else:
				dust_direction.x = 1
			camera.camera_vfx(PlayerCamera.TransformVFX.recoil, 1)
			dust.dust_animation(dust_direction)
		
		feedback.freeze_frame:
			Engine.time_scale = 0
			freeze_frame_timer.start()
		
		feedback.shake:
			camera.camera_vfx(PlayerCamera.TransformVFX.shake, 3)
	

func weapon_hit(target:Weapon)->void:
	play_feedback(target.display.hit_feedback)

func play_weapon_vfx()->void:
	play_feedback(weapon.display.use_feedback)


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
	weapon.display.set_process_mode(Node.PROCESS_MODE_INHERIT);
	
	if weapon.hit_scan:
		## idk sometimes it doesnt keep its position properly
		weapon.hit_scan.reparent(equipment.hitbox_anchor)
		weapon.hit_scan.show()
	
	for p:CanvasItem in to_equip.projections:
		p.show()

	var modifier:ItemModifier = weapon.applied_modifier
	if modifier and modifier.stat_modifiers:
		for stat:String in CombatStats.all_stats:
			if modifier.stat_modifiers[stat]:
				## feels like it's not this simple?
				equipment.holder.stat_modifiers[stat] += modifier.stat_modifiers[stat];
				equipment.holder.stat_changed.emit(stat)

	if modifier and modifier.stat_multipliers:
		for stat:String in CombatStats.all_stats:
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
	current_weapon.display.set_process_mode(PROCESS_MODE_DISABLED)
	
	for p:CanvasItem in current_weapon.projections:
		p.hide()



	var modifier:ItemModifier = current_weapon.applied_modifier
	if modifier and modifier.stat_modifiers:
		for stat:String in CombatStats.all_stats:
			equipment.holder.in_battle_stat_modifiers[stat] -= modifier.stat_modifiers[stat];
	
	current_weapon.unequipped.emit();
	
	equip_weapon(alternative_weapon, true);

	var main_weapon_cd_left:float = weapon_cd.time_left;
	var alt_weapon_cd_left:float = alt_weapon_cd.time_left;
	
	alternative_weapon = current_weapon;
	equipment.alt_weapon  = alternative_weapon; ## sending these to equipment node to make accessing cleaner

	
	refresh_weapon_cooldown(weapon, alt_weapon_cd_left);
	refresh_weapon_cooldown(alternative_weapon, main_weapon_cd_left)

	## weapon variable is already equipped weapon as this is emmtied
	equipment.weapon_unequipped.emit(alternative_weapon)
	equipment.weapon_equipped.emit(weapon);
	equipment.weapon_changed.emit();
	if Input.is_action_pressed("use_weapon"):
		use_weapon_command();
	elif Input.is_action_pressed("weapon_alt"):
		use_weapon_command(true)
	


func refresh_weapon_cooldown(target_weapon:Weapon, time_left:float=0.0)->void:
	var new_wait_time:float = target_weapon.cooldown - CombatStats.agility_cooldown_reduction(target_weapon.cooldown, equipment.holder.agility);	
	var timer:Timer = weapon_cd
	if target_weapon == alternative_weapon:
		timer = alt_weapon_cd
	timer.stop()
	if time_left:
		timer.start(time_left);
	timer.wait_time = new_wait_time
