class_name Resources extends RefCounted

const resource_colors = {
	"food":Color(0.698, 0.698, 0.212, 1.0),
	"fuel":Color(0.7, 0.341, 0.21, 1.0),
	"money":Color(0.161, 0.8, 0.161, 1.0),
	
	"juice":Color(0.537, 0.212, 0.698, 1.0),
	"scrap":Color(0.8, 0.8, 0.8, 1.0),
	"chips":Color(0.212, 0.698, 0.698, 1.0)
}
const all_resources = [
	"money",
	
	"food",
	"fuel",
	
	"juice",
	"scrap",
	"chips"
]

const resource_base_prices = {
	"food":1.25,
	"fuel":1.5,
	"juice":2.0,
	"scrap":3.0,
	"chips":5.0
}

static func resource_colored_name(resource:String, close_tag:bool=true, capitalize:bool=false)->String:
	var color:String = resource_colors[resource].to_html();
	var string:String = "[color=" + color + "]";
	if capitalize:
		string += resource.capitalize();
	else:
		string += resource;
	if close_tag:
		string += "[/color]"
	return string

static var resource_descriptions:Dictionary[String, String] = {
	"food": "[color="+resource_colors.food.to_html() + "]Basic survival resource[/color], you and your party need to eat some food every hour, if there's not enough food for everyone, [color=green]Morale[/color] in the party will drop.",
	
	"fuel": "[color="+resource_colors.fuel.to_html() + "]Basic travel resource[/color], consumed every hour of travel in the world map, the more units there are in the party the more fuel travelling will\
	cost.\nIf you have no fuel, you will travel much slower.",

	"money": "[color="+resource_colors.money.to_html() + "]Basic currency[/color] used for trading items and resources.",

	"juice": "[color="+resource_colors.juice.to_html() + "]Strange substance[/color] with many practical uses, a [color=green]common[/color] trade comodity.\nUsed for [color=cyan]upgrading units[/color] and as [color=cyan]ammo for certain weapons and modules[/color].",
	"scrap": "Broken down [color="+resource_colors.scrap.to_html() + "]pieces of metal[/color] used for all kinds of purposes, usable scrap is [color=green]rare[/color] to come across.\nUsed for [color=cyan]forging[/color] and as [color=cyan]ammo for certain weapons and module[/color].",
	"chips": "[color="+resource_colors.fuel.to_html() + "]Intact processor chips[/color] are [color=green]exetrmely rare and valuable[/color]. A valuable trade comodity and used for [color=cyan]upgrading units[/color] and as [color=cyan]ammo for certain weapons and module[/color]."
}
