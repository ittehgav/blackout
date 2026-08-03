extends Control

class_name UIRoot;



@export var ui_sfx:UISFX;

func _ready()->void:
	assert(ui_sfx)
	if not get_parent() is UIRoot:
		get_window().size_changed.connect(resize);
		resize.call_deferred()
	
	if ui_sfx:
		## if it doesn't have SFX this just serves to resize along with window
		recursive_connect_ui_feedback(self)
	

func resize()->void:
	if is_inside_tree():
		set_deferred("size", get_window().size)


func recursive_connect_ui_feedback(node:Node)->void:
	if "pressed" in node:
		node.pressed.connect(ui_sfx.ui_click_sound.bind(node));

	if node is BaseButton:
		node.mouse_entered.connect(ui_sfx.ui_mouseover_sound.bind(node))
		node.mouse_entered.connect(Tweens.mouseover_shake.bind(node))
	if node is TabContainer:
		node.tab_hovered.connect(ui_sfx.tab_mouseover_sound.bind(node))
		node.tab_changed.connect(ui_sfx.tab_click_sound.bind(node))
	if node is Icon:
		node.mouse_entered.connect(ui_sfx.ui_mouseover_sound.bind(node))
		node.mouse_entered.connect(Tweens.mouseover_shake.bind(node))

	for c in node.get_children():
		if c is Control:
			recursive_connect_ui_feedback(c);
