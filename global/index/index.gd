extends Node



## TODO redo this script with the pages in mind
## when the new world map is up and running and a ton of stuff here gets deleted/repurposed
@export var scenes:SceneIndex;
@export var fighters:FighterIndex;
@export var textures:TextureIndex;



## make this catch the size properly?
@export var irl_time_scale:float = 500;


## colors and metadata stay in this file to facilitate fetching in UI
@export_group("Colors")
## keepingthis as simple as possible for now
@export var player_team_color:Color
@export var enemy_team_color:Color

@export var mod_tier_colors:Array[Color]



@export var day_reflection_color:Color;
@export var night_reflection_color:Color;



@export var primary_tag_colors:Dictionary[String, Color];


func tagged_location_name(location:Location)->String:
	return "[color=green][url="+location.name+"]"+location.name+"[/url][/color]"


# const all_disciplines = [
# 	"charisma",
# 	"navigation",
# 	"tactics",
# 	"leadership",
# 	"scavenging"
# ]

# const discipline_descriptions = {
# 	"charisma":
# 		"Charisma improves your trading skills, the rate at which your relations improve and your ability to [u]convince[/u] people.",
# 	"navigation":
# 		"Navigation improves [u]movement[/u] and [u]vision[/u] in the [u]world map[/u].",
# 	"tactics":
# 		"Tactics unlocks [u]tactical abilities[/u] in battle and allows you to control the [u]Tide of Battle[/u].",
# 	"leadership":
# 		"Leadership improves the [u]units in your party[/u], making them [u]level up faster[/u] and imrpoving their resource efficiency.",
# 	"scavenging":
# 		"Scavenging improves the efficiency of [u]resources[/u] and the rate at which you find [/u]resources[/u]."
# }


const flavor_colors = {
	"blackout":Color.MEDIUM_ORCHID
}

const combat_effect_colors = {
	"stun":Color.PURPLE,
	"damage":Color(.8, .1, .1),
	"debuff":Color.DARK_OLIVE_GREEN ## might be too dark?
}

const misc_colors = {
	"no_dmg":Color.LIGHT_BLUE,
	"shield":Color.YELLOW,
	"morale":Color.YELLOW,
	"electrify":Color.YELLOW,
	"neutral":Color.LIGHT_GRAY
}


func get_color(key:String)->Color:
	## this can just reference the other classes as i remove stuff from here
	var color:Color;
	if key in ["t1", "t2", "t3"]:
		var tier:int = int(key[1]) - 1;
		color = mod_tier_colors[tier];
	if key in Resources.resource_colors:
		color = Resources.resource_colors[key];
	elif key in CombatStats.stat_colors:
		color = CombatStats.stat_colors[key]
	elif key in flavor_colors:
		color = flavor_colors[key]
	elif key in misc_colors:
		color = misc_colors[key]
	elif key in combat_effect_colors:
		color = combat_effect_colors[key]
	elif key in primary_tag_colors:
		color = primary_tag_colors[key]

	assert(color != Color(0.0, 0.0, 0.0, 1.0))
	return color;

func get_color_tag(key:String)->String:
	var color:Color = get_color(key);
	return "[color=" + color.to_html() + "]";

func colored_text(color_tag:String, data:Variant, trailing_text:String="")->String:
	## converting text to string here sice a lot of this will be numbers
	## and when they're strings it still works
	## trailing so i can add a string within the tags alongside numbers
	if data is float:
		data = snapped(data, .01)
	return get_color_tag(color_tag ) + str(data)+trailing_text + "[/color]"

	
const isometric_angle_indexes = [
	## put this in a place where both player and npcs catch?
	Vector2i.UP,
	Vector2i(1, -1),
	Vector2i.RIGHT,
	Vector2i(1, 1),
	Vector2i.DOWN,
	Vector2i(-1, 1),
	Vector2i.LEFT,
	Vector2i(-1, -1)
]
@onready var isometric_rad_indexes:Array[float] = set_angle_rads();
func set_angle_rads()->Array[float]:
	## idk this is faster than to bsearch a v2 array 
	## and i couldnt get it to work right away with v2s
	var angles:Array[float]
	for angle:Vector2i in isometric_angle_indexes:
		angles.append(Vector2(angle).angle())
	return angles
