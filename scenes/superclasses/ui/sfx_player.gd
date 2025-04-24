extends AudioStreamPlayer

class_name SfxPlayer

func play_sound_by_key(key:String)->void:
	if not playing:
		stream=self[key];
		play()
	
func play_sound_obj(obj:AudioStream)->void:
	if not playing: 
		stream = obj;
		play();
