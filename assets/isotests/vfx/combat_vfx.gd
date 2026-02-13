extends Sprite2D

class_name CombatVFX
## class for any VFX that will play in combat 
## besides skill windup highlights

## WILL GET THEIR OWN SEPARATE FOLDER AND GET BUILT MODULARLY
## first batch will be for recruits
## player's version will have modifiers to stick out more 
## in a scripted way that still lets you just drag and drop them on the item/unit

@export var animation_player:AnimationPlayer;
## animation player is limited
## (can't make a directed motion in a modular way based on the 
## direction the unit is facing)
## WILL ALWAYS CONTROL: 
## Y frame coord
## scale (and anchor will likely need to be adjusted on X frame change?)

enum AnimationType {regular}
## IEs: grow and fade, grow and brighten up
## gravity pulse will be the pulse in source and target and that will be spefcified here too
@export var animation_type:AnimationType;

var angle_source:Sprite2D
func _ready() -> void:
	set_sprite_root()
	
	
func set_sprite_root()->void:
	var parent:Node = get_parent();
	while not (parent is Sprite2D) or parent is Item:
		parent = parent.get_parent();
		assert (not (parent is Arena)) ## catches misplaced vfx node
	angle_source = parent;
	angle_source.frame_changed.connect(match_source_angle);

func match_source_angle()->void:
	## likely will have to add more adjustments?
	frame_coords.x = angle_source.frame_coords.x;
	
