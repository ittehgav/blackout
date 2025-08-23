extends Equipment

class_name Accessory

const tooltip_hint = "[right-click] to equip."

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
