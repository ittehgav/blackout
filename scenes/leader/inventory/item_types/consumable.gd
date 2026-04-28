@abstract 
@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/icon_potion.png")
class_name Consumable
extends Item


const type = "consumable"
@export var use_sfx:AudioStream;

@export var special_graphics:PackedScene;

@export_enum("unit", "item", "instant") var use_type:String = "instant";

@export_enum(
	## if none are checked, can target any item
	"weapon",
	"module",
	"accessory",
	
	"consumable",
	"container"
) var item_target:String;
@export_enum(
	"bodybuilder",
	"mechanic",
	"scientist",
	"cyborg",

	"brawler",
	"hunter",
	"juggernaut",
	"disruptor") var tag_target:String;


func use()->void:
	printerr("MISSING USE ", name)
func use_on_target(_target:FighterUnit)->void:
	printerr("MISSIGUESONTARGET ", name)
