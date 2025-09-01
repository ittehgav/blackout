extends Equipment

class_name Accessory


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
				description += exclusive_tag+"s";
			else:
				description += "units"
	description += ".\n";
	return description;
