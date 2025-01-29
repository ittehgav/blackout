extends Sprite2D

@export var stats:Node;

const skill_effects = ["aoe_damage", "aoe_debuff"];
const skill_visuals = ["lunge_forward"]

const target_type = "nearest_enemy"

const profile = {
	"skill_name": "Wrecking Punch",
	"short_description":"Throws a powerful punch that reduces the defense of the target.",
	"long_description":"Can tear through even the toughest of enemies."
}

const hitbox_radius = 50;
const hitbox_height = 150;

const hit_scan_radius = 100;
const skill_range = 100;

const debuff_type = "stat";

const stats_to_debuff = ["defense"];
const stat_debuff_values = {
	"defense":5
}


const skill_cooldown = 3;
