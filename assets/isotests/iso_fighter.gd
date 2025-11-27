extends CharacterBody2D

class_name IsoFighter;

## will be an attribute of arena eventually?
@onready var grid:TileMapLayer = get_parent();

@export var skill_range:int;

var target:IsoFighter;
@export var sprite:Sprite2D;



@export var target_position:Vector2;

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
	if target:
		var direction:Vector2i = position.direction_to(target.position).ceil()
		sprite.frame_coods.x = angle_indexes.find(direction)
	if not grid.check_target_in_range(self):
		pass

func _on_refresh_target_timeout() -> void:
	set_direction()
	
	
