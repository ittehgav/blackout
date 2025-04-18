extends FighterBase



const skill_effects = ["special"];
const skill_visuals = ["grow", "shake"]

const skill_use_sfx = ["engine"]
const skill_hit_sfx = ["small_hit"]

const sample_offset = Vector2(15, -26)

const target_type = "nearest_enemy"

const skill_name =  "Accelerate"
const description = "Deals damage to surrounding enemies that speeds up over time."
const flavor = "Proud of the engineering of his weapon, even though he sort of just copied someone else.";

const tags = [
	"brawler",
	"hunter",
	"mechanic"
]

func full_skill_description(unit:FighterUnit)->String:
	var damage_str:String = Index.get_unit_damage_string(unit);
	var acceleration:String = Index.get_technique_scaled_string(unit, "", 10, .5, "%");
	var string:String = "Spins a wheel that deals " + damage_str + " to surrounding enemies every second.\n"\
	+ "Each additional activation makes the wheel go " + acceleration + " faster.";
	return string

const hitbox_radius = 50;
const hitbox_height = 100;
const hitbox_offset = Vector2(5, 0);

const skill_range = MELEE_RANGE;
const skill_cooldown = 5;
const hit_scan_radius = 100;

const hit_scan_type = "surrounding";

func damage_modifier(damage:float, _unit:FighterUnit=null)->float:
	return damage/10

@export var dmg_timer:Timer;
const skill_projection = "wheel_spin"

func _ready()->void:
	dmg_timer.timeout.connect(Combat.aoe_damage.bind(fighter));

func special_skill()->void:
	if not dmg_timer.is_stopped():
		dmg_timer.wait_time -= (dmg_timer.wait_time/10.0)*(fighter.technique/2.0);
	else:
		dmg_timer.start();
		fighter.get_node("hit_scan/shape").start_aoe_highlight();
