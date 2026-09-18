extends TextureRect

class_name PartyIcon

@export var count_label:Label;
@onready var player:Player = Entities.player;

func _ready()->void:
	if count_label:
		refresh();
		Entities.player.party_changed.connect(refresh)


func refresh()->void:
	count_label.text = str(len(player.roster.units)) + "/" + str(player.party_cap);
		
