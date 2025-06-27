extends TextureProgressBar

@export var icon:TextureRect;
@onready var icon_anchor:Vector2 = icon.position;

@export_group("sfx")
@export var ally_death_sound:AudioStream;
@export var enemy_death_sound:AudioStream;

@export var tide_low_sound:AudioStream;
@export var tide_high_sound:AudioStream;

var tweening_icon:bool = false

var alert_tween:Tween;
var shake_tween:Tween;
var tweening_alert:bool=false;

var team_1_unit_values:Dictionary[ActiveFighter,float];
var team_2_unit_values:Dictionary[ActiveFighter,float];


func set_tide_bar()->void:

	var team_1_power:=0;
	var team_2_power:=0;
	
	for key:ActiveFighter in team_1_unit_values.keys():
		team_1_power += team_1_unit_values[key]
	for key:ActiveFighter in team_2_unit_values.keys():
		team_2_power += team_2_unit_values[key];
	max_value = team_1_power + team_2_power;
	value = team_1_power;


func on_unit_death(_killer:ActiveFighter, victim:ActiveFighter)->void:
	## THIS IS RUNNING MORE OFTEN THAN IT SHOULDITSEEMS
	if victim is InFightPlayer:
		## this will end up triggering even though the battle will end
		return
	if victim.ally_team == Entities.arena.team_1:
		$sfx.stream = ally_death_sound;
		$sfx.pitch_scale = 1 + value/max_value;
		$sfx.play()
		var unit_value:float = team_1_unit_values[victim];
		max_value -= unit_value
		value -= unit_value
	else:
		$sfx.stream = enemy_death_sound;
		$sfx.play()
		value += team_2_unit_values[victim]


func move_tide(_value: float) -> void:
	if value == 0:
		Entities.arena.end_battle(2);
		return
	elif value == max_value:
		Entities.arena.end_battle(1);
		return
	## where a flashy animation will go eventually
	var tide_fraction:float = 1/max_value * value

	const danger_threshold = .2;
	
	if tide_fraction <= danger_threshold:
		icon.material.set_shader_parameter("base_color", Color.RED)
		
		scale.y = 2
		modulate = Color.RED
		
		$sfx.pitch_scale = 1;
		$sfx.stream = tide_low_sound;
		$sfx.play();
		
		enable_alert_tween()
	elif tide_fraction <= .5:
		icon.material.set_shader_parameter("base_color", Color.YELLOW.blend(Color(1,0,0,.3)))
		
		scale.y = 1;
		modulate = Color.INDIAN_RED
		
		disable_alert_tween()
	elif tide_fraction <= 1.0 - danger_threshold:
		icon.material.set_shader_parameter("base_color", Color.YELLOW_GREEN)
		
		scale.y = 1;
		modulate = Color.LIGHT_GREEN;
		
		disable_alert_tween()
	else:
		icon.material.set_shader_parameter("base_color", Color.YELLOW.blend(Color.CYAN))
		
		$sfx.pitch_scale = 1 + value/max_value
		$sfx.stream = tide_high_sound;
		$sfx.play();
		
		scale.y = 3;
		modulate = Color.GREEN
		
		enable_alert_tween()


	if not tweening_icon:
		tweening_icon = true

		var target_icon_x:float = tide_fraction * size.x - 30;
		var original_scale:Vector2 = icon.scale;

		icon.scale *= 2;
		icon_anchor.x = target_icon_x
		
		var tween:Tween = create_tween();
		tween.tween_property(icon, "position:x", target_icon_x, .5);
		tween.set_trans(Tween.TRANS_BOUNCE)
		tween.parallel().tween_property(icon, "scale", original_scale, .5)
		tween.tween_callback(enable_icon_tween)

func enable_alert_tween()->void:
	if not tweening_alert:
		tweening_alert = true
		alert_blink_tween()
		alert_shake_tween();

func disable_alert_tween()->void:
	if tweening_alert:
		alert_tween.kill();
		shake_tween.kill();
		tweening_alert=false

func alert_blink_tween()->void:
	const blink_half_time = .15
	var original_color:Color = tint_under;
	alert_tween = create_tween();
	alert_tween.tween_property(self, "tint_under", Color(.5, .5, .5), blink_half_time);
	alert_tween.tween_property(self, "tint_under", original_color, blink_half_time)
	alert_tween.tween_interval(.5)
	alert_tween.tween_callback(alert_blink_tween)

func alert_shake_tween()->void:
	const shake_range = 5;
	var x_roll:int = randi_range(icon_anchor.x - shake_range, icon_anchor.x + shake_range)
	var y_roll:int = randi_range(icon_anchor.y - shake_range, icon_anchor.y + shake_range);
	var target: = Vector2(x_roll, y_roll)
	shake_tween = create_tween();
	shake_tween.tween_property(icon, "position", target, .05);
	shake_tween.tween_callback(alert_shake_tween)
	

func enable_icon_tween()->void:
	tweening_icon = false;


func _on_sfx_finished() -> void:
	$sfx.pitch_scale = 1;
	$sfx.volume_db = 0;
