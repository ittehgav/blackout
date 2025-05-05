extends Node2D

func _draw()->void:
	const shadow_color = Color(0, 0, 0, .2);
	draw_circle(Vector2(0, 50), 15, shadow_color)
