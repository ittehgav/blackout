extends Sprite2D

@export var animation_player:AnimationPlayer
@export var hit_scan:Area2D

func explode()->void:
	show()
	animation_player.play("smoke_dissipation");
	await animation_player.animation_finished
	queue_free()
	
