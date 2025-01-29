extends Sprite2D


const skill_effects = ["special"];
const skill_visuals = ["recoil"]

const target_type = "nearest_enemy"

const profile = {
	"skill_name":"Shockwave",
	"short_description":"Knocks back and stuns enemies.",
	"long_description":"Knocks back and stuns an enemy, if they collide with another enemy, both get stunned."
}

const hitbox_radius = 50;
const hitbox_height = 150;

const skill_range = 300;

const stats = {
	"max_hp":200,
	"attack":100,
	"move_speed":500,
	"defense":10
}

const skill_cooldown = 2;

func special_skill(fighter:CharacterBody2D)->void:
	pass
