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
	refine,
	bounty_board
}
var option_descriptions:={
	Option.trade:
		"Buy and sell items and resources.",
	Option.recruit:
		"Hire units to fight in your party.",
	Option.evolve:
		"Use " + Index.get_color_tag("juice") +"Juice[/color] to transform your units, making them much more powerful.",
	Option.refine:
		"Use "+Index.get_color_tag("scrap") + "Scrap to refine weapons[/color], or "+Index.get_color_tag("chips")+"Chips to modify modules[/color] making them much stronger.",
		Option.bounty_board:
			"TODO"
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
	var player:Player = Entities.player;
	match o:
		Option.trade:
			return true
		Option.recruit:
			if player.inventory.money > 0:
				return true
		Option.evolve:
			for unit:FighterUnit in player.roster.units:
				if len(unit.base.evolutions):
					return true
		Option.refine:
			if player.inventory.scrap or player.inventory.chips:
				return true
	return false
