extends Sprite2D

@export var stats:Node;

const skill_effects = ["direct_damage"];
const skill_visuals = ["lunge_forward"]

const target_type = "nearest_enemy"

const profile = {
	"skill_name": "Crowbar Swing",
	"short_description":"Surprisingly strong for a scientist with a crowbar.",
	"long_description":"Low resistance, fairly high damage.\n
	Can be upgraded to deal heavy damage or to apply heavy crowd control."
}

const hitbox_radius = 50;
const hitbox_height = 150;

const skill_range = 100;

const debuff_type = "stat";
const skill_cooldown = 1;

const stats_to_debuff = ["defense"];
const stat_debuff_values = {
	"defense":5
}
