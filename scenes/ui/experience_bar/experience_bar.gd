extends TextureProgressBar

class_name ExperienceBar;

signal level_up;
signal feedback_finished

@onready var initial_tint:Color = tint_over;

@export var level_up_text:Label;
@export var level_up_sfx:AudioStreamPlayer;

@export var from_player:bool=false;

var target:Node;
var exp_tracked:String;

func _ready()->void:
	if from_player:
		build(Entities.player);

func build(source: Node)->void:
	target = source;



func refresh()->void:
	update_max_value(true);
	
func gain_exp(increase:float)->void:
	assert(target)
	## THIS IS WHERE ALL EXP GAIN FOR ALL 
	## UNITS AND THE PLAYER IS APPLIED
	var tween := create_tween();
	if value + increase < max_value:
		## VALUE AS THIS RUN IS SET TO THE TARGET'S EXP
		set_target_exp(value + increase)
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
		set_target_exp(exp_left);
		exp_gain_animation(tween, exp_left)
		
func exp_gain_animation(tween:Tween, increase:int)->void:
	tween.tween_property(self, "value", value + increase, .5);
	



func set_target_exp(_value:int)->void:
	target.experience = value;

	
func level_up_target()->void:
	target.level_up.emit()
	level_up.emit()
	target.level += 1;
	target.experience = 0;
	update_max_value();
	
func update_max_value(update_value:bool=false)->void:
	value = 0;
	max_value = Scaling.exp_for_next_level(target.level)
	if update_value:
		value = target.experience;



func level_up_animation(tween:Tween)->void:
	tween.tween_property(self, "value", max_value, .5);
	tween.tween_callback(level_up_feedback)
	tween.tween_callback(reset_value)


func level_up_feedback()->void:
	level_up_sfx.play();
	
	floating_text()
	
	tint_over = Color.WHITE
	
	var tween := create_tween()
	tween.tween_property(self, "tint_over", initial_tint, .5);

func floating_text()->void:
	var text: = level_up_text.duplicate();
	add_child(text);
	text.show();
	var tween: = create_tween();
	tween.tween_property(text, "position:y", text.position.y - 20, .5);
	tween.tween_callback(text.queue_free)

func reset_value()->void:
	value = 0;
