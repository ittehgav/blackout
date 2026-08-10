extends Projectile
class_name StraightProjectile

@export var auto_expire:bool= true;
@export var pierce:int=0;

@export var despawn_timer:Timer;

func shoot(target_direction:Vector2)->Projectile:
	var projectile:Projectile = super(target_direction);
	projectile.pierce = pierce
	return projectile

func start_flight(target_direction:Vector2)->void:
	show();
	move_target = target_direction;
	hit.connect(_on_hit);
	shooter.ally_team.projectiles.add_child(self);
	
	if hit_player:
		prevent_autohit_player()
	despawn_timer.start()
	
	global_position = shooter.global_position;
	look_at(position + target_direction)



func _physics_process(delta: float) -> void:
	position += move_target * flight_speed * delta;


func _on_hit(_fighter: CombatEntity) -> void:
	if not pierce:
		self_modulate.a = 0
		particles.emitting = false
		set_physics_process(false)
		hit_scan.set_collision_mask_value(1, false);
		hit_scan.set_collision_mask_value(2, false);
		await get_tree().create_timer(particles.lifetime).timeout
		queue_free()
	else:
		pierce -= 1;


func _on_despawn_timer_timeout() -> void:
	if auto_expire:
		queue_free();


func _on_hitbox_area_entered(area: Area2D) -> void:
	assert(area is HurtBox);
	var target:CombatEntity = area.source
	if target is PlayerFighter and hit_player:
		hit.emit(target);
		return;
	if hit_allies:
		if target != shooter:
			hit.emit(target);
	else:
		hit.emit(target);

func prevent_autohit_player()->void:
	hit_scan.set_collision_mask_value(10, false)
	await get_tree().create_timer(.5).timeout;
	hit_scan.set_collision_mask_value(10, true)
