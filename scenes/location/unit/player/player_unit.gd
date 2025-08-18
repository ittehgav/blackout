extends ActiveUnit



func _ready()->void:
	Entities.player_unit = self;

	
func _physics_process(delta: float) -> void:
	var input_direction:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * move_speed;
	if velocity != Vector2.ZERO:
		if velocity.x != 0:
			sprite.flip_h = velocity.x < 0;
		if not moving:
			started_moving.emit();
			moving = true;
	elif moving:
		stopped_moving.emit();
		moving = false;
	move_and_slide();
