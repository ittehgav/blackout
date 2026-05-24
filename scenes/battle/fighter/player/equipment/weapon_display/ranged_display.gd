extends WeaponDisplay;
class_name RangedWeaponDisplay;

func body_frame_changed()->void:
	pass
func _input(e:InputEvent)->void:
	if e is InputEventMouseMotion:
		turn_weapon()

func turn_weapon()->void:
	var cursor:Vector2 = equipment.get_global_mouse_position()
	equipment.weapon_anchor.rotation = equipment.global_position\
	.angle_to_point(cursor)
	if equipment.global_position.x < cursor.x:
		weapon.scale.y = abs(weapon.scale.y);
	else:
		weapon.scale.y = abs(weapon.scale.y) * -1
