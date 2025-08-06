extends Node

## TODO redo this script with the pages in mind
## when the new world map is up and running and a ton of stuff here gets deleted/repurposed
@export var scenes:SceneIndex;
@export var fighters:FighterIndex;
@export var textures:TextureIndex;

## make this catch the size properly?
@export var world_map_cell_size:int = 32;
@export var irl_time_scale:float;
@export var cell_to_km:float;

func _ready()->void:
	for scene:PackedScene in fighters.all_fighter_base_scenes:
		## because FighterBases need index to be ready
		## TODO work out a better solution for this if there's too much trouble
		## with this method
		fighters.all_fighter_bases.append(scene.instantiate())

## colors and metadata stay in this file to facilitate fetching in UI
@export_group("Colors")
@export var color_schemes:Array[Array];
@export var resource_colors:Dictionary[String, Color] = {
	## really saturated here and we fix it out in-context?
	"food":Color.YELLOW,
	"fuel":Color.ORANGE_RED,
	"money":Color.GREEN,
	
	"juice":Color.PURPLE,
	"scrap":Color.DIM_GRAY,
	"chips":Color.CYAN
}

@export var day_reflection_color:Color;
@export var night_reflection_color:Color;

@export var  stat_colors:Dictionary[String, Color] = {
	"max_hp": Color.WEB_GREEN,
	"attack": Color(.8, 0, 0),
	"defense": Color.SKY_BLUE,
	"agility": Color(.8, .8, 0),
	"technique": Color.DEEP_PINK
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


func tagged_settlement_name(settlement:Settlement)->String:
	return "[color=green][url="+settlement.name+"]"+settlement.name+"[/url][/color]"
	return "[color=green][url="+settlement.name+"]"+settlement.name+"[/url][/color]"


const discipline_colors = {
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
	elif key in discipline_colors:
		color = discipline_colors[key];
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
	"food": get_color_tag("food") + "Basic survival resource[/color], you and your party need to eat some food every hour, if there's not enough food for everyone, [color=green]Morale[/color] in the party will drop.",
	
	"fuel": get_color_tag("fuel") + "Basic travel resource[/color], consumed every hour of travel in the world map, the more units there are in the party the more fuel travelling will\
	 cost. If you have no fuel, you will travel much slower.",

	"money": get_color_tag("money") + "Basic currency[/color] used for trading items and resources.",
	
	
	"juice": "Strange substance with many practical uses, a [color=green]common[/color] trade comodity.\nUsed for [color=cyan]upgrading units[/color] and as [color=cyan]ammo for equipment[/color].",
	"scrap": "Broken down pieces of metal used for all kinds of purposes, usable scrap is [color=green]rare[/color] to come across.\nUsed for [color=cyan]upgrading units[/color] and as [color=cyan]ammo for equipment[/color].",
	"chips": "Intact processor chips are [color=green]exetrmely rare and valuable[/color]. A valuable trade comodity and used for [color=cyan]upgrading units[/color] and as [color=cyan]ammo for equipment[/color]."
}

const all_combat_stats:Array[String] = [
	"max_hp", "attack", "defense", "agility", "technique"
]


const stat_descriptions = {
	"max_hp": "The unit's total HP at the start of battle.",
	"attack": "The damage dealt by weapons and skills. (some units and weapons deal no damage)",
	"defense": "Reduces the damage taken by the unit.",
	"agility": "Reduces the cooldown of the player's weapon and units' skills.",
	"technique": "Improves special effects in modules and units' skills."
}


func get_unit_damage_string(unit:FighterUnit, trailing_text:String=" damage")->String:
	var damage:float = unit.stats.attack
	if "damage_modifier" in unit.base:
		damage = unit.base.damage_modifier(damage, unit)

	var string:String = get_color_tag("damage") + str(int(damage)) + trailing_text + "[/color]"
	return string
	
func get_technique_scaled_string(unit:FighterUnit, mechanic:String, value_key:String="", hard_value:float = 0.0)->String:
	var string:String = Index.get_color_tag("technique");
	if hard_value:
		## WILL COME FROM EITHER A HARD-SET VALUE OR A KEY FROM THE SOURCE'S BASE
		var final_value:float = snapped(Scaling.technique_scaled_value(hard_value, unit.stats.technique, mechanic) , .01)
		string += str(final_value)
	else:
		var final_value:float = snapped(Scaling.technique_scaled_value(unit.base[value_key], unit.stats.technique, mechanic), .01)
		string += str(final_value)
		
	return string + "[/color]";
	
