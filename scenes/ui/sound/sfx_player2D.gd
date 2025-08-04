extends AudioStreamPlayer2D;

class_name SfxPlayer2D;

func play_sound_by_key(key:String)->void:
	stream=self[key];
	play()
	
func play_sound_obj(obj:AudioStream)->void:
	stream = obj;
	play();
