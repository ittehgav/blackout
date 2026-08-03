extends Projectile
class_name ArcProjectile

@export var arc_height:float = 200

signal detonated(p:Vector2)

func start_flight(target:Vector2)->void:
	show()
	hit.connect(_on_hit)
	shooter.ally_team.projectiles.add_child(self)
	global_position = shooter.global_position;
	var tween:= tween_arc(target, flight_speed);
	tween.tween_callback(detonate)


func _on_hit(_target:ActiveFighter)->void:
	## still feels right to keep this abstract?
	pass

func detonate()->void:
	await get_tree().process_frame;
	detonated.emit(global_position)
	for h:Area2D in hit_scan.get_overlapping_areas():
		assert(h is HurtBox)
		var target:CombatEntity = h.source;
		hit.emit(target)
	queue_free()

func tween_arc(
	target: Vector2,
	speed: float,
) -> Tween:
	var start :Vector2 = global_position
	var distance := start.distance_to(target)
	var duration := distance / speed

	var tween := create_tween()

	tween.tween_method(
		func(t:Variant)->void:
			var pos := start.lerp(target, t)
			var height :float = 4.0 * arc_height * t * (1.0 - t)

			global_position = pos + Vector2(0, -height),
		0.0, 1.0, duration).set_trans(Tween.TRANS_LINEAR)

	return tween
