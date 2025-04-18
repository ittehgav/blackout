extends HBoxContainer

@export var sample:SpriteSample;
@export var exp_bar:ExperienceBar;


func display_recruit_data(unit:FighterUnit):
	show()
	var exp = Entities.arena.battle_exp_value;
	
	exp_bar.build_from_unit(unit);
	sample.set_sample(unit.base.duplicate(), Entities.player.color_scheme_index);
	
	
