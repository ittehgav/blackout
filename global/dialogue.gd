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
	match Entities.main.state:
		## WHERE HUDS WILL BE HIDDEN/SHOWN
		"location":
			target = Entities.current_location.ui;

	target.add_child(current_player)
	current_player.tree_exited.connect(on_dialogue_ended)

func on_dialogue_ended()->void:
	match Entities.main.state:
		"location":
			get_tree().paused= false;
	current_player = null;
	
func start_trade()->void:
	current_player.hide();
	var trade_menu:TradeMenu = Index.scenes.ui.trade_menu.instantiate()
	trade_menu.start_trade(current_speaker.inventory, current_speaker.name)
	match Entities.main.state:
		"location":
			Entities.current_location.ui.add_child(trade_menu)

func trade_finished()->void:
	current_player.show();
	current_player.dialogue_next();
