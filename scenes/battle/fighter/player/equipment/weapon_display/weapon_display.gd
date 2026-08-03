@abstract
class_name WeaponDisplay;
extends Node

enum PlayerScreenFeedback{
	lunge,
	freeze_frame,
	recoil,
	shake
}
## easier to program if they never overlap but may be an angle to enrich VFX of player POV eventually?
@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
@export var use_feedback:PlayerScreenFeedback=-1;
@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
@export var hit_feedback:PlayerScreenFeedback=-1

enum CameraRange{
	short, long
}
@export var camera_range:CameraRange = CameraRange.short
@export var visual_scale:int = 2;

var equipment:EquipmentControl;
var body:FighterBase
var weapon:Weapon;

var behind_player:bool;

func _ready() -> void:
	if not equipment:
		set_process_mode(PROCESS_MODE_DISABLED)
		queue_free();


func not_attacking()->bool:
	var atk_key:String = weapon.get_animation_key("attack")
	var current:String = weapon.animation_player.current_animation
	return current != atk_key;


func setup(player:PlayerFighter, target:Weapon)->void:
	weapon = target
	## cleaner like this than to make a crossed reference?
	equipment = player.equipment;
	body = player.body;
	body.frame_changed.connect(body_frame_changed);
	target.position = self["weapon_offset"]
	set_process_mode(PROCESS_MODE_DISABLED)

func weapon_animation_finished(_anim_name:String)->void:
	set_process_input(not_attacking());
	

@abstract func body_frame_changed()->void;
## cleaner to just put a pass if a display class ends up not needing this?
