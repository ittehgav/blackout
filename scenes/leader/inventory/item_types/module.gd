extends Equipment

class_name Module;
	
signal equipped;

## circle around the player that blinks when the module is available
@export var projection_color:Color;
@export var projection_range:int=0;
@export_range(0, 4) var projection_texture_index:int = 2;
@export var show_aoe_vfx:bool=false;
@export var custom_projection_texture:Texture;

func _ready()->void:
	super();
	name = "Module - " + name

	
const size_x = 2;
const size_y = 2;
	
func check_available()->bool:
	return true;

const tooltip_hint = "[right-click] to equip.";
