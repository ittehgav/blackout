extends Node

@export_group("Common Scenes")
@export_subgroup("Game States")
@export var arena_scene:PackedScene;
@export var world_map_scene:PackedScene;
@export_subgroup("Map Entities")
@export var common_leader_scenes:Array[PackedScene]
@export var vehicle_scenes:Array[PackedScene];
@export var npc_map_party_scene:PackedScene;
@export var farm_scene:PackedScene;
@export var factory_scene:PackedScene;
@export var scrapyard_scene:PackedScene
@export_subgroup("In Fight Entities")
@export var fighter_unit_scene:PackedScene;
@export var npc_fighter_scene:PackedScene;
@export_subgroup("UI Scenes")
@export var stat_icon_scene:PackedScene;
@export var resource_icon_scene:PackedScene;
@export var item_icon_scene:PackedScene;
@export var sprite_sample_scene:PackedScene;
@export var tooltip_scene:PackedScene;

@export_group("Colors")
@export var color_schemes:Array[Array];

const all_resources = [
	"food",
	"fuel",
	"money",
	
	"juice",
	"scrap",
	"chips"
]

var all_fighter_base_scenes:Array[PackedScene] = [
	preload("res://scenes/indexes/fighters/armguy.tscn"),
	preload("res://scenes/indexes/fighters/coilguy.tscn"),
	preload("res://scenes/indexes/fighters/crossbowguy.tscn"),
	
	preload("res://scenes/indexes/fighters/crowbarguy.tscn"),
	preload("res://scenes/indexes/fighters/doorguy.tscn"),
	preload("res://scenes/indexes/fighters/doublearmguy.tscn"),
	
	preload("res://scenes/indexes/fighters/gravityguy.tscn"),
	preload("res://scenes/indexes/fighters/mecharmguy.tscn"),
	preload("res://scenes/indexes/fighters/tailpipeguy.tscn"),
	
	preload("res://scenes/indexes/fighters/taserguy.tscn"),
	preload("res://scenes/indexes/fighters/tetherguy.tscn"),
	preload("res://scenes/indexes/fighters/wheelguy.tscn")
]

func random_fighter_base()->FighterBase:
	var base:PackedScene = all_fighter_base_scenes.pick_random();
	return base.instantiate();

@onready var icons:Dictionary = {
	"defense":load("res://assets/visual/icons/stats/defense.png"),
	"attack":load("res://assets/visual/icons/stats/attack.png"),
	"max_hp":load("res://assets/visual/icons/stats/max_hp.png"),
	"agility":load("res://assets/visual/icons/stats/agility.png"),
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

const stat_colors = {
	"max_hp": Color.WEB_GREEN,
	"attack": Color(.8, 0, 0),
	"defense": Color.SKY_BLUE,
	"agility": Color(.8, .8, 0),
	"technique": Color.DEEP_PINK
}

const flavor_colors = {
	"blackout":Color.MEDIUM_ORCHID
}

const combat_effect_colors = {
	"stun":Color.PURPLE,
	"damage":Color(.8, .1, .1)
}

const misc_colors = {
	"no_dmg":Color.LIGHT_BLUE,
	"shield":Color.YELLOW
}


const item_rarity_colors:={
	1: Color.LIGHT_GRAY,
	2: Color.GREEN_YELLOW,
	3: Color.RED
}


func get_color_tag(key:String)->String:
	var color:Color;
	if key in resource_colors:
		color = resource_colors[key];
	elif key in stat_colors:
		color = stat_colors[key]
	elif key in flavor_colors:
		color = flavor_colors[key]
	elif key in misc_colors:
		color = misc_colors[key]
	elif key in combat_effect_colors:
		color = combat_effect_colors[key]
	assert(color != Color(0.0, 0.0, 0.0, 1.0))
	return "[color=" + color.to_html() + "]";


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



const stat_descriptions = {
	"max_hp": "The unit's total HP at the start of battle.",
	"attack": "The damage the unit's skill will deal (some units deal no damage.)",
	"defense": "Reduces the damage taken by the unit.",
	"agility": "Increases the speed at which the unit uses their skill/weapon.",
	"technique": "Improves special effects in units' skills."
}


func get_unit_damage_string(unit:FighterUnit, trailing_text:String=" damage")->String:
	var damage:float = unit.stats.attack
	if "damage_modifier" in unit.base:
		damage = unit.base.damage_modifier(damage, unit)

	var string:String = get_color_tag("damage") + str(int(damage)) + trailing_text + "[/color]"
	return string
	
func get_technique_scaled_string(unit:FighterUnit, value_key:String="", hard_value:float = 0.0, additional_multiplier:float=1, trailing_string:String="")->String:
	var string:String = "[color=" + stat_colors.technique.to_html() + "]";
	if hard_value:
		string += str(snapped(hard_value * unit.stats.technique * additional_multiplier, .01)) + trailing_string + "[/color]"
	elif not value_key:
		string += str(snapped(unit.stats.technique * additional_multiplier, .01)) + trailing_string + "[/color]"
	else:
		string += str(snapped(unit.base[value_key] * unit.stats.technique * additional_multiplier, .01)) + trailing_string + "[/color]";
	return string;
	
