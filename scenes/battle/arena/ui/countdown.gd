extends ColorRect

@export var arena:Node2D;
## this will be the main arena after we send this stuff over

@export var teams:Node2D;
@export var countdown_label:Label;

@export var countdown_second:int = 3;

func _ready()->void:
	show() ## so it doesn't get in the way of the editor in the arena
	get_tree().paused = true
	await get_tree().create_timer(.1).timeout;
	arena.battle_started.emit();
	get_tree().paused = false
	queue_free()

func _on_countdown_timeout() -> void:
	countdown_second -= 1;
	if countdown_second == 0:
		arena.battle_started.emit();
		get_tree().paused = false
		queue_free()
		
	
	countdown_label.text = str(countdown_second)
	
