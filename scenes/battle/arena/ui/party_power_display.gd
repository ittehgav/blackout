extends HBoxContainer

@export var player_party_power:Label;
@export var enemy_party_power:Label;


func _on_arena_battle_started() -> void:
	player_party_power.text = str(Entities.arena.team_1.roster.get_level());
	enemy_party_power.text = str(Entities.arena.team_2.roster.get_level());
	


func _on_team_1_fighter_died(fighter: ActiveFighter) -> void:
	var current:int = int(player_party_power.text);
	current -= fighter.level;
	player_party_power.text = str(current)
	loss_blink(player_party_power)


func _on_team_2_fighter_died(fighter: ActiveFighter) -> void:
	var current:int = int(enemy_party_power.text);
	current -= fighter.level;
	enemy_party_power.text = str(current)
	loss_blink(enemy_party_power);

func _on_team_1_fighter_converted(fighter: ActiveFighter) -> void:
	var current:int = int(player_party_power.text);
	current -= fighter.level;
	player_party_power.text = str(current)
	
	var enemy_current:int = int(enemy_party_power.text);
	enemy_current += fighter.level;
	enemy_party_power.text = str(enemy_current)


func _on_team_2_fighter_converted(fighter: ActiveFighter) -> void:
	var current:int = int(player_party_power.text);
	current += fighter.level;
	player_party_power.text = str(current)
	
	var enemy_current:int = int(enemy_party_power.text);
	enemy_current -= fighter.level;
	enemy_party_power.text = str(enemy_current)

func loss_blink(target:Control)->void:
	target = target.get_parent()
	var tween:Tween = create_tween();
	tween.tween_property(target, "modulate", Color.RED, .1);
	tween.parallel().tween_property(target, "offset_transform_scale", Vector2(2, 2), .1)
	
	tween.tween_property(target, "modulate", Color.WHITE, .1);
	tween.parallel().tween_property(target, "offset_transform_scale", Vector2.ONE, .1)
