extends Control;

class_name SpriteSample;

@export var target_base:Sprite2D;
@export var additional_data:Label;

@export var tooltip_scene:PackedScene;
@export var tooltip:Tooltip;

@export var add_tooltip = true;
@export var enable_hover_panel = true;

@export var autostart:bool;

func _ready()->void:
	if autostart:
		$bob_timer.start()

func disable_panel():
	$panel.queue_free();
	mouse_entered.disconnect(show_panel);
	mouse_exited.disconnect(hide_panel);
	

func set_sample(target:Sprite2D)->void:
	if target_base and not autostart:
		target_base.queue_free();
	
	if not autostart:
		## idk but it works
		target_base = target.duplicate();
		add_child(target_base)
	
	if target_base is FighterBase:
		ColorCoder.color_code_fighter(target_base, 1, true);
		target_base.centered = false;
		if not target_base is PlayerFighterBase:

			target_base.set_material(null)
			set_rectangle();
			set_tooltip();

	if target_base is Weapon:
		$bob_timer.stop()
		ColorCoder.color_code_weapon(target_base);
			
		target_base.offset = Vector2.ZERO;
		target_base.scale = Vector2(2, 2);
		target_base.centered = false;
		set_rectangle()
		set_tooltip();

		## tooltip needs to be set AFTER transforming the target so the hoverbox gets set appropriately
	

func set_rectangle():
	if enable_hover_panel:
		var sample_size = target_base.texture.get_size() * target_base.scale.x;
		custom_minimum_size = sample_size;
		size = sample_size;
		if target_base is FighterBase and not target_base is PlayerFighterBase:
			mouse_entered.connect(show_panel);
			mouse_exited.connect(hide_panel)
			target_base.offset.x = -50
			custom_minimum_size.x /= 12
			custom_minimum_size.y /= 3

func set_tooltip():
	if add_tooltip:
		if tooltip:
			tooltip.queue_free();

		tooltip = tooltip_scene.instantiate();
		tooltip.target = target_base;

		add_child(tooltip)


func _on_timer_timeout() -> void:
	if target_base:
		if target_base.frame:
			target_base.frame = 0;
		else:
			target_base.frame = 1;

func show_panel():
	$panel.modulate.a = .5;

func hide_panel():
	$panel.modulate.a = 0;
