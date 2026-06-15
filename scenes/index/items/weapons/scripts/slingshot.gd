
extends Weapon

const rarity = 1;

const size_x = 1;
const size_y = 2;

const r1_improvement = "+5 base damage";
const r2_imrpovement = "Shots pierce 1 target";
const r3_improvement = "Shots have a 10% chance to stun the target for 1 second."

func get_description()->String:
	return "Flings stones at enemies, dealing " + str(final_damage()) + " damage to enemies.";

func use(_alt:bool=false)->void:
	animation_player.play(animation_root_key+"/attack");
	Combat.shoot_projectile(projectile, Entities.player_fighter, projectile_hit);

func projectile_hit(target:CombatEntity)->void:
	Combat.deal_damage(Entities.player_fighter, target);
	hit.emit()
