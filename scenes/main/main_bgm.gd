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

		play();


func _on_finished() -> void:
	if stream not in [victory, defeat]:
		play()


func _on_main_scenario_changed(new: String, _old: String) -> void:
	match new:
		"main":
			play_bgm("main")
		"world_map":
			play_bgm("world_map")

		"in_settlement":
			var location:Location = Entities.player_party.current_settlement.locations[0];
			## will only ever hit a key if it's a single-location settlement?
			var key:String = location.bgm_key;
			if key:
				play_bgm(key)
			else:
				if location is Building:
					play_bgm("in_settlement")
				elif location is Dungeon:
					play_bgm("combat")


func _on_main_substate_changed(new: String, _previous: String) -> void:
	match new:
		"main":
			volume_db = -10;
		"dialogue":
			volume_db = -15
		"pre_battle":
			volume_db = 0;
			play_bgm("battle")
		"battle_finishing":
			stop();
		"post_battle":
			if Entities.arena.won_battle:
				volume_db = -10
				play_bgm('victory');
			else:
				volume_db = -10
				play_bgm("defeat")
