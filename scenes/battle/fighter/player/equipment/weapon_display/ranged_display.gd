extends WeaponDisplay;
class_name RangedWeaponDisplay;

## doesn't rotat
const equipment_offset = Vector2(0, -25)

## rotates
const weapon_offset = Vector2(10, 0)


func body_frame_changed()->void:
	if weapon.get_global_mouse_position().y < Entities.player_fighter.global_position.y:
		weapon.z_index = -1;
	else:
		weapon.z_index = 1


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
