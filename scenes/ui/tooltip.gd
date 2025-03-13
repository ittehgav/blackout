extends PanelContainer

class_name Tooltip;

@export var target:Node;
## where the tooltip will get the data from

@export var name_label:Label;
@export var description_label:RichTextLabel;
@export var icon:TextureRect;
@export var hint:Label;

@export var hover_timer:Timer;

@onready var window_size:Vector2 = DisplayServer.screen_get_size();

func _ready() -> void:
	var parent:Control = get_parent()
	assert (parent is Control and not parent is Container);
	if not parent.is_node_ready():
		await parent.ready
		setup()
	else:
		setup();
	## lots of places where the sample target is defined on load

func setup():
	if not target:
		queue_free();
		return

	var parent = get_parent();
	parent.mouse_entered.connect(hover_timer.start);
	parent.mouse_exited.connect(stop_hover_timer);

	name_label.text = target.name;
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
	
	description_label.custom_minimum_size.x = size.x;



func _on_hover_timer_timeout() -> void:
	modulate.a = .1;

	show();
	position = get_parent().get_local_mouse_position();
	size.y -= 10000
	size.y += 10
		
	var tween = create_tween();
	tween.tween_property(self, "modulate:a", 1, .5);

func stop_hover_timer():
	hide();
	hover_timer.stop();
