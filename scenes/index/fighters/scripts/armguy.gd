extends FighterBase

const skill_name = "Throw Hands"
const description = "Slow and tough, damages and stuns enemies."
const flavor = "He's heard that joke you're thinking of a thousand times."


const evolutions = [
	"Slammy",
	"Rocky"
]

func full_skill_description(unit:FighterUnit)->String:
	var damage:String = Index.get_unit_damage_string(unit);
	var stun_duration_str:String = Index.get_technique_scaled_string(unit, "stun", "", status.duration);
	
	var string:String = "Punches the nearest enemy, dealing " + damage + \
	" and "+Index.get_color_tag("stun") + "stunning[/color] them for "\
	 + stun_duration_str + " seconds.";

	string += "\nCan be [u]upgraded[/u] to deal much more damage or to apply crowd control over a large area."
	return string;





const skill_range = MELEE_RANGE;
const skill_cooldown = 3.5;

const status_duration = .125;



func skill()->void:
	## pass this stuff to npcfighter if everyone ends up getting some version of it?:
	Combat.set_windup_angle(fighter)

	animation_player.play("armguy/skill")
	animation_player.queue("fighter_base/idle")

func skill_effect()->void:
	Combat.deal_damage(fighter);
	status.apply_on_target()
	skill_finished.emit();
