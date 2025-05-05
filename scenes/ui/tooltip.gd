extends PanelContainer

class_name Tooltip;

@export var target:Node;
## where the tooltip will get the data from

@export var name_label:Label;
@export var sub_name_label:Label;
@export var description_label:RichTextLabel;
@export var icon:TextureRect;
@export var hint:Label;

@export var hover_timer:Timer;

@onready var window_size:Vector2 = DisplayServer.screen_get_size();

@export_group("hardcode")
@export var hardcoded_name:String;
@export var hardcoded_sub_name:String;
@export var hardcoded_description:String;

func _ready() -> void:
	var parent:Control = get_parent()
	assert (parent is Control and not parent is Container);
	if not parent.is_node_ready():
		await parent.ready
		setup()
	else:
		setup();
	## lots of places where the sample target is defined on load

func setup()->void:
	if not target:
		queue_free();
		return

	var parent:Node = get_parent();
	parent.mouse_entered.connect(hover_timer.start);
	parent.mouse_exited.connect(stop_hover_timer);

	name_label.text = target.name;
	if "sub_name" in target:
		sub_name_label.show()
		sub_name_label.text = target.sub_name;
	if "tooltip_name_color" in target:
		name_label.modulate = target.tooltip_name_color;
	if "icon_texture" in target:
		icon.show()
		icon.texture = target.icon_texture;
	if "description" in target:
		description_label.show()
		description_label.text = target.description;
	if "tooltip_hint" in target:
		hint.show();
		hint.text = target.tooltip_hint;
	
	if hardcoded_name:
		name_label.text = hardcoded_name;
	if hardcoded_sub_name:
		sub_name_label.show()
		sub_name_label.text = hardcoded_sub_name
	if hardcoded_description:
		description_label.show();
		description_label.text = hardcoded_description
	




func disable()->void:
	hover_timer.timeout.disconnect(_on_hover_timer_timeout)
	
func enable()->void:
	hover_timer.timeout.connect(_on_hover_timer_timeout)

func _on_hover_timer_timeout() -> void:
	if target is Settlement and Entities.world_map.tile_map.position_in_fog(target.position):
		return
	modulate.a = .1;

	show();
	position = get_parent().get_local_mouse_position();
	size.y -= 10000
	size.y += 10
		
	Tweens.ui_fade_in(self);

func stop_hover_timer()->void:
	hide();
	hover_timer.stop();
