extends Artifice

const size_x = 2;
const size_y = 2;

const rarity = 3;

@export var hit_scan:Area2D;
@export var vfx:Node2D;
@export var animation:AnimationPlayer;

func get_description()->String:
	return "In combat, use to throw a grenade that damages and pulls all enemies hit towards the center of the explosion.";


func use()->bool:
	vfx.reparent(Entities.player_fighter.ally_team.projectiles)
	
	hit_scan.reparent(Entities.player_fighter.ally_team.projectiles);
	hit_scan.global_position = get_global_mouse_position()
	## is ok to rip the hit scan from the projectile node since
	## it only shoots once per instance
	
	throw()
	return consume()

func detonate_callback(hit_location:Vector2)->void:
	animation.play("singularity")
	detonate_sfx.play();
	vfx.global_position = hit_location;
	
	Combat.radial_pull(Entities.player_fighter, hit_scan, 5)
	
	Combat.aoe_damage(Entities.player_fighter, hit_scan)
	
	Entities.player_fighter.equipment.weapon_control.play_feedback(WeaponDisplay.PlayerScreenFeedback.shake)
	## TODO make this cleaner and more designed to be used by anything
	## put the feedback types on the combat camera class and 
	## make them directly accesible via Entities?

	
