extends Node2D

class_name WorldMap

signal speed_up_started;
## just for the class thingy

signal hour_passed;
signal day_passed;

signal settlement_hovered(settlement:Settlement);
signal settlement_mouse_exited;

signal returned_from_battle(won:bool);
## to play animations/dialogues that depend on whether you won the battle

@export var origin:Settlement;
@export var road_tiles:TileMapLayer;

@export var speed_up_icon:TextureRect
@export var minute_ticker:Timer
@export var ui_canvas:CanvasLayer;

## world map persists throughout the entire session
## the true player node is located here
## and set to Entities before the world enters the tree
@export var player_node:Player;

## y3k?
@export var current_year:int = 3000;
@export_range(1, 12) var current_month:int
@export_range(1, 31) var current_day:int; 
@export_range(0, 23) var current_hour:int
@export_range(0, 59) var current_minute:int;

@export var speed_up_persist_timer:Timer;
@export var speed_5x_persist_timer:Timer;

func _ready()->void:
	## TODO move this declaration for the moment the world map is instantiated
	get_tree().paused = true;
	speed_up_loop()
	
func speed_up_loop()->void:
	const loop_latency = 1
	var tween:Tween = create_tween();
	tween.tween_property(speed_up_icon, "modulate:a", .1, loop_latency);
	tween.tween_property(speed_up_icon, "modulate:a", .75, loop_latency);
	tween.tween_callback(speed_up_loop);


func _on_enter_pressed() -> void:
	enter_settlement();


func enter_settlement(_target:Settlement = Entities.player_party.current_settlement)->void:
	Entities.main.set_scenario("in_settlement")

func _process(_delta:float)->void:
	if Input.is_action_just_pressed("skip_time") and not get_tree().paused:
		set_travel_speed(2);
		speed_up_persist_timer.start()
	elif Input.is_action_just_released("skip_time") and not get_tree().paused:
		set_travel_speed(1);

func set_travel_speed(target:float)->void:
	if target > 1:
		speed_up_started.emit()
		speed_up_icon.show();
	else:
		speed_up_icon.hide()
	Engine.time_scale = target


func _on_player_party_settlement_visited(_settlement: Settlement) -> void:
	set_travel_speed(1)
	
func advance_day()->void:
	## putting this here so it's quicker to access for a lot of day-cycle
	## depending things
	day_passed.emit()
	current_day += 1;
	if current_day == 32:
		minute_ticker.advance_month();
		current_day = 0;


func _on_speed_up_persist_timeout() -> void:
	if Input.is_action_pressed("skip_time"):
		speed_5x_persist_timer.start()
		set_travel_speed(3);
	


func _on_speed_up_persist_5x_timeout() -> void:
	if Input.is_action_pressed("skip_time"):
		set_travel_speed(5);
