extends Camera2D

var in_player:bool = true;

@export var world_map:WorldMap

@export var marker:Sprite2D;
var zoom_tween:Tween;

@export var player:InMapPlayer;


const move_speed = 600;


func free_panning()->void:
	reparent(Entities.world_map);
	in_player = false;
	Entities.current_camera = self;

func return_to_player(instant:bool = false)->void:
	if not in_player:
		in_player = true;
		if not instant:
			var tween:Tween = create_tween();
			tween.set_ease(Tween.EASE_OUT);
			tween.set_trans(Tween.TRANS_QUAD)
			var duration:float = global_position.distance_to(player.global_position)/1000
			tween.tween_property(self, "global_position", player.global_position, duration);
			await tween.finished;
			reparent(player, true);
			position = Vector2.ZERO
		else:
			reparent(player);
			position = Vector2.ZERO


func _process(_delta: float) -> void:
	#var direction:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	#position += direction * delta * move_speed * 1/zoom.x;
	if Input.is_action_just_pressed("world_map_zoom_in") \
	and zoom < Vector2(2, 2) and(not zoom_tween or not zoom_tween.is_running()) and not Entities.world_map.pause_stack:
		zoom_tween= create_tween();
		zoom_tween.tween_property(self, "zoom", zoom*2, 1);
	elif Input.is_action_just_pressed("world_map_zoom_out")\
	 and zoom > Vector2(.5, .5) and (not zoom_tween or not zoom_tween.is_running()) and not Entities.world_map.pause_stack:
		zoom_tween = create_tween();
		zoom_tween.tween_property(self, "zoom",zoom/2, 1);


func pan_to_target(target:MapEntity, add_marker:bool=false)->void:
	set_process_mode(PROCESS_MODE_ALWAYS)
	free_panning()
	var tween:Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_position", target.global_position, 2);
	tween.tween_callback(set_process_mode.bind(PROCESS_MODE_INHERIT))
	
	if add_marker:
		await tween.finished
		marker.show_in_position(target.global_position);
		await get_tree().create_timer(.5).timeout;
		marker.modulate.a = 0;
		await get_tree().create_timer(.5).timeout;
		marker.modulate.a = 1;
		await get_tree().create_timer(.5).timeout;
		marker.modulate.a = 0;
		await get_tree().create_timer(.5).timeout;
		marker.modulate.a = 1;
	


func _on_world_map_returned_from_battle(_won: bool) -> void:
	Entities.current_camera = self
