extends Node

var current_player:DialoguePlayer;
var current_speaker:Variant

func get_ui_target()->Control:
	match State.scenario:
		## WHERE HUDS WILL BE HIDDEN/SHOWN
		"in_settlement":
			return Entities.current_area.ui;
	assert(false)
	return null
	

func start_dialogue(dialogue:DialogueResource, speaker:Variant, speaker_sprite:Sprite2D)->void:
	get_tree().paused = true;
	current_speaker = speaker
	current_player = Index.scenes.ui.dialogue_player.instantiate()
	if speaker_sprite:
		current_player.load_speaker_sprite(speaker_sprite)
	current_player.current_dialogue = dialogue;
	var ui_target:Control = get_ui_target();

	ui_target.add_child(current_player)
	current_player.tree_exited.connect(on_dialogue_ended)

func evolution_menu()->void:
	var canvas:CanvasLayer = CanvasLayer.new();
	canvas.layer = 4;
	var menu:EvolutionMenu = Index.scenes.ui.evolution_menu.instantiate();
	#menu.load_options(Dialogue.current_speaker.evolve_option)
	canvas.add_child(menu)
	var target:Control = get_ui_target();
	target.add_child(canvas);
	Tweens.ui_fade_in(menu)

func on_dialogue_ended()->void:
	if not get_tree():
		## idk this shoots an error when you close the window mid dialogue?
		return
	match Entities.main.scenario:
		"in_settlement":
			get_tree().paused = false;
	current_player = null;

func get_scenario()->Control:
	match Entities.main.scenario:
		"in_settlement":
			Entities.main_hud.hide()
			return Entities.current_area.ui;
	assert(false)
	return Control.new()

func start_trade()->void:
	current_player.hide();
	var trade_menu:TradeMenu = Index.scenes.ui.trade_menu.instantiate()
	var target_inventory:Inventory = current_speaker.inventory;
	trade_menu.start_trade(target_inventory, current_speaker.name)
	
	var target:Control = get_scenario();
	target.add_child(trade_menu);
	Tweens.ui_fade_in(trade_menu)

	
	trade_menu.trade_finished.connect(trade_finished)
	
func start_recruitment()->void:
	current_player.hide();
	var recruitment_menu:RecruitmentMenu = Index.scenes.ui.recruitment_menu.instantiate()
	
	recruitment_menu.current_roster = current_speaker.roster
	var target:Control = get_scenario();
	target.add_child(recruitment_menu);
	Tweens.ui_fade_in(recruitment_menu)
	
func trade_finished()->void:
	match Entities.main.scenario:
		"in_settlement":
			get_tree().paused = false
			Entities.main_hud.show();
