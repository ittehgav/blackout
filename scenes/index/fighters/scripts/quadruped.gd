extends FighterBase

const after_dash_frame_y = 11

@export var sfx:SfxPlayer2D;
@export var dash_projection:Polygon2D;
## dash_projection.polygon[0] = tip of arrow projection
@export var dash_projection_animation:AnimationPlayer
@export var dash_hit_scan:Area2D; 
## will interact with CollisionScans rather than hurtboxes

@export var dash_impact_hit_scan:Area2D
## slightly wider than dash hit scan so it doesn't drag a unit across the map

@export var kicks_hit_scan:Area2D;

@export var stagger_status:Status

func full_skill_description(_unit:FighterUnit)->String:
	return ""


var acceleration:float = 1.0;
func skill_windup()->void:
	print("SKILL WINDUP ", Time.get_ticks_msec()/1000.0)
	
	start_dash_cycle()
	fighter.skill_disabled = true;
	stagger_status.source = fighter
	## just skip over the skill component and 
	## implement all of the behavior in this script
	## also when full override this only runs once and
	## just before the skill code start running which is nice
	
func start_dash_cycle()->void:
	print("START DASH CYCLE ", Time.get_ticks_msec()/1000.0, "\n")
	dash_miss_count = 0;
	start_dash_windup()

func start_dash_windup()->void:
	print("START DASH WINDUP ", Time.get_ticks_msec()/1000.0)
	
	var angle:float = fighter.position.angle_to_point(Entities.player_fighter.position)
	var sector:int = fighter.get_sector(angle);
	frame_coords.x = sector;
	
	dash_projection.rotation = angle;
	animation_player.play("dash_windup")
	adjust_projection = true
	start_projection_adjust();
	await animation_player.animation_finished;
	adjust_projection = false

var dash_tween:Tween;
var dash_miss_count:int;
func start_dash()->void:
	sfx.play_sound_by_key("dash_start")
	print("START DASH ", Time.get_ticks_msec()/1000.0)
	
	dash_hit_scan.monitoring = true;
	animation_player.play("run")
	var player_direction:Vector2 = fighter.position.direction_to(Entities.player_fighter.position)
	var move_target:Vector2 = fighter.global_position + player_direction * 1500;
	var overshoot := fighter.global_position + player_direction * 1800
	
	var dash_duration:float = 1.5/acceleration
	
	dash_tween = create_tween();
	dash_tween.tween_property(fighter, "global_position", move_target, dash_duration)
	dash_tween.tween_callback(missed_dash)
	dash_tween.set_trans(Tween.TRANS_CIRC);
	dash_tween.tween_property(fighter, "global_position", overshoot, dash_duration/3)
	
	dash_projection.self_modulate.a = .75;
	dash_projection.top_level = true;
	dash_projection.global_position = fighter.global_position
	var tween:= create_tween();
	tween.tween_property(dash_projection, "self_modulate:a", 0, dash_duration);
	await tween.finished;
	dash_projection.top_level = false
	dash_projection.position = Vector2.ZERO;

var adjust_projection:bool
func start_projection_adjust()->void:
	var angle_to_player:float = fighter.position.angle_to_point(Entities.player_fighter.position)
	dash_projection.rotation = angle_to_player;
	await get_tree().process_frame;
	if adjust_projection:
		start_projection_adjust()

func _on_dash_hit_scan_area_entered(area: Area2D) -> void:
	## dash hit scan is only ever monitoring during dash
	assert(area is CollisionScan);
	print("DASH HIT SCAN AREA ENTERED ", Time.get_ticks_msec()/1000.0)
	if area != fighter.collision_scan:
		sfx.play_sound_by_key("collision")
		print("NOT FIGHTER COLLISIONSC ", Time.get_ticks_msec()/1000.0)
		dash_hit_scan.set_monitoring.call_deferred(false)
		Combat.radial_knockback(fighter, dash_impact_hit_scan)
		Combat.aoe_damage(fighter, dash_impact_hit_scan)
		dash_tween.kill();
		start_kicks()

func missed_dash()->void:
	print("MISSED DASH ", Time.get_ticks_msec()/1000.0)
	dash_miss_count += 1
	dash_hit_scan.monitoring = false;
	animation_player.stop();

	var angle:float = fighter.global_position.angle_to_point(Entities.player_fighter.global_position)
	var sector:int = fighter.get_sector(angle);
	frame_coords.x = sector;
	
	frame_coords.y = after_dash_frame_y;

	if dash_miss_count < 3:
		start_dash_windup();
	else:
		start_stagger(10);


func start_kicks()->void:
	print("START KICKS ", Time.get_ticks_msec()/1000.0)
	kicks_hit_scan.monitoring = true;
	kicks_left = int(4 + (acceleration - 1)*10) ## make less based on how many charges were missed?
	start_kick(true)

var kicks_left:int;
func start_kick(first:bool=false)->void:
	print("START KICK ", Time.get_ticks_msec()/1000.0)
	if first:
		frame_coords.x = randi_range(0, 7)
	else:
		var roll:int = randi_range(0, 7);
		while roll == frame_coords.x:
			roll = randi_range(0, 7);
		frame_coords.x = roll
	
	var r:int = fighter.get_sector_angle(frame_coords.x, true);
	kicks_hit_scan.rotation_degrees = r;

	animation_player.play("kick")

func kick_impact()->void:
	print("KICK IMPACT ", kicks_left, Time.get_ticks_msec()/1000.0)
	Combat.aoe_damage(fighter, kicks_hit_scan, 100);
	Combat.aoe_knockback(fighter, kicks_hit_scan, 5);
	kicks_left -= 1;
	await animation_player.animation_finished;
	if kicks_left:
		start_kick();
	else:
		start_stagger(2 + dash_miss_count * 3);

func start_stagger(time:int=5)->void:
	print("START STAGGER ", Time.get_ticks_msec()/1000.0)
	sfx.play_sound_by_key("stagger")
	stagger_status.duration = time;
	if frame_coords.x == 0:
		if fighter.position.x < Entities.player_fighter.position.x:
			frame_coords.x = 1;
		else:
			frame_coords.x = 7;
	elif frame_coords.x == 4:
		if fighter.position.x < Entities.player_fighter.position.x:
			frame_coords.x = 3;
		else:
			frame_coords.x = 5;
	animation_player.play("stuck")
	stagger_status.duration = time;
	for s:Node in stagger_status.get_children():
		s.duration = time;
	var stagger:Status = stagger_status.apply_on_target(fighter);
	stagger.removed.connect(_on_stagger_removed)


func _on_stagger_removed()->void:
	print("STAGGER REMOVED ", Time.get_ticks_msec()/1000.0)
	acceleration += .1;
	start_dash_cycle()
