extends Control
class_name PlayerView;

@export var name_label:Label;

@export var player_sample:Control;

@export_subgroup("Levels")
@export var level_label:Label;
@export var player_experience:ExperienceBar;

@onready var player:Player = Entities.player

func _ready()->void: 
	name_label.text = player.name

func refresh_data(change:Equipment=null)->void:
	## carryingh change argument for playing atk animation 
	## on player sample on weapon change
	level_label.text = "Level: " + str(player.level)
	var current_weapon:Weapon = player.equipped_weapon;
	player_sample.load_weapon(current_weapon)
	if change == Entities.player.equipped_weapon:
		## easier than to catch first load?
		player_sample.play_weapon_attack()
	else:
		player_sample.play_weapon_idle();
	
