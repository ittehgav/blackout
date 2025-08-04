extends Node

class_name TextureIndex;

@export_group("Floating Icons")
@export var max_hp_floating_icon:Texture;
@export var attack_floating_icon:Texture;
@export var defense_floating_icon:Texture;
@export var technique_floating_icon:Texture;
@export var agility_floating_icon:Texture;
@export_group("Circles")
@export var hollow_circles:Array[Texture];
@export var filled_circles:Array[Texture]



@export_group("party behavior icons")
@export var idle_icon_texture:Texture;
@export var scared_icon_texture:Texture;
@export var agressive_icon_texture:Texture;
@export var salesman_icon_texture:Texture


@onready var icons:Dictionary = {
	"defense":load("res://assets/visual/icons/stats/defense.png"),
	"attack":load("res://assets/visual/icons/stats/attack.png"),
	"max_hp":load("res://assets/visual/icons/stats/max_hp.png"),
	"agility":load("res://assets/visual/icons/stats/agility.png"),
	"technique":load("res://assets/visual/icons/stats/technique.png"),

	"food":load("res://assets/visual/icons/resources/food.png"),
	"money":load("res://assets/visual/icons/resources/money.png"),
	"fuel":load("res://assets/visual/icons/resources/fuel.png"),

	"juice":load("res://assets/visual/icons/resources/juice.png"),
	"scrap":load("res://assets/visual/icons/resources/scrap.png"),
	"chips":load("res://assets/visual/icons/resources/chips.png"),
}
