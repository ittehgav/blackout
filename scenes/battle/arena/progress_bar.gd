extends TextureProgressBar

@export var icon:TextureRect;

var tweening_icon:bool = false

var alert_tween:Tween;
var tweening_alert:bool=false;

func set_tide_bar()->void:
	var team_1_power:=0;
	var team_2_power:=0;
	
	for unit:ActiveFighter in Entities.arena.team_1.units:
		if unit is NpcFighter:
			team_1_power += unit.unit.level;

	for unit:ActiveFighter in Entities.arena.team_2.units:
		team_2_power += unit.unit.level;
	
	max_value = team_1_power + team_2_power;
	value = team_1_power;
	await Entities.arena.ready
	move_tide(value)
	

func move_tide(_value: float) -> void:
	## where a flashy animation will go eventually
	var tide_fraction:float = 1/max_value * value
	var target_icon_x:float = tide_fraction * size.x;
	
	const danger_threshold = .3;
	
	if tide_fraction <= danger_threshold:
		fill_mode = 1
		scale.y = 2
		modulate = Color.RED
		enable_alert_tween()
	elif tide_fraction <= .5:
		fill_mode = 1
		scale.y = 1;
		disable_alert_tween()
		modulate = Color.INDIAN_RED
	elif tide_fraction <= 1.0 - danger_threshold:
		fill_mode = 0
		scale.y = 1;
		disable_alert_tween()
		modulate = Color.LIGHT_GREEN;
	else:
		fill_mode = 0
		scale.y = 3;
		modulate = Color.GREEN
		enable_alert_tween()


	if not tweening_icon:
		tweening_icon = true
		var original_scale:Vector2 = icon.scale;
		icon.scale *= 2;
		var tween:Tween = create_tween();
		tween.tween_property(icon, "position:x", target_icon_x, .5);
		tween.set_trans(Tween.TRANS_BOUNCE)
		tween.parallel().tween_property(icon, "scale", original_scale, .5)
		tween.tween_callback(enable_icon_tween)

func enable_alert_tween()->void:
	if not tweening_alert:
		tweening_alert = true
		alert_blink_tween()

func disable_alert_tween()->void:
	if tweening_alert:
		alert_tween.kill();
		tweening_alert=false

func alert_blink_tween()->void:
	const blink_half_time = .15
	var original_color:Color = tint_under;
	alert_tween = create_tween();
	alert_tween.tween_property(self, "tint_under", Color(.5, .5, .5), blink_half_time);
	alert_tween.tween_property(self, "tint_under", original_color, blink_half_time)
	alert_tween.tween_interval(.5)
	alert_tween.tween_callback(alert_blink_tween)

	

func enable_icon_tween()->void:
	tweening_icon = false;

func refresh_tide_value(_killer:ActiveFighter, victim:ActiveFighter)->void:
	if victim is InFightPlayer:
		return
	if victim.ally_team == Entities.arena.team_1:
		value -= victim.unit.level;
	else:
		value += victim.unit.level;

	var enemy_value:float = max_value - value;
	
	## make smaller fights demand wipeouts?
	if enemy_value <= value/100:
		Entities.arena.battle_over(1)
	elif enemy_value >= value * 100:
		Entities.arena.battle_over(2)
