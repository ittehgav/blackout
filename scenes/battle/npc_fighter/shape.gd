extends CollisionShape2D

var show_projection:bool;

const circle_center_color = Color.RED - Color(0, 0, 0, .5);
const circle_outside_color = Color.RED - Color(0, 0, 0, .9)

var circle_center_radius;
var circle_outside_radius;

func _ready():
	if shape is CircleShape2D:
		circle_center_radius = shape.radius/2
		circle_outside_radius = shape.radius

func _draw()->void:
	if show_projection:
		draw_circle(Vector2(0, 0), circle_center_radius, circle_center_color);
		draw_circle(Vector2(0, 0), circle_outside_radius, Color.RED, );

func start_aoe_highlight():
	show();
	aoe_highlight();

func aoe_highlight():
	if visible and show_projection:
		var tween = create_tween();
		tween.tween_property(self, "modulate:a", 0, .5);
		tween.tween_property(self, "modulate:a", 1, .5)
		tween.tween_callback(aoe_highlight)
