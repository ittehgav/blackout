extends TextureRect

class_name PartyIcon

@export var count_label:Label;
var leader:Leader;

func _ready()->void:
	if Entities.player:
		Entities.player.party_changed.connect(refresh)
		refresh();
	
func refresh()->void:
	if not leader:
		leader = Entities.player;
	count_label.text = str(len(leader.roster.units));



func _on_visibility_changed() -> void:
	if leader:
		refresh();
