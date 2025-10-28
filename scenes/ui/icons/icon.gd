extends TextureRect

class_name Icon;

var default_color:Color;
var highlight_color:Color;

var floating:bool=false;
var positive:bool=true;


@export var label:Label;
@export var bg:ColorRect

func _ready()->void:
	## just so setup can be called whenever to set an icon's stat
	setup()
		
func setup()->void:
	var color:Color = get_color();
	
	texture = get_icon_texture();
	
	if floating:
		## so it works properly for node2D parents
		position = Vector2.ZERO
		modulate = color;
		size = Vector2(16, 16);
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var y_shift:int = 20;
		var tween_duration:float = 2;
		if not positive:
			y_shift *= -1;
			tween_duration *= 1.5
			modulate.v -= .2;
			modulate.r += .5
		
		var tween:Tween = create_tween();
		tween.tween_property(self, "position:y", position.y - y_shift, tween_duration);
		tween.parallel().tween_property(self, "modulate:a", 0, tween_duration*.75);
		tween.tween_callback(queue_free)
	else:
		
		default_color = color;
		highlight_color = color;
		highlight_color.v += .25;
		
		modulate = default_color;
		label.add_theme_color_override("font_color", default_color)
		bg.show();

func _on_mouse_entered() -> void:
	modulate = highlight_color;
	label.add_theme_color_override("font_color", highlight_color)


func _on_mouse_exited() -> void:
	modulate = default_color;
	label.add_theme_color_override("font_color", default_color)

func animated_update()->void:
	printerr("animatedupdatemissing ", name)

func update()->void:
	## normalize this by making a method that get the value so this method doesn't propagate?
	## more complex than just propagating this?
	printerr("updatemissing ", name)

func get_color()->Color:
	printerr("gcolormissing ", name)
	return Color.DEEP_PINK

func get_icon_texture()->Texture:
	printerr("gtexturemissing ", name);
	return Texture.new();
