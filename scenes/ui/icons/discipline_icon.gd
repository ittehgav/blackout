extends Icon

class_name DisciplineIcon;

@export var charisma_icon:Texture;
@export var navigation_icon:Texture;
@export var tactics_icon:Texture;
@export var leadership_icon:Texture;
@export var scavenging_icon:Texture;

@export_enum("charisma", "navigation", "tactics", "leadership", "scavenging") var discipline:String;

func _ready() -> void:
	texture = self[discipline+"_icon"];
