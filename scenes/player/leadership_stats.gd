extends Node

class_name LeadershipStats

const stats = ["charisma", "navigation", "tactics", "team_management", "scavenging"];

@export var charisma:int;
@export var navigation:int;
@export var tactics:int
@export var team_management:int;
@export var scavenging:int;



const tooltips = {
	"charisma":
		"Charisma improves your trading skills, the rate at which your relations improve and your chances at [b]dialogue chance events[/b].",
	"navigation":
		"Navigation improves [b]movement[/b] in the [b]world map[/b], allowing you to [b]see further[/b] and gain see [b]more data from parties and settlements[/b].",
	"tactics":
		"Tactics unlocks [b]tactical abilities[/b] in battle and allows you to control the [b]Tide of Battle[/b].",
	"team_management":
		"Team management improves the [b]units in your party[/b], making them [b]level up faster[/b] and imrpoving their resource efficiency.",
	"scavenging":
		"Scavenging improves the efficiency of [b]resoures[/b] and the rate at which you find [/b]resources[/b]."
}

var charsima_perks :Dictionary[String, String]= {
	"Diplomacy" :
		"For each " + Index.get_color_tag("charisma") + "Charisma level,[/color] your relationships with [b]settlements[/b] improve 5% faster",
	"Bartering":
		"For each " + Index.get_color_tag("charisma") + "Charisma level,[/color] you sell items for 2.5% more and buy them for 2.5% less.",
	"Never Miss a Thing":
		"You gain twice as much information from [b]Listening Around[/b] in settlements.",
	"Trade Panic":
		"[b]Price shifts[/b] found by [b]Listening Around[/b] in settlements are 50% higher.",
	"Supernatural Charm":
		"Increases [b]Relation Level[/b] with all [b]settlements[/b] by 1."
}

var navigation_perks:Dictionary[String, String] = {
	"Eagle's Eye":
		"Each " + Index.get_color_tag("navigation") + "Navigation level[/color] increases [b]sight range[/b] in the [b]World Map[/b] by 10%.",
	"Ever-Ready":
		"Each " + Index.get_color_tag("navigation") + "Navigation level[/color] reduces [b]night-time speed and sight impairments[/b] by 20% and [b]party size speed penalty[/b] by 10%.",
	"Espionage":
		"Each " + Index.get_color_tag("navigation") + "Navigation level[/color] allows you to see [b]more information[/b] from nearby [b]parties[/b] and [b]settlements[/b] in the [b]World Map[/b].",
	"Trailblazer":
		"Each " + Index.get_color_tag("navigation") + "Navigation level[/color] improves [b]Movement Speed[/b] in the [b]World Map[/b] by 5%.",
	"Road Trip":
		"For each [b]hour[/b] spent moving uninterrupted in the [b]world map[/b], the party gains 0.1 "+Index.get_color_tag("morale") + "morale."
}

var tactics_peks:Dictionary[String, String] = {
	"Confidence":
		"If the [b]Tide of Battle[/b] is in your favor, your units gain bonus " + Index.get_color_tag("technique") + "Technique[/color] the more to your side it is.",
	"Tactical Skill: Retreat":
		"Unlocks a [b]Tactical Skill[/b] that makes your units run the enemy team and gain a " + Index.get_color_tag("defense") + "defense[/color] bonus for a period of time.",
	"Tactical Skill: Laser Focus": "Unlocks a [b]Tactical Skill[/b] which instructs all units who can to [b]attack the same target[/b] and gives an " + Index.get_color_tag("attack") + " attack [/color] buff to the ally unit that's closest to it.",
	"Effective Communication":
		"Each "+ Index.get_color_tag("tactics") + "Tactics level[/color] improves the stat buffs from [b]Tactical Skills[/b] by 10%.",
	"Tactical Skill: Rallying Cry":
		"Unlocks a powerful[b]Tactical Skill[/b].\nIf the [b]Tide of battle[/b] is in your favor, give the unit that's closest to you a massive [b]buff on all stats[/b], if the "\
		+"[b]Tide of Battle[/b] is not in your favor, you and the nearest ally become [b]Immune to damage[/b] for a few seconds"
}

var team_management_perks:Dictionary[String, String] = {
	"Training":
		"Each " + Index.get_color_tag("team_management") + "Team Management level[/color] increases the experience you and your units gain by 2.5%.",
	"First-Aid":
		"Each " + Index.get_color_tag("team_management") + " Team Management level[/color] [b]decreases the downed status duration[/n] of units that are defeated in battle by 20%",
	"Strength in Numbers":
		"Gain a bonus to all stats based on the amount of ally units in combat.",
	"Logistics": 
		"Reduces [b]movement speed penalty[/b] from [b]party size[/b] in the [b]World Map[/b].",
	"Spirit Food": "If party " + Index.get_color_tag("morale") + " Morale[/color] is high, increase [b]world map[/b] movement speed, if party " + Index.get_color_tag("morale")\
	 + " Morale[/color] is low, reduce [b]upkeep costs.[/b]" 
}

var scavenging_perks:Dictionary[String, String] = {
	"One Man's Trash":
		"Unlocks the option to " + Index.get_color_tag("scavenging") + " scavenge for resources[/color] in settlements, resources found by this are replenished gradually in the settlement.",
	"Bottom of the Barrel":
		"Each " + Index.get_color_tag("scavenging") + "Scavenging level[/color] [b]Increases resources gained in battle[/b] by 10%.",
	"Make Do":
		"Each " + Index.get_color_tag("scavenging") + "Scavenging level[/color] decreases the [b]resource costs[/b] from [b]Weapons and Modules[/b] by 5%.",
	"One With Nature": 
		"Each [b]hour[/b] you spend moving uninterrupted in the [b]world map[/b], reduce upkeep costs by 5%, down to 50%.",
	"Pocked Dimensions": 
		"Increases the [b]storage capacity[/b] of [b]containers[/b] by 50%."
}
