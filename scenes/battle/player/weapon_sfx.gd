extends SfxPlayer

@export var hit_sfx:AudioStreamPlayer;
@export var swing:AudioStream;

@export var swing_hit:AudioStream
@export var shoot:AudioStream;
@export var spray:AudioStream;
@export var charge_up:AudioStream;
@export var explosion:AudioStream;
@export var heal:AudioStream;
@export var buff:AudioStream;

func play_weapon_sfx(key:String, loop=false)->void:
	## need to do the pitch randomization with these so can't use the superclass function
	pitch_scale = randf_range(.85, 1.15)
	stream = self[key];
	play();

func play_hit_sfx(key:String)->void:
	hit_sfx.pitch_scale = randf_range(.85, 1.15)
	hit_sfx.stream = self[key]
	hit_sfx.play();
