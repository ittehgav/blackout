extends UIRoot

@export var world_map_scene:PackedScene
@export var arena_scene:PackedScene;

@export var opponent:Leader

func test_battle() -> void:
	var arena:Arena = arena_scene.instantiate()
	get_tree().paused = true;
	arena.start_battle(opponent);
	Entities.main_bgm.play_bgm("combat")
	get_parent().add_child(arena);
	hide();


func world_map() -> void:
	var map:WorldMap = world_map_scene.instantiate();
	get_parent().add_child(map);
	hide()
