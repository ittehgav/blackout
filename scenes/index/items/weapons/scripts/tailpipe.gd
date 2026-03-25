extends Weapon

## weapons can be weapons or tools with effects such as heals/buffs
const rarity = 1;

const size_x = 2;
const size_y = 4;



func get_description()->String:
	return "Short range, hits enemies in front of you, dealing "\
	+ Index.get_color_tag("attack") + str(final_damage()) + " damage.";


const aoe_radius = 100;


var swung:bool = false;

func use(_alt:bool=false)->void:
	use_sfx.play();
	animation_player.play("weapon_generic/swing")

func impact()->void:
	Combat.aoe_damage(Entities.player_fighter, hit_scan);
	
	if len(Entities.player_fighter.hit_targets):
		## projectiles do this on their own
		hit.emit();
