extends Sprite2D


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

## TODO: figure out how defense works (fractions are cooler than percentages)
const buff_type = "stat";

const stats_to_buff = ["def"]
const def_buff_value = 5;

const stats = {
	"max_hp":200,
	"attack":100,
	"move_speed":500,
	"def":10
}

const skill_cooldown = 3;
