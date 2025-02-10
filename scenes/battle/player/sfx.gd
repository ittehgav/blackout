extends AudioStreamPlayer

@export var damage_taken:AudioStream;

func damage_taken_sfx(_damage:float)->void:
	stream = damage_taken;
	play()
