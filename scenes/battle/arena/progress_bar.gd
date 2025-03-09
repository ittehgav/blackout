extends ProgressBar

@export var icon:TextureRect;

func set_tide_bar()->void:
	var team_1_hp:=0;
	var team_2_hp:=0;
	
	for unit:ActiveFighter in Entities.arena.team_1.units:
		team_1_hp += unit.hp;
	for unit:ActiveFighter in Entities.arena.team_2.units:
		team_2_hp += unit.hp;
	
	max_value = team_1_hp + team_2_hp;
	value = team_1_hp;
	var tide_fraction = 1/max_value * value
	icon.position.x = tide_fraction * 1240 - 16;


func _on_value_changed(value: float) -> void:
	## where a flashy animation will go eventually
	var tide_fraction = 1/max_value * value
	var target_icon_x = tide_fraction * 1240 - 16;
	
	
	if tide_fraction <= .1:
		icon.scale = Vector2(2, 2)
		icon.modulate = Color.DARK_RED
	elif tide_fraction <= .2:
		icon.scale = Vector2(1.5, 1.5)
		icon.modulate = Color.RED;
	elif tide_fraction <= .5:
		icon.scale = Vector2(2, 2)
		icon.modulate = Color.YELLOW;
	elif tide_fraction <= .7:
		icon.scale = Vector2(3, 3)
		scale.y = 2;
		var bar_tween = create_tween();
		bar_tween.tween_property(self, "scale:y", 1, .5)
		icon.modulate = Color.LIGHT_GREEN
	
	var tween = create_tween();
	tween.tween_property(icon, "position:x", target_icon_x, .5);
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.parallel().tween_property(icon, "scale", Vector2.ONE, .5)
		

func refresh_tide_value(_killer, victim:ActiveFighter)->void:
	if victim.ally_team == Entities.arena.team_1:
		value -= victim.max_hp;
	else:
		value += victim.max_hp;

	var enemy_value = max_value - value;
	if enemy_value <= value/5:
		Entities.arena.battle_over(1)
	elif enemy_value >= value * 5:
		Entities.arena.battle_over(2)
