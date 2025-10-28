extends Control;

class_name SpriteSample;

@export var target_base:Sprite2D=null;
@export var additional_data:Label;
@export var anchor:Control

@export var tooltip:Tooltip;

@export var add_tooltip:bool = true;
@export var enable_hover_panel:bool = true;

@export var target_scale:Vector2 = Vector2.ONE

func set_sample(target:FighterBase)->void:
	if target_base:
		## so a sample can load units and replace them
		target_base.queue_free();
	

	target_base = target.duplicate();
	target_base.texture = ColorCoder.color_code_fighter_base_texture(target, 1)
	
	target_base.scale = target_scale
	anchor.add_child(target_base)
	target_base.position = Vector2.ZERO;
	target.clear_for_sample.call_deferred()
	target_base.z_index = 5

	
	
	if not target_base is PlayerFighterBase:
		target_base.set_material(null)
		set_rectangle();
		set_tooltip();


	

func set_rectangle()->void:
	if enable_hover_panel:
		var sample_size:Vector2 = target_base.texture.get_size() * target_base.scale.x;
		custom_minimum_size = sample_size;
		size = sample_size;
		if target_base is FighterBase and not target_base is PlayerFighterBase:
			mouse_entered.connect(show_panel);
			mouse_exited.connect(hide_panel)
			custom_minimum_size.x /= 12
			custom_minimum_size.y /= 3

func set_tooltip()->void:
	if add_tooltip:
		tooltip = Index.scenes.ui.tooltip.instantiate();
		tooltip.target = target_base;

		add_child(tooltip)


func _on_timer_timeout() -> void:
	if target_base:
		if target_base.frame:
			target_base.frame = 0;
		else:
			target_base.frame = 1;

func show_panel()->void:
	$panel.modulate.a = .5;

func hide_panel()->void:
	$panel.modulate.a = 0;
