extends Weapon


const rarity = 2;

const size_x = 2;
const size_y = 2;

const stun_duration = .75

func get_description()->String:
	return "Shoots taser darts that deal " + Index.get_color_tag("attack") +" "+ str(final_damage())+\
			"damage[/color] and stun the target for " + str(stun_duration) +" seconds.";


func use(_alt:bool=false)->void:
	animation_player.play("generic/recoil")
	use_sfx.play();
	Combat.shoot_projectile(projectile, Entities.player_fighter, projectile_hit)


func projectile_hit(target:ActiveFighter)->void:
	hit.emit()
	hit_sfx.play()
	Combat.deal_damage(Entities.player_fighter, target);
	status.apply_on_target(target);
