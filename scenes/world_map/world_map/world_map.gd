extends Node2D

class_name WorldMap

signal hour_passed;
signal day_passed;

signal settlement_hovered(settlement:Settlement);
signal settlement_mouse_exited;

@export var origin:Settlement;
@export var road_tiles:TileMapLayer;

@export var speed_up_icon:TextureRect

@export var ui_canvas:CanvasLayer;

## y3k?
@export var current_year:int = 3000;
@export_range(1, 12) var current_month:int
@export_range(1, 31) var current_day : int; 
@export_range(0, 23) var current_hour:int
@export_range(0, 59) var current_minute:int;

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
	elif Input.is_action_just_released("skip_time") and not get_tree().paused:
		set_travel_speed(1);

func set_travel_speed(target:float)->void:
	if target > 1:
		speed_up_icon.show();
	else:
		speed_up_icon.hide()
	Engine.time_scale = target


func _on_player_party_settlement_visited(_settlement: Settlement) -> void:
	set_travel_speed(1)
