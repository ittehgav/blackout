extends CharacterBody2D

class_name IsoFighter;

signal started_moving;
signal stopped_moving;
var moving:bool;

@export var skill_cooldown:Timer;
@export var skill_retry:Timer;
@export var animation:AnimationPlayer;

## will be an attribute of arena eventually?
@export var grid:NavigationGrid;

@export_range(1, 100) var skill_range:int;

@export var sprite:Sprite2D;
@export var skill:SkillComponent;

@export var target:IsoFighter;


## cell = spot in nav grid
var current_cell:Vector2i;

## movement target = position in regular 2D coords
var movement_target:Vector2;



const angle_indexes = [
	Vector2i.UP,
	Vector2i(1, -1),
	Vector2i.RIGHT,
	Vector2i(1, 1),
	Vector2i.DOWN,
	Vector2i(-1, 1),
	Vector2i.LEFT,
	Vector2i(-1, -1)
]


func set_direction()->void:
	var direction:Vector2
	if moving:
		direction = position.direction_to(movement_target)
	else:
		direction = position.direction_to(target.position)
	
	## to make ceil work on negative numbers
	if direction.x < 0 and direction.x > -1:
		direction.x -= 1;
	if direction.y < 0 and direction.y > -1:
		direction.y -= 1;
	var angle:Vector2i = direction.ceil()

	sprite.frame_coords.x = angle_indexes.find(angle);

func angle_to_target()->Vector2i:
	var direction:Vector2 = position.direction_to(target.position);
	if direction.x < 0:
		direction.x -= 1;
	if direction.y < 0:
		direction.y -= 1;
	return direction.ceil()

func find_target()->void:
	## where it'll look in enemy team eventually 
	## but rn the target is just an exported var
	pass

func target_in_range()->bool:
	return grid.cell_distance(position, target.position) <= skill_range 

func _on_refresh_target_timeout() -> void:
	print(grid.cell_distance(position, target.position), current_cell)
	if not target_in_range():
		move()
	else:
		print("nomo?")
		stop()
	set_direction()
	
	
func move()->void:
	movement_target = grid.get_next_cell_in_path(self);
	
	if grid.spot_taken(movement_target):
		## to prevent two units from overlapping
		## when they move towards eachother at the exact same time
		## otherwise will respect the taken cells by only
		## moving through astar pathfinding
		stop()
		return
	var tween:Tween = create_tween();
	tween.tween_property(self, "position", movement_target, .25);
	grid.occupy_cell(self)
	
	if not moving:
		moving = true;
		started_moving.emit()

func stop()->void:
	if moving:
		moving = false;
		stopped_moving.emit()


func try_skill() -> void:
	if target_in_range():
		use_skill()
		skill_retry.stop();
		skill_cooldown.start();
	else:
		skill_retry.start()

func use_skill()->void:
	## function calls in animation players are bad?
	animation.play("skill_windup");
	await animation.animation_finished;
	skill.impact()
	
