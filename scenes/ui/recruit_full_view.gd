extends MarginContainer


@export var sample:SpriteSample;
@export var showing_unit:FighterUnit

@export var unit_name_label:Label;
@export var skill_name_label:Label;
@export var skill_description_label:RichTextLabel;

@export var unit_level_label:Label;
@export var level_progress_bar:ProgressBar;

@export_subgroup("stat labels")
@export var max_hp_label:Label;
@export var attack_label:Label;
@export var defense_label:Label;
@export var move_speed_label:Label;
@export var technique_label:Label;

## TODO also display
## range (melee, short or long)
## cooldown
## tags (and color code the tags)



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

func fade_in():
	modulate.a = 0;
	show();
	var tween = create_tween();
	tween.tween_property(self, "modulate:a", 1, .5)
