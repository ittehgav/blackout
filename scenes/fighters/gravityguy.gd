extends Sprite2D

@export var stats:Node;

var fighter_node:CharacterBody2D;
var hit_scan_shape:CollisionShape2D;

func special_setup(fighter:CharacterBody2D)->void:
	fighter.target_change.connect(update_hit_scan.bind(fighter));
	fighter_node = fighter;
	hit_scan_shape = fighter.get_node("hit_scan/shape")

func _process(_delta)->void:
	if fighter_node and fighter_node.target_unit:
		hit_scan_shape.global_position = fighter_node.target_unit.global_position;
		hit_scan_shape.position.x += hit_scan_shape.shape.size.x/2;

const skill_effects = ["special"];
const skill_visuals = ["recoil"]

const target_type = "nearest_enemy"

const profile = {
	"skill_name":"Shockwave",
	"short_description":"Knocks back and stuns enemies.",
	"long_description":"Knocks back and stuns an enemy, also stuns any other enemies it comes into contact with."
}

const hitbox_radius = 50;
const hitbox_height = 150;

const hit_scan_type = "rectangle";
const hit_scan_length = 500;
const hit_scan_width = 100;

const skill_range = 300;

const skill_cooldown = 2;

const knock_back_distance = 500;

const stun_duration = 1;
const secondary_stun_duration = .5;

func special_skill(fighter:CharacterBody2D)->void:
	Combat.stun_target(fighter, fighter.target_unit);
	
	for target in fighter.hit_scan.get_overlapping_bodies():
		Combat.stun_target(fighter, target, secondary_stun_duration)
	
	var direction = fighter.position.direction_to(fighter.target_unit.position).normalized();
	var target_position:Vector2 = fighter.target_unit.position + direction * knock_back_distance;
	
	var tween = create_tween();
	tween.tween_property(fighter.target_unit, "position", target_position, .1)
	

func update_hit_scan(fighter:CharacterBody2D)->void:
	fighter.hit_scan.get_node("shape").shape.size.y = fighter.target_unit.get_node("hitbox").shape.height
	
