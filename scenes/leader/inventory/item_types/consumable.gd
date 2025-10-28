extends Item

class_name Consumable;

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
	printerr("USEMISSING")

func use_on_target(_target:FighterUnit)->void:
	assert(false)
