extends Module

const rarity = 2;

const cooldown = 5;

## juice consumption scales with leadership_level?
@onready var  description:String = "Cosumes 1 " + Index.get_color_tag("juice") + "juice[/color] and double your attack speed for 5 seconds.";
 
func use()->void:
	pass
