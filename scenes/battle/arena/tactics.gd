extends Control

@export var tactic_left:ColorRect;
@export var tactic_right:ColorRect;

func _process(_delta:float)->void:
	if Input.is_action_pressed("show_tactics", true):
		if Engine.time_scale <= .5:
			show_tactics();
		else:
			Engine.time_scale -= .05
			modulate.a += .1;

	elif Input.is_action_just_released("show_tactics"):
		get_tree().paused = false
		tactic_right.mouse_filter = MOUSE_FILTER_IGNORE
		tactic_left.mouse_filter = MOUSE_FILTER_IGNORE
		modulate.a = 0;
		Engine.time_scale = 1;


	
		
func show_tactics()->void:
	modulate.a = 1;
	get_tree().paused = true;
	tactic_right.mouse_filter = MOUSE_FILTER_STOP
	tactic_left.mouse_filter = MOUSE_FILTER_STOP

func _on_tactic_left_mouse_entered() -> void:
	var highlight:ColorRect = tactic_left.get_node("hover_highlight")
	var tween:Tween = create_tween();
	tween.tween_property(highlight, "modulate:a", 1, .5)
	


func _on_tactic_left_mouse_exited() -> void:
	var highlight:ColorRect = tactic_left.get_node("hover_highlight")
	var tween:Tween = create_tween();
	tween.tween_property(highlight, "modulate:a", 0, .5)


func _on_tactic_right_mouse_entered() -> void:
	var highlight:ColorRect = tactic_right.get_node("hover_highlight")
	var tween:Tween = create_tween();
	tween.tween_property(highlight, "modulate:a", 1, .5)
	

func _on_tactic_right_mouse_exited() -> void:
	var highlight:ColorRect = tactic_right.get_node("hover_highlight")
	var tween = create_tween();
	tween.tween_property(highlight, "modulate:a", 0, .5)
