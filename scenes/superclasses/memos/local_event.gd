extends Memo;

class_name LocalEvent

var location:Settlement;

@export_enum("brawler", "bodybuilder", "cyborg", "hunter", "scientist", "doctor", "juggernaut", "disruptor", "mechanic") var tag:String;

@export var time_cost:int;
@export_group("Resource Changes")
## for now the ints just signify if there's any gain and if it's positive or negative, 
## the proper calculation will be done in the event scripts


@export var money_change:int;
@export var food_change:int;
@export var fuel_change:int;

@export var juice_change:int;
@export var scrap_change:int;
@export var chips_change:int;


@export_group("Unit Gains")
## for now the ints just signify if there's any gain and if it's positive or negative

@export var units_max_hp_gain:int;
@export var units_attack_gain:int;

@export var units_defense_gain:int;
@export var units_agility_gain:int;
@export var units_technique_gain:int;

var final_action_prompt:String;
var description:String;

func setup_action_prompt()->void:
	var prompt:String = self["action_prompt"] + ": ";
	if time_cost:
		prompt += str(time_cost) + "h";
	if money_change < 0:
		if time_cost:
			prompt += ", ";
		## probably change this eventually
		prompt +=Index.get_color_tag("money")+ "$" + str(-money_change);

	final_action_prompt = prompt
