extends AudioStreamPlayer

@export var world_map:AudioStream;
@export var settlement:AudioStream;
@export var combat:AudioStream;
@export var intro:AudioStream;
@export var dialogue:AudioStream;

@export var victory:AudioStream;
@export var defeat:AudioStream;

## probably a neater way of doing this but this node never plays multiple 
## streams anyway
var current_key:String;

func _ready()->void:
	Entities.main_bgm = self;
	play_bgm("intro")
	
func play_bgm(key:String)->void:
	if key != current_key:
		current_key = key;
		var target_stream:AudioStream = self[key];

		pitch_scale = 1;
		stream = target_stream;
	
		if stream == world_map:
			pitch_scale = Entities.world_map.get_hour_pitch()

		#play();


func _on_finished() -> void:
	if stream not in [victory, defeat]:
		play()
