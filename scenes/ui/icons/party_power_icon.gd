extends TextureRect

class_name PartyPowerIcon

@export var value_label:Label;
var leader:Leader;

func _ready()->void:
	refresh()

func refresh()->void:
	if not leader:
		leader = Entities.player
	value_label.text = str(get_party_power())
	
func get_party_power()->int:
	var total_power:int=0;
	if leader is Player:
		total_power += leader.combat_level + leader.leadership_level;
	else:
		total_power += leader.leader_unit.level * 2;
		
	for unit in leader.roster.units:
		total_power += unit.level;
	
	return total_power


func _on_visibility_changed() -> void:
	if leader:
		refresh();
