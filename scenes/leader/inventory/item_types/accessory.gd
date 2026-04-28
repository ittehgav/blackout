@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/icon_ring.png")
@abstract
class_name Accessory
extends Equipment

## to make it easier to access this on implementations
## until godot makes custom class names more accessible?
const type = "accessory"

@export var stat_modifiers:CombatStats;
## MULTIPLIERS HERE AS THE VALUES THAT ARE ADDED TO THE UNIT'S MULTIPLIERS
## IE to double a stat you make the multiplier 1
## and everything that doesn't change is set to 0
@export var stat_multipliers:CombatStats; ## these are described by the item unlike the modifiers

@export_enum("battle_start") var application:String = "";
## only for function calls, stat changes are applies as these are equipped
@export var apply_during_battle:bool=false
## if the effect contains Combat singleton calls

@export var equippable:Dictionary[String, bool] = {
	"player":false,
	"unit":false
}


@export var tag_restriction:bool;
@export var exclusive_tag:FighterBase.Tag;


func get_description()->String:
	var description:String = "Equippable on ";
	if equippable.player and equippable.unit and not tag_restriction:
		description += "anyone";
	else:
		if equippable.unit:
			if tag_restriction:
				var tag_str:String = FighterBase.Tag.keys()[exclusive_tag];
				## only makes it here when not player or has exclusive tag
				description += tag_str+"s"
				if equippable.player:
					description += " and " + tag_str + "s"
			else:
				description += "units"
		if equippable.player:
			description += "you";
	description += ".\n\n";
	
	if stat_modifiers:
		for stat:String in Index.all_combat_stats:
			if stat_modifiers[stat]:
				var text:String = Index.get_color_tag(stat) + "+" + str(stat_modifiers[stat]) + " " + stat
				description +=  text + "[/color]"+"\n" ;
	return description;
	

func other_equipped_accessory()->Accessory:
	assert(self == player.equipped_accessory_1 or 
	self == player.equipped_accessory_2)
	if self == player.equipped_accessory_1:
		return player.equipped_accessory_2;
	else:
		return player.equipped_accessory_1

func battle_start_apply(_target:ActiveFighter)->void:
	printerr("nobsa ", name)
