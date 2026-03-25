extends Weapon

const rarity = 2;

const size_x = 3;
const size_y = 2;

@export var splash:Sprite2D

func get_description()->String:
	return Index.get_color_tag("juice") +\
"Consumes 1 juice per shot.[/color]\nShoots grenades that damage and debuff enemies, reducing their defense.";

const defense_debuff = 5

func use(_alt:bool=false)->void:
	use_sfx.play()
	consume_ammo();
	animation_player.play("weapon_generic/recoil")
	var new_splash:Sprite2D = splash.duplicate();
	

	var new_projectile:Projectile = Combat.shoot_projectile(projectile, Entities.player_fighter, projectile_hit.bind(new_splash))
	new_splash.rotation = new_projectile.rotation


func projectile_hit(target:CombatEntity, smoke:Sprite2D)->void:
	## smoke's hit scan mask is just hardcoded into team 2 
	## which is fine for the build i'm working towards right now
	Entities.player_fighter.ally_team.projectiles.add_child.call_deferred(smoke);
	
	smoke.global_position = target.global_position;
	smoke.explode();
	hit.emit()
	
	## not fancy but should work and hardly ever have any impact in the hit outcome
	await get_tree().create_timer(.05).timeout
	Combat.aoe_damage(Entities.player_fighter, smoke.hit_scan);
	Combat.aoe_status(Entities.player_fighter, status, smoke.hit_scan)
