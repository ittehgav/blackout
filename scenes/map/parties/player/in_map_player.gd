extends MapParty

class_name InMapPlayer;

@export var camera:Camera2D;

@export var sight_shape:CollisionShape2D;



func _ready()->void:
	Entities.in_map_player = self;
	target_position = position;

func _input(e:InputEvent)->void:
	if e is InputEventMouseButton and e.is_pressed() \
	and e.button_index==MOUSE_BUTTON_LEFT:
		var cursor_position:Vector2 = Entities.world_map.get_local_mouse_position()
		if position.distance_to(cursor_position) > 30:
			if Entities.map_entity_under_mouse:
				move_toward_entity();
			else: 
				target_position = cursor_position
			if not camera.in_player:
				target_position += camera.position - position;
			

			started_moving.emit();



	if camera.in_player:
		var camera_direction:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if camera_direction and camera.in_player:
			camera.free_panning()
			
func move_toward_entity():
	target_entity = Entities.map_entity_under_mouse
	target_position = target_entity.position;
	
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true);
	
	target_entity.set_collision_layer_value(1, false)
	target_entity.set_collision_layer_value(2, true)

	
func _physics_process(delta: float) -> void:
	if target_position != position:
		if position.distance_to(target_position) < 2.5:
			stop_movement();
		else:
			var gap:Vector2 = (target_position - position).normalized()
			var movement = gap * move_speed * delta;
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

	elif entity is MapParty:
		Entities.current_speaking_party = entity;
		Entities.world_map.ui.settlement_ui.settlement_left.emit(entity)
		Entities.dialogue_player.start_dialogue(entity.leader.dialogue)


func _on_started_moving() -> void:
	get_tree().paused = false;
	camera.return_to_player()



func _on_stopped_moving() -> void:
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, false)
	
	if target_entity:
		target_entity.set_collision_layer_value(2, false)
		target_entity.set_collision_layer_value(1, true)
		target_entity = null;
	get_tree().paused = true;


func _on_sight_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	print("erm")


func _on_sight_area_entered(area: Area2D) -> void:
	print("ermarea")


func _on_sight_body_entered(body: Node2D) -> void:
	print(body)
