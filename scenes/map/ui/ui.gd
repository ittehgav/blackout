extends Control

@export var settlement_ui:Control;

#func _ready() -> void:
	#Entities.ui_sfx.recursive_connect_ui_feedback(self);
