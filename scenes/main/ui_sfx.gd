extends AudioStreamPlayer

@export var mouseover_sounds:Array[AudioStream];
@export var disabled_mouseover:AudioStream;

@export var button_click_sound:AudioStream;
@export var cancel_sound:AudioStream;
@export var settlement_entered:AudioStream;

func _ready() -> void:
	Entities.ui_sfx = self;
	recursive_connect_ui_feedback(get_parent().get_node("main_ui"))

func recursive_connect_ui_feedback(node:Control)->void:
	var cloned:bool = false;
	node.mouse_entered.connect(ui_mouseover_sound.bind(node));
	if "pressed" in node:
		node.pressed.connect(ui_click_sound.bind(node));

	if node is Label and "hover" in node.name:
		## cloned nodes can't have children
		add_label_hover_effect(node)
		cloned = true

	if not cloned:
		for c in node.get_children():
			recursive_connect_ui_feedback(c);
	
func add_label_hover_effect(label:Label)->void:
	label.mouse_filter =Control.MOUSE_FILTER_PASS
	
	label.mouse_entered.connect(label.set_modulate.bind(Color.LIGHT_GREEN));
	label.mouse_exited.connect(label.set_modulate.bind(Color.WHITE))


func ui_click_sound(node:Control)->void:
	if node is Button:
		if node.name in ["exit", "return"]:
			play_stream(cancel_sound);
		else:
			play_stream(button_click_sound);
			

func ui_mouseover_sound(node:Control)->void:
	if node is Button:
		if node.disabled:
			play_stream(disabled_mouseover)
		else:
			play_stream(mouseover_sounds.pick_random());
	
func play_stream(to_play:AudioStream)->void:
	stream = to_play;
	play();

func play_stream_by_key(key:String)->void:
	## key needs to be a string matching an AudioStream declared in this script
	stream = self[key];
	play();
