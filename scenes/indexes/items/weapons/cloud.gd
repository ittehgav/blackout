extends Sprite2D;

signal hit(target:ActiveFighter)

@export var ticker:Timer;
@export var hitbox:Area2D;
@export var polygon:CollisionPolygon2D;

func launch()->void:
	show();
	const tween_duration = 5

	
	Entities.arena.projectiles.add_child(self)
	global_position = Entities.in_fight_player.global_position
	rotation = Entities.in_fight_player.hit_scan.rotation;
	position += global_position.direction_to(get_global_mouse_position()) * 100
	
	
	var tween: = create_tween()
	tween.tween_property(self, "position", global_position + global_position.direction_to(get_global_mouse_position()) * 100, tween_duration);
	tween.parallel().tween_property(self, "scale", scale * 2, tween_duration);
	tween.parallel().tween_property(self, "modulate:a", 0, tween_duration);
	tween.tween_callback(queue_free)
	
	ticker.timeout.connect(_on_ticker_timeout);
	ticker.start()
	
func _on_ticker_timeout() -> void:
	for target in hitbox.get_overlapping_bodies():
		hit.emit(target);
