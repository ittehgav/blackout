extends Sprite2D

class_name WeaponBlur

@onready var base:Sprite2D = get_parent()

func _ready()->void:
	assert(base is FighterBase);
	## easier to reiterate this than to manually connect signals on every fighterbase
	base.frame_changed.connect(update_angle);

func update_angle()->void:
	frame_coords.x = base.frame_coords.x;
