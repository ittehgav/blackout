extends Control

@export var sample:SpriteSample;
@export var exp_bar:ExperienceBar;
@export var recruit_name:Label;
@export var recruit_level:Label;

@export var unit:FighterUnit

func build(target:FighterUnit)->void:
	unit = target;
	sample.set_sample(unit.base);
	exp_bar.build_from_unit(unit);
	recruit_name.text = unit.base.name;
	recruit_level.text = "Lv. " + str(unit.level)
	

func _on_exp_bar_level_up() -> void:
	recruit_level.text = "Lv." + str(unit.level) 
