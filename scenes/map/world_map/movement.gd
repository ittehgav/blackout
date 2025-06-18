extends Control

@export var player:InMapPlayer

@onready var world_size:int = Entities.world_map.quadrants.entity_spawn_range;

func _on_gui_input(e: InputEvent) -> void:
	if e.is_action_pressed("world_map_move") and not Entities.world_map.pause_stack:
		var cursor_position:Vector2 = Entities.world_map.get_local_mouse_position();
		if player.global_position.distance_to(cursor_position) > 30:
			player.target_position = cursor_position;
			player.started_moving.emit();
	elif e.is_action_pressed("stop_movement"):
		player.stop_movement();
	
	if player.camera.in_player and player.camera.in_player:
		var camera_direction:Vector2 =\
		Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if camera_direction:
			player.camera.free_panning();
