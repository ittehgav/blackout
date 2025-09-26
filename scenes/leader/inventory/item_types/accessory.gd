extends Equipment

class_name Accessory

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



@export_enum(
	"bodybuilder",
	"brawler",
	"cyborg",
	"scientist",
	"mechanic",
	"hunter",
	"doctor", 
	"juggernaut",
	"disruptor") var exclusive_tag:String;


func get_description()->String:
	var description:String = "Equippable on ";
	if equippable.player and equippable.unit and not exclusive_tag:
		description += "anyone";
	else:
		if equippable.player:
			description += "you";
		if equippable.unit:
			if exclusive_tag != "none":
				## only makes it here when not player or has exclusive tag
				if equippable.player:
					description += " and "
				description += Index.get_color_tag(exclusive_tag) + exclusive_tag+"s[/color]";
			else:
				description += "units"
	description += ".\n";
	
	if stat_modifiers:
		for stat:String in Index.all_combat_stats:
			if stat_modifiers[stat]:
				var text:String = Index.get_color_tag(stat) + "+" + str(stat_modifiers[stat]) + " " + stat
				description +=  text + "[/color]"+"\n" ;
	return description;
	

func other_equipped_accessory()->Accessory:
	assert(self == Entities.player.equipped_accessory_1 or 
	self == Entities.player.equipped_accessory_2)
	if self == Entities.player.equipped_accessory_1:
		return Entities.player.equipped_accessory_2;
	else:
		return Entities.player.equipped_accessory_1

func battle_start_apply(_target:ActiveFighter)->void:
	printerr("noapplywhenthereshouldbe?s")
