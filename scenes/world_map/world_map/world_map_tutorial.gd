@icon("res://assets/visual/editor_ui/IconGodotNode/control/icon_interrogation.png")
extends Control

@export var location_menu:LocationMenu

@export var drag_instruction:RichTextLabel;
@export var travel_instruction:Control;

@export var skill_check:ShiftSkillCheck;

@export var shift_instruction:Control
@export var shift_animation:AnimationPlayer;
@export var shift_press_to_start:Label
@export var spacebar_clear:Timer;

@export var upkeep_explanation:Control;

@export var quick_buy_highlight:TextureRect;
@export var buy_resources_instruction:Control;
@export var confirm_trade_highlight:TextureRect

@export var free_travel_instruction:Control;



func _ready()->void:
	set_process_input(false)
	if State.world_map_tutorial_completed:
		queue_free();
		travel_instruction.queue_free();
		return
	else:
		State.world_map_tutorial_completed = true;

	await Entities.player_party.started_moving
	drag_instruction.queue_free()
	travel_instruction.queue_free()
	await get_tree().create_timer(.25).timeout;
	Tweens.ui_fade_in(upkeep_explanation)
	await skill_check.started;
	shift_tutorial()
	await Entities.player_party.stopped_moving;
	upkeep_explanation.queue_free();
	await location_menu.opened;
	Tweens.ui_fade_in(buy_resources_instruction)
	await location_menu.menu_opened;
	buy_resources_instruction.queue_free()
	await get_tree().create_timer(1).timeout
	quick_buy_highlight.show()
	await location_menu.trade_menu.player_inventory_display.item_dropped;
	quick_buy_highlight.queue_free()
	confirm_trade_highlight.show();
	await location_menu.trade_menu.trade_finished;
	confirm_trade_highlight.queue_free();
	await location_menu.closed;
	Tweens.ui_fade_in(free_travel_instruction)
	await get_tree().create_timer(10).timeout;
	free_travel_instruction.queue_free()
	
func shift_tutorial()->void:
	skill_check.set_process_input(false)
	skill_check.motion_tween.pause()
	shift_instruction.show()
	Engine.time_scale = 0;
	shift_animation.play("skill_check_glow")
	
	set_process_input(true)
	
	spacebar_clear.start()

func _input(e:InputEvent)->void:
	if e.is_action_pressed("shift_press"):
		if not spacebar_clear.is_stopped():
			spacebar_clear.start(1)
		else:
			skill_check.set_process_input(true)
			skill_check.motion_tween.play()
			shift_animation.play("RESET")
			shift_instruction.hide()
			Engine.time_scale = .1
			set_process_input(false)

func _on_spacebar_clear_timeout() -> void:
	shift_press_to_start.show();
	
