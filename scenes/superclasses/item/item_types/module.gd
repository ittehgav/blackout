extends Equipment

class_name Module;
	
signal equipped;

func _ready()->void:
	name = "Module - " + name

func check_available()->bool:
	return true;
