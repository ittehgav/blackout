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

func setup(make_connection:bool=true)->void:
	var connections:Array = get_parent().mouse_entered.get_connections();
	if make_connection:
		for c:Dictionary in connections:
			if c.callable == hover_timer.start:
				make_connection = false;
	
	if not target:
		return
	if target is Item:
		sub_name_label.show()
		if target is Weapon:
			sub_name_label.text = "Weapon";
		elif target is ResourceContainer:
			if target.raw_stack:
				sub_name_label.text = "Resource";
			else:
				sub_name_label.text = "Container";
		elif target is Module:
			sub_name_label.text = "Module";
		elif target is Accessory:
			sub_name_label.text = "Accessory"
		

	
	if make_connection:
		var parent:Node = get_parent();
		parent.mouse_entered.connect(hover_timer.start);
		parent.mouse_exited.connect(stop_hover_timer);

	if target is Item:
		if not target.description:
			target.set_hint_data();

	var target_name:String = target.name;
	while target_name[-1].is_valid_int():
		target_name = target_name.left(-1);
	name_label.text = target_name;
	
	if "sub_name" in target:
		sub_name_label.show()
		sub_name_label.text = target.sub_name;
	if "tooltip_name_color" in target:
		name_label.add_theme_color_override("font_color", target.tooltip_name_color);
	if "icon_texture" in target:
		icon.show()
		icon.texture = target.icon_texture;
	if "description" in target:
		description_label.show()
		description_label.text = target.description;
	if "tooltip_hint" in target and not get_parent() is ItemSample:
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
	if not len(hover_timer.timeout.get_connections()):
		hover_timer.timeout.connect(_on_hover_timer_timeout)

func _on_hover_timer_timeout() -> void:
	Tweens.ui_fade_in(self);
	var window_size:Vector2 = get_window().size;
	
	var target_position:Vector2 = get_global_mouse_position();
	global_position = target_position
	
	if target_position.x + size.x >= window_size.x - 50:
		position.x -= size.x
	if target_position.y + size.y >= window_size.y -10:
		position.y -= size.y
		
func stop_hover_timer()->void:
	if not hover_timer.is_stopped():
		hover_timer.stop();
	hide();
