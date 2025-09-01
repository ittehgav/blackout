extends Equipment;

class_name Weapon;

signal equipped;
signal unequipped;

signal refresh_request;

@export var has_finish:bool = false


@export var cooldown:float;


func set_hint_data()->void:
	pass
