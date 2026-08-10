
extends Weapon

const rarity = 1;

const size_x = 1;
const size_y = 2;


func get_description()->String:
	return "Flings stones at enemies, dealing " + str(final_damage()) + " damage to enemies.";

func use(_alt:bool=false)->void:
	animation_player.play(get_animation_key("attack"));
	Combat.shoot_projectile(projectile, Entities.player_fighter, projectile_hit);

func projectile_hit(target:CombatEntity)->void:
	Combat.deal_damage(Entities.player_fighter, target);
	Combat.knock_back_target(Entities.player_fighter, target, 1)
	if refinement_level >= 2:
		var roll:float = randf();
		if roll >= .9:
			status.apply_on_target(target)
	hit.emit()

const r1_improvement = "+25% fire rate";
const r2_improvement = "Shots have a 10% chance to stun the target for 1 second."
const r3_improvement = "Shots pierce 1 target";

func apply_r1()->void:
	cooldown -= cooldown/4
func apply_r2()->void:
	pass
func apply_r3()->void:
	projectile.pierce = 1;
