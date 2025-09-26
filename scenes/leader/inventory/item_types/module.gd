extends Equipment

class_name Module;

const size_x = 2;
const size_y = 2;


@export var continuous:bool=false;
var active:bool=false;##only matters for continuous modules

@export var cooldown:float;
@export var sfx:AudioStream;

@export var animation_player:AnimationPlayer

func _ready()->void:
	name = "Module - " + name
