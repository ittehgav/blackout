extends Sprite2D



func _on_shuffle_timeout() -> void:
	var roll:int = randi_range(0, 4)
	frame_coords.x = roll
