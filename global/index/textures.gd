extends Node

class_name TextureIndex;


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
	
	"charisma":load("res://assets/visual/icons/disciplines/chrisma.png"),
	"navigation":load("res://assets/visual/icons/disciplines/navigation.png"),
	"tactics":load("res://assets/visual/icons/disciplines/tactics.png"),
	"leadership":load("res://assets/visual/icons/disciplines/leadership.png"),
	"scavenging":load("res://assets/visual/icons/disciplines/scavenging.png"),
	
	"trade":load("res://assets/visual/icons/options/trade.png"),
	"combat":load("res://assets/visual/icons/options/combat.png"),
	"recruit":load("res://assets/visual/icons/options/recruit.png"),
	"exit":load("res://assets/visual/icons/options/exit.png"),
	"evolve":load("res://assets/visual/icons/options/evolve.png"),
	
	"bodybuilder":load("res://assets/visual/icons/tags/bodybuilder.png"),
	"cyborg":load("res://assets/visual/icons/tags/cyborg.png"),
	"scientist":load("res://assets/visual/icons/tags/scientist.png"),
	"mechanic":load("res://assets/visual/icons/tags/mechanic.png")
}
