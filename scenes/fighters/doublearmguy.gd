extends Sprite2D

@export var stats:Node;

const skill_effects = ["aoe_damage", "aoe_stun"];
const skill_visuals = ["lunge_forward"]

const target_type = "nearest_enemy"

const profile = {
	"skill_name":"Throw More Hands",
	"short_description":"Damages and stuns enemies in a large area.",
	"long_description":"Very resistant and disruptive."
}

const stun_duration = 2;

const hitbox_radius = 50;
const hitbox_height = 150;

const hit_scan_radius = 200;
const skill_range = 200;



const skill_cooldown = 5;
