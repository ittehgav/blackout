extends Control

@export var arena_scene:PackedScene;
@export var world_map_scene:PackedScene

@export var thug_leader:Leader;

func test_battle() -> void:
	var arena:Arena = arena_scene.instantiate();
	arena.load_teams(thug_leader)
	get_tree().paused = true;
	get_parent().add_child(arena);
	hide();


func world_map() -> void:
	var map:WorldMap = world_map_scene.instantiate()
	get_parent().add_child(map);
	hide()
