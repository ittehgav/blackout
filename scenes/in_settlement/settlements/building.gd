@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/icon_map.png")
class_name Building
## settlement where you do anything that's not fighting
## and maybe also fighting?
extends Settlement;



@export var theme_color:Color;

enum Option{
	trade,
	recruit,
	evolve,
	forge
}
var option_descriptions:={
	Option.trade:
		"Buy and sell items and resources.",
	Option.recruit:
		"Hire units to fight in your party.",
	Option.evolve:
		"Use " + Index.get_color_tag("juice") +"Juice[/color] to transform your units, making them much more powerful.",
	Option.forge:
		"Use "+Index.get_color_tag("scrap") + "Scrap[/color] to apply modifiers to weapons, modules and accessories."
}

@export var options:Array[Option]
## CAN HAVE AT MOST SIZE + 1 OPTIONS

@export var evolve_tag:FighterBase.RecruitTag;
@export_subgroup("Nodes")

## size = thirds of the space the building takes up,
## a size 3 bulding always takes up the whole location

## theres gotta be a cleaner way to do this?
## some (if not most buildings) will just not have inventories or roster, if they
## have no operations that need them to have one;
@export var inventory:ShopInventory;
@export var roster:RecruitmentRoster;


func refresh()->void:
	pending_refresh = false;
	refresh_stores()

func refresh_stores()->void:
	if inventory:
		inventory.refresh_inventory();
	if roster:
		roster.refresh_recruits();


func accepts_trade(item:Item)->bool:
	## overrideable
	return item is ResourceContainer;
	
func has_use(o:Option)->bool:

	match o:
		Option.trade:
			return true
		Option.recruit:
			var player:Player = get_tree().get_first_node_in_group("player")
			if player.inventory.money > 0:
				return true
		Option.evolve:
			var player:Player = get_tree().get_first_node_in_group("player")
			for unit:FighterUnit in player.roster.units:
				if len(unit.base.evolutions):
					return true
		Option.forge:
			var player:Player = get_tree().get_first_node_in_group("player")
			if player.inventory.scrap > 0:
				return true
	return false
