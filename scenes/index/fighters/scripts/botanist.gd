extends FighterBase



const skill_name = "Explosive Gardening"
const description = "Spreads seeds on the ground that explode to apply random debuffs and damage enemies.";
const flavor = "The smell stays in your nose for hours.";

const explosion_range:int = 50;

const skill_range = MID_RANGE
const skill_cooldown = 4

const evolutions = [
	"Dryad",
	"Keeper"
]

@export var sprout_node:Sprite2D;

func damage_modifier(damage:float, _unit:FighterUnit=null)->float:
	return damage/2;

func full_skill_description(unit:FighterUnit)->String:
	var total_sprouts:int = max(1, int(unit.stats.technique))
	var sprouts_string:String = Index.get_color_tag("technique") + str(total_sprouts) + " sprout";
	if total_sprouts > 1:
		sprouts_string += "s";
	sprouts_string += "[/color]";
	 
	var damage_string:String = Index.get_unit_damage_string(unit);
	
	var string:String = "Places " +sprouts_string +\
	 " around a target enemy that grow and explode after 2 seconds, dealing "+\
	damage_string + " to enemies in an area."
	string += "\nCan be [u]upgraded[/u] to apply escalating DOT or to apply strong debuffs to enemies in an area."
	
	return string

func skill()->void:
	animation_player.play("botanist/skill")
	animation_player.queue("fighter_base/idle")

func skill_effect()->void:
	var total_sprouts:int = max(1, int(fighter.technique));
	var sprout:Sprite2D;
	for i:int in total_sprouts:
		sprout = sprout_node.duplicate()
		var roll:Vector2 = get_random_point_in_circle(explosion_range)
		sprout.sow();
		fighter.ally_team.projectiles.add_child(sprout)
		sprout.global_position = fighter.target_unit.global_position + roll;
		
	sprout.animation_player.animation_finished.connect(skill_finished.emit)

func last_explosion_finished(_anim_name:String)->void:
	## so it catches the signal argument
	skill_finished.emit();

func get_random_point_in_circle(radius: float) -> Vector2:
	# Get a random angle between 0 and 2*PI
	var angle: = randf() * 2 * PI
	# Get a random distance (sqrt to ensure uniform distribution)
	var distance: = sqrt(randf()) * radius
	# Convert polar coordinates (angle + distance) to Cartesian coordinates (x, y)
	return Vector2(cos(angle), sin(angle)) * distance
