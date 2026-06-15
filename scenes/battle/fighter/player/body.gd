extends FighterBase
class_name PlayerFighterBase;

@export var player:PlayerFighter
@export var weapon_control:WeaponControl;

## very ugly how this inherits fighterbase and has a ton of properties that do nothing
## and could lead to bugs as i expand on fighterbase

func full_skill_description(_unit:FighterUnit)->String:
	return "fsd?"

func _physics_process(_delta: float) -> void:
	frame_coords.x =  player.get_sector(player.body_angle);

func turn_to_cursor()->void:
	var angle:float = global_position.angle_to_point(get_global_mouse_position());
	frame_coords.x = player.get_sector(angle);
	
func _on_equipment_weapon_used() -> void:
	set_physics_process(false)
	turn_to_cursor()
	var weapon:Weapon = weapon_control.weapon;
	animation_player.play("player/" + weapon.use_feedback);
	var facing_left:bool = global_position.x > get_global_mouse_position().x;
	var offset_target:int = 30;
	if facing_left:
		offset_target *= -1;

	if weapon.use_feedback == "recoil":
		offset_target *= -1;

	var tween:Tween = create_tween()
	tween.tween_property(self, "position:x", offset_target, .05);
	tween.tween_property(self, "position:x", 0, .15);
	await weapon.animation_player.animation_finished;
	set_physics_process(true)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	## TODO make walking animation face cursor and play backwards if going the opposite X direction
	if anim_name in ["player/lunge", "player/recoil"]:
		## make this nicer once we get more feedbacks?
		if not player.moving:
			animation_player.play("player/idle")
		else:
			animation_player.play("player/walk")
