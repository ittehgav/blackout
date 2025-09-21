extends Control;

class_name SpriteSample;

@export var target_base:Sprite2D=null;
@export var additional_data:Label;

@export var tooltip:Tooltip;

@export var add_tooltip:bool = true;
@export var enable_hover_panel:bool = true;

@export var target_scale:Vector2 = Vector2.ONE

func set_sample(target:Sprite2D, color_scheme_index:int=Entities.player.color_scheme_index, extra_offset:Vector2 = Vector2(30, -15))->void:
	if target_base:
		target_base.free();

	## idk but it works
	target_base = target.duplicate();
	target_base.centered = false
	target_base.scale = target_scale
	add_child(target_base)
	target_base.z_index = 5
	target_base.position = Vector2(-100, -100)

	
	target_base.offset.x -= 5 * target_scale.x
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
			target_base.position.y += sample_size.y/3;
			mouse_entered.connect(show_panel);
			mouse_exited.connect(hide_panel)
			custom_minimum_size.x /= 12
			custom_minimum_size.y /= 3

func set_tooltip()->void:
	if add_tooltip:
		if tooltip:
			tooltip.free();

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
