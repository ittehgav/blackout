extends AudioStreamPlayer

@export var hit_sfx:AudioStreamPlayer;

@export var swing:AudioStream;

@export var swing_hit:AudioStream

func play_sfx_by_key(key:String)->void:
	pitch_scale = randf_range(.85, 1.15)
	stream = self[key];
	play();

func play_hit_sfx_by_key(key:String)->void:
	hit_sfx.pitch_scale = randf_range(.85, 1.15)
	hit_sfx.stream = self[key]
	hit_sfx.play();
