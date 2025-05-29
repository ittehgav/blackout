extends Node

@export_group("Common Scenes")
@export_subgroup("Game States")
@export var arena_scene:PackedScene;
@export var world_map_scene:PackedScene;

@export_subgroup("Map Entities")
@export var thugs_scene:PackedScene;
@export var travelling_trader_scene:PackedScene;

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

@export_subgroup("Resource Stack Scenes")
@export var resource_storage_scenes:Array[PackedScene];
@export var food_stack_scene:PackedScene;
@export var fuel_stack_scene:PackedScene;
@export var juice_stack_scene:PackedScene;
@export var scrap_stack_scene:PackedScene
@export var chips_stack_scene:PackedScene

@export_subgroup("Resource Container Scenes")
@export var food_bag_scene:PackedScene;
@export var food_basket_scene:PackedScene;
@export var food_barrel_scene:PackedScene;

@export var fuel_gallon_scene:PackedScene;
@export var fuel_tank_scene:PackedScene;
@export var fuel_barrel_scene:PackedScene;

@export var juice_can_scene:PackedScene;
@export var juice_flask_scene:PackedScene;
@export var juice_tank_scene:PackedScene;

@export var scrap_crate_scene:PackedScene;
@export var scrap_compactor_scene:PackedScene;

@export var chips_case_scene:PackedScene;
@export_subgroup("Equipment Scenes")
@export var weapon_scenes:Array[PackedScene];
@export var module_scenes:Array[PackedScene]

@export_subgroup("Item Scene Groups")
## grouping them in ways to facilitate loot genration
## add items here as other types are implemented
## TODO tool scripts?
@export var rarity_1_item_scenes:Array[PackedScene];
@export var rarity_2_item_scenes:Array[PackedScene];
@export var rarity_3_item_scenes:Array[PackedScene];

@export_subgroup("Fighter Base Scenes")
@export var arm_guy_scene:PackedScene;
@export var mech_arm_guy_scene:PackedScene;
@export var double_arm_guy_scene:PackedScene;

@export var crowbar_guy_scene:PackedScene;
@export var crossbow_guy_scene:PackedScene;
@export var gravity_guy_scene:PackedScene;

@export var tailpipe_guy_scene:PackedScene;
@export var wheel_guy_scene:PackedScene;
@export var door_guy_scene:PackedScene;

@export var taser_guy_scene:PackedScene;
@export var tether_guy_scene:PackedScene;
@export var coil_guy_scene:PackedScene;

@export_subgroup("Events")
@export var local_event_scenes:Array[PackedScene];

@export_group("Colors")
@export var color_schemes:Array[Array];

const all_resources = [
	"money",
	
	"food",
	"fuel",
	
	"juice",
	"scrap",
	"chips"
]
const resource_base_prices = {
	"food":1.0,
	"fuel":1.0,
	"juice":2.0,
	"scrap":3.0,
	"chips":5.0
}


@onready var basic_fighter_base_scenes:Array[PackedScene] = [
	## settlements will only sell these by default?
	arm_guy_scene,
	crowbar_guy_scene,
	tailpipe_guy_scene,
	taser_guy_scene
]


@onready var evolved_fighter_base_scenes:Array[PackedScene] = [
	mech_arm_guy_scene,
	double_arm_guy_scene,
	
	crossbow_guy_scene,
	gravity_guy_scene,
	
	wheel_guy_scene,
	door_guy_scene,
	
	tether_guy_scene,
	coil_guy_scene
]

@onready var all_fighter_base_scenes:Array[PackedScene] = [
	arm_guy_scene,
	mech_arm_guy_scene,
	double_arm_guy_scene,
	crowbar_guy_scene,
	crossbow_guy_scene,
	gravity_guy_scene,
	tailpipe_guy_scene,
	wheel_guy_scene,
	door_guy_scene,
	taser_guy_scene,
	tether_guy_scene,
	coil_guy_scene
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
	## really saturated here and we fix it out in-context?
	"food":Color.YELLOW,
	"fuel":Color.ORANGE_RED,
	"money":Color.GREEN,
	
	"juice":Color.PURPLE,
	"scrap":Color.DIM_GRAY,
	"chips":Color.CYAN
}

const stat_colors = {
	"max_hp": Color.WEB_GREEN,
	"attack": Color(.8, 0, 0),
	"defense": Color.SKY_BLUE,
	"agility": Color(.8, .8, 0),
	"technique": Color.DEEP_PINK
}

const leadership_stat_colors = {
	"charisma":Color.ORANGE,
	"navigation":Color.ORANGE,
	"tactics":Color.ORANGE,
	"team_management":Color.ORANGE,
	"scavenging":Color.ORANGE,
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
	"shield":Color.YELLOW,
	"morale":Color.YELLOW
}


const item_rarity_colors:={
	1: Color.LIGHT_GRAY,
	2: Color.GREEN_YELLOW,
	3: Color.RED
}


func get_color(key:String)->Color:
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
	elif key in leadership_stat_colors:
		color = leadership_stat_colors[key];
	assert(color != Color(0.0, 0.0, 0.0, 1.0))
	return color;

func get_color_tag(key:String)->String:
	var color:Color = get_color(key);
	return "[color=" + color.to_html() + "]";


func resource_colored_name(resource:String, close_tag:bool=true, capitalize:bool=false)->String:
	var color:String = resource_colors[resource].to_html();
	var string:String = "[color=" + color + "]";
	if capitalize:
		string += resource.capitalize();
	else:
		string += resource;
	if close_tag:
		string += "[/color]"
	return string
	
func stat_colored_name(stat:String, close_tag:bool=true)->String:
	var color:String = stat_colors[stat].to_html();
	var string:String = "[color=" + color + "]" + stat.capitalize();
	if close_tag:
		string += "[/color]";
	return string;


var resource_descriptions:Dictionary[String, String] = {
	"food": get_color_tag("food") + "Basic survival resource[/color], you and your party need to eat some food every hour, if there's not enough food for everyone, [color=green]Morale[/color] in the party will drop",
	
	"fuel": get_color_tag("fuel") + "Basic travel resource[/color], consumed every hour of travel in the world map, the more units there are in the party the more fuel travelling will\
	 cost. If you have no fuel, you will travel much slower.",

	"money": get_color_tag("money") + "Basic currency[/color] used for trading items and resources.",
	
	
	"juice": "Strange substance with many practical uses, a [color=green]common[/color] trade comodity.\nUsed for the [color=cyan]upkeep and upgrading[/color] of certain units.",
	"scrap": "Broken down pieces of metal used for all kinds of purposes, usable scrap is [color=green]rare[/color] to come across.\nUsed for the [color=cyan]upkeep and upgrade[/color] of certain units.",
	"chips": "Intact processor chips are [color=green]exetrmely rare and valuable[/color]. A valuable trade comodity and used for [color=cyan]upgrading[/color] certain units."
}

const all_combat_stats:Array[String] = [
	"max_hp", "attack", "defense", "agility", "technique"
]


const stat_descriptions = {
	"max_hp": "The unit's total HP at the start of battle.",
	"attack": "The damage the unit's skill will deal. (some units and weapons deal no damage)",
	"defense": "Reduces the damage taken by the unit.",
	"agility": "Speed at which the unit uses their skill/weapon.",
	"technique": "Improves special effects in weapons and units' skills."
	## TODO make player technique matter
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
	
