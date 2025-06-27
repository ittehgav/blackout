extends FighterBase


const skill_visuals = ["recoil", "shrink_target"]
const projection_vfx = ["gravity"];

const skill_use_sfx = ["gravity"]
const skill_hit_sfx = []

const sample_offset = Vector2(1, -26)
const target_type = "nearest_enemy"

const skill_name = "Shockwave"
const description = "Knocks back and stuns enemies."
const flavor = "He's not entierly sure how it works either."

const tags = [
	"disruptor",
	"scientist",
	"doctor"
]


const hitbox_radius = 25;
const hitbox_height = 60;
const hitbox_offset = Vector2(0, 5)

const skill_range = 300;
const skill_cooldown = 6;

const hit_scan_type = "rectangle";
const hit_scan_length = 500;
const hit_scan_width = 100;

const knock_back_distance = 500;

const status_duration = .5;

var hit_scan_shape:CollisionShape2D;

func full_skill_description(unit:FighterUnit)->String:
	var stun_duration_string:String = Index.get_technique_scaled_string(unit, "stun", "status_duration");
	var string:String = Index.get_color_tag("no_dmg") + "Doesn't deal damage.[/color] Knocks back an enemy target and stuns them and any enemies they collide with for "\
	+ stun_duration_string + " seconds.";
	return string;


func special_setup()->void:
	fighter.target_changed.connect(update_hit_scan);
	hit_scan_shape = fighter.get_node("hit_scan/shape")

func _process(_delta:float)->void:
	if fighter and fighter.target_unit:
		hit_scan_shape.global_position = fighter.target_unit.global_position;
		hit_scan_shape.position.x += hit_scan_shape.shape.size.x/2;


func skill()->void:
	Combat.stun_target(fighter, fighter.target_unit);
	
	for target:Node in fighter.hit_scan.get_overlapping_bodies():
		Combat.stun_target(fighter, target)
	
	var direction:Vector2 = fighter.position.direction_to(fighter.target_unit.position).normalized();
	var target_position:Vector2 = fighter.target_unit.position + direction * knock_back_distance;
	
	var tween:Tween = create_tween();
	tween.tween_property(fighter.target_unit, "position", target_position, .1)
	

func update_hit_scan()->void:
	if fighter.target_unit:
		fighter.hit_scan.get_node("shape").shape.size.y = fighter.target_unit.get_node("hitbox").shape.height
	
