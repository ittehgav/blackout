@abstract
@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/icon_bullet.png")
class_name Projectile
extends Sprite2D;


signal hit(fighter:ActiveFighter);

var move_target:Vector2;
@export var rotating:bool=false;

@export var hit_allies:bool=false;
@export var hit_enemies:bool=true;



@export var hit_scan:Area2D;

@export var flight_speed:int = 2000
## determines how long it'll take to reach a given position
## in both straight and arc projectiles
@export var particles:CPUParticles2D

var shooter:ActiveFighter;

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
	
	particles.amount = 30.0/(flight_speed/2000.0)
	if hit_enemies:
		hit_scan.set_collision_mask_value(enemy_mask, true);
	if hit_allies:
		hit_scan.set_collision_mask_value(ally_mask, true)

func rotation_loop()->void:
	if is_instance_valid(self):
		var tween:Tween = create_tween();
		tween.tween_property(self, "rotation_degrees", rotation_degrees + 90, .1);
		tween.tween_callback(rotation_loop)


func shoot(target_direction:Vector2)->Projectile:
	## expose the projectiles hit signal to the weapon node;
	var clone:Projectile = duplicate();
	clone.material = material
	clone.shooter = shooter;
	clone.particles.queue_free();
	clone.particles = particles.duplicate();
	clone.add_child(clone.particles)
	clone.particles.emitting = true
	clone.start_flight(target_direction);

	if rotating:
		clone.rotation_loop()
	return clone;


@abstract func start_flight(target:Vector2)->void;
## TARGET IS A NORMALIZED DIRECTION FOR STRAIGHT PROJ
## AND A GLOBAL POSITION FOR ARC PROJ
@abstract func _on_hit(target:ActiveFighter)->void;
