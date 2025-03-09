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

const tags = [
	"healer",
	"scientist",
	"doctor"
]


func special_skill(fighter:ActiveFighter)->void:
	recurring_heal(fighter, fighter.target_unit, total_heal_ticks);



func recurring_heal(source:ActiveFighter, target:ActiveFighter, ticks_left:int):
	Combat.heal_unit(source, target, heal_value );
	ticks_left -= 1
	if ticks_left and get_tree():
		await get_tree().create_timer(heal_interval).timeout
		if target.hp > 0:
			recurring_heal(source, target, ticks_left)
