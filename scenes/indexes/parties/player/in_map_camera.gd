extends Camera2D

var in_player:bool = true;

@export var world_map:WorldMap

@export var marker:Sprite2D;
var zoom_tween:Tween;


const move_speed = 300;



func free_panning()->void:
	position_smoothing_enabled = false
	reparent(Entities.world_map);
	in_player = false;

func return_to_player(instant:bool = false)->void:
	if not in_player:
		in_player = true;
		if not instant:
			var tween:Tween = create_tween();
			tween.set_trans(Tween.TRANS_CIRC)
			tween.tween_property(self, "position", Entities.in_map_player.position, .25);
			await tween.finished;
			reparent(Entities.in_map_player, true);
			global_position = Entities.in_map_player.global_position;
		else:
			reparent(Entities.in_map_player);
			global_position = Entities.in_map_player.global_position


func _process(delta: float) -> void:
	var direction:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	position += direction * delta * move_speed * 1/zoom.x;
	#
	#if Input.is_action_just_pressed("world_map_zoom_in") \
	#and zoom < Vector2(2, 2) and(not zoom_tween or not zoom_tween.is_running()):
		#zoom_tween= create_tween();
		#zoom_tween.tween_property(self, "zoom", zoom*2, 1);
	#elif Input.is_action_just_pressed("world_map_zoom_out")\
	 #and zoom > Vector2(.5, .5) and (not zoom_tween or not zoom_tween.is_running()):
		#zoom_tween = create_tween();
		#zoom_tween.tween_property(self, "zoom",zoom/2, 1);


func pan_to_target(target:MapEntity, add_marker:bool=false)->void:
	free_panning()
	var tween:Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_position", target.global_position, 2);
	
	if add_marker:
		await tween.finished
		marker.show_in_position(target.position);
		await get_tree().create_timer(.5).timeout;
		marker.modulate.a = 0;
		await get_tree().create_timer(.5).timeout;
		marker.modulate.a = 1;
		await get_tree().create_timer(.5).timeout;
		marker.modulate.a = 0;
		await get_tree().create_timer(.5).timeout;
		marker.modulate.a = 1;
	
