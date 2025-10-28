extends Equipment

class_name Module;

const type = "module"

const size_x = 2;
const size_y = 2;

@export var use_sfx:AudioStreamPlayer

@export var cooldown:float;

@export var animation_player:AnimationPlayer

func _ready()->void:
	name = "Module - " + name

func use()->void:
	## modules won't have alt uses so needs to be separated from 
	## weapon's use super
	printerr(name + " MISSING USE")
