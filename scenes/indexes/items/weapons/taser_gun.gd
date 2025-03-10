extends Weapon

const rarity = 2;

## taser gun, stuns and damages a target
const type = "ranged";
const projectile_lifespan = 2;
const projectile_speed = 500;

const use_sfx = "shoot";
const hit_sfx = "projectile_hit"

@export var projectile:RigidBody2D;

func use()->void:
	pass
