extends AudioStreamPlayer

@export var intro:AudioStream;
@export var world_map:AudioStream;
@export var encounter:AudioStream;
@export var battle:AudioStream;

@export var victory:AudioStream;
@export var defeat:AudioStream




## probably a neater way of doing this but this node never plays multiple 
## streams anyway
var current_key:String;

func _ready()->void:
	if get_tree().root.get_children()[-1].name == "main":
		## encapsulate f6 run checks if i end up doing this again eslehwewe
		play_bgm("intro")


func play_bgm(key:String)->void:
	if key != current_key:
		current_key = key;
		var target_stream:AudioStream = self[key];

		pitch_scale = 1;
		stream = target_stream;

		play();


func _on_finished() -> void:
	if stream not in [victory, defeat]:
		play()

@onready var initial_db:float = volume_db;

func on_scenario_changed(new: State.Scenario, _old: State.Scenario) -> void:
	match new:
		State.Scenario.main:
			play_bgm("intro")
		State.Scenario.battle:
			play_bgm("battle")
			if State.tutorial_scene:
				volume_db = initial_db - 5;
			else:
				volume_db = initial_db;
		State.Scenario.world_map:
			play_bgm("world_map")



func on_substate_changed(new: State.Substate, _previous: State.Substate) -> void:
	match new:
		State.Substate.post_battle:
			stop()
		State.Substate.pre_battle:
			play_bgm("battle")
		State.Substate.battle_finishing:
			stop();
