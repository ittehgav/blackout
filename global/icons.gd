extends Node

## this file is gonna need a more appropriate name

@onready var defense:Texture = load("res://assets/visual/icons/stats/defense.png");
@onready var attack:Texture = load("res://assets/visual/icons/stats/attack.png")
@onready var max_hp:Texture = load("res://assets/visual/icons/stats/max_hp.png");
@onready var move_speed:Texture = load("res://assets/visual/icons/stats/move_speed.png");
@onready var technique:Texture = load("res://assets/visual/icons/stats/technique.png")

@onready var food:Texture = load("res://assets/visual/icons/resources/food.png");
@onready var money:Texture = load("res://assets/visual/icons/resources/money.png");
@onready var fuel:Texture = load("res://assets/visual/icons/resources/fuel.png");

@onready var juice:Texture = load("res://assets/visual/icons/resources/juice.png");
@onready var scrap:Texture = load("res://assets/visual/icons/resources/scrap.png");
@onready var chips:Texture = load("res://assets/visual/icons/resources/chips.png");


const resource_colors = {
	"food":Color.YELLOW,
	"fuel":Color.ORANGE_RED,
	"money":Color(0, .7, 0),
	
	"juice":Color.PURPLE,
	"scrap":Color.DARK_GRAY,
	"chips":Color.SKY_BLUE
}

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

const stat_colors = {
	"max_hp": Color.WEB_GREEN,
	"attack": Color.DARK_RED,
	"defense": Color.SKY_BLUE,
	"move_speed": Color(.8, .8, 0), ## darkish yellow
	"technique": Color.DEEP_PINK
}

const item_rarity_colors:={
	1: Color.LIGHT_GRAY,
	2: Color.GREEN_YELLOW,
	3:Color.RED
}

const stat_descriptions = {
	"max_hp": "The unit's total HP at the start of battle.",
	"attack": "The damage the unit's skill will deal (some units deal no damage.)",
	"defense": "Flat mitigation from all damage dealt to the unit (??????????????)",
	"move_speed": "The speed at which the character moves in battle",
	"technique": "Multiplier applied to special effects in units' skills"
}
