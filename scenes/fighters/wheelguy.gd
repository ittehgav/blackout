extends Sprite2D

const skill_effects = ["special"];
const skill_visuals = ["power_up_glow", "shake"]

const target_type = "nearest_enemy"

const profile = {
	"skill_name": "Accelerate",
	"short_description":"Deals damage to surrounding enemies that speeds up over time.",
	"long_description":"Can ramp up to deal massive damage"
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

func special_skill(fighter:CharacterBody2D):
	pass
