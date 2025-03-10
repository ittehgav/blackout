extends PanelContainer

class_name Tooltip;

@export var target:Node;
## where the tooltip will get the data from

@export var name_label:Label;
@export var description_label:RichTextLabel;
@export var icon:TextureRect;

@export var hover_timer:Timer;

@onready var window_size:Vector2 = DisplayServer.screen_get_size();

func _ready() -> void:
	var parent:Control = get_parent()
	assert (parent is Control);
	await parent.ready
	parent.mouse_entered.connect(hover_timer.start);
	parent.mouse_exited.connect(stop_hover_timer);
	
	

	name_label.text = target.name;
	if "tooltip_name_color" in target:
		name_label.modulate = target.tooltip_name_color;
	if "icon_texture" in target:
		icon.texture = target.icon_texture;
	if "description" in target:
		description_label.text = target.description;
	
	description_label.custom_minimum_size.x = size.x;



func _on_hover_timer_timeout() -> void:
	modulate.a = .1;
	show();
	var tween = create_tween();
	tween.tween_property(self, "modulate:a", 1, .5);

func stop_hover_timer():
	hide();
	hover_timer.stop();


func set_rel():
	var parent:Control = get_parent()
	if global_position.x < window_size.x:
		if global_position.y < window_size.y:
			set_anchors_preset(PRESET_TOP_LEFT);
			#position -= size
		else:
			set_anchors_preset(PRESET_BOTTOM_LEFT);
			#position += parent.size
	else:
		if global_position.y < window_size.y:
			set_anchors_preset(PRESET_TOP_RIGHT);
			#position.x += parent.size.x
		else:
			set_anchors_preset(PRESET_BOTTOM_RIGHT);
			#position.x -= size.x;
