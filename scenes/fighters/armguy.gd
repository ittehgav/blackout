extends Sprite2D


const skill_effects = ["aoe_damage", "aoe_stun"];
const skill_visuals = ["lunge_forward"]

const target_type = "nearest_enemy"

const profile = {
	"skill_name":"Throw Hands",
	"short_description":"Slow and resistant, deals damage and stuns enemies in an area.",
	"long_description":"Packs a decent punch, but takes a long time between attacks.\n
	Can be upgraded for more crowd control and resistance or for more damage."
}

const hitbox_radius = 50;
const hitbox_height = 150;


const hit_scan_radius = 100;
const skill_range = 100;

const stun_duration = 2;


const stats = {
	"max_hp":200,
	"attack":100,
	"move_speed":500,
	"def":10

}

const skill_cooldown = 5;
