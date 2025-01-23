extends Control

@export var arena_scene:PackedScene;


func test_battle() -> void:
	var arena = arena_scene.instantiate();
	get_tree().paused = true;
	get_parent().add_child(arena);
	hide();
