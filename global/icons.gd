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
	"scrap":Color.SADDLE_BROWN,
	"chips":Color.SKY_BLUE
}

const stat_colors = {
	"max_hp": Color.WEB_GREEN,
	"attack": Color.DARK_RED,
	"defense": Color.SKY_BLUE,
	"move_speed": Color(.8, .8, 0), ## darkish yellow
	"technique": Color.DEEP_PINK
}

const item_rarity_colors:={
	1: Color.WEB_GRAY,
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
