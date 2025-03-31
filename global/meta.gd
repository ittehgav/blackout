extends Node

## this file is gonna need a more appropriate name

@onready var icons:Dictionary = {
	"defense":load("res://assets/visual/icons/stats/defense.png"),
	"attack":load("res://assets/visual/icons/stats/attack.png"),
	"max_hp":load("res://assets/visual/icons/stats/max_hp.png"),
	"move_speed":load("res://assets/visual/icons/stats/move_speed.png"),
	"technique":load("res://assets/visual/icons/stats/technique.png"),

	"food":load("res://assets/visual/icons/resources/food.png"),
	"money":load("res://assets/visual/icons/resources/money.png"),
	"fuel":load("res://assets/visual/icons/resources/fuel.png"),

	"juice":load("res://assets/visual/icons/resources/juice.png"),
	"scrap":load("res://assets/visual/icons/resources/scrap.png"),
	"chips":load("res://assets/visual/icons/resources/chips.png"),
}

func tagged_settlement_name(settlement:Settlement)->String:
	return "[color=green][url="+settlement.name+"]"+settlement.name+"[/url][/color]"


const resource_colors = {
	"food":Color.YELLOW,
	"fuel":Color.ORANGE_RED,
	"money":Color(0, .7, 0),
	
	"juice":Color.PURPLE,
	"scrap":Color.DIM_GRAY,
	"chips":Color.SKY_BLUE
}

func resource_colored_name(resource:String)->String:
	var color:String = resource_colors[resource].to_html();
	var string:String = "[color=" + color + "]"+resource
	return string


const resource_descriptions = {
	"food": "[color=green]Basic survival resource[/color], you and your recruits need to eat some food 
	every hour, if there's not enough food for everyone, [color=green]Morale[/color] in the party will drop",
	
	"fuel": "[color=green]Basic travel resource[/color], consumed every hour of travel in the world map, the more units there are in the party the more fuel travelling will\
	 cost. If you have no fuel, you will travel much slower.",

	"money": "[color=green]Basic currency[/color] used for trading items and resources.",
	
	
	"juice": "Strange substance with many practical uses, a [color=green]common[/color] trade comodity, required for the [color=cyan]upkeep and upgrade[/color] of certain units.",
	"scrap": "Broken down pieces of metal used for all kinds of purposes, pure scrap is [color=green]rare[/color] to come across because of its trade value. Used for the 
[color=cyan]upkeep and upgrade[/color] of certain units.",
	"chips": "Intact processor chips are [color=green]exetrmely rare and valuable[/color]. A valuable trade comodity and used for [color=cyan]upgrading[/color] certain units."
}

const flavor_colors = {
	"blackout":Color.MEDIUM_ORCHID
}

func get_color_tag(key:String)->String:
	var color:Color;
	if key in resource_colors:
		color = resource_colors[key];
	elif key in stat_colors:
		color = stat_colors[key]
	elif key in flavor_colors:
		color = flavor_colors[key]
	return "[color=" + color.to_html() + "]";
	

const stat_colors = {
	"max_hp": Color.WEB_GREEN,
	"attack": Color(.8, 0, 0),
	"defense": Color.SKY_BLUE,
	"move_speed": Color(.8, .8, 0), ## darkish yellow
	"technique": Color.DEEP_PINK
}

const item_rarity_colors:={
	1: Color.LIGHT_GRAY,
	2: Color.GREEN_YELLOW,
	3: Color.RED
}

const stat_descriptions = {
	"max_hp": "The unit's total HP at the start of battle.",
	"attack": "The damage the unit's skill will deal (some units deal no damage.)",
	"defense": "Flat mitigation from all damage dealt to the unit (??????????????)",
	"move_speed": "The speed at which the character moves in battle",
	"technique": "Multiplier applied to special effects in units' skills"
}


func get_unit_damage_string(unit:FighterUnit)->String:
	var string:String = "[color=" + stat_colors.attack.to_html() + "]";
	string += str(unit.stats.attack) + "[/color]"
	return string
	
func get_technique_scaled_string(unit:FighterUnit, value_key:String="", hard_value:float = 0.0, trailing_string:String="")->String:
	var string:String = "[color=" + stat_colors.technique.to_html() + "]";
	if hard_value:
		string += str(snapped(hard_value * unit.stats.technique, .01)) + trailing_string + "[/color]"
	elif not value_key:
		string += str(unit.stats.technique) + trailing_string + "[/color]"
	else:
		string += str(snapped(unit.base[value_key] * unit.stats.technique, .01)) + trailing_string + "[/color]";
	return string;
	
