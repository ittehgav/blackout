extends FighterBase


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ColorCoder.color_code_fighter(self, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	
	if frame == hframes - 1:
		frame = 0;
	else:
		
		frame += 1
	
