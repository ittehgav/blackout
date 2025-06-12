extends Control

@export var player:InFightPlayer
@export var area:Area2D;
@export var polygon:CollisionPolygon2D;

var x_min:int=20
var y_min:int=50;

var x_max:float;
var y_max:float

var target:NpcFighter;

@export var arrow:Sprite2D;

func _ready()->void:
	set_physics_process(false)
	resize_polygon();
	get_window().size_changed.connect(resize_polygon)

func _physics_process(_delta:float)->void:
	if not is_instance_valid(target):
		## only skips a few frames until new target is found
		return
	arrow.rotation = player.global_position.angle_to_point(target.global_position);
	


func show_pointer()->void:
	var targets:Array = player.enemy_team.units
	targets.sort_custom(sort_by_distance)
	target= targets[0];
	target.death.connect(show_pointer);
	
	show();
	set_physics_process(true)
	
	var relative_position:Vector2 = target.position - player.position;

	if relative_position.x > x_max:
		relative_position.x = x_max;
	elif relative_position.x < x_min:
		relative_position.x = x_min
	
	if relative_position.y > y_max:
		relative_position.y = y_max;
	elif relative_position.y < y_min:
		relative_position.y = y_min
	
	arrow.position = relative_position;
	

func sort_by_distance(a:NpcFighter, b:NpcFighter)->bool:
	return Entities.in_fight_player.position.distance_to(a.position) < Entities.in_fight_player.position.distance_to(b.position);


func _on_sweep_timeout() -> void:
	if len(area.get_overlapping_bodies()) == 0:
		show_pointer()
	else:
		hide();
		
		



func resize_polygon()->void:

	const x_padding = 20;
	const top_padding = 50
	const bottom_padding = 20;
	
	var window_size:Vector2 = get_window().size;
	
	x_min = x_padding + 50
	y_min = top_padding + 50
	
	x_max = window_size.x - x_padding 
	y_max = window_size.y - bottom_padding

	polygon.polygon[1] = Vector2(0, window_size.y)
	polygon.polygon[2] = Vector2(window_size.x, window_size.y)
	polygon.polygon[3] = Vector2(window_size.x, 0)
	
	area.position.x = -window_size.x/2;
	area.position.y = -window_size.y/2;
