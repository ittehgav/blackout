extends Weapon

## weapons can be weapons or tools with effects such as heals/buffs
const rarity = 1;

const size_x = 2;
const size_y = 4;

const r1_imrpovement = "+10 base damage";
const r2_improvement = "+50% damage against stunned enemies.";
const r3_improvement = "+20% attack speed, hitting the same enemy 5 times stunst them for 1 second."


func get_description()->String:
	return "Short range, hits enemies in front of you, dealing "\
	+ Index.get_color_tag("attack") + str(final_damage()) + " damage.";



func use(_alt:bool=false)->void:
	animation_player.play("melee/attack")
	pending_impact = true;
	## ONLY ALL TO ANIM PLAYER IN WEAPON NODES IS THE ATTACK ANIMATION CALL
	## because it calls impact so it should be on each individual weapon node
	

func impact()->void:
	Combat.aoe_damage(Entities.player_fighter, hit_scan);
	pending_impact = false;
	if len(Entities.player_fighter.hit_targets):
		## projectiles do this on their own
		hit.emit();
