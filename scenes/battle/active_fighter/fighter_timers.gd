extends Node

@export var stun_display:TextureProgressBar;
@export var stun_timer:Timer;

func display_stun():
	## runs AFTER stun timer gets set and started
	stun_display.max_value = stun_timer.wait_time;
	
func _process(_delta:float)->void:
	if not stun_timer.is_stopped():
		stun_display.value = stun_timer.time_left;
