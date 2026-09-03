class_name Resources extends RefCounted

const resource_colors:Dictionary[String, Color] = {
	"food":Color(0.698, 0.698, 0.212, 1.0),
	"fuel":Color(0.7, 0.315, 0.175, 1.0),
	"money":Color(0.161, 0.8, 0.161, 1.0),
	
	"juice":Color(0.537, 0.212, 0.698, 1.0),
	"scrap":Color(0.65, 0.562, 0.553, 1.0),
	"chips":Color(0.24, 0.8, 0.8, 1.0)
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
	"money": "[color="+resource_colors.money.to_html() +\
	 "]Basic currency[/color] used for [color=green]recruiting units[/color] as well as [color=green]buying and selling[/color] items and resources.",
	
	"food": "[color="+resource_colors.food.to_html() + "]Basic survival resource.\n[/color]While travelling, you and your party need to eat every 30 minutes, if there's not enough food for everyone, [color=green]Morale[/color] in the party will drop.",
	
	"fuel": "[color="+resource_colors.fuel.to_html() + "]Basic travel resource, consumed when travelling in the world map[/color], the your cars have an hourly travel fuel cost.\nIf you have no fuel, your party will travel much slower.\nAlso used as [color=green]ammo[/color] for some equipment.",

	"juice": "[color="+resource_colors.juice.to_html() + "]Strange substance[/color] with many practical uses, found all over the land.\nA [color=green]common[/color] trade comodity.\nUsed for [color=cyan]upgrading units.[/color]\nAlso used as [color=green]ammo[/color] for some equipment.",
	
	"scrap": "Broken down [color="+resource_colors.scrap.to_html() + "]pieces of metal.[/color]\nUsable scrap is [color=green]rare[/color] to come across.\nUsed for [color=cyan]refining weapons.[/color]\nAlso used as [color=green]ammo[/color] for some equipment.",
	
	"chips": "[color="+resource_colors.chips.to_html() + "]Intact processor chips[/color] are [color=cyan]very rare and valuable[/color].\nUsed for [color=cyan]modifying Modules[/color]\nAlso used as [color=green]ammo[/color] for some equipment."
}
