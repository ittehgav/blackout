extends UIRoot


@export var opponent:Leader

func test_battle() -> void:
	var arena:Arena = Index.arena_scene.instantiate()
	arena.start_battle(opponent);
	Entities.main_bgm.play_bgm("combat")
	hide();


func world_map() -> void:
	var map:WorldMap = Index.world_map_scene.instantiate();
	get_parent().add_child(map);
	hide()
