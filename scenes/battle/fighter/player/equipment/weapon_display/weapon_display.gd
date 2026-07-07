@abstract
class_name WeaponDisplay;
extends Node

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

@abstract func body_frame_changed()->void;
## cleaner to just put a pass if a display class ends up not needing this?

func setup(player:PlayerFighter, target:Weapon)->void:
	weapon = target
	## cleaner like this than to make a crossed reference?
	equipment = player.equipment;
	body = player.body;
	body.frame_changed.connect(body_frame_changed);
	set_process_mode(PROCESS_MODE_DISABLED)

func weapon_animation_finished(_anim_name:String)->void:
	set_process_input(not_attacking());
