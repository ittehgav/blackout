extends AnimatedSprite2D

## TODO implement active fighter player sprite in this script as well
## if there ends up being any sprite-related things that only ever happen in combat


func _on_player_unit_started_moving() -> void:
	play("walk")


func _on_player_unit_stopped_moving() -> void:
	play("idle")
