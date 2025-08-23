extends Module

const rarity = 2;




const sfx_key = "adrenaline"
const juice_cost = 5;

const base_agility_frac = .5

## juice consumption scales with level?
var description:String;

func set_hint_data()->void:
	description = "Cosumes " + str(juice_cost)+" " + Index.resource_colored_name("juice") +\
	" and increases your "+Index.stat_colored_name("agility")+" for the rest of the battle.";

func check_available()->bool:
	return Entities.player.inventory.juice >= juice_cost; 

func use()->void:
	var frac: = base_agility_frac
	var technique:float = Entities.player_fighter.technique;
	if technique > 1:
		frac *= technique
	var bonus_agility:float = Entities.player_fighter.agility + 1 * frac
	Entities.player.inventory.juice -= juice_cost;
	Combat.apply_stat_change(Entities.player_fighter, Entities.player_fighter, bonus_agility, "agility");
