extends TextureRect;


func _ready() -> void:
	hint_loop();
	
func hint_loop()->void:
	pivot_offset.y = 10
	var tween:Tween = create_tween();
	tween.tween_property(self, "pivot_offset:y", pivot_offset.y + 10, .5);
	tween.tween_interval(.3);
	tween.tween_callback(hint_loop);
