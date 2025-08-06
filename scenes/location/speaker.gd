extends Node2D

class_name Speaker;
## as of right now just the hitbox and the dialogue object
@export var dialogue:DialogueResource
@export var prompt:Label;

## where the dialogue will look for inventories and rosters for trading/recruiting
var source:Building;
var contact:bool = false;

func _ready()->void:
	## make this cleaner when speakers appear in other contexts
	source = get_parent().building

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == Entities.player_unit:
		show_prompt()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == Entities.player_unit:
		hide_prompt()

func show_prompt()->void:
	## will include some sort of highlight eventually so already leaving it in 
	## separate method
	contact = true
	prompt.show()
	
func hide_prompt()->void:
	contact = false;
	prompt.hide()
	
func _input(e:InputEvent)->void:
	if contact and e.is_action_pressed("interact") and not get_tree().paused:
		Dialogue.start_dialogue(dialogue, source);
