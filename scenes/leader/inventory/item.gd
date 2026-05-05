@abstract 
class_name Item
extends Sprite2D

var mirror:ItemMirror;

var applied_modifier:ItemModifier

@export_enum(
	## type of shit i don't get to do by making things too tidy with enums
	"food",
	"fuel",
	"money",
	
	"juice",
	"scrap",
	"chips",
	
	"max_hp",
	"attack",
	"defense",
	"agility",
	"technique",
	## if no color tag, just color it based on the rarity
	)var color_tag:String= "none";

@export var inventory_position:Vector2=InventoryDisplay.ITEM_UNPLACED;

@export var stack_size:int=1;

## get applied to the price before the shop modifiers, may be negative/less than 1
var price_change:int; 
var price_multiplier:float=1;

func match_mirror()->void:
	## encapsulating this because to make it easier to find the calls to this
	inventory_position = mirror.inventory_position;


func get_description()->String:
	return "DESCRIPTION MISSOMG"


const rarity_saturation = {
	1:.8,
	2:.95,
	3:1
}
func get_mirror_color()->Color:
	if color_tag != "none":
		var target_color:Color = Index.get_color(color_tag);
	
		target_color.s *= rarity_saturation[self["rarity"]]
		return target_color;
	else:
		return Index.item_rarity_colors[self["rarity"]];

func get_price()->int:
	## not selling = buying
	## true price = higher than selling and lowe than buying
	## true price dont matter right now?

	var price:float = (self["rarity"] + 1) ** 2
	price *= self["size_x"] * self["size_y"]
	
	price += price_change;
	price *= price_multiplier
	return int(price)
