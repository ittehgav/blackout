extends TileMapLayer

func _ready()->void:
	blink_loop()

func blink_loop()->void:
	var tween:Tween = create_tween();
	tween.tween_property(self, "modulate:a", 0, .75);
	tween.tween_property(self, "modulate:a", 1, .25);
	tween.tween_callback(blink_loop)

func highlight_path(cells:PackedVector2Array)->void:
	clear();
	for c:Vector2 in cells:
		set_cell(c, 0, Vector2.ZERO)
