extends Sprite2D

@export var stats:Node;

const skill_effects = ["aoe_damage", "aoe_debuff"];
const skill_visuals = ["lunge_forward"]

const target_type = "nearest_enemy"


const skill_name = "Rusty Pipe"
const short_description = "Moderate resistance and damage, attacks reduce enemies' damage."
const long_description = "Disruptive and resistant. Can be upgraded to become extremely resistant or to deal great AOE damage."


const hitbox_radius = 50;
const hitbox_height = 150;

const hit_scan_radius = 100;

const skill_range = 100;
const skill_cooldown = 3;

const debuff_type = "stat";

const stats_to_debuff = ["attack"];
const stat_debuff_values = {
	"attack":5
}
