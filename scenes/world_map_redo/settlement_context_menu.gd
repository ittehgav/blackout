extends Control

@export var continue_travel_btn:Button;

func _on_player_party_settlement_visited(settlement: Settlement) -> void:
	reparent(settlement.hover_box, false)
	Tweens.ui_fade_in(self)
	## where other options will be implemented based on stuff that you can do on the settlement
	## IE trade with places
	## only after you've entered
	## (or interacted with the buildings?(once per type?))
	if len(Entities.player_party.stops):
		continue_travel_btn.show();
	else:
		continue_travel_btn.hide()


func _on_player_party_started_moving() -> void:
	hide();


func _on_continue_pressed() -> void:
	var target:Settlement = Entities.player_party.stops[len(Entities.player_party.stops) - 1]
	Entities.player_party.move_to_settlement(target)
