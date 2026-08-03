@icon("res://assets/visual/editor_ui/IconGodotNode/control/icon_audio.png")
extends AudioStreamPlayer
class_name UISFX;


@export var mouseover_sounds:Array[AudioStream];
@export var disabled_mouseover:AudioStream;

@export var button_click:AudioStream;
@export var cancel:AudioStream;
@export var location_entered:AudioStream;
@export var invalid:AudioStream;


func ui_click_sound(node:Control)->void:
	if node is Button:
		if node.name in ["exit", "return"]:
			play_stream("cancel");
		elif not node.name in \
		["confirm_trade"]:## just add every name that doesnt play the default sound??
			play_stream("button_click");


func ui_mouseover_sound(node:Control)->void:
	if node is Button:
		if node.disabled:
			play_stream("disabled_mouseover")
		else:
			play_stream_obj(mouseover_sounds.pick_random());
	else:
		play_stream_obj(mouseover_sounds.pick_random())


func play_stream(key:String)->void:
	## key needs to be a string matching an AudioStream declared in this script
	stream = self[key];
	play()


func tab_mouseover_sound(_tab:int, _node:TabContainer)->void:
	## need do this in separate fucntion because of signal-bound arguments
	play_stream_obj(mouseover_sounds.pick_random())


func tab_click_sound(_tab:int, _node:TabContainer)->void:
	play_stream("button_click")


func play_stream_obj(to_play:AudioStream)->void:
	stream = to_play;
	play();
