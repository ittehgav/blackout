extends TextureRect

class_name PartyIcon

@export var count_label:Label;
var leader:Leader;

func _ready():
	Entities.player.party_changed.connect(refresh)
	refresh();
	
func refresh():
	if not leader:
		leader = Entities.player;
	var available_count = 0;
	var downed_count = 0;
	for unit:FighterUnit in leader.roster.units:
		if unit.remaining_downed_minutes:
			downed_count += 1;
		else:
			available_count += 1
	if not downed_count:
		count_label.text = str(len(leader.roster.units));
	else:
		count_label.text = str(available_count) + "(" + str(downed_count) + ")"


func _on_visibility_changed() -> void:
	if leader:
		refresh();
