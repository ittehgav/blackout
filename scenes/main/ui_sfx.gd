extends AudioStreamPlayer

class_name UISFX;


@export var mouseover_sounds:Array[AudioStream];
@export var disabled_mouseover:AudioStream;

@export var button_click_sound:AudioStream;
@export var cancel_sound:AudioStream;
@export var settlement_entered:AudioStream;


func ui_click_sound(node:Control)->void:
	if node is Button:
		if node.name in ["exit", "return"]:
			play_stream(cancel_sound);
		elif not node.name in \
		["confirm_trade"]:## just add every name that doesnt play the default sound??
			play_stream(button_click_sound);
			

func ui_mouseover_sound(node:Control)->void:
	if node is Button:
		if node.disabled:
			play_stream(disabled_mouseover)
		else:
			play_stream(mouseover_sounds.pick_random());
	else:
		play_stream(mouseover_sounds.pick_random())
		
	
func play_stream(to_play:AudioStream)->void:
	stream = to_play;
	play();

func play_stream_by_key(key:String)->void:
	## key needs to be a string matching an AudioStream declared in this script
	play_stream(self[key]);
	
func tab_mouseover_sound(_tab:int, _node:TabContainer)->void:
	## need do this in separate fucntion because of signal-bound arguments
	play_stream(mouseover_sounds.pick_random())

func tab_click_sound(_tab:int, _node:TabContainer)->void:
	play_stream(button_click_sound)
