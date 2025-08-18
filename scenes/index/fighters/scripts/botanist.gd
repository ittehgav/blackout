extends FighterBase


const target_type = "nearest_enemy";

const skill_name = "Sow Seeds"
const description = "Spreads seeds on that ground that explode to random effects after growing.";
const flavor = "The smell stays in your nose for hours.";

const explosion_range:int = 50;

const skill_range = 200
const skill_cooldown = 5

@export var sprout_node:Sprite2D;



func skill()->void:
	animation_player.play("botanist/skill")
	animation_player.queue("fighter_base/idle")

func skill_impact()->void:
	if fighter.dead:
		return;
	var total_sprouts:int = max(1, int(fighter.technique));
	for i:int in total_sprouts:
		var sprout:Sprite2D = sprout_node.duplicate()
		var roll:Vector2 = get_random_point_in_circle(explosion_range)
		sprout.sow();
		fighter.ally_team.projectiles.add_child(sprout)
		sprout.global_position = fighter.target_unit.global_position + roll;

	

func get_random_point_in_circle(radius: float) -> Vector2:
	# Get a random angle between 0 and 2*PI
	var angle: = randf() * 2 * PI
	# Get a random distance (sqrt to ensure uniform distribution)
	var distance: = sqrt(randf()) * radius
	# Convert polar coordinates (angle + distance) to Cartesian coordinates (x, y)
	return Vector2(cos(angle), sin(angle)) * distance
