@icon("res://assets/visual/editor_ui/IconGodotNode/node/icon_audio.png")
extends AudioStreamPlayer
class_name SfxPlayer

func play_sound_by_key(key:String)->void:
	if is_inside_tree():
		if stream != self[key]:
			stream=self[key];
		play()
	
func play_sound_obj(obj:AudioStream)->void:
	if is_inside_tree():
		stream = obj;
		play();
