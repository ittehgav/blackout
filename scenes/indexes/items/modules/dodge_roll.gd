extends Module

const rarity = 1;

const size_x = 1;
const size_y = 1;

const sfx_key = "dash";

const movement_distance = 300
const cooldown = 5;
const base_duration = .75

const description  = "Quickly dashes in a direction, briefly becoming invulnerable and able to move through enemies.";

func use()->void:
	var direction:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction == Vector2.ZERO:
		if get_global_mouse_position().x > Entities.in_fight_player.position.x:
			direction = Vector2(1, 0);
		else:
			direction = Vector2(-1, 0)
	var target_position:Vector2 = Entities.in_fight_player.global_position + direction * movement_distance;
	
	var duration:=base_duration;
	var technique :float = Entities.in_fight_player.technique;
	if technique > 1:
		duration *= technique
	
	Combat.turn_ellusive(Entities.in_fight_player, duration);
	
	Entities.in_fight_player.modulate.a = .5
	
	var tween: = Entities.in_fight_player.create_tween();
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(Entities.in_fight_player, "global_position", target_position, base_duration/2);
	tween.tween_callback(clear_vfx);
	
	
func clear_vfx()->void:
	Entities.in_fight_player.modulate.a = 1;
