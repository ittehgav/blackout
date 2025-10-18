extends Icon;

class_name PartyPowerIcon

@export var source:Roster;

@export var from_player:bool=false;

func _ready()->void:
	if from_player:
		source = Entities.player.roster;
	if source:
		refresh();

func refresh()->void:
	label.text = str(source.get_level());
