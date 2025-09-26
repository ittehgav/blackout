extends Sprite2D

@export var animation_player:AnimationPlayer
@export var hit_scan:Area2D

func explode()->void:
	show()
	animation_player.play("smoke_dissipation");
	Combat.aoe_damage(Entities.player_fighter, hit_scan);
	await animation_player.animation_finished
	queue_free()
	
