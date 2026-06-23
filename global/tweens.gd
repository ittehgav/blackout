extends Node


func ui_fade_in(target:CanvasItem, duration:float = .5)->Tween:
	target.show();
	
	target.modulate.a = .1
	## tween goes into the control because of nodes that process when pasued
	var tween:Tween = create_tween();
	tween.tween_property(target, "modulate:a", 1, duration);
	return tween

func ui_fade_out(target:CanvasItem, hide_after:bool=true, duration:float = .5)->Tween:
	var tween:Tween = create_tween();
	tween.tween_property(target,"modulate:a", 0, duration);
	if hide_after:
		tween.tween_callback(target.hide);
		return tween;
	else:
		return tween;


func shader_color_blink(target:Sprite2D, target_color:Color, duration:float = .5)->Tween:
	## TODO make this just tween the I property of the fighter's modulate
	## when they make it accessible by code
	target.material.set_shader_parameter("target_color", target_color);
	target.material.set_shader_parameter("grad", 1.0);

	var tween:Tween = create_tween();
	tween.tween_property(target.material, "shader_parameter/grad", 0.0, duration);
	return tween;



func fade_up(target:CanvasItem, free_after:bool = true)->Tween:
	var tween:Tween = create_tween();
	tween.tween_property(target, "position:y", target.position.y - 50, .5)
	if free_after:
		tween.parallel().tween_property(target, "modulate:a", 0, .5)
		tween.tween_callback(target.queue_free);
	return tween
	

func squish_bar(target:TextureProgressBar)->Tween:
	## bar can't be in a container
	target.scale = Vector2(.9, .5);
	var tween:Tween = create_tween();
	tween.tween_property(target, "scale", Vector2.ONE, .2);
	return tween;

func stretch_bar(target:TextureProgressBar)->Tween:
	## bar can't be in a container
	target.scale = Vector2(1.1, 1.5);
	var tween:Tween = create_tween();
	tween.tween_property(target, "scale", Vector2.ONE, .5);
	return tween;

func color_blink(target:CanvasItem, target_color:Color, duration:float = .2, target_property:String="modulate")->Tween:
	target[target_property] = target_color;

	var tween:Tween = create_tween();
	tween.tween_property(target, target_property, Color.WHITE, duration);
	return tween
#
#func y_shake(target:CanvasItem, shake_count:int = 2, shake_range:int = 50)->Tween:
	#var initial_y:int = target.position.y;
	#var roll_1:int = randi_range(0, shake_range)
	#target.position.y -= roll_1
	#
	#var tween:Tween = create_tween();
	#for i in shake_count:
		#var roll:int = randi_range(0, shake_range)
		#if i % 2:
			#roll *= -1;
		#tween.tween_property(target, "position:y", initial_y + roll, .1)
	#tween.tween_property(target, "position:y", initial_y, .1);
#
	#return tween
	#
func tween_count_label(target:Label, final_value:int, duration:float = .5)->Tween:
	var tween:Tween = create_tween();
	var current_value:int = int(target.text)
	tween.tween_method(set_label_text.bind(target), current_value, final_value, duration );
	return tween

func set_label_text( target:int, label:Label)->void:
	label.text = str(target)

const default_floating_text_font_size = 64
func floating_text(string:String, label_parent:Node, on_cursor:bool=true, font_color:Color=Color.BLACK, font_size:int=default_floating_text_font_size)->Tween:
	var label:Label = Label.new();
	label.text = string
	label_parent.add_child(label);
	if on_cursor:
		label.global_position = label_parent.get_global_mouse_position();

	if font_color != Color.BLACK:
		label.add_theme_color_override("font_color", font_color);

	label.add_theme_constant_override("font_size", font_size);
	
	var tween:Tween = create_tween();
	tween.tween_property(label, "position:y", label.position.y - 30, 1);
	tween.parallel().tween_property(label, "modulate:a", 0, 1);
	tween.tween_callback(label.queue_free);

	return tween
