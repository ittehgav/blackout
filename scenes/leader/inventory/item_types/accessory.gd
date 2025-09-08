extends Equipment

class_name Accessory

@export var stat_modifiers:CombatStats;
## MULTIPLIERS HERE AS THE VALUES THAT ARE ADDED TO THE UNIT'S MULTIPLIERS
## IE to double a stat you make the multiplier 1
## and everything that doesn't change is set to 0
@export var stat_multipliers:CombatStats; ## these are described by the item unlike the modifiers


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
	"disruptor") var exclusive_tag:String = "none";

func get_description()->String:
	var description:String = "Equippable on ";
	if equippable.player and equippable.unit and exclusive_tag == "none":
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
				description += "\n" + text;
	return description;
