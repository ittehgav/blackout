extends Sprite2D


const skill_effects = ["stun", "direct_damage"];
const skill_visuals = ["recoil"]

const target_type = "nearest_enemy"

const profile = {
	"skill_name":"Taser Gun",
	"short_description":"Deals light damage and stuns target.",
	"long_description":"Can be upgraded to heal allies or for heavy AOE damage."
}

const hitbox_radius = 50;
const hitbox_height = 150;

const skill_range = 500;

const stats = {
	"max_hp":200,
	"attack":100,
	"move_speed":500,
	"def":10
}

const skill_cooldown = 1;
