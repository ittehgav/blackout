extends AudioStreamPlayer

@export var intro:AudioStream;
@export var world_map:AudioStream;
@export var encounter:AudioStream;
@export var battle:AudioStream;

@export var victory:AudioStream;
@export var defeat:AudioStream

@export var in_settlement:AudioStream;



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

		#play();


func _on_finished() -> void:
	if stream not in [victory, defeat]:
		play()


func _on_main_state_changed(new_state: String) -> void:
		## eventually diversify osts i suppose
		assert(new_state in self)
		play_bgm(new_state);
