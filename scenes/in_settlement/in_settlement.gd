extends Node2D;




@export var right_exit:CollisionShape2D

@export var exit_prompt:Control;
@export var exit_area:Area2D;

@export var player_camera:Camera2D

@export var ui_canvas:CanvasLayer
var world_map_ui:CanvasLayer
@export var ui:Control;

@export var buildings_node:Node2D;
@export var foreground:Node2D;

@export var player_unit:CharacterBody2D

var location:Location

@export var backdrop:TileMapLayer

func _ready()->void:
	## because this enters the tree from the world map when the player is 
	## in a settlement
	get_tree().paused = false;
	Entities.current_area = self;
	


var building_offset:int = 0;


func load_location(target:Location)->void:
	## right now this only runs if the settlement is not a dungeon type
	location = target
	if len(location.buildings) == 1:
		var interior:Interior = load_interior(location.buildings[0]);
		full_size_setup(interior)
	else:
		set_backdrop_color()
		for building:Settlement in location.buildings:
			## buildings are loaded in order
			var interior:Interior = load_interior(building);
			building_offset = interior.right_side_anchor.position.x + interior.position.x

		player_camera.limit_right = building_offset + 100

		right_exit.position.x += building_offset



func load_interior(building:Building)->Interior:
	var front_porch:Interior = building.front_porch_scene.instantiate();
	front_porch.building = building;

	buildings_node.add_child(front_porch);
	front_porch.position.x += building_offset
	
	return front_porch

func full_size_setup(interior:Interior)->void:
	foreground.free();
	player_camera.limit_left = 0;
	player_camera.limit_top = 0
	player_camera.limit_right = interior.size.x;
	player_camera.limit_bottom = interior.size.y
	
	player_unit.position = interior.player_origin
	for c:Node in exit_area.get_children():
		c.queue_free();
	for c:Node in interior.exit_area.get_children():
		## moving the areas because the exit signals are bound to location's exit area
		c.reparent(exit_area)
	
	 
func return_to_world_map()->void:
	State.set_scenario(State.Scenario.world_map)
	
func set_backdrop_color()->void:
	var hour:int = Entities.world_map.current_hour;
	if hour < 2 or hour >= 22:
		backdrop.modulate.v = .2
	elif hour >= 2 and hour < 6:
		backdrop.modulate.v = .5;
	elif hour >= 6 and hour < 10:
		backdrop.modulate.v = .8;
	elif hour >= 10 and hour < 14:
		backdrop.modulate.v = 1;
	elif hour >= 14 and hour < 18:
		backdrop.modulate.v = .8;
	else:
		backdrop.modulate.v = .5 
	

func _on_exit_body_entered(body: Node2D) -> void:
	if body == Entities.player_unit:
		exit_prompt.exit_prompt();
