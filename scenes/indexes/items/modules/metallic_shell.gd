extends Module

const rarity = 2;

const cooldown = 5;

@onready var description:String = "Consumes 10 " + Index.get_color_tag("scrap") + "Scrap[/color] and gains a shield equal to 20% of your " + Index.get_color_tag("max_hp") + "Max HP";

func use()->void:
	print("moduluse ", name)
