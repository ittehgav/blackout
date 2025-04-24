extends Module

const rarity = 2;

const cooldown = 5;

const sfx_key = "adrenaline"
const juice_cost = 5;

## juice consumption scales with leadership_level?
@onready var  description:String = "Cosumes " + Index.get_color_tag("juice") + str(juice_cost) +\
" juice[/color] and double your "+Index.get_color_tag("agility")+" Agility[/color] for the rest of the battle.";

func check_available()->bool:
	return Entities.player.inventory.juice >= juice_cost; 

func use()->void:
	Entities.player.inventory.juice -= juice_cost;
	Combat.apply_stat_change(Entities.in_fight_player, Entities.in_fight_player, Entities.in_fight_player.agility, "agility");
