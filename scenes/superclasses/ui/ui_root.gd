extends Control

class_name UIRoot;

@export var ui_sfx:UISFX;


func _ready():
	recursive_connect_ui_feedback(self)


func recursive_connect_ui_feedback(node:Control)->void:
	if "pressed" in node:
		node.pressed.connect(ui_sfx.ui_click_sound.bind(node));
	
	if node is Button:
		node.mouse_entered.connect(ui_sfx.ui_mouseover_sound.bind(node))
	if node is TabContainer:
		node.tab_hovered.connect(ui_sfx.tab_mouseover_sound.bind(node))
		node.tab_changed.connect(ui_sfx.tab_click_sound.bind(node))
	if node is Icon:
		node.mouse_entered.connect(ui_sfx.ui_mouseover_sound.bind(node))



	for c in node.get_children():
		if c is Control:
			recursive_connect_ui_feedback(c);
