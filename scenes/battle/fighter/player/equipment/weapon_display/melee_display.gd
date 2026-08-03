extends WeaponDisplay;
class_name MeleeWeaponDisplay;


const skew_shift = 0.349065 ## 20º rad
const position_x_shift:int = 15;
const position_y_shift:int = 5;


## doesn't rotat
const equipment_offset: = Vector2(0, -10);
## rotate
const weapon_offset = Vector2.ZERO

func body_frame_changed() -> void:
	if weapon.is_visible_in_tree() and not_attacking():
		check_skew();
		check_behind_player();

func _input(e:InputEvent)->void:
	if e is InputEventMouseMotion:
		check_skew();


func check_skew()->void:
	var sector:int = body.frame_coords.x
	match sector:
		1:
			weapon.skew = -skew_shift
			weapon.position = Vector2(position_x_shift, -position_y_shift)
		2:
			weapon.skew = 0;
			weapon.position = Vector2.ZERO
		3:
			weapon.skew = skew_shift
			weapon.position = Vector2(-position_x_shift, -position_y_shift);
		5:
			weapon.skew = -skew_shift;
			weapon.position = Vector2(-position_x_shift, position_y_shift)
		6:
			weapon.skew = 0;
			weapon.position = Vector2.ZERO;
		7:
			weapon.skew = skew_shift;
			weapon.position = Vector2(position_x_shift, position_y_shift)

const behind_scale = Vector2(-1, -1);
const front_scale = Vector2(1, 1)

const behind_z_index = -1;
const front_z_index = 1;

const front_modulate = Color.WHITE;
const behind_modulate = Color("a0a0a0ff")

const z_sensitive_attributes = ["scale", "z_index", "modulate"]

func set_behind_player(behind:bool)->void:
	behind_player = behind
	var key:String = "behind"  if behind else "front"

	for p:String in z_sensitive_attributes:
		weapon[p] = self[key+'_'+p];

func check_behind_player(force_update:bool=false)->void:
	assert(not (body.frame_coords.x in [0, 4]))
	var is_behind:bool = body.frame_coords.x > 4  or body.frame_coords.x < 0
	if is_behind:
		if not behind_player or force_update:
			set_behind_player(true);
	else:
		if behind_player or force_update:
			set_behind_player(false)
