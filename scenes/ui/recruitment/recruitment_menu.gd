extends UIRoot

class_name RecruitmentMenu

@export var hire_sound:AudioStream;

@export var option_scene:PackedScene;

@export var current_roster:Roster;

var current_unit:FighterUnit;
var current_price:int;
var current_option:RecruitmentCard

@export var options_holder:VBoxContainer
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

@export var hired_overlay:ColorRect;
@export var placeholder:ColorRect

func _ready()->void:
	super() ## for the UIRoot stuff
	## loads with the roster already set
	
	options_vbox.queue_free()
	options_vbox = VBoxContainer.new();
	options_holder.add_child(options_vbox);
	
	for unit:FighterUnit in current_roster.units:
		var card:RecruitmentCard = option_scene.instantiate();
		card.setup(unit);
		options_vbox.add_child(card)
		
		card.pressed.connect(load_option.bind(card))
	refresh_affordability()
	recursive_connect_ui_feedback(options_vbox)

func load_option(card:RecruitmentCard)->void:
	current_option = card;
	var unit:FighterUnit = card.unit;
	var price:int = card.unit_price

	current_unit = unit
	current_price = price
	
	name_label.text = unit.base.name;
	level_label.text = "Level " + str(unit.level);
	
	sprite_sample.set_sample(unit.base)
	
	tags_label.text = "";
	for tag:String in unit.base.tags:
		tags_label.text += tag + "\n";
	
	skill_name_label.text = "Skill: "+unit.base.skill_name
	skill_description_label.text = unit.base.full_skill_description(unit);
	flavor_label.text = unit.base.flavor;
	
	stats.source = unit

	recruit_button.text = "Recruit - $"+str(current_price)
	recruit_button.disabled = Entities.player.inventory.money < current_price;
	
	if placeholder:
		placeholder.queue_free();
	hired_overlay.hide()


func _on_hire_pressed() -> void:
	Entities.player.inventory.change_resource("money", -current_price);
	Entities.player.roster.add_unit(current_unit)
	current_option.unit_hired()
	
	show_hired_overlay();
	
	ui_sfx.play_stream_obj(hire_sound)

func refresh_affordability()->void:
	for node:Node in options_vbox.get_children():
		node.refresh_affordability()

func show_hired_overlay()->void:
	hired_overlay.scale = Vector2(2, 2);
	var tween:Tween = Tweens.ui_fade_in(hired_overlay);
	tween.parallel().tween_property(hired_overlay, "scale", Vector2.ONE, .5);
	
func exit()->void:
	await Tweens.ui_fade_out(self).finished;
	get_tree().paused = false
