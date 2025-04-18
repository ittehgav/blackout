extends Node2D

@export var weapon:Weapon;

func play_vfx():
	var effect = duplicate();
	var tween = create_tween();
	tween.tween_property(effect, "modulate:a", .35, .25);
	tween.tween_property(effect, "modulate:a", 0, .25);
	Entities.arena.projectiles.add_child(effect)
	effect.global_position = get_global_mouse_position();
	
func _draw():
	draw_circle(Vector2.ZERO, weapon.aoe_radius, Color(.6, .6, .6), false, 2);
	draw_circle(Vector2.ZERO, weapon.aoe_radius, Color.WHITE);
