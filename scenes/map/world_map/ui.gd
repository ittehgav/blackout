extends Control

func _ready() -> void:
	Entities.ui_sfx.recursive_connect_ui_sfx(self);
