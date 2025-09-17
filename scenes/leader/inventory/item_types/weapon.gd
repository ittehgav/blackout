extends Equipment;

class_name Weapon;

signal equipped;
signal unequipped;

signal refresh_request;

@export var has_finish:bool = false
@export var melee:bool=false; ## short-handing this for now until i normalize the way weapons work


@export var cooldown:float;


func get_mirror_color()->Color:
	return Index.item_rarity_colors[self["rarity"]]
