extends Sprite2D

@export var stats:Node;

const skill_effects = ["aoe_damage", "aoe_stun"];
const skill_visuals = ["lunge_forward"]

const target_type = "nearest_enemy"

const skill_name = "Throw Hands"
const short_description ="Slow and resistant, deals damage and stuns enemies in an area."
const long_description ="Packs a decent punch, but takes a long time between attacks.\n
Can be upgraded for more crowd control and resistance or for more damage."


const hitbox_radius = 50;
const hitbox_height = 150;

const hit_scan_radius = 100;

const skill_range = 100;
const skill_cooldown = 5;

const stun_duration = 2;
