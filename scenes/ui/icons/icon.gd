extends TextureRect

class_name Icon;

var default_color:Color;
var highlight_color:Color;


@export var label:Label;


func _on_mouse_entered() -> void:
	modulate = highlight_color;
	label.add_theme_color_override("font_color", highlight_color)


func _on_mouse_exited() -> void:
	modulate = default_color;
	label.add_theme_color_override("font_color", default_color)

func update()->void:
	## normalize this by making a method that get the value so this method doesn't propagate?
	## more complex than just propagating this?
	pass
