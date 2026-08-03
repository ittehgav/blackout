extends Artifice

const size_x = 2;
const size_y = 2;

const rarity = 1;

func get_description()->String:
	return "Use in battle to heal the most damaged unit in your team by 50% of their missing health."

func use()->bool:
	var lowest_hp:ActiveFighter;
	for fighter:ActiveFighter in Entities.player_fighter.ally_team.fighters:
		if not lowest_hp or lowest_hp.max_hp - lowest_hp.hp < fighter.max_hp - fighter.hp:
			lowest_hp = fighter;

	var missing_hp:float = lowest_hp.max_hp - lowest_hp.hp;
	var heal_value:float = missing_hp/2;
	Combat.heal_target(Entities.player_fighter, lowest_hp, heal_value)
	return consume();
