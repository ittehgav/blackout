extends UIRoot



func world_map() -> void:
	var map:WorldMap = Index.world_map_scene.instantiate();
	get_parent().add_child(map);
	get_parent().remove_child(self);
	## one day this menu will have more stuff to do and will need to be returned to

func test_battle()->void:
	var enemy_leader:NpcLeader = Index.thugs_scene.instantiate();
	enemy_leader.generate(1110);
	
	var arena:Arena = Index.arena_scene.instantiate()
	arena.start_battle(enemy_leader)
	Entities.main_bgm.play_bgm("combat");
	hide();
