extends UIRoot

@export var navigation_data:Control;
@export var location_data:Control;

@export var player_data:Control;
@export var resources:ResourcesDropdown;

@export var clock:Control


func _ready()->void:
	refresh_elements()

func refresh_elements() -> void:
	## TODO make this adapt to scenario/substate changes
	## unless it turns out we dont need this?
	resources.update()




func _on_location_menu_menu_opened() -> void:
	Tweens.ui_fade_out(self)


func _on_location_menu_menu_closed() -> void:
	show()
	modulate.a = 1
