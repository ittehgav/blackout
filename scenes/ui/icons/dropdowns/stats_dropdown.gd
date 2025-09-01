extends VBoxContainer

class_name StatsDropdown


@export var source:CombatStats;

@export var from_player:bool=false;

@export var stat_labels:Dictionary[String, Label];

func _ready()->void:
	if source:
		load_stats(source);
	elif from_player:
		load_stats(Entities.player.combat_stats)

func load_stats(new_source:CombatStats)->void:
	source = new_source;
	update();


func update()->void:
	for stat:String in Index.all_combat_stats:
		stat_labels[stat].text = str(source[stat]);
