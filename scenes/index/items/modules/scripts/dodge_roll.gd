extends Module

const rarity = 1;



func get_description()->String:
	return "Quickly dashes in the direction you're facing, briefly becoming invulnerable and able to move through enemies.";



const movement_distance = 500
const base_duration = .75


func use()->void:
	use_sfx.play()
	Trail.attach(Entities.player_fighter.sprite)
	
	var direction:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction == Vector2.ZERO:
		if get_global_mouse_position().x > Entities.player_fighter.position.x:
			direction = Vector2(1, 0);
		else:
			direction = Vector2(-1, 0)
	var target_position:Vector2 = Entities.player_fighter.global_position + direction * movement_distance;
	
	var duration:=base_duration;
	var technique :float = Entities.player_fighter.technique;
	if technique > 1:
		duration *= technique
	
	Combat.turn_ellusive(Entities.player_fighter, duration);
	
	Entities.player_fighter.modulate.a = .5
	
	var tween: = Entities.player_fighter.create_tween();
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(Entities.player_fighter, "global_position", target_position, base_duration/2);
	tween.tween_callback(clear_vfx);


func clear_vfx()->void:
	if modifier == 1:
		status.apply_on_target(Entities.player_fighter);
	Trail.detach(Entities.player_fighter.sprite)
	Entities.player_fighter.modulate.a = 1;



const m1_description = "Gain an agility buff after rolling.";
const m1_prefix = "Momentum"

const m2_description = "-50% cooldown."
const m2_prefix = "Ever-ready"




func apply_m2()->void:
	cooldown /= 2;
