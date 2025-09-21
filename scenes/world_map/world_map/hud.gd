extends UIRoot

@export var navigation_data:Control;
@export var location_data:Control;

@export var player_data:Control;
@export var resources:ResourcesDropdown;

@export var clock:Control


func _ready()->void:
	Entities.main_hud = self


func _on_player_scenario_changed(new_scenario: String, _previous_scenario: String) -> void:
	match new_scenario:
		"location":
			navigation_data.hide();
			location_data.hide();
			
			player_data.show();
			resources.show();
			clock.show()
		"world_map":
			navigation_data.show();
			location_data.show();
			
			player_data.show();
			resources.show();
			clock.show()
