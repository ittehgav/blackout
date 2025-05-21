extends AudioStreamPlayer

class_name SfxPlayer

func play_sound_by_key(key:String)->void:
	if stream != self[key]:
		stream=self[key];
	play()
	
func play_sound_obj(obj:AudioStream)->void:
	stream = obj;
	play();
