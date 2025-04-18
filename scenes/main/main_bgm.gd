extends AudioStreamPlayer

@export var in_map:AudioStream;
@export var in_settlement:AudioStream;
@export var combat:AudioStream;
@export var intro:AudioStream;
@export var dialogue:AudioStream;

@export var victory:AudioStream;
@export var defeat:AudioStream;

func _ready()->void:
	Entities.main_bgm = self;
	play_bgm("intro")
	
func play_bgm(key:String)->void:
	pitch_scale = 1;
	stream = self[key];
	
	if stream == in_map:
		pitch_scale = Entities.world_map.get_hour_pitch()
	play();


func _on_finished() -> void:
	if stream not in [victory, defeat]:
		play()
