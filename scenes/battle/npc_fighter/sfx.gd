extends AudioStreamPlayer

@export var ally_death:AudioStream;
@export var enemy_death:AudioStream;

func play_sfx_by_key(key:String)->void:
	stream = self[key];
	play();
