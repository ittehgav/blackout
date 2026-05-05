extends Control

@export var post_fight:PostFight

@export var player_exp_bar:ExperienceBar;
@export var player_level_label:Label;

@export var party_power_label:Label;
@export var party_power_gain_label:Label;

@export var party_leveled_up:HBoxContainer;
@export var party_level_up_counter:Label;

@export var morale_icon:MoraleIcon

@export var continue_btn:Button;

@export var loot_panel:Panel;


var gained_power:bool=false;
func start_sequence()->void:
	show()
	refresh_player_level_label()
	
	var exp_gain:int = post_fight.enemy_roster.get_exp_bounty();
	var player:Player = post_fight.player;
	
	player.morale += 1;
	morale_icon.animated_update()
	
	
	var party_power_before:int = player.get_party_level()
	party_power_label.text = str(party_power_before)

	player_exp_bar.gain_exp(exp_gain);
	var party_levels_gained:int = distribute_party_exp(exp_gain);
	if party_levels_gained:
		gained_power = true
		party_leveled_up.show()
		party_level_up_counter.text = "Party LVL +"+str(party_levels_gained);
	
	var party_power_after:int = player.get_party_level();
	
	if party_power_after > party_power_before:
		gained_power = true
		var gain:int = party_power_after - party_power_before
		party_power_gain_label.text = "+"+str(gain);


	await player_exp_bar.feedback_finished;
	continue_btn.show()

func refresh_player_level_label() -> void:
	## doing this separately so it can refresh alone with the level ups
	player_level_label.text = "Level: " + str(post_fight.player.level);


	

func distribute_party_exp(exp_gain:int)->int:
	var levels_gained:int = 0;
	for unit:FighterUnit in post_fight.player.roster.units:
		levels_gained += unit.gain_exp(exp_gain)
		
	return levels_gained;


func _on_continue_pressed() -> void:
	## does nothing but delay it by the tween length if the player didnt gain PP
	var current_party_power:int = post_fight.player.get_party_level()
	await Tweens.tween_count_label(party_power_label, current_party_power).finished;
	slide_in_loot();

func slide_in_loot()->void:
	## HARDCODED FOR SIMPLE DEMO WILL NEED TO
	## MAKE THIS ADAPT TO CENTRALIZED STUFF
	var target_x:int = loot_panel.position.x - 1280
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(loot_panel, "position:x", target_x, .75);
	
	loot_panel.display_loot(post_fight.player.inventory, post_fight.enemy_roster.loot)
