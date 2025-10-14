extends Speaker

@export var index:int;

var inventory:NpcInventory

func _ready()->void:
	super();
	inventory = source["rotating_inventory_"+str(index)]
	
	

func _input(e:InputEvent)->void:
	if contact and e.is_action_pressed("interact") and not get_tree().paused:
		Dialogue.start_dialogue(dialogue, self, clerk_sprite);
