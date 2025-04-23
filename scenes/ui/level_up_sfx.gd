extends SfxPlayer;

@export var level_up:AudioStream;

func _ready()->void:
	stream = level_up;

func level_up_sfx()->void:
	pitch_scale = randf_range(.5, 2);
