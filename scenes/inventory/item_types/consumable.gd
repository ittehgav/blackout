@abstract 
@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/icon_potion.png")
class_name Consumable
extends Item

enum UseFeedback{
	show_player_view,## MUTUALLY EXCLUSIVE
	show_party_view,
	
	board_shake,
	play_sfx
}
@export var feedback:Array[UseFeedback] = [UseFeedback.board_shake]

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
	"container",
	"artifice"
) var item_target:String;

@export var tag_target:FighterBase.Tag;


func use()->void:
	printerr("MISSING USE ", name)
func use_on_target(_target:FighterUnit)->void:
	printerr("MISSIGUESONTARGET ", name)

func filter_valid_target(target:FighterUnit)->bool:
	return tag_target in target.base.tags;
