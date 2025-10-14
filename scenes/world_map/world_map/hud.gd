extends UIRoot

@export var navigation_data:Control;
@export var location_data:Control;

@export var player_data:Control;
@export var resources:ResourcesDropdown;

@export var clock:Control



func _on_tree_entered() -> void:
	match Entities.main.scenario:
		"in_settlement":
			## TODO remove world-map only nodes from 
			## hud scene them and add them into world map as
			## external
			navigation_data.hide()
			location_data.hide()
	Entities.main_hud = self

func _ready()->void:
	Entities.main.scenario_changed.connect(refresh_elements)
	Entities.main.substate_changed.connect(refresh_elements)

func refresh_elements(_new_scenario: String, _previous_scenario: String) -> void:
	## TODO make this adapt to scenario/substate changes
	## unless it turns out we dont need this?
	pass
