extends Sprite2D

@export var stats:Node;

const skill_effects = ["self_buff"];
const skill_visuals = ["lunge_forward"]

const target_type = "nearest_enemy"

const profile = {
	"skill_name":"Buckle up",
	"short_description":"Shields self, becoming progressively more resistant. Can't deal damage.",
	"long_description":"Can be extremely difficult to take down."
}

const hitbox_radius = 50;
const hitbox_height = 150;

const hit_scan_radius = 100;
const skill_range = 100;

const buff_type = "stat";

const stats_to_buff = ["defense"]
const stat_buff_values = {
	"def":5
}


const skill_cooldown = 3;
