extends FighterBase

const skill_visuals = ["lunge_forward", "recoil_target", "overhead"]
const projection_vfx = [];


const skill_use_sfx = ["swing"]
const skill_hit_sfx = ["metal"]


const sample_offset = Vector2(13, -26)

const target_type = "nearest_enemy"

const skill_name =  "Crowbar Swing"
const description = "Low resistance, high melee damage."
const flavor = "Surprisingly strong for just a scientist with a crowbar."

const tags = [
	"hunter",
	"scientist"
]

func full_skill_description(unit:FighterUnit)->String:
	var base_damage_str:String = Index.get_color_tag("attack") +  str(unit.stats.attack) + "[/color]";

	var final_damage_color_hex:String = Index.stat_colors.attack.blend(Index.stat_colors.technique).to_html();
	var final_damage_str:String = Index.get_unit_damage_string(unit);
	final_damage_str= "[color=" + final_damage_color_hex + "]" + final_damage_str + "[/color]"
	
	var technique_str:String = Index.get_technique_scaled_string(unit, "", 0, .5);
	
	var string:String = "Deals " + final_damage_str + " (" + base_damage_str + " * " + technique_str + ") to the nearest enemy.";

	string += "\n\nCan be upgraded to deal heavy, long-range damage or to apply AOE crowd control.";
	return string;


func damage_modifier(damage:float, unit:FighterUnit=null)->float:
	if not unit:
		if fighter.technique >= 2:
			return damage * fighter.technique/2;
		else:
			return damage
	else:
		if unit.stats.technique >= 2:
			return damage * unit.stats.technique/2;
		else:
			return damage

const hitbox_radius = 25;
const hitbox_height = 60;
const hitbox_offset = Vector2(0, 5)

const skill_range = MELEE_RANGE;
const skill_cooldown = 5;

const evolutions = {
	"crossbow_guy":{
		"scrap":50,
		"fuel":20
	},
	"gravity_guy":{
		"chips":20,
		"scrap":50
	}
}

func skill()->void:
	Combat.deal_damage(fighter);
	fighter.catch_hit_target(fighter.target_unit)
