extends Node

@export_group("Unit Data")
@export var status_timers:HBoxContainer;
@export var status_bar:TextureProgressBar;
@export var cooldown_timer:Timer;

@export var unit:NpcFighter;
@export var floating_icon_anchor:Node2D;

@export_group("particle textures")
@export var hook_particle:Texture;
@export var overhead_particle:Texture;
@export var beam_particle:Texture;



func _on_npc_fighter_damage_taken(damage: float,source:ActiveFighter) -> void:
	var intensity:int=1;
	if damage > unit.max_hp/2:
		intensity = 3;
	elif damage > unit.max_hp/3:
		intensity = 2;
	
	if source is NpcFighter:
		Tweens.damage_vfx(unit, intensity)
	else:
		Tweens.damage_vfx(unit, intensity, true)

func _on_npc_fighter_healing_received(value: float) -> void:
	var heal_fraction:float = unit.max_hp/value;
	var transparency:float;
	if heal_fraction > .5:
		transparency = 0;
	elif heal_fraction > .3:
		transparency = .6
	else:
		transparency = .2
	
	Tweens.heal_vfx(unit, transparency)


func _on_npc_fighter_status_applied(_source: ActiveFighter, data: Dictionary) -> void:
	## VFX from statuses will be handled her
	var timer_bar:TextureProgressBar = status_bar.duplicate();
	match data.type:
		"stun":
			Tweens.stun_vfx(unit);
			timer_bar.modulate = Color.PURPLE
		"stat_change":
			var icon:StatIcon = Index.scenes.ui.stat_icon.instantiate();
			timer_bar.modulate = Index.stat_colors[data.stat]
			
			icon.stat = data.stat;
			icon.floating = true;
			floating_icon_anchor.add_child(icon);
			icon.global_position = floating_icon_anchor.global_position
			icon.panel.hide()
			if data.amount > 0:
				var tween: = create_tween();
				tween.tween_property(icon, "position:y", icon.position.y -30, .25);
				tween.tween_callback(icon.free)
			else:
				var tween: = create_tween();
				tween.tween_property(icon, "position:y", icon.position.y +30, .25);
				tween.tween_callback(icon.free)
	if data.duration:
		timer_bar.show()
		timer_bar.max_value = data.duration
		timer_bar.value = data.duration
		status_timers.add_child(timer_bar);
		var tween:= create_tween();
		tween.tween_property(timer_bar, "value", 0, data.duration);
		tween.tween_callback(timer_bar.queue_free)

func _on_npc_fighter_status_removed(status_type: String, _data: Dictionary) -> void:
	match status_type:
		"stun":
			pass

func particle_animation(key:String)->void:
	if key == "beam":
		var beam:Node2D = generate_beam();
		beam.modulate = Color.RED;
		beam.modulate.a = .6;
		unit.add_child(beam);
		
		var beam_tween: = create_tween();
		beam_tween.tween_property(beam, "modulate:a", 0, .5);
		beam_tween.tween_callback(beam.free);
		
		return
	
	var sprite: = Sprite2D.new();
	sprite.hframes = 3;
	sprite.scale = Vector2(3,3);
	sprite.z_index = 10
	sprite.modulate = Color.RED;
	sprite.modulate.v = .2
	sprite.modulate.a = .5
	sprite.texture = self[key+"_particle"];
	unit.add_child(sprite);
	sprite.global_position = unit.target_unit.global_position;
	sprite.flip_h = unit.global_position.x > unit.target_unit.global_position.x;
	
	var tween: = create_tween()
	tween.tween_property(sprite, "frame_coords:x", 2, .15);
	tween.tween_property(sprite, "modulate:a", 0, .1);
	tween.tween_callback(sprite.free);


func _on_windup_timer_timeout() -> void:
	if unit.ally_team.team_n == 2:
		for vfx:String in unit.base.projection_vfx:
			match vfx:
				"aoe_circle":
					aoe_circle_projection();
				"beam":
					beam_projection();
				"gravity":
					gravity_projection();
					
func beam_projection()->void:
	var beam:Node2D = generate_beam();
	beam.modulate = Color(.2, .2,.2, .2);
	unit.add_child(beam);
	beam.global_position = unit.global_position;

	projection_fade_in(beam);

	await unit.skill_used;
	if is_instance_valid(beam):
		beam.queue_free();
	
func gravity_projection()->void:
	var vfx:Node2D = Node2D.new();
	var sprite:Sprite2D = Sprite2D.new();
	sprite.texture = Index.textures.filled_circles[2];
	sprite.scale = Vector2(2, 2);
	sprite.modulate = Color.REBECCA_PURPLE - Color(.2, .2, .2, .7);
	vfx.add_child(sprite)
	
	unit.add_child(vfx);
	vfx.global_position = unit.target_unit.global_position;
	
	projection_fade_in(vfx);
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(vfx, "scale", Vector2(2, 2), 1);
	
	await unit.skill_used;
	if is_instance_valid(vfx):
		vfx.queue_free();
	

func aoe_circle_projection()->void:
	var rect: = TextureRect.new();
	
	var aoe_radius:int = unit.base.hit_scan_radius;
	
	if aoe_radius < 10:
		rect.texture = Index.textures.filled_circles[0]
	elif aoe_radius < 100:
		rect.texture = Index.textures.filled_circles[1];
	elif aoe_radius <= 300:
		rect.texture = Index.textures.filled_circles[2];
	else:
		rect.texture = Index.textures.filled_circles[3]
	rect.size = Vector2(aoe_radius, aoe_radius);
	var offset :float = aoe_radius / 2 * -1;
	rect.modulate = Color(.2, .2, .2, .2)
	
	projection_fade_in(rect)
	unit.add_child(rect);
	rect.global_position = unit.target_unit.global_position;
	rect.position += Vector2(offset,offset);
	await unit.skill_used;
	if is_instance_valid(rect):
		rect.queue_free()
	
func projection_fade_in(projection:CanvasItem)->void:
	if not is_instance_valid(projection):
		return;
	projection.modulate.a = .1
	var tween: = create_tween();
	tween.tween_property(projection, "modulate:a", 1, cooldown_timer.wait_time/6);
	unit.skill_attempted.connect(projection.queue_free, CONNECT_ONE_SHOT);


	

func generate_beam()->Node2D:
	## right now just generates it for crossbow guy but will be where other beams will be implemented 
	## once i need more versatile beams
	var beam:Node2D = Node2D.new();
	var beam_node_count:int = (unit.global_position.distance_to(unit.target_unit.global_position)/9)*2
	for i in beam_node_count:
		var sprite:Sprite2D = Sprite2D.new();
		sprite.scale *= 3;
		sprite.position.x = i * 9;
		sprite.texture = beam_particle;
		beam.add_child(sprite);
		
	beam.rotation = unit.global_position.angle_to_point(unit.target_unit.global_position)
	return beam;
