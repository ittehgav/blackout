extends Panel

class_name PlayerView;

@export var name_label:Label;

@export var player_sample:Control;

@export_subgroup("Levels")
@export var level_label:Label;
@export var player_experience:ExperienceBar;

@onready var player:Player = get_tree().get_first_node_in_group("player");


func _ready()->void: 
	name_label.text = player.name

func refresh_data()->void:
	level_label.text = "Level: " + str(player.level)
	var current_weapon:Weapon = player.equipped_weapon;
	player_sample.load_weapon(current_weapon)
	
	
