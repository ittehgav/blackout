extends Node2D

class_name WorldMap

signal minute_passed;
signal hour_passed;
signal day_passed;

var current_day:int=1;
var current_month:int=1;

var pause_stack:int = 0;

var current_hour:int=8;
var current_minute:int=30;


@export var ui:Control;
@export var tile_map:TileMapLayer;

@export var player:InMapPlayer

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
@export_subgroup("scenes")
@export var arena_scene:PackedScene;

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


func _ready()->void:
	Entities.world_map = self;
	get_tree().paused = true;
	Entities.main_bgm.play_bgm("in_map")


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
		Entities.in_map_player.set_process_input(false)
		process_mode = PROCESS_MODE_DISABLED
		Entities.in_map_player.process_mode = Node.PROCESS_MODE_DISABLED;
	
func unpause_map()->void:
	pause_stack -= 1
	if not pause_stack:
		Entities.in_map_player.set_process_input(true)
		process_mode = PROCESS_MODE_PAUSABLE
		Entities.in_map_player.process_mode = Node.PROCESS_MODE_ALWAYS;



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
	if not get_tree().paused:
		var target_color:Color = get_hour_sky_color();
		
		var tween: = create_tween();
		tween.tween_property(self, "modulate", target_color, .5)
		tween.parallel().tween_property(Entities.main_bgm, "pitch_scale", get_hour_pitch(), 2)

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



func _process(_delta:float)->void:
	if Input.is_action_just_pressed("world_map_zoom_in"):
		if scale == Vector2.ONE or scale == Vector2(.5, .5):
			var target_scale:Vector2 = scale * 2
			
			var tween:Tween = Entities.player.create_tween();
			tween.tween_property(self, "scale", target_scale, 1)
	elif Input.is_action_just_pressed("world_map_zoom_out"):
		if scale == Vector2.ONE or scale == Vector2(2, 2):
			var target_scale:Vector2 = scale / 2
			
			var tween:Tween = Entities.player.create_tween();
			tween.tween_property(self, "scale", target_scale, 1)
	
