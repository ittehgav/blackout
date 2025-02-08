extends AudioStreamPlayer

@export var swing:AudioStream;

func play_sfx_by_key(key:String):
	stream = self[key];
	play();
