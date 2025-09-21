extends Node

var current_player:DialoguePlayer;
var current_speaker:Variant

func start_dialogue(dialogue:DialogueResource, speaker:Variant, speaker_texture:Texture)->void:
	get_tree().paused = true;
	current_speaker = speaker
	current_player = Index.scenes.ui.dialogue_player.instantiate()
	if speaker_texture:
		current_player.speaker_texture = speaker_texture;
	current_player.current_dialogue = dialogue;
	var target:Control;
	match Entities.player.current_scenario:
		## WHERE HUDS WILL BE HIDDEN/SHOWN
		"location":
			target = Entities.current_location.ui;
	target.add_child(current_player)
	current_player.tree_exited.connect(on_dialogue_ended)

func on_dialogue_ended()->void:
	match Entities.player.current_scenario:
		"location":
			get_tree().paused = false;
	current_player = null;

func ready_scenario()->Control:
	match Entities.player.current_scenario:
		"location":
			Entities.main_hud.hide()
			return Entities.current_location.ui;
	assert(false)
	return Control.new()

func start_trade()->void:
	current_player.hide();
	var trade_menu:TradeMenu = Index.scenes.ui.trade_menu.instantiate()
	trade_menu.start_trade(current_speaker.inventory, current_speaker.name)
	
	var target:Control = ready_scenario();
	target.add_child(trade_menu);
	Tweens.ui_fade_in(trade_menu)

	
	trade_menu.trade_finished.connect(trade_finished)
	
func start_recruitment()->void:
	current_player.hide();
	var recruitment_menu:RecruitmentMenu = Index.scenes.ui.recruitment_menu.instantiate()
	
	recruitment_menu.current_roster = current_speaker.roster
	var target:Control = ready_scenario();
	target.add_child(recruitment_menu);
	Tweens.ui_fade_in(recruitment_menu)
	
func trade_finished()->void:
	match Entities.player.current_scenario:
		"location":
			get_tree().paused = false
			Entities.main_hud.show();
