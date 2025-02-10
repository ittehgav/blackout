extends MapParty

class_name InMapPlayer;

@export var camera:Camera2D;
var move_speed:float = 200.0;

var in_settlement:bool = false;

signal settlement_entered(settlement:Settlement);

func _ready()->void:
	Entities.in_map_player = self;

func _input(e:InputEvent)->void:
	if not in_settlement:
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
					

func stop_movement()->void:
	position = target_position;
	stopped_moving.emit()

func interact_with_map_entity(entity:MapEntity)->void:
	if entity is Settlement:
		Entities.current_settlement = entity;
		settlement_entered.emit(entity)
		Entities.ui_sfx.play_stream_by_key("settlement_entered")
		in_settlement = true;
	elif entity is MapParty:
		print("ismapp")


func _on_started_moving() -> void:
	camera.return_to_player()
