extends HBoxContainer

@export var recruit_name_label:Label
@export var sample:SpriteSample;
@export var exp_bar:ExperienceBar;

var unit:FighterUnit;


func display_recruit_data(target:FighterUnit)->void:
	unit = target;
	show()

	refresh_name_label()
	
	exp_bar.build_from_unit(unit);
	
	sample.set_sample(unit.base.duplicate(), Entities.player.color_scheme_index);

func refresh_name_label(from_level_up:bool=false)->void:
	var name_str:String = "Lv. ";
	if not from_level_up:
		name_str += str(unit.level);
	else:
		var level := int(recruit_name_label.text.split("Lv. ")[1].split(" ")[0])
		name_str += str(level + 1);
		
	name_str += " " + unit.base.name
	recruit_name_label.text = name_str

func _on_exp_bar_bar_level_up() -> void:
	refresh_name_label(true);
	recruit_name_label.add_theme_font_size_override("font_size", 48);
	var tween: = create_tween();
	tween.tween_property(recruit_name_label, "theme_override_font_sizes/font_size", 32, .15)
