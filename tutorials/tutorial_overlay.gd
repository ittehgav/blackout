extends Control

class_name TutorialOverlay;

signal next_tutorial
## will do nothing sometimes but its ok

@export var pause_on_show:bool=false;

@export_enum("camera_pan",
"click_to_navigate",
"spacebar_to_speed_up",

"in_settlement_wasd",
"right_click_shop",

"wasd_combat",
"lmb_attack",
"switch_weapon",
"use_module",

"right_click_interact") var which:String;
## matches the bools in the tutorial singleton

## enters and exits from manually connected signals
func fade_in(_args:Variant=null)->void:
	if pause_on_show:
		get_tree().paused = true;
	if not Tutorial[which]:
		Tweens.ui_fade_in(self)
		Tutorial[which] = true;
		

func clear(_args:Variant=null)->void:
	if visible:
		if pause_on_show:
			get_tree().paused = false
		Tweens.ui_fade_out(self)
		await get_tree().create_timer(2).timeout;
		next_tutorial.emit()
		queue_free()
