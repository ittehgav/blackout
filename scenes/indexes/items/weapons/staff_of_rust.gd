extends Sprite2D

## magnetic staff, maybe chargeable?
const type="ranged";
const projctile_lifespan =5;
const projectile_speed = 200;

const use_sfx = "cast";
const hit_sfx = "strong_hit";

@export var projectile:RigidBody2D

func use()->void:
	pass
