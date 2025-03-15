extends FighterBase

var hit_scan_shape:CollisionShape2D;

const skill_effects = ["special"];
const skill_visuals = ["recoil", "shrink_target"]

const target_type = "nearest_enemy"

const skill_name = "Shockwave"
const description = "Knocks back and stuns enemies."
const long_description = "[color=blue]Doesn't deal damage.[/color] Knocks back and stuns a target enemy, also stuns any other enemy it comes into contact with."

func full_skill_description(unit:FighterUnit)->String:
	var stun_duration_string = Meta.get_technique_scaled_string(unit, "stun_duration");
	var string:String = "[color=blue]Doesn't deal damage.[/color] Knocks back an enemy target and stuns them and any enemies they collide with for "\
	+ stun_duration_string + " seconds.";
	return string;

const tags = [
	"disruptor",
	"scientist",
	"doctor"
]

const hitbox_radius = 25;
const hitbox_height = 60;
const hitbox_offset = Vector2(0, 5)

const hit_scan_type = "rectangle";
const hit_scan_length = 500;
const hit_scan_width = 100;

const skill_range = 300;

const skill_cooldown = 2;

const knock_back_distance = 500;

const stun_duration = 1;
const secondary_stun_duration = .5;

func special_setup()->void:
	fighter.target_change.connect(update_hit_scan.bind(fighter));
	hit_scan_shape = fighter.get_node("hit_scan/shape")

func _process(_delta:float)->void:
	if fighter and fighter.target_unit:
		hit_scan_shape.global_position = fighter.target_unit.global_position;
		hit_scan_shape.position.x += hit_scan_shape.shape.size.x/2;


func special_skill()->void:
	Combat.stun_target(fighter, fighter.target_unit);
	
	for target:Node in fighter.hit_scan.get_overlapping_bodies():
		Combat.stun_target(fighter, target, secondary_stun_duration)
	
	var direction:Vector2 = fighter.position.direction_to(fighter.target_unit.position).normalized();
	var target_position:Vector2 = fighter.target_unit.position + direction * knock_back_distance;
	
	var tween:Tween = create_tween();
	tween.tween_property(fighter.target_unit, "position", target_position, .1)
	

func update_hit_scan()->void:
	fighter.hit_scan.get_node("shape").shape.size.y = fighter.target_unit.get_node("hitbox").shape.height
	
