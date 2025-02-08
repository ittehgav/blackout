extends ActiveFighter;

class_name InFightPlayer

##redeclaring body as base so it gets its VFX to work the same way as they do on ActiveFighter
@export_category("Unique to Player")
@export var body: FighterBase;
@export var weapon:Node2D;
@export var hit_scan:Area2D;
@export var camera:Camera2D;


var moving:bool = false;

func _ready()->void:
	max_hp = 1000;
	hp = 1000;
	Entities.fighting_player = self;

func get_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * move_speed
	body.moving_right = velocity.x > 0;
	if velocity:
		if not moving:
			moving = true;
			body.switch_animation("walk")
	else:
		if moving:
			moving = false;
			body.switch_animation("idle")
	

func _physics_process(_delta:float):
	if stun_timer.is_stopped():
		get_input()
		move_and_slide()
	hit_scan.look_at(get_global_mouse_position())
