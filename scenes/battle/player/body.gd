extends FighterBase

@export var ticker:Timer;


var current_state:String = "idle";
var moving_right:bool = true;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ColorCoder.color_code_player(self);

func _process(_delta)->void:
	flip_h = get_local_mouse_position().x < position.x

func switch_animation(type:String)->void:
	current_state = type;
	match type:
		"walk":
			frame = hframes;
			ticker.wait_time = .2;
		"idle":
			frame = 0;
			ticker.wait_time = .5;
	ticker.start();

func next_frame() -> void:
	match current_state:
		"walk":
			if moving_right:
				if flip_h:
					walk_frame_backward();
				else:
					walk_frame_forward()
			else:
				if not flip_h:
					walk_frame_backward();
				else:
					walk_frame_forward()
				
		"idle":
			if frame:
				frame = 0;
			else:
				frame = 1;

func walk_frame_forward()->void:
	if frame_coords.x == hframes - 1:
		frame = hframes;
	else:
		frame += 1;

func walk_frame_backward()->void:
	if frame_coords.x == 0:
		frame_coords.x = hframes - 1;
	else:
		frame -= 1;
