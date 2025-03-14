extends MarginContainer


@export var sample:SpriteSample;
@export var showing_unit:FighterUnit

@export var unit_name_label:Label;
@export var skill_name_label:Label;
@export var skill_description_label:RichTextLabel;

@export var tags_label:Label;

@export var unit_level_label:Label;
@export var level_progress_bar:ProgressBar;

@export_subgroup("stat labels")
@export var max_hp_label:Label;
@export var attack_label:Label;
@export var defense_label:Label;
@export var move_speed_label:Label;
@export var technique_label:Label;

@export var skill_range_label:Label;
@export var skill_cooldown_label:Label;

## TODO also display
## range (melee, short or long)
## cooldown
## tags (and color code the tags)



func _ready():
	sample.disable_panel();

func display_recruit(unit:FighterUnit):
	if showing_unit:
		showing_unit.queue_free();

	showing_unit = unit.duplicate();
	sample.set_sample(showing_unit.base);
	sample.target_base.scale *= 6
	sample.target_base.offset = Vector2(-80, -10)
	refresh_data();
	fade_in()
	
func refresh_data():
	unit_name_label.text = showing_unit.base.name;
	tags_label.text = "";
	for tag in showing_unit.base.tags:
		tags_label.text += tag.capitalize() + "\n"
	
	unit_level_label.text = "Level " + str(showing_unit.level);
	level_progress_bar.max_value = Scaling.exp_for_next_level(showing_unit.level);
	level_progress_bar.value = showing_unit.experience;
	
	skill_name_label.text = "Skill: " + showing_unit.base.skill_name;
	skill_description_label.text = showing_unit.base.full_skill_description(showing_unit);
	
	max_hp_label.text = str(showing_unit.stats.max_hp)
	attack_label.text = str(showing_unit.stats.attack)
	defense_label.text = str(showing_unit.stats.defense)
	move_speed_label.text = str(showing_unit.stats.move_speed)
	technique_label.text = str(showing_unit.stats.technique)
	
	skill_cooldown_label.text = "Cooldown: " + str(showing_unit.base.skill_cooldown) + "s";
	skill_range_label.text = get_skill_range(showing_unit.base);

func get_skill_range(fighter:FighterBase)->String:
	if fighter.skill_range == fighter.MELEE_RANGE:
		return "Melee";
	elif fighter.skill_range < 350:
		return "Short Range";
	else:
		return "Long Range"
	

func fade_in():
	modulate.a = 0;
	show();
	var tween = create_tween();
	tween.tween_property(self, "modulate:a", 1, .35)
	
func fade_out():
	var tween = create_tween();
	tween.tween_property(self, "modulate:a", 0, .35)
	await tween.finished;
	hide();

func _input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_cancel") and visible:
		fade_out();
