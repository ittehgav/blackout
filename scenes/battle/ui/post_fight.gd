extends UIRoot

@export var victory_view:Control;
@export var defeat_view:Control;


func _ready()->void:
	set_process_input(false)

func show_post_fight(winner_n:int)->void:
	show()
	Entities.main_bgm.stop()
	var tween: = Entities.arena.create_tween();
	tween.set_ignore_time_scale(true)
	tween.tween_property(Engine, "time_scale", .3, 1.5);
	tween.parallel().tween_property($bg, "modulate:a", 1, 1);
	await tween.finished
	set_process_input(true);
	Engine.time_scale = 1;
	

	
	get_tree().paused = true;
	Entities.main_bgm.stop();
	if winner_n == 1:
		victory_view.victory_animation()
		Entities.main_bgm.play_bgm("victory");
	else:
		defeat_view.defeat_animation();
		defeat_view.defeat_animation();
		Entities.main_bgm.play_bgm("defeat")


func end_post_fight()->void:
	if Entities.world_map:
		## to differentiate from when the battle was a test battle press in the main vieW
		Entities.arena.return_to_world_map();
