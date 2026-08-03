extends Projectile
class_name StraightProjectile

@export var auto_expire :bool= true;

@export var despawn_timer:Timer;

func start_flight(target_direction:Vector2)->void:
	show();
	move_target = target_direction;
	hit.connect(_on_hit);
	shooter.ally_team.projectiles.add_child(self);
	despawn_timer.start()
	
	global_position = shooter.global_position;
	look_at(position + target_direction)



func _physics_process(delta: float) -> void:
	position += move_target * flight_speed * delta;


func _on_hit(_fighter: CombatEntity) -> void:
	hit_scan.set_collision_mask_value(1, false);
	hit_scan.set_collision_mask_value(2, false);
	set_physics_process(false)
	particles.emitting = false
	self_modulate.a = 0
	await get_tree().create_timer(particles.lifetime).timeout
	queue_free()
	


func _on_despawn_timer_timeout() -> void:
	if auto_expire:
		queue_free();


func _on_hitbox_area_entered(area: Area2D) -> void:
	assert(area is HurtBox);
	var target:CombatEntity = area.source
	if hit_allies:
		if target != shooter:
			hit.emit(target);
	else:
		hit.emit(target);
