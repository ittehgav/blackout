extends Control;

class_name SpriteSample;




@export var target_base:Sprite2D=null;
@export var additional_data:Label;

@export var tooltip:Tooltip;

@export var add_tooltip:bool = true;
@export var enable_hover_panel:bool = true;

@export var autostart:bool;



func _ready()->void:
	if autostart:
		$bob_timer.start()

	

func set_sample(target:Sprite2D, color_scheme_index:int=Entities.player.color_scheme_index, extra_offset:Vector2 = Vector2(30, -15))->void:
	if target_base:
		target_base.free();
	
	if not autostart and target:
		## idk but it works
		target_base = target.duplicate();
		add_child(target_base)
		
	if target_base is FighterBase:
		target_base.offset = target_base.sample_offset + extra_offset;

		ColorCoder.color_code_fighter(target_base, color_scheme_index, true);
		if not target_base is PlayerFighterBase:
			target_base.set_material(null)
			set_rectangle();
			set_tooltip();

	if target_base is Weapon:
		$bob_timer.stop()
		ColorCoder.color_code_weapon(target_base, Entities.player.color_scheme_index);
			
		target_base.offset = Vector2.ZERO;
		target_base.scale = Vector2(2, 2);
		target_base.centered = false;
		set_rectangle()
		set_tooltip();

		## tooltip needs to be set AFTER transforming the target so the hoverbox gets set appropriately
	

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
