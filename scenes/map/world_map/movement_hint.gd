extends Label

func _ready()->void:
	blink_loop();
	Entities.player_map_party.started_moving.connect(queue_free);
	
func blink_loop()->void:
	if is_instance_valid(self):
		visible = not visible;
		await get_tree().create_timer(.75).timeout;
		blink_loop();
