extends AudioStreamPlayer

@export var in_map:AudioStream;
@export var in_settlement:AudioStream;
@export var combat:AudioStream;
@export var intro:AudioStream;

func _ready()->void:
	Entities.main_bgm = self;
	play_bgm("intro")
	
func play_bgm(key:String)->void:
	pitch_scale = 1;
	stream = self[key];
	#play();
