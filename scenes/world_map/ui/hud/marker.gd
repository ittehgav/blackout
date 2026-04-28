extends Sprite2D

@onready var player_party:PlayerParty = get_parent();
@export var bounce_timer:Timer;

const bounce_offsets:Array[int] = [-15, -10, -5]

func show_in_location(target:Location)->void:
	show();
	global_position = target.global_position - Vector2(0, 30);
	start_bounce_animation();
	
func clear()->void:
	hide();
	bounce_timer.stop();

func start_bounce_animation()->void:
	offset.y = bounce_offsets[0]
	bounce_timer.start();


func bounce_animation()->void:
	for i:int in len(bounce_offsets):
		if offset.y == bounce_offsets[i]:
			if i == len(bounce_offsets) - 1:
				offset.y = bounce_offsets[0];
			else:
				offset.y = bounce_offsets[i + 1];
			return
		
		
	
