extends CollisionShape2D

const circle_center_color = Color.RED - Color(0, 0, 0, .5);
const circle_outside_color = Color.RED - Color(0, 0, 0, .9)

var shape_fn:Callable;

var circle_center_radius:float;
var circle_outside_radius:float;

func _ready()->void:
	if shape is CircleShape2D:
		circle_center_radius = shape.radius/2
		circle_outside_radius = shape.radius

func _draw()->void:
	if visible:
		shape_fn.call();

func start_aoe_highlight()->void:
	show();
	aoe_highlight();

func aoe_highlight(cycle_time:float=1,accelerate:bool=false)->void:
	Tweens.ui_fade_out(self, false, cycle_time);
	var tween :Tween = Tweens.ui_fade_in(self, cycle_time);

	if accelerate:
		## make this match the acceleration in the same proportion as the skill accelerates?
		cycle_time *= 1.1;
	tween.tween_callback(aoe_highlight.bind(cycle_time, accelerate))

func set_shape_fn(key:String="basic_aoe", in_player_party:bool=true)->void:
	## TODO make this turn green when the unit is in the player's party
	shape_fn = self[key];


func basic_aoe()->void:
	## TODO: make this adapt to all other forms of shapes??
	## draws a circle in the exact shape of the recruit's skill's hitbox
	draw_circle(Vector2(0, 0), circle_center_radius, circle_center_color);
	draw_circle(Vector2(0, 0), circle_outside_radius, Color.RED);

func wheel_spin()->void:
	if get_parent().fighter in Entities.arena.team_2.units:
		draw_circle(Vector2(0, 0), circle_outside_radius, circle_outside_color);
		rotation_degrees += 1;
