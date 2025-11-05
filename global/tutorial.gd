extends Node

enum TutorialChecks {
	wasd_map,
	click_travel,
	speed_up,
	
	wasd_in_settlement,
	
	wasd_combat,
	click_wpn,
	e_switch,
	spacebar_module,
	
	tab_inventory,
	right_click_item
}

var checks:Dictionary[TutorialChecks, bool] = {
	TutorialChecks.wasd_map:false,
	TutorialChecks.click_travel:false,
	TutorialChecks.speed_up:false,
	
	TutorialChecks.wasd_in_settlement:false,
	
	TutorialChecks.wasd_combat:false,
	TutorialChecks.click_wpn:false,
	TutorialChecks.e_switch:false,
	TutorialChecks.spacebar_module:false,
	
	TutorialChecks.tab_inventory:false,
	TutorialChecks.right_click_item:false
}
