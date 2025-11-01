extends Module

const rarity = 2;

func get_description()->String:
	return "Cosumes " + str(ammo_cost)+" " + Index.resource_colored_name(ammo_type) +\
	" and increases your "+Index.stat_colored_name("agility")+" for the rest of the battle.";


const base_agility_frac = 1

## juice consumption scales with level?
var description:String;

func use()->void:
	consume_ammo()
	use_sfx.play()
	
	var frac: = base_agility_frac
	var technique:float = Entities.player_fighter.technique;
	if technique > 1:
		frac *= technique
	var bonus_agility:float = Entities.player_fighter.agility + 1 * frac
	status.apply_on_target(Entities.player_fighter, bonus_agility);
