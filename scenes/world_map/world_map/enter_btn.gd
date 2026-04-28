extends Button


var current_location:Location;
@export var location_menu:LocationMenu


func _on_player_party_location_visited(location: Location) -> void:
	global_position = location.global_position + Vector2(-size.x/2, 50);
	current_location = location



func _on_pressed() -> void:
	location_menu.display_location()



func _on_player_party_started_moving() -> void:
	hide()


func _on_location_menu_opened() -> void:
	hide()


func _on_location_menu_closed() -> void:
	show()
