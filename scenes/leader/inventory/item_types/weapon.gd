extends Equipment;

class_name Weapon;

signal equipped;
signal unequipped;

signal refresh_request;

@export var has_finish:bool = false

const tooltip_hint = "[right-click] to equip.\n[alt+right-click] to equip as secondary";



func set_hint_data()->void:
	pass
