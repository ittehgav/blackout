extends UIRoot

@export var post_fight:Control;


func start()->void:
	get_tree().paused = true;
	Tweens.ui_fade_in(self);

func resume() -> void:
	get_tree().paused = false;
	hide();

func restart_battle()->void:
	await Tweens.ui_fade_in(Entities.loading_screen).finished;
	var enemy_leader:Leader = Entities.arena.team_2.leader;
	var new_arena:Arena = Index.arena_scene.instantiate();
	Entities.player.reparent(new_arena);
	Entities.arena.queue_free();
	new_arena.finished_loading.connect(Entities.loading_screen.fade_out, CONNECT_ONE_SHOT);
	new_arena.start_battle(enemy_leader);
