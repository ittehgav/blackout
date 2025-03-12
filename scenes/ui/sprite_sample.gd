extends Control;

class_name SpriteSample;

@export var target_base:Sprite2D;

@export var tooltip_scene:PackedScene;
@export var tooltip:Tooltip;

func _ready():
	if target_base:
		## for samples that always show the same node
		set_sample(target_base)
	
func set_sample(target:Sprite2D)->void:
	if not target_base or (target_base and not is_ancestor_of(target_base)) or target_base is Item:
		## idk but it works
		target_base = target.duplicate();
		add_child(target_base)
	
	if target_base is FighterBase:
		ColorCoder.color_code_fighter(target_base, 1, true);
		$bob_timer.start()
	if target_base is Weapon:
		ColorCoder.color_code_weapon(target_base);
		
		target_base.offset = Vector2.ZERO;
		target_base.scale = Vector2(2, 2);
		target_base.centered = false;
		
		## tooltip needs to be set AFTER transforming the target so the hoverbox gets set appropriately
		set_tooltip();

		
func set_tooltip():
	if tooltip:
		tooltip.queue_free();

	tooltip = tooltip_scene.instantiate();
	tooltip.target = target_base;

	add_child(tooltip)
	var sample_size = target_base.texture.get_size() * target_base.scale.x;
	custom_minimum_size = sample_size;

func _on_timer_timeout() -> void:
	if target_base.frame:
		target_base.frame = 0;
	else:
		target_base.frame = 1;
