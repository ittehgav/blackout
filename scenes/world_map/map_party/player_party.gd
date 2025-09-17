extends MapParty;

class_name PlayerParty;

@export var marker:Sprite2D;

@export var resources_warning:Control;

func _ready()->void:
	## PLAYER PARTY IS COMPLETELY IMPLEMENTED IN WORLD MAP AS IT APPEARS NOWHERE ELSE
	super()
	Entities.player_party = self;
	ColorCoder.color_code_vehicle(vehicle, leader)
	
	marker.show_in_settlement(current_settlement);
	
	settlement_visited.emit(current_settlement)
	current_settlement.player_visited.emit()

func _input(e:InputEvent)->void:
	if e.is_action_pressed("show_player_sheet") and not Entities.player_sheet.open:
		Entities.player_sheet.show_player_sheet()
		if navigation_tween.is_running():
			## other parties pause with the tree
			navigation_tween.pause();
			Entities.player_sheet.closed.connect(resume_navigation, CONNECT_ONE_SHOT)

func move_to_settlement(target:Settlement, warnings_cleared:bool=false)->void:
	var costs:Dictionary = get_travel_cost(target);
	if leader.inventory.food < costs.food or\
	leader.inventory.fuel < costs.fuel:
		Tweens.ui_fade_in(resources_warning);
		await resources_warning.response;
		if resources_warning.accepted:
			super(target);
	else:
		super(target)

func resume_navigation()->void:
	navigation_tween.play();

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
	
	
func get_travel_cost(target:Settlement)->Dictionary[String, int]:
	var dict:Dictionary[String, int] = leader.travel_upkeep_cost();
	var travel_minutes:int = get_travel_minutes(target);

	var upkeep_hits:int = (travel_minutes + float((Entities.world_map.current_minute % 30)))/30.0;

	dict.food *= upkeep_hits;
	dict.fuel *= upkeep_hits;
	return dict
