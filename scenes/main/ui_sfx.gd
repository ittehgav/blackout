extends AudioStreamPlayer

@export var mouseover_sounds:Array[AudioStream];
@export var disabled_mouseover:AudioStream;

@export var button_click_sound:AudioStream;
@export var cancel_sound:AudioStream;
@export var settlement_entered:AudioStream;

func _ready() -> void:
	Entities.ui_sfx = self;
	recursive_connect_ui_sfx(get_parent().get_node("main_ui"))

func recursive_connect_ui_sfx(node:Control)->void:
	node.mouse_entered.connect(ui_mouseover_sound.bind(node));
	if "pressed" in node:
		node.pressed.connect(ui_click_sound.bind(node));

	for c in node.get_children():
		recursive_connect_ui_sfx(c);
		
func ui_click_sound(node:Control):
	if node is Button:
		if node.name in ["exit", "return"]:
			play_stream(cancel_sound);
		else:
			play_stream(button_click_sound);
			

func ui_mouseover_sound(node:Control):
	if node is Button:
		if node.disabled:
			play_stream(disabled_mouseover)
		else:
			play_stream(mouseover_sounds.pick_random());
	
func play_stream(to_play:AudioStream):
	stream = to_play;
	play();

func play_stream_by_key(key:String)->void:
	## key needs to be a string matching an AudioStream declared in this script
	stream = self[key];
	play();
