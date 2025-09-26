extends Weapon

const rarity = 2;

const size_x = 3;
const size_y = 2;

@export var splash:Sprite2D

func get_description()->String:
	return Index.get_color_tag("juice") +\
"Consumes 1 juice per shot.[/color]\nShoots grenades that damage and debuff enemies, reducing their defense.";


func use(_alt:bool=false)->void:
	consume_ammo();
	animation_player.play("weapon_generic/recoil")
	var new_splash:Sprite2D = splash.duplicate();

	var new_projectile:Projectile = Combat.shoot_projectile(projectile, Entities.player_fighter, projectile_hit.bind(new_splash))
	new_splash.rotation = new_projectile.rotation


func projectile_hit(target:ActiveFighter, smoke:Sprite2D)->void:
	Entities.player_fighter.ally_team.projectiles.add_child(smoke);
	smoke.global_position = target.global_position;
	smoke.explode();
