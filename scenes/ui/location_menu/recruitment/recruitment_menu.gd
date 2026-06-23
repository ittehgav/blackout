extends UIRoot

class_name RecruitmentMenu

signal recruitment_finished;

@export_subgroup("nodes")
@export var hire_sfx:AudioStreamPlayer;
@export var content_hbox:HBoxContainer;


@export var option_scene:PackedScene;


var current_unit:FighterUnit;
var current_price:int;
var current_option:RecruitmentCard

@export var options_holder:VBoxContainer
@export var options_vbox:VBoxContainer;

@export var unit_sprite:Sprite2D;

@export var stats:StatsDropdown;

@export var name_label:Label;
@export var level_label:Label;
@export var tags_label:Label

@export var skill_name_label:Label;
@export var skill_description_label:RichTextLabel;

@export var recruit_button:Button

@export var hired_overlay:ColorRect;
@export var placeholder:ColorRect

func start_recruitment(roster:RecruitmentRoster)->void:
	options_vbox.queue_free();
	options_vbox = VBoxContainer.new();
	options_holder.add_child(options_vbox)
	
	for unit:FighterUnit in roster.units:
		var card:RecruitmentCard = option_scene.instantiate();
		card.setup(unit);
		options_vbox.add_child(card);
		
		card.pressed.connect(load_option.bind(card));
	
	refresh_affordability();
	recursive_connect_ui_feedback(options_vbox)
	slide_in()
	
func slide_in()->void:
	show()
	content_hbox.add_theme_constant_override("separation", 400);
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_CUBIC);
	tween.tween_property(content_hbox, "theme_override_constants/separation", 0, .75)

func slide_out()->void:
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_CUBIC);
	tween.tween_property(content_hbox, "theme_override_constants/separation", 400, .5)
	tween.parallel().tween_property(self, "modulate:a", 0, .5);
	tween.tween_callback(hide);
	tween.tween_callback(set_modulate.bind(Color.WHITE))
	await tween.finished;
	placeholder.show()

func load_option(card:RecruitmentCard)->void:
	current_option = card;
	var unit:FighterUnit = card.unit;
	var price:int = card.unit_price

	current_unit = unit
	current_price = price
	
	name_label.text = unit.base.name;
	level_label.text = "Level " + str(unit.level);
	unit_sprite.texture = unit.base.texture;
	
	tags_label.text = "";
	var keys:Array = FighterBase.Tag.keys()
	for tag:FighterBase.Tag  in unit.base.tags:
		var tag_name:String = keys[tag].capitalize()
		tags_label.text += tag_name + "\n";
	
	skill_name_label.text = "Skill: " + unit.base.skill.name
	skill_description_label.text = unit.base.full_skill_description(unit);
	
	stats.source = unit
	stats.update()

	recruit_button.text = "Recruit - $"+str(current_price)
	recruit_button.disabled = Entities.player.inventory.money < current_price;
	
	placeholder.hide()
	hired_overlay.hide()


func _on_hire_pressed() -> void:
	Entities.player.inventory.change_resource("money", -current_price);
	Entities.player.roster.add_unit(current_unit)
	current_option.unit_hired()
	
	show_hired_overlay();
	
	hire_sfx.play()

func refresh_affordability()->void:
	for node:Node in options_vbox.get_children():
		node.refresh_affordability()

func show_hired_overlay()->void:
	hired_overlay.scale = Vector2(2, 2);
	var tween:Tween = Tweens.ui_fade_in(hired_overlay);
	tween.parallel().tween_property(hired_overlay, "scale", Vector2.ONE, .5);
	
func exit()->void:
	slide_out();
	recruitment_finished.emit()
