extends TextureProgressBar

class_name ExperienceBar;

signal level_up;
signal feedback_finished

@onready var initial_tint:Color = tint_over;

@export var level_up_text:Label;
@export var level_up_sfx:AudioStreamPlayer;

@export var from_player:bool=false;

@export var target:Node;
var exp_tracked:String;

func build(node: Node)->void:
	assert(node is Player or node is FighterUnit)
	target = node;
	update_max_value(true)

func levels_from_exp(level:int, current_exp:int, amount:int)->Array[int]:
	var gain:int = 0
	
	var for_next_level:int = Scaling.exp_for_next_level(level) - current_exp
	while amount >= for_next_level:
		amount -= for_next_level;
		gain += 1;
		
		for_next_level = Scaling.exp_for_next_level(level + gain);


	return [gain, amount]


func gain_exp(increase:float)->void:
	assert(target)
	## THIS IS WHERE ALL EXP GAIN FOR ALL 
	## UNITS AND THE PLAYER IS APPLIED?
	var tween := create_tween();
	
	if value + increase < max_value:
		## VALUE AS THIS RUN IS SET TO THE TARGET'S EXP
		set_target_exp(value + increase)
		exp_gain_animation(tween, increase);
	else:
	
		var simulation:Array[int] = levels_from_exp(target.level, target.experience, increase)
		var levels_gained:int = simulation[0];
		var exp_left:int = simulation[1]
		

			
		for l:int in levels_gained:
			level_up_animation(tween);
	
	
		exp_gain_animation(tween, exp_left)
	
	await tween.finished;
	feedback_finished.emit()
	
func exp_gain_animation(tween:Tween, increase:int)->void:
	tween.tween_property(self, "value", value + increase, .5);
	

func set_target_exp(experience:int)->void:
	target.experience = experience;

	

func update_max_value(update_value:bool=false)->void:
	value = 0;
	max_value = Scaling.exp_for_next_level(target.level)
	if update_value:
		value = target.experience;



func level_up_animation(tween:Tween)->void:
	tween.tween_property(self, "value", max_value, 1);
	tween.tween_callback(level_up_feedback)
	tween.tween_callback(level_up_target)
	tween.tween_callback(level_up.emit)
	
	tween.tween_callback(reset_value)

func level_up_target()->void:
	target.level_up();
	update_max_value(true)
	

func level_up_feedback()->void:
	if from_player:
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
