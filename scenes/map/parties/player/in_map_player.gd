extends MapParty

class_name InMapPlayer;

@export var camera:Camera2D;

var morale:float;


func _ready()->void:
	Entities.in_map_player = self;
	target_position = position;

func _input(e:InputEvent)->void:
	if e is InputEventMouseButton and e.is_pressed() \
	and e.button_index==MOUSE_BUTTON_LEFT:
		target_position = Entities.world_map.get_local_mouse_position();
		if not camera.in_player:
			target_position += camera.position - position;
		started_moving.emit();

	if camera.in_player:
		var camera_direction:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if camera_direction and camera.in_player:
			camera.free_panning()
			
			

func _physics_process(delta: float) -> void:
	if not target_entity:
		if target_position != position:
			var gap:Vector2 = target_position - position
			if abs(gap) < Vector2(2.5, 2.5):
				stop_movement();
			else:
				var direction:Vector2 = gap.normalized();
				var movement:Vector2 = direction * move_speed * delta
				var collision:KinematicCollision2D = move_and_collide(movement)
				if collision:
					target_position = position
					stop_movement();
					interact_with_map_entity(collision.get_collider());
					

func stop_movement(finish:bool =true)->void:
	if finish:
		position = target_position;
	else:
		target_position = position
	stopped_moving.emit()

func interact_with_map_entity(entity:MapEntity)->void:
	if entity is Settlement:
		Entities.current_settlement = entity;
		Entities.world_map.ui.settlement_ui.settlement_entered.emit(entity)
		#Entities.ui_sfx.play_stream_by_key("settlement_entered")

	elif entity is MapParty:
		Entities.current_speaking_party = entity;
		Entities.world_map.ui.settlement_ui.settlement_left.emit(entity)
		Entities.dialogue_player.start_dialogue(entity.leader.dialogue)


func _on_started_moving() -> void:
	get_tree().paused = false;
	camera.return_to_player()


func _on_stopped_moving() -> void:
	get_tree().paused = true;
