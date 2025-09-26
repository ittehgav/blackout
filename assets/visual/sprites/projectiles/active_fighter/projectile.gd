extends Node2D;

class_name Projectile

signal hit(fighter:ActiveFighter);

var move_target:Vector2;

@export var hit_allies:bool=false;
@export var hit_enemies:bool=true;

@export var shooter:ActiveFighter;

@export var sprite:Sprite2D;
@export var despawn_timer:Timer;
@export var hitbox:Area2D;

@export var flight_speed:int = 2000


var self_target:bool = false;
var ally_mask:int;
var enemy_mask:int;

var source:bool=false;
## projectile nodes will fire clones of themselves, the original projectile is never truly fired.
## projectile will mimick the holder's collision mask



func setup(new_shooter:ActiveFighter)->void:
	shooter = new_shooter;
	source = true
	## can only run after assigning shooter
	var shooter_team_n:int = shooter.ally_team.team_n;
	
	if shooter_team_n == 1:
		ally_mask = 1;
		enemy_mask = 2
	else:
		ally_mask = 2;
		enemy_mask = 1;
	
	if hit_enemies:
		hitbox.set_collision_mask_value(enemy_mask, true);
	if hit_allies:
		hitbox.set_collision_mask_value(ally_mask, true)

	


func shoot(target_direction:Vector2)->Projectile:
	## expose the projectiles hit signal to the weapon nodeç;
	var clone:Projectile = duplicate();
	clone.shooter = shooter;
	clone.start_flight(target_direction);
	return clone;
	
func start_flight(target_direction:Vector2)->void:
	show();
	move_target = target_direction;
	hit.connect(_on_hit);
	shooter.ally_team.projectiles.add_child(self);
	
	global_position = shooter.global_position;
	look_at(position + target_direction)
	
func _physics_process(delta: float) -> void:
	position += move_target * flight_speed * delta;


func _on_hit(_fighter: ActiveFighter) -> void:
	hitbox.set_collision_mask_value(1, false);
	hitbox.set_collision_mask_value(2, false);
	queue_free()


func _on_despawn_timer_timeout() -> void:
	queue_free();


func _on_hitbox_body_entered(body: Node2D) -> void:
	if hit_allies:
		if body != shooter:
			hit.emit(body);
	else:
		hit.emit(body);
