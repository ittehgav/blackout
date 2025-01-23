extends Sprite2D


const skill_effects = ["aoe_damage"];
const skill_visuals = ["recoil"]

const target_type = "nearest_enemy"

const profile = {
	"skill_name": "Piercing Shot",
	"short_description":"Fires a strong, piercing bolt.",
	"long_description":"Deals massive damage to enemies in a straight line."
}

const hit_scan_type = "line";
const hit_scan_length = 2000.0;

const hitbox_radius = 50;
const hitbox_height = 150;

const skill_range = 1000;

const stats = {
	"max_hp":200,
	"attack":100,
	"move_speed":500,
	"def":10
}

const skill_cooldown = 5;
