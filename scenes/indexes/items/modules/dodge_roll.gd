extends Module

const rarity = 1;

const sfx_key = "dash";

const movement_distance = 300
const cooldown = 5;
const duration = .75

const description  = "Quickly dashes towards the cursor, briefly becoming invulnerable and able to move through enemies.";

func use()->void:
	var direction:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction == Vector2.ZERO:
		if get_global_mouse_position().x > Entities.in_fight_player.position.x:
			direction = Vector2(1, 0);
		else:
			direction = Vector2(-1, 0)
	var target_position = Entities.in_fight_player.global_position + direction * movement_distance;
	
	Combat.turn_ellusive(Entities.in_fight_player, duration);
	
	Entities.in_fight_player.modulate.a = .5
	
	var tween = create_tween();
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(Entities.in_fight_player, "global_position", target_position, duration/2);
	tween.tween_callback(clear_vfx);
	
	
func clear_vfx():
	Entities.in_fight_player.modulate.a = 1;
