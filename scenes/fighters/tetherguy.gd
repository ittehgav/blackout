extends Sprite2D

@export var stats:Node;

const skill_effects = ["special"];
const skill_visuals = ["recoil"]

const target_type = "least_hp_ally"

const profile = {
	"skill_name":"Healing Tether",
	"short_description":"Deals no damage. Regenerates allies' health.",
	"long_description":"Prioritizes low-health allies."
}


const hitbox_radius = 50;
const hitbox_height = 150;

const skill_range = 500;



const skill_cooldown = 1;
