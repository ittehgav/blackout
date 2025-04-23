extends TextureProgressBar

class_name ExperienceBar;

signal bar_level_up;
signal feedback_finished

@onready var original_size:Vector2 = size;

@export var level_up_text:Label;
@export var level_up_sfx:AudioStreamPlayer;

var target:Node;
var exp_tracked:String;


func build_from_player(which:String)->void:
	target = Entities.player;
	exp_tracked = which;
	level_up_sfx.volume_db = -5;
	match which:
		"leadership":
			max_value = Scaling.exp_for_next_level(Entities.player.leadership_level);
			value = Entities.player.leadership_exp;
		"combat":
			max_value = Scaling.exp_for_next_level(Entities.player.combat_level)
			value = Entities.player.combat_exp;

func build_from_unit(fighter_unit:FighterUnit)->void:
	level_up_sfx.volume_db = -10;
	target = fighter_unit;
	max_value = Scaling.exp_for_next_level(fighter_unit.level);
	value = fighter_unit.experience;

func level_up_target()->void:
	if target is Player:
		if exp_tracked == "leadership":
			Entities.player.leadership_level += 1;
			Entities.player.leadership_exp = 0;
		else:
			Entities.player.combat_level += 1;
			Entities.player.combat_exp = 0;
	else:
		target.level += 1;
		target.experience = 0;
	update_max_value();
	
func update_max_value()->void:
	value = 0;
	if target is Player:
		if exp_tracked == "leadership":
			max_value = Scaling.exp_for_next_level(target.leadership_level)
		else:
			max_value = Scaling.exp_for_next_level(target.combat_level)
	else:
		assert(target is FighterUnit);
		max_value = Scaling.exp_for_next_level(target.level)
		



	
func animate(increase:float)->void:
	var tween := create_tween();
	if value + increase < max_value:
		exp_gain_animation(tween, increase);
		
	else:
		var levels_gained :int= 0;
		var exp_left :int= increase;
		while exp_left > max_value - value:
			levels_gained += 1;
			exp_left -= max_value - value;
			level_up_target();

		for l:int in levels_gained:
			level_up_animation(tween);
		exp_gain_animation(tween, exp_left)
		
func exp_gain_animation(tween:Tween, increase:int)->void:
	tween.tween_property(self, "value", value + increase, .5);
	

func level_up_animation(tween:Tween)->void:
	tween.tween_property(self, "value", max_value, .5);
	tween.tween_callback(level_up_feedback)
	tween.tween_callback(reset_value)


func level_up_feedback()->void:
	level_up_sfx.play();
	var tween := create_tween()
	stretch()
	floating_text()
	bar_level_up.emit()
	tween.tween_property(self, "custom_minimum_size", original_size, .15);
	tween.parallel().tween_property(self, "size", original_size, .15);

func floating_text()->void:
	var text: = level_up_text.duplicate();
	add_child(text);
	text.show();
	var tween: = create_tween();
	tween.tween_property(text, "position:y", text.position.y - 20, .5);
	tween.tween_callback(text.queue_free)

func stretch()->void:
	custom_minimum_size = original_size * 1.1;
	size = original_size * 1.1

func reset_value()->void:
	value = 0;
