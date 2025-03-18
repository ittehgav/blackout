extends Node2D

class_name WorldMap

signal hour_passed;
signal day_passed;

var current_minute:int=59;
var current_hour:int=23;

const map_size = 10000;

@export var ambient_light:CanvasModulate;

@export var ui:Control;

@export var player:InMapPlayer

@export_subgroup("scenes")
@export var arena_scene:PackedScene;

@export var farm_scene:PackedScene;
@export var scrapyard_scene:PackedScene;
@export var factory_scene:PackedScene;

@export_subgroup("props")
@export var small_props_node:Node2D;
@export var props_node:Node2D;
@export var small_prop_textures:Array[Texture];
var small_prop_sprites:Array[Sprite2D];

@export var prop_textures:Array[Texture];
var prop_sprites:Array[Sprite2D]


func _ready()->void:
	set_props()
	set_small_props()
	Entities.world_map = self;
	get_tree().paused = true;
	generate_world()


func _on_player_started_moving() -> void:
	$entities.process_mode = PROCESS_MODE_PAUSABLE


func _on_player_stopped_moving() -> void:
	$entities.process_mode = PROCESS_MODE_DISABLED;

func pause_map()->void:
	## the built in pause functionality is used to control whether
	## the other parties are moving,
	## (eventually) the day/night cycle, global clock and everything tied to it
	
	## truly pausing the map includes disabling the player's navigation
	## (when there's a menu open)

	process_mode = PROCESS_MODE_DISABLED
	Entities.in_map_player.process_mode = Node.PROCESS_MODE_DISABLED;
	
func unpause_map()->void:
	process_mode = PROCESS_MODE_PAUSABLE
	Entities.in_map_player.process_mode = Node.PROCESS_MODE_ALWAYS;


func generate_world()->void:
	const spawn_range = 2000;
	var taken_positions:Array[Vector2] = [Entities.in_map_player.position]
	var alternatives:Array[PackedScene] = [farm_scene, scrapyard_scene, factory_scene];
	for i in 10:
		var settlement_name:String = NameDatabase.generate_name();
		var settlement:Settlement = alternatives.pick_random().instantiate();
		
		var location:Vector2 = Vector2(randi_range(0, spawn_range), randi_range(0, spawn_range));
		while position_taken(location, taken_positions):
			location = Vector2(randi_range(0, spawn_range), randi_range(0, spawn_range));
		taken_positions.append(location)
		settlement.position = location;
		settlement.name = settlement_name;
		day_passed.connect(settlement.daily_reset)
		add_child(settlement);

func set_small_props():
	for texture in small_prop_textures:
		var sprite = Sprite2D.new();
		sprite.texture = texture;
		ColorCoder.color_code_prop(sprite);
		sprite.scale = Vector2(2, 2)
		small_prop_sprites.append(sprite)
		
	var taken_positions:Array[Vector2] = [];
	const prop_amounts = 1000;
	for prop in small_prop_sprites:
		for i in prop_amounts:
			set_prop(prop, taken_positions, 10, true)

func set_props():
	for texture in prop_textures:
		var sprite = Sprite2D.new();
		sprite.texture = texture;
		ColorCoder.color_code_prop(sprite, true)
		sprite.scale = Vector2(2, 2);
		prop_sprites.append(sprite);
	
	var taken_positions:Array[Vector2] = [];
	const prop_amounts = 30;
	for prop in prop_sprites:
		for i in prop_amounts:
			set_prop(prop, taken_positions);


func set_prop(which:Sprite2D, taken_positions:Array[Vector2], min_gap:float=30, small=false)->void:
	var prop = which.duplicate();
	var x_roll = randi_range(map_size * -1, map_size);
	var y_roll = randi_range(map_size*-1, map_size );
	var target_position = Vector2(x_roll,  y_roll)
	while position_taken(target_position, taken_positions, min_gap):
		x_roll = randi_range(map_size * -1, map_size);
		y_roll = randi_range(map_size*-1, map_size );
		target_position = Vector2(x_roll,  y_roll)
	
	taken_positions.append(target_position);
	
	prop.position = target_position;
	if not small:
		props_node.add_child(prop);
	else:
		small_props_node.add_child(prop);
func position_taken(to_check:Vector2, taken_positions:Array[Vector2], min_gap:float = 30)->bool:
	for p in taken_positions:
		if to_check.distance_to(p)< min_gap:
			return true;
	return false;

func _on_minute_ticker_timeout() -> void:
	current_minute += 1;
	if current_minute == 60:
		current_minute = 0;
		hour_passed.emit()


func _on_hour_passed() -> void:
	current_hour += 1;
	if current_hour == 24:
		current_hour = 0;
		day_passed.emit()
