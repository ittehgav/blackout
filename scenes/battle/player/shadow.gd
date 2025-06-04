extends Node2D
const shadow_color = Color(0, 0, 0, .5)

func _draw()->void:
	draw_circle(Vector2.ZERO, 25, shadow_color)
