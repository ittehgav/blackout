extends WeaponDisplay;
class_name MeleeWeaponDisplay;


const skew_shift = 0.349065 ## 20º rad
const position_x_shift:int = 30;
const position_y_shift:int = 10;


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
	if behind:
		equipment.right_hand.z_index = 0;
		equipment.left_hand.z_index = -1;
	else:
		equipment.right_hand.z_index = -1;
		equipment.left_hand.z_index = 0
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

func weapon_used() -> void:
	if behind_player:
		equipment.weapon_anchor.scale.x = -1;
		weapon.scale = front_scale
		weapon.position.x = 100

	match body.frame_coords.x:
		1, 5:
			equipment.weapon_anchor.rotation_degrees = -45
		3, 7:
			equipment.weapon_anchor.rotation_degrees = 45;
	weapon.skew = 0;
	## TODO catch overlapping attack animations to keep 
	## double resets from screwing up attack animations
	## on really fast attack speeds
	await weapon.animation_player.animation_finished;

	equipment.weapon_anchor.rotation = 0
	equipment.weapon_anchor.scale = Vector2.ONE
	weapon.position = Vector2.ZERO;
	check_behind_player(true)


func body_frame_changed() -> void:
	if weapon.is_visible_in_tree() and not_attacking():
		check_skew();
		check_behind_player();
