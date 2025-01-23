extends Sprite2D


const skill_effects = ["aoe_damage", "aoe_damage_debuff"];
const skill_visuals = ["lunge_forward"]

const target_type = "nearest_enemy"

const profile = {
	"skill_name":"Rusty Pipe",
	"short_description":"Moderate resistance and damage, attacks reduce enemies' damage.",
	"long_description":"Decent front-line unit.\n
Can be upgraded to become more resistant or to deal great AOE damage."
}

const hitbox_radius = 50;
const hitbox_height = 150;

const hit_scan_radius = 100;
const skill_range = 100;

const stats = {
	"max_hp":200,
	"attack":100,
	"move_speed":500,
	"def":10
}

const skill_cooldown = 3;
