extends Module

const rarity = 2;

const cooldown = 5;

const size_x = 1;
const size_y = 1;

const sfx_key = "adrenaline"
const juice_cost = 5;

## juice consumption scales with leadership_level?
@onready var  description:String = "Cosumes " + str(juice_cost) + Index.resource_colored_name("juice") +\
" and doubles your "+Index.stat_colored_name("agility")+" for the rest of the battle.";

func check_available()->bool:
	return Entities.player.inventory.juice >= juice_cost; 

func use()->void:
	Entities.player.inventory.juice -= juice_cost;
	Combat.apply_stat_change(Entities.in_fight_player, Entities.in_fight_player, Entities.in_fight_player.agility, "agility");
