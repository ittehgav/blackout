extends RigidBody2D

class_name Projectile

signal hit(fighter:ActiveFighter);

var move_target:Vector2;

@export var shooter:ActiveFighter;

@export var sprite:Sprite2D;
@export var despawn_timer:Timer;

const flight_speed = 50;

@export_enum("arrow", "needle") var type:String="arrow";

@export var arrow_texture:Texture;
@export var syringe_texture:Texture;

var source:bool=false;
## projectile nodes will fire clones of themselves, the original projectile is never truly fired.
## projectile will mimick the holder's collision mask

func setup(new_shooter:ActiveFighter)->void:
	shooter = new_shooter;
	source = true
	## can only run after assigning shooter
	var shooter_team_n:int = shooter.ally_team.team_n;
	var target_mask:int;
	if shooter_team_n == 1:
		target_mask = 2
	else:
		target_mask = 1;
		
	set_collision_mask_value(target_mask, true);
	sprite.texture = self[type + "_texture"];

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
	Entities.arena.projectiles.add_child(self);
	
	global_position = shooter.global_position;
	sprite.look_at(position + target_direction)
	
func _physics_process(_delta: float) -> void:
	if not source:
		var direction:Vector2 = move_target * flight_speed;
		var collision:KinematicCollision2D = move_and_collide(direction);
		if collision:
			hit.emit(collision.get_collider())

func _on_hit(_fighter: ActiveFighter) -> void:
	queue_free();

func _on_despawn_timer_timeout() -> void:
	queue_free();
