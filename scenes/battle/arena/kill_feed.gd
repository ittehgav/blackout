extends Control

var queue:Array[Control] = []
@onready var current_kill_tween:Tween=create_tween();

func unit_died(killer:ActiveFighter, dead:ActiveFighter):
	var killer_name;
	if killer is InFightPlayer:
		killer_name = killer.name
	else:
		killer_name = "Lv. " + str(killer.unit.level) + " "+ str(killer.base.name)
	
	if dead is InFightPlayer:
		return;

	var dead_name = "Lv. " + str(dead.unit.level) + " " + str(dead.base.name)

	if killer.ally_team == Entities.in_fight_player.ally_team:
		$kill/data/dead.modulate = Color.RED;
		$kill/data/killer.modulate = Color.GREEN;
		
		$kill.self_modulate = Color.GREEN - Color(0, 0, 0, .2);
	else:
		$kill/data/dead.modulate = Color.GREEN;
		$kill/data/killer.modulate = Color.RED;
		
		$kill.self_modulate = Color.RED - Color(0, 0, 0, .2)
	
	$kill/data/killer.text = killer_name;
	$kill/data/dead.text = dead_name;
	
	var new_kill = $kill.duplicate()
	add_child(new_kill);
	
	queue.append(new_kill)
	if len(queue) == 1:
		display_new_kill()
	


func display_new_kill():
	if len(queue):
		var next_kill = queue[0];
		next_kill.show()
		var tween = create_tween();
		tween.parallel().tween_property(next_kill, "position:y", 70, 1);
		tween.parallel().tween_property(next_kill, "modulate:a", 0, 1);
		tween.tween_callback(next_kill.queue_free)
		await get_tree().create_timer(.75).timeout
		queue.pop_front()
		display_new_kill()
