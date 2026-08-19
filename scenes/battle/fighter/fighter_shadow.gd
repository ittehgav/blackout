extends Sprite2D
class_name FighterShadow;

@export var source:ActiveFighter

const light_origin = Vector2(0, -1000)

func source_ready()->void:
	texture = source.sprite.texture;
	hframes = source.sprite.hframes
	vframes = source.sprite.vframes

func source_frame_changed()->void:
	frame_coords = source.sprite.frame_coords;

func _process(_delta:float)->void:
	flip_h = not source.sprite.flip_h
	global_rotation = light_origin.angle_to_point(source.position) + PI/2
