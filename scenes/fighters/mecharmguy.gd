extends Sprite2D


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
const stats_to_debuff = ["def"];
const def_debuff_value = 5;

const stats = {
	"max_hp":200,
	"attack":100,
	"move_speed":500,
	"def":10
}

const skill_cooldown = 3;
