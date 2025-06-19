extends Node

var current_state:String = "main"

func _ready()->void:
	Entities.main = self;
	
