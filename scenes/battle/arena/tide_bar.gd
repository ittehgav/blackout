extends TextureProgressBar

@export var arena:Node2D;

@export var team_1:Team;
@export var team_2:Team;

@export var tide_icon:TextureRect;

@export var icon_colors:Array[Color]


var total_levels_sum:int=0;
var t1_levels_sum:int = 0;
var t2_levels_sum:int = 0;


func _ready()->void:
	if arena is TestArena:
		queue_free();
		return
	await arena.battle_started;
	max_value = 0;
	for fighter:ActiveFighter in team_1.units:
		total_levels_sum += fighter.level
		t1_levels_sum += fighter.level
	for fighter:ActiveFighter in team_2.units:
		total_levels_sum += fighter.level
		t2_levels_sum += fighter.level
	
	refresh_value(0)
	shake_loop()
	max_value = total_levels_sum;
	var frac:float = value/max_value;
	shake_intensity = abs(.5-frac) * 50
	

func refresh_value(team_hit:int=0)->void:
	max_value = total_levels_sum;
	value = t1_levels_sum
	if value == 0:
		battle_lost();
	elif value == max_value:
		battle_won()
	match team_hit:
		1:
			color_blink(Color.INDIAN_RED)
		2:
			color_blink(Color.GREEN)
	refresh_icon();

func refresh_icon()->void:
	var frac:float = value/max_value;
	var target_color:Color;
	if frac < .2:
		target_color = icon_colors[0];
	elif frac < .35:
		target_color = icon_colors[1];
	elif frac < .6:
		target_color = icon_colors[2];
	elif frac < .8:
		target_color = icon_colors[3]
	else:
		target_color = icon_colors[4]
	
	modulate = target_color
	shake_intensity = abs(.5-frac) * 50
	
	const tween_duration=.5
	var tween:Tween = create_tween()
	tween.tween_property(tide_icon, "position:x", size.x * frac - 16, tween_duration);
	tween.parallel().tween_property(tide_icon, "modulate", target_color, tween_duration)

var shake_intensity:float;
var shake_tween:Tween
func shake_loop()->void:
	var target_x:int = randi_range(-shake_intensity/1.5, shake_intensity/1.5)
	var target_y:int = randi_range(-shake_intensity/1.5, shake_intensity/1.5)
	var target_offset:Vector2 = Vector2(target_x, target_y)
	shake_tween = create_tween();
	shake_tween.tween_property(tide_icon, "pivot_offset", target_offset, 2/shake_intensity)
	shake_tween.tween_callback(shake_loop)

func color_blink(target_color:Color)->void:
	const blink_half_time = .25
	var tween:Tween = create_tween();
	tween.tween_property(self, "self_modulate", target_color, blink_half_time);
	tween.tween_property(self, "self_modulate", Color.WHITE, blink_half_time)

func _on_team_1_unit_died(unit: ActiveFighter) -> void:
	t1_levels_sum -= unit.level;
	total_levels_sum -= unit.level;
	refresh_value(1)

func _on_team_2_unit_died(unit: ActiveFighter) -> void:
	t2_levels_sum -= unit.level;
	total_levels_sum -= unit.level
	refresh_value(2)


func _on_unit_converted(_unit: ActiveFighter) -> void:
	refresh_value();


func _on_player_fighter_death(_killer: ActiveFighter) -> void:
	battle_lost();

func battle_lost()->void:
	Entities.arena.start_post_battle(false)
	
func battle_won()->void:
	Entities.arena.start_post_battle(true)
