extends Module

const rarity = 2;
@export var trail:MotionTrail

func get_description()->String:
	return "Cosumes " + str(ammo_cost)+" " + Resources.resource_colored_name(ammo_type) +\
	" and increases your "+CombatStats.stat_colored_name("agility")+" for the rest of the battle.";


const base_agility_frac = 1

func use()->void:
	if modifier != 1:
		consume_ammo()
	use_sfx.play()

	var frac: = base_agility_frac
	var technique:float = Entities.player_fighter.technique;
	if technique > 1:
		frac *= technique
	var bonus_agility:float = Entities.player_fighter.agility + 1 * frac
	status.apply_on_target(Entities.player_fighter, bonus_agility);
	if modifier == 2:
		var most_atk:ActiveFighter = find_most_atk_ally();
		await trail.trail_jump(Entities.player_fighter.global_position, most_atk.global_position).finished
		status.apply_on_target(most_atk);
func find_most_atk_ally()->ActiveFighter:
	var most_atk:ActiveFighter;
	for f:ActiveFighter in Entities.player_fighter.ally_team.fighters:
		if not most_atk or f.attack > most_atk.attack:
			most_atk = f;
	return most_atk

const m1_description = "No longer costs any juice.";
const m1_prefix = "Somatic"

const m2_description = "Also applies the buff to the ally with the most attack."
const m2_prefix = "Coordinated"
