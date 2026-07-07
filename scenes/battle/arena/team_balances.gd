extends Control

@export var arena:Arena

@export var team_1:Team;
@export var team_2:Team

@export var team_1_icons:HBoxContainer;
@export var team_2_icons:HBoxContainer

var team_1_icon_owners:Dictionary[ActiveFighter, TextureRect]
var team_2_icon_owners:Dictionary[ActiveFighter, TextureRect]

@export var team_1_icon_base:TextureRect;
@export var team_2_icon_base:TextureRect;

func _ready()->void:
	await arena.battle_started;
	generate_fighters_icons();

func generate_fighters_icons()->void:
	for fighter:ActiveFighter in team_1.fighters:
		if fighter is PlayerFighter or not fighter.dummy:
			var icon:TextureRect = generate_fighter_icon(fighter, 1);
			team_1_icons.add_child(icon);
			team_1_icon_owners[fighter] = icon
		
	for fighter:ActiveFighter in team_2.fighters:
		if not fighter.dummy:
			var icon:TextureRect = generate_fighter_icon(fighter, 2);
			team_2_icons.add_child(icon);
			team_2_icon_owners[fighter] = icon
	

func generate_fighter_icon(fighter:ActiveFighter, team_n:int)->TextureRect:
	var target_icon:TextureRect;
	if team_n == 1:
		target_icon = team_1_icon_base;
	else:
		target_icon = team_2_icon_base;
	var new_icon:TextureRect = target_icon.duplicate();
	new_icon.texture = target_icon.texture.duplicate();
	new_icon.texture.atlas = fighter.sprite.texture;
	new_icon.show()
	return new_icon
	

func fade_out_icon(icon:TextureRect)->void:
	var tween:Tween = create_tween();
	const fade_time = .5
	tween.tween_property(icon, "modulate:v", 0, fade_time)
	tween.parallel().tween_property(icon, "modulate:a", 0, fade_time)
	tween.tween_callback(icon.queue_free)
	


func _on_team_1_fighter_died(fighter: ActiveFighter) -> void:
	if fighter.summon:return
	fade_out_icon(team_1_icon_owners[fighter])
	team_1_icon_owners.erase(fighter)



func _on_team_2_fighter_died(fighter: ActiveFighter) -> void:
	if fighter.summon:return
	fade_out_icon(team_2_icon_owners[fighter])
	team_2_icon_owners.erase(fighter)
