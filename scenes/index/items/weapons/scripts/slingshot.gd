extends Weapon

const rarity = 1;

const size_x = 1;
const size_y = 2;

func get_description()->String:
	return "Flings stones at enemies, dealing " + str(final_damage()) + " damage to enemies.";

func use(_alt:bool=false)->void:
	use_sfx.play();
	animation_player.play("weapon_generic/recoil");
	Combat.shoot_projectile(projectile, Entities.player_fighter, projectile_hit);

func projectile_hit(target:CombatEntity)->void:
	Combat.deal_damage(Entities.player_fighter, target);
	hit.emit()
