extends FighterBase

const skill_effects = ["special"];
const skill_visuals = ["recoil"]

const skill_use_sfx = ["shoot"]
const skill_hit_sfx = ["heal"]

const sample_offset = Vector2(8, -26)

const target_type = "least_hp_ally"


const skill_name = "Healing Tether"
const description = "[color=blue]Doesn't deal damage.[/color] Regenerates allies' health."
const long_description = "Prioritizes wounded allies."

func full_skill_description(unit:FighterUnit)->String:
	var total_heal:float = heal_value * total_heal_ticks;
	var heal_str:String = Meta.get_technique_scaled_string(unit, "", total_heal);
	var string:String = "[color=blue]Doesn't deal damage.[/color] Heals the most damaged ally for "\
	 + heal_str + " over " + str(total_heal_ticks) + " seconds.";
	return string;

const hitbox_radius = 25;
const hitbox_height = 60;
const hitbox_offset = Vector2(0, 5)

const skill_range = 200;

const skill_cooldown = 1;

const heal_value = 5.0;
const total_heal_ticks = 10;
const heal_interval = 1.0;

const tags = [
	"healer",
	"scientist",
	"doctor"
]


func special_skill()->void:
	recurring_heal(fighter.target_unit, total_heal_ticks);


func recurring_heal(target:ActiveFighter, ticks_left:int)->void:
	Combat.heal_unit(fighter, target, heal_value );
	ticks_left -= 1
	if ticks_left and get_tree():
		await get_tree().create_timer(heal_interval).timeout
		fighter.skill_hit.emit(target);
		if target.hp > 0:
			recurring_heal( target, ticks_left)
