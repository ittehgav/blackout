extends Module

const rarity = 3;

const cooldown = 5;

@onready var description :String = "Consumes 5 " + Index.get_color_tag("chips") + "Chips[/color] to stun all nearby enemies for 1 second and increase the " + Index.get_color_tag("technique") + "Technique[/color] of nearby allies for the rest of the battle.";

func use()->void:
	print("moduluse ", name)
