extends FighterBase

const skill_effects = ["special"];
const skill_visuals = ["recoil"]

const target_type = "least_hp_ally"


const skill_name = "Healing Tether"
const short_description = "[color=blue]Doesn't deal damage.[/color] Regenerates allies' health."
const long_description = "Prioritizes wounded allies."



const hitbox_radius = 50;
const hitbox_height = 150;

const skill_range = 500;

const skill_cooldown = 1;

const heal_value = 5.0;
const total_heal_ticks = 10;
const heal_interval = 1.0;

func special_skill(fighter:ActiveFighter)->void:
	var effect:Callable = Combat.heal_unit.bind(fighter, fighter.target_unit, heal_value);
	Combat.recurring_effect(fighter.target_unit, effect, heal_interval, total_heal_ticks);
