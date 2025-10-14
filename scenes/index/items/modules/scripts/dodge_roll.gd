extends Module

const rarity = 1;

@export var trail:Sprite2D;
@export var dust:Sprite2D;

func get_description()->String:
	return "Quickly dashes in the direction you're facing, briefly becoming invulnerable and able to move through enemies.";



const movement_distance = 500
const base_duration = .75


func use()->void:
	play_animation();
	
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
	
	
func play_animation()->void:
	## try and do these separately from the use functions
	## because module use functions are 
	## already gonna be clusterfucks of code as is
	dust.position = Entities.player_fighter.global_position;
	dust.flip_h = Entities.player_fighter.body.flip_h;
	var shift: = -20;
	if dust.flip_h:
		shift *= -1
	dust.position.x += shift;
	animation_player.play("dodge_roll")
	dust.get_node("dust_animation").play("dust")
	
	trail.frame = Entities.player_fighter.body.frame;
	const after_images = 3;
	for i:int in after_images:
		var blur:Sprite2D = trail.duplicate();
		Entities.player_fighter.ally_team.projectiles.add_child(blur)

		var delay:float = base_duration * ((float(i) + 1)/6) ** 2
		show_trail(delay, blur);

func show_trail(delay:float, blur:Sprite2D)->void:
	await get_tree().create_timer(delay).timeout;
	blur.global_position = Entities.player_fighter.global_position;
	blur.show();
	var tween:Tween = create_tween();
	tween.tween_property(blur, "modulate:a", 0, .35);
	tween.tween_callback(blur.queue_free)
	


func clear_vfx()->void:
	Entities.player_fighter.modulate.a = 1;
