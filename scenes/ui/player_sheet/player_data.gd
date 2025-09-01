extends Panel

@export var name_label:Label;


@export_subgroup("Levels")
@export var level_label:Label;
@export var player_experience:ExperienceBar;



func _ready()->void: 
	name_label.text = Entities.player.name

func refresh_data()->void:
	level_label.text = "Level: " + str(Entities.player.level)

	
	
