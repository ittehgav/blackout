extends VBoxContainer

class_name DisciplinesDropdown

@export var charisma_icon:DisciplineIcon;
@export var navigation_icon:DisciplineIcon;
@export var tactics_icon:DisciplineIcon;
@export var leadership_icon:DisciplineIcon;
@export var scavenging_icon:DisciplineIcon;

func _ready()->void:

	
	update();

func update()->void:
	for d:String in Index.all_disciplines:
		self[d+"_icon"].update();
