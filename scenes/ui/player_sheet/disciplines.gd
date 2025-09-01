extends Node

class_name DisciplineTree

const all_disciplines = ["charisma", "navigation", "tactics", "leadership", "scavenging"];

@export var charisma:int;
@export var navigation:int;
@export var tactics:int
@export var leadership:int;
@export var scavenging:int;



#
#var charsima_perks :Dictionary[String, String]= {
	#"Diplomacy" :
		#"For each " + Index.get_color_tag("charisma") + "Charisma level,[/color] your relationships with [b]settlements[/b] improve 5% faster",
	#"Bartering":
		#"For each " + Index.get_color_tag("charisma") + "Charisma level,[/color] you sell items for 2.5% more and buy them for 2.5% less.",
	#"Never Miss a Thing":
		#"You gain twice as much information from [b]Listening Around[/b] in settlements.",
	#"Trade Panic":
		#"[b]Price shifts[/b] found by [b]Listening Around[/b] in settlements are 50% higher.",
	#"Supernatural Charm":
		#"Increases [b]Relation Level[/b] with all [b]settlements[/b] by 1."
#}
#
#var navigation_perks:Dictionary[String, String] = {
	#"Eagle's Eye":
		#"Each " + Index.get_color_tag("navigation") + "Navigation level[/color] increases [b]sight range[/b] in the [b]World Map[/b] by 10%.",
	#"Ever-Ready":
		#"Each " + Index.get_color_tag("navigation") + "Navigation level[/color] reduces [b]night-time speed and sight impairments[/b] by 20% and [b]party size speed penalty[/b] by 10%.",
	#"Espionage":
		#"Each " + Index.get_color_tag("navigation") + "Navigation level[/color] allows you to see [b]more information[/b] from nearby [b]parties[/b] and [b]settlements[/b] in the [b]World Map[/b].",
	#"Trailblazer":
		#"Each " + Index.get_color_tag("navigation") + "Navigation level[/color] improves [b]Movement Speed[/b] in the [b]World Map[/b] by 5%.",
	#"Road Trip":
		#"For each [b]hour[/b] spent moving uninterrupted in the [b]world map[/b], the party gains 0.1 "+Index.get_color_tag("morale") + "morale."
#}
#
#var tactics_peks:Dictionary[String, String] = {
	#"Confidence":
		#"If the [b]Tide of Battle[/b] is in your favor, your units gain bonus " + Index.get_color_tag("technique") + "Technique[/color] the more to your side it is.",
	#"Tactical Skill: Retreat":
		#"Unlocks a [b]Tactical Skill[/b] that makes your units run the enemy team and gain a " + Index.get_color_tag("defense") + "defense[/color] bonus for a period of time.",
	#"Tactical Skill: Laser Focus":
		#"Unlocks a [b]Tactical Skill[/b] which instructs all units who can to [b]attack the same target[/b] and gives an " + Index.get_color_tag("attack") + " attack [/color] buff to the ally unit that's closest to it.",
	#
	#"Effective Communication":
		#"Each "+ Index.get_color_tag("tactics") + "Tactics level[/color] improves the effects from [b]Tactical Skills[/b] by 10%.",
	#
	#
	#
	#"Everyone plays their part":
		#"Unlocks powerful passive effects based on the types of the units in your party.
#
		#Callusing:
			#Unlocked if your party has 5 or more [u]Bodybuilders[/u]
			#And the end of each battle, permanently increase the "+Index.get_color_tag("defense") + "defense[/color] of all [u]bodybuilders[/u] in your party.
#
		#Shadow Boxing:
			#Unlocked if your party has 5 or more [u]Brawlers[/u]
			#When your party defeats an enemy, permanently increase the damage your [u]brawlers[/u] deal to that type of enemy by 0.5% (willneedfinetuningwhenbalancing)
#
		#Smell of Gas:
			#Unlocked if your party has 3 or more [u]Mechanics[/u]
			#Mechanics in your party gain bonus"+Index.get_color_tag("agility")+"agility[/color] based on the amount of "+Index.get_color_tag("fuel")+"fuel[/color] in your inventory.
		#
		#FIGURE THIS OUT AFTER REDO OF UNITS
#
		### FORMATTHIS
		#thresholds of unit counts that unlock passive buffs?:!!:!?!:!?:!?
		#single use? and like even more ridiculously poweful?
#DONE		Bodybuilder
#DONE		Brawler
		#Cyborg 
		#Scientist 
#DONE		Mechanic:
		#Hunter
		#Doctor
		#Juggernaut
		#Disruptor
		#"
#}
#
#var leadership_perks:Dictionary[String, String] = {
	#"Training":
		#"Each " + Index.get_color_tag("team_management") + "Team Management level[/color] increases the experience you and your units gain by 2.5%.",
	#"First-Aid":
		#"Each " + Index.get_color_tag("team_management") + " Team Management level[/color] [b]decreases the downed status duration[/n] of units that are defeated in battle by 20%",
	#"Strength in Numbers":
		#"Gain a bonus to all stats based on the amount of ally units in combat.",
	#"Logistics": 
		#"Reduces [b]movement speed penalty[/b] from [b]party size[/b] in the [b]World Map[/b].",
	#"Spirit Food": "If party " + Index.get_color_tag("morale") + " Morale[/color] is high, increase [b]world map[/b] movement speed, if party " + Index.get_color_tag("morale")\
	 #+ " Morale[/color] is low, reduce [b]upkeep costs.[/b]" 
#}
#
#var scavenging_perks:Dictionary[String, String] = {
	#"One Man's Trash":
		#"Unlocks the option to " + Index.get_color_tag("scavenging") + " scavenge for resources[/color] in settlements, resources found by this are replenished gradually in the settlement.",
	#"Bottom of the Barrel":
		#"Each " + Index.get_color_tag("scavenging") + "Scavenging level[/color] [b]Increases resources gained in battle[/b] by 10%.",
	#"Make Do":
		#"Each " + Index.get_color_tag("scavenging") + "Scavenging level[/color] decreases the [b]resource costs[/b] from [b]Weapons and Modules[/b] by 5%.",
	#"One With Nature": 
		#"Each [b]hour[/b] you spend moving uninterrupted in the [b]world map[/b], reduce upkeep costs by 5%, down to 50%.",
	#"Pocked Dimensions": 
		#"Increases the [b]storage capacity[/b] of [b]containers[/b] by 50%."
#}
