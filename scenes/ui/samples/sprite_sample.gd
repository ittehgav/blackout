extends Control;

class_name SpriteSample;

@export var sprite:Sprite2D;
@export var additional_data:Label;
@export var anchor:Control

@export var tooltip:Tooltip;

@export var add_tooltip:bool = true;
@export var enable_hover_panel:bool = true;



func set_sample(target:FighterBase)->void:
	sprite.texture = target.texture;
	sprite.hframes = target.hframes
	sprite.frame_coords.x = 3;
	## not sure if changin the hframes messes with the frame_coords?


	
	
	if not target is PlayerFighterBase:
		set_rectangle(target);
		set_tooltip(target);


	

func set_rectangle(target:FighterBase)->void:
	if enable_hover_panel:
		var sample_size: = sprite.texture.get_size()/Vector2(8, target.hframes)
		custom_minimum_size = sample_size;
		size = sample_size;
		
		if target is FighterBase and not target is PlayerFighterBase:
			mouse_entered.connect(show_panel);
			mouse_exited.connect(hide_panel)
			custom_minimum_size.x /= 12
			custom_minimum_size.y /= 3

func set_tooltip(target:FighterBase)->void:
	if add_tooltip:
		tooltip = Index.scenes.ui.tooltip.instantiate();
		tooltip.target = target;

		add_child(tooltip)




func show_panel()->void:
	$panel.modulate.a = .5;

func hide_panel()->void:
	$panel.modulate.a = 0;
