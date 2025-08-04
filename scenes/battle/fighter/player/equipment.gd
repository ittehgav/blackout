extends Node2D

signal weapon_changed
signal weapon_used;
signal weapon_equipped(weapon:Weapon);
signal module_used
signal module_fumbled

@export var module_projection:TextureRect;
@export var module_aoe_vfx:TextureRect;



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

var holding_module:bool;

@export var freeze_frame_timer:Timer;

var current_float_tween:Tween;

func _ready()->void:
	await holder.ready
	var equipped_weapon:Weapon = Entities.player.equipped_weapon.duplicate(DUPLICATE_USE_INSTANTIATION)
	add_child(equipped_weapon);
	equip_weapon(equipped_weapon)

	
	ColorCoder.color_code_weapon(equipped_weapon, Entities.player.color_scheme_index)
	var alt_weapon:Weapon = Entities.player.alternative_weapon;
	if alt_weapon:
		alternative_weapon = alt_weapon.duplicate(DUPLICATE_USE_INSTANTIATION);
		ColorCoder.color_code_weapon(alternative_weapon, Entities.player.color_scheme_index)
		add_child(alternative_weapon);
		alternative_weapon.hide();
	
	equip_module();


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
		
	if holding_module and Input.is_action_just_released("use_module"):
		release_module()
		
	if Input.is_action_just_pressed("switch_weapon") and alternative_weapon and ("active" not in weapon or not weapon.active):
		switch_weapon();
	
	if Input.is_action_just_pressed("weapon_alt") and "alt_use" in weapon:
		## for now it's fine but maybe some alt uses will send the weapon to cooldown?
		weapon.alt_use();
		weapon_sfx.play_sound_by_key(weapon.alt_use_sfx)


func equip_module()->void:
	module = Entities.player.equipped_module.duplicate(DUPLICATE_USE_INSTANTIATION);
	module.hide();
	
	add_child(module)
	module_cd.wait_time = module.cooldown;
	
	if module.custom_projection_texture:
		module_aoe_vfx.texture = module.custom_projection_texture
		module_aoe_vfx.size = Vector2(2, 2) * module.projection_range;
		module_aoe_vfx.modulate = module.projection_color
		module_aoe_vfx.position = Vector2(module.projection_range, module.projection_range) * -1;

	
	if module.projection_range:
		module_projection.show();
		module_projection.modulate = module.projection_color;
		module_projection.texture = Index.textures.hollow_circles[module.projection_texture_index];
	
		module_projection.size = Vector2(module.projection_range * 2, module.projection_range * 2);
		module_projection.position = Vector2(module.projection_range, module.projection_range) * -1;
		
		if module.show_aoe_vfx:
			module_aoe_vfx.texture = Index.textures.filled_circles[module.projection_texture_index];
			module_aoe_vfx.size = Vector2(2, 2) * module.projection_range
			module_aoe_vfx.modulate = module.projection_color;
			module_used.connect(play_module_aoe_vfx);
			module_aoe_vfx.position = Vector2(module.projection_range, module.projection_range) * -1;

	module.equipped.emit();


func module_input()->void:
	if module_cd.is_stopped() and module.check_available():
		module_sfx.play_sound_by_key(module.sfx_key)
		module.use();

		
		module_used.emit();
		if not "continuous" in module:
			module_cd.start();
		else:
			holding_module = true;
	else:
		module_fumbled.emit()
		module_sfx.play_sound_by_key("module_unavailable")

func play_module_aoe_vfx()->void:
	module_aoe_vfx.show();
	module_aoe_vfx.modulate.a = 1;
	var tween:Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(module_aoe_vfx, "modulate:a", 0, .5)
	

func release_module()->void:
	module_cd.start();
	module.release();
	holding_module = false;



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
		if weapon.has_finish:
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
				Tweens.camera_lunge(Entities.player_fighter)
			"camera_recoil":
				Tweens.camera_recoil(Entities.player_fighter)
			"gun_recoil":
				Tweens.gun_recoil(weapon)
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
	equip_weapon(alternative_weapon, false, false);
	alternative_weapon = current_weapon;
	## weapon variable is already equipped weapon as this is emmtied
	weapon_equipped.emit(weapon);
	weapon_changed.emit();
	
	current_weapon.refresh_request.disconnect(equip_weapon)
	current_weapon.unequipped.emit();
	
	
func equip_weapon(to_equip:Weapon, from_refresh:bool=false, from_switch:bool=false)->void:
	## decouple the refreshing one of these days?
		
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
	refresh_weapon_cooldown()
	if remaining_time_left:
		weapon_cd.start(remaining_time_left)
		weapon_cd.timeout.connect(refresh_weapon_cooldown, ConnectFlags.CONNECT_ONE_SHOT);
	else:
		weapon_cd.stop();
	
	if "base_damage" in weapon:
		holder.attack = weapon.base_damage + Entities.player_fighter.attack;
	else:
		holder.attack = 0;
	if not from_refresh:
		weapon.refresh_request.connect(equip_weapon.bind(weapon, false))
		weapon.equipped.emit()
	## surley this doesn't cause any rtouble?
	if not from_switch:
		## gotta emit this signal after changing the alternative_weapon property
		weapon_equipped.emit(weapon);
	
	
func refresh_weapon_cooldown()->void:
	weapon_cd.wait_time = weapon.cooldown - (weapon.cooldown/10)*holder.agility


func _on_freeze_frame_control_timeout() -> void:
	Engine.time_scale = 1;
