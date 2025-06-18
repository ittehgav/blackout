extends UIRoot



func world_map() -> void:
	hide()
	await Tweens.ui_fade_in(Entities.loading_screen).finished
	var map:WorldMap = Index.world_map_scene.instantiate();
	map.finished_generating.connect(Entities.loading_screen.fade_out, CONNECT_ONE_SHOT);
	map.player_party.setup();
	get_parent().add_child(map);
	get_parent().remove_child(self);
	## one day this menu will have more stuff to do and will need to be returned to

func test_battle()->void:
	var enemy_leader:NpcLeader = Index.thugs_scene.instantiate();
	enemy_leader.generate(500);
	
	var arena:Arena = Index.arena_scene.instantiate()
	arena.start_battle(enemy_leader)
	Entities.main_bgm.play_bgm("combat");
	hide();
