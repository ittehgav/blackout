extends MapParty;

class_name PlayerParty;

@export var marker:Sprite2D;

func _ready()->void:
	## PLAYER PARTY IS COMPLETELY IMPLEMENTED IN WORLD MAP AS IT APPEARS NOWHERE ELSE
	super()
	Entities.player_party = self;
	ColorCoder.color_code_vehicle(vehicle, leader)
	
	marker.show_in_settlement(current_settlement);
	
	settlement_visited.emit(current_settlement)
	
func _input(e:InputEvent)->void:
	if e.is_action_pressed("show_player_sheet") and not Entities.player_sheet.open:
		Entities.player_sheet.show_player_sheet()

func _on_started_moving() -> void:
	get_tree().paused = false;
	marker.show_in_settlement(movement_target);
	get_tree().call_group("all_settlements", "player_started_moving")


func _on_settlement_visited(settlement: Settlement) -> void:
	settlement.data.visited = true;
	stopped_moving.emit();
	get_tree().call_group("all_settlements", "player_stopped_moving");


func _on_stopped_moving() -> void:
	get_tree().paused = true;
