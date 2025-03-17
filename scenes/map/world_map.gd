extends Node2D

class_name WorldMap

signal hour_passed;
signal day_passed;

var current_minute:int;
var current_hour:int;

const map_size = 1000;

@export var ambient_light:CanvasModulate;

@export var ui:Control;

@export var player:InMapPlayer

@export_subgroup("scenes")
@export var arena_scene:PackedScene;

@export var farm_scene:PackedScene;
@export var scrapyard_scene:PackedScene;
@export var factory_scene:PackedScene;

@export_subgroup("props")
@export var props_node:Node2D;
@export var prop_textures:Array[Texture];
var taken_positions:Array[Vector2];
var prop_sprites:Array[Sprite2D]


func _ready()->void:
	set_props()
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
	var taken_spots:Array[Vector2] = [Entities.in_map_player.position]
	var alternatives:Array[PackedScene] = [farm_scene, scrapyard_scene, factory_scene];
	for i in 10:
		var settlement_name:String = NameDatabase.generate_name();
		var settlement:Settlement = alternatives.pick_random().instantiate();
		var location:Vector2 = Vector2(randi_range(0, spawn_range), randi_range(0, spawn_range));
		var spot_taken = false;
		for spot in taken_spots:
			var gap = location - spot
			if abs(gap.x) < 50 or abs(gap.y) < 50:
				spot_taken = true;

		while spot_taken:
			spot_taken = false;
			location = Vector2(randi_range(0, spawn_range), randi_range(0, spawn_range));
			for spot in taken_spots:
				var gap = location - spot
				if abs(gap.x) < 50 or abs(gap.y) < 50:
					spot_taken = true;
					
		taken_spots.append(location)
				
		
		settlement.position = location;
		settlement.name = settlement_name;
		add_child(settlement);


func set_props():
	for texture in prop_textures:
		var sprite = Sprite2D.new();
		sprite.texture = texture;
		ColorCoder.color_code_prop(sprite)
		#sprite.scale = Vector2(2, 2);
		prop_sprites.append(sprite);
	
	const prop_amounts = 2;
	for prop in prop_sprites:
		for i in prop_amounts:
			set_prop(prop);


func set_prop(which:Sprite2D)->void:
	const tile_size = 16;
	var prop = which.duplicate();
	var x_roll = randi_range(map_size * -1, map_size);
	var y_roll = randi_range(map_size*-1, map_size );
	var target_position = Vector2(x_roll,  y_roll)
	while position_taken(target_position):
		x_roll = randi_range(map_size * -1, map_size);
		y_roll = randi_range(map_size*-1, map_size );
		target_position = Vector2(x_roll,  y_roll)
	
	taken_positions.append(target_position);
	
	prop.position = target_position;
	props_node.add_child(prop);
	
func position_taken(to_check:Vector2)->bool:
	for p in taken_positions:
		var x_gap = to_check.x - p.x;
		var y_gap = to_check.y - p.y;
		if abs(x_gap) < 50 or abs(y_gap) < 50:
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
	$ambient_light.update_lighting();
