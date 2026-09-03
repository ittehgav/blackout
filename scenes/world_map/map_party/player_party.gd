extends MapParty;

class_name PlayerParty;


@export var marker:Sprite2D;

@export var resources_warning:Control;
@export var location_menu:LocationMenu

func _ready()->void:
	## PLAYER PARTY IS COMPLETELY IMPLEMENTED IN WORLD MAP AS IT APPEARS NOWHERE ELSE
	Entities.player_party = self;
	leader = Entities.player
	super()
	
	leader.inventory.changed.connect(refresh_speed)
	
	marker.show_in_location(current_location);
	global_position = current_location.global_position


func _input(e:InputEvent)->void:
	if e.is_action_pressed("show_player_sheet") and not Entities.player_sheet.open:
		Entities.player_sheet.show_player_sheet()
		if navigation_tween.is_running():
			## other parties pause with the tree
			navigation_tween.pause();
			Entities.player_sheet.closed.connect(resume_navigation, CONNECT_ONE_SHOT)


func move_to_location(target:Location)->void:
	var costs:Dictionary = get_travel_cost(target);
	if leader.inventory.food < costs.food or\
	leader.inventory.fuel < costs.fuel:
		Tweens.ui_fade_in(resources_warning);
		await resources_warning.response;
		if resources_warning.accepted:
			super(target);
	else:
		super(target);

func resume_navigation()->void:
	navigation_tween.play();

func _on_started_moving() -> void:
	get_tree().paused = false;
	marker.show_in_location(movement_target);
	get_tree().call_group("all_locations", "player_started_moving")


func _on_location_visited(location: Location) -> void:
	stopped_moving.emit();
	get_tree().paused = true;
	
	get_tree().call_group("all_locations", "player_stopped_moving");
	location.player_visited.emit()
	location_menu.display_location(location)



	
	
func get_travel_cost(target:Location)->Dictionary[String, int]:
	var dict:Dictionary[String, int] = leader.travel_upkeep_cost();
	var travel_minutes:int = get_travel_minutes(target);

	var upkeep_hits:int = (travel_minutes + float((world_map.current_minute % 30)))/30.0;

	dict.food *= upkeep_hits;
	dict.fuel *= upkeep_hits;
	return dict

func enter_location()->void:
	location_menu.show_location()


func _on_shift_skill_check_fail_hit() -> void:
	if navigation_tween and navigation_tween.is_running():
		navigation_tween.set_speed_scale(.75)


func _on_shift_skill_check_good_hit() -> void:
	if navigation_tween and navigation_tween.is_running():
		navigation_tween.set_speed_scale(1)


func _on_shift_skill_check_perfect_hit() -> void:
	if navigation_tween and navigation_tween.is_running():
		navigation_tween.set_speed_scale(1.5)
