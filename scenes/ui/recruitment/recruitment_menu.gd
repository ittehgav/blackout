extends UIRoot

class_name RecruitmentMenu


@export var option_scene:PackedScene;

@export var current_roster:Roster;
var current_unit:FighterUnit;
@export var options_vbox:VBoxContainer;

@export var sprite_sample:SpriteSample

@export var stats:StatsDropdown;

@export var name_label:Label;
@export var level_label:Label;
@export var tags_label:Label

@export var skill_name_label:Label;
@export var skill_description_label:RichTextLabel;
@export var flavor_label:Label;

@export var recruit_button:Button

func _ready()->void:
	super() ## for the UIRoot stuff
	## loads with the roster already set
	
	options_vbox.queue_free()
	options_vbox = VBoxContainer.new();
	$main.add_child(options_vbox);
	
	for unit:FighterUnit in current_roster.units:
		var card:RecruitmentCard = option_scene.instantiate();
		card.setup(unit);
		options_vbox.add_child(card)
		
		card.pressed.connect(load_option.bind(unit))
	recursive_connect_ui_feedback(options_vbox)

func load_option(unit:FighterUnit)->void:
	current_unit = unit
	
	name_label.text = unit.base.name;
	level_label.text = "Level " + str(unit.level);
	
	sprite_sample.set_sample(unit.base)
	
	tags_label.text = "";
	for tag:String in unit.base.tags:
		tags_label.text += tag + "\n";
	
	skill_name_label.text = "Skill: "+unit.base.skill_name
	skill_description_label.text = unit.base.full_skill_description(unit);
	flavor_label.text = unit.base.flavor;
	
	stats.load_stats(unit.final_stats())
