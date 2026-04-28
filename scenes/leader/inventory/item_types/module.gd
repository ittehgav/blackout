@abstract
@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/icon_thunder.png")
class_name Module
extends Equipment


const type = "module"

const size_x = 2;
const size_y = 2;

@export var use_sfx:AudioStreamPlayer

@export var cooldown:float;

@export var animation_player:AnimationPlayer

func _ready()->void:
	name = "Module - " + name

func use()->void:
	printerr("MISSINGUSE ", name)
	## modules won't have alt uses so needs to be separated from 
	## weapon's use super
