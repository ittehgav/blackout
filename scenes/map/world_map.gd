extends Node2D

class_name WorldMap

@export var player_party:InMapPlayer;
@export var ui_canvas:CanvasLayer;

signal finished_generating;

signal returned_from_battle(won:bool);

signal time_skipped;

signal minute_passed;
signal hour_passed;
signal day_passed;

signal map_paused;
signal map_unpaused;

var current_day:int=1;
var current_month:int=1;

var pause_stack:int = 0;

var current_hour:int=12;
var current_minute:int=0;

@export var ui:Control

@export var player:InMapPlayer

@export var quadrants:WorldMapPlane;

@export var sky_colors:Array[Color] = [
	Color.WHITE,
	Color.WHITE,
	Color.WHITE,
	Color.WHITE,
	Color.WHITE,
	Color.WHITE,
	Color.WHITE,
	Color.WHITE,
	Color.WHITE,
	Color.WHITE,
	Color.WHITE,
	Color.WHITE,
]


var hour_bgm_pitches:Array[float] = [
	.8,
	.85,
	.9,
	.95,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
]
var all_settlements: = {}

var session_start_time:int;
var play_time_acm:int = 0;

func _ready()->void:
	## Entities.player needs to be ready to go before world map enters the tree
	session_start_time = Time.get_unix_time_from_system()
	Entities.main.current_state = "world_map"

	get_tree().paused = true;
	Entities.main_bgm.play_bgm("world_map")
	minute_passed.emit()


func _on_player_started_moving() -> void:
	$entities.process_mode = PROCESS_MODE_PAUSABLE


func _on_player_stopped_moving() -> void:
	$entities.process_mode = PROCESS_MODE_DISABLED;

func pause_map()->void:
	## the built in pause functionality is used to control whether
	## the other parties are moving,
	## the day/night cycle, global clock and everything tied to it
	
	## truly pausing the map includes disabling the player's navigation
	## (when there's a menu open)
	pause_stack += 1;
	if pause_stack == 1:
		Entities.player_map_party.set_process_input(false)
		Entities.player_map_party.stop_movement(false)
		process_mode = PROCESS_MODE_DISABLED
		Entities.player_map_party.process_mode = Node.PROCESS_MODE_DISABLED;
		map_paused.emit();
 

func unpause_map(force:bool=false)->void:
	if force:
		pause_stack = 0;
	else:
		pause_stack -= 1
	
	if not pause_stack:
		Entities.main_bgm.play_bgm("world_map")
		Entities.player_map_party.set_process_input(true)
		process_mode = PROCESS_MODE_PAUSABLE
		Entities.player_map_party.process_mode = Node.PROCESS_MODE_ALWAYS;
		Entities.player_map_party.camera.process_mode = Node.PROCESS_MODE_ALWAYS 
		map_unpaused.emit()


func _on_minute_ticker_timeout() -> void:
	current_minute += 1;
	if current_minute == 60:
		current_minute = 0;
		hour_passed.emit()
	minute_passed.emit()


func _on_hour_passed() -> void:
	current_hour += 1;
	if current_hour == 24:
		current_hour = 0;
		day_passed.emit()
	update_light();


func _on_day_passed() -> void:
	current_day += 1;
	if current_day == 32:
		current_day = 1;
		current_month += 1;
		if current_month == 13:
			current_month = 1;

func update_light()->void:
	var target_color:Color = get_hour_sky_color();
	if not get_tree().paused:
		var tween: = create_tween();
		tween.tween_property(self, "modulate", target_color, .5)
		tween.parallel().tween_property(Entities.main_bgm, "pitch_scale", get_hour_pitch(), 2)
	else:
		modulate = target_color;


func get_hour_pitch(hour:int = current_hour)->float:
	var pitch_index:int;
	if current_hour > 11:
		pitch_index = 11-(hour-12)
	else:
		pitch_index = hour
	return hour_bgm_pitches[pitch_index]

func get_hour_sky_color(hour:int=current_hour)->Color:
	var color_index:int;
	if current_hour > 11:
		color_index = 11-(hour-12)
	else:
		color_index = hour
	return sky_colors[color_index];



func _on_player_left_settlement() -> void:
	update_light()

func load_game(data:Dictionary)->void:
	player_party.load_data(data.player)
	play_time_acm += data.world.play_time
	
	current_day = data.world.day;
	current_hour = data.world.hour;
	current_minute = data.world.minute;
	
	quadrants.load_game(data)

	
func _on_returned_from_battle(won: bool) -> void:
	## where something different will happen if you lose 
	unpause_map(true);
	var party:NpcMapParty = Entities.current_speaking_party;
	if won:
		match party.leader.after_defeat:
			"disappear":
				Entities.current_speaking_party.queue_free();
	else:
		match party.leader.after_victory:
			"rob_player":
				Entities.dialogue_player.start_dialogue(party.leader, "defeated_player")
				await Entities.dialogue_player.dialogue_ended;
				MapEvents.yield_resources();
	

func quadrant_for_global_position(p:Vector2)->WorldMapQuadrant:
	if p.x < 0 and p.y < 0:
		return quadrants.quadrant_1;
	elif p.y < 0:
		return quadrants.quadrant_2;
	elif p.x < 0:
		return quadrants.quadrant_3;
	else:
		return quadrants.quadrant_4;
