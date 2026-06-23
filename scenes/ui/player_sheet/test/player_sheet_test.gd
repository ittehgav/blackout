extends Control
@export var sheet:PlayerSheet

func _ready() -> void:
	sheet.show_player_sheet()

func _input(e:InputEvent)->void:
	if e.is_action_pressed("show_player_sheet") and not sheet.open:
		sheet.show_player_sheet()
