@icon("res://assets/visual/editor_ui/IconGodotNode/control/icon_interrogation.png")
extends Control

@export var location_menu:LocationMenu

@export var drag_instruction:RichTextLabel;
@export var travel_instruction:Control;
@export var upkeep_explanation:Control;

@export var quick_buy_highlight:TextureRect;
@export var buy_resources_instruction:Control;
@export var confirm_trade_highlight:TextureRect

@export var free_travel_instruction:Control;


func _ready()->void:
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
	
