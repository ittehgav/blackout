extends TextureRect

class_name PartyPowerIcon

@export var value_label:Label;
var leader:Leader;

func _ready()->void:
	refresh()

func refresh()->void:
	if not leader:
		leader = Entities.player
	value_label.text = str(leader.level)
	



func _on_visibility_changed() -> void:
	if leader:
		refresh();
