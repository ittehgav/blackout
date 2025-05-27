extends UIRoot

class_name DialoguePlayer;

signal dialogue_started;
signal dialogue_ended;

var suspended:bool=false;

@onready var manager:DialogueManager=DialogueManager;

@export var current_dialogue:DialogueResource;
@export var trade_menu:TradeMenu;

@export_group("Scenes")
@export var input_hold_timer:Timer;

@export var dialogue_choice_scene:PackedScene;

@export_group("Elements")
@export var speaking_party_avatar:Control;
@export var blip:AudioStreamPlayer;
@export var dialogue_sfx:AudioStreamPlayer;

var current_speaking_sprite:Sprite2D;
@export var player_sprite:Sprite2D
var current_exposed:Sprite2D;


@export var choices_box:PanelContainer;
@export var choices_container:VBoxContainer;

@export var speaker_name_label:Label;
@export var text_label:RichTextLabel;

var current_line:DialogueLine;

func _ready()->void:
	super();
	manager.mutated.connect(check_end)
	Entities.dialogue_player = self;
	
func _process(_delta:float)->void:
	if Input.is_action_just_pressed("dialogue_next") and visible and not choices_box.visible and not suspended:
		dialogue_next();

func start_dialogue(target:Leader)->void:
	suspended = false
	Entities.main_bgm.play_bgm(target.party_type)
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	Entities.world_map.pause_map()
	show()
	choices_box.hide();
	
	set_speaking_avatar();
	
	current_dialogue = target.dialogue;
	current_line = await manager.get_next_dialogue_line(current_dialogue, "start")
	display_line()
	
	expose_avatar(current_speaking_sprite);
	dialogue_started.emit()

func end_dialogue()->void:
	if not suspended:
		hide()
		set_process_mode(Node.PROCESS_MODE_DISABLED)
		Entities.world_map.unpause_map();
		dialogue_ended.emit()


func check_end()->void:
	if not suspended:
		var next_line:DialogueLine = await manager.get_next_dialogue_line(current_dialogue, current_line.next_id);
		if not next_line is DialogueLine:
			end_dialogue()


func set_speaking_avatar()->void:
	if current_speaking_sprite:
		current_speaking_sprite.queue_free();
	
	var leader:Leader = Entities.current_speaking_party.leader;
	
	current_speaking_sprite = leader.unit.base.duplicate();
	current_speaking_sprite.offset = current_speaking_sprite.sample_offset
	ColorCoder.color_code_fighter(current_speaking_sprite, leader.color_scheme_index);

	speaking_party_avatar.add_child(current_speaking_sprite)


func dialogue_next()->void:
	if len(current_line.responses):
		show_responses();
	else:
		get_next_line()


func show_responses()->void:
	expose_avatar(player_sprite)
	for c in choices_container.get_children():
		c.queue_free()
	for response:DialogueResponse in current_line.responses:
		var button_text:String = parse_dialogue_text(response.text);
		## may be invalidated based on type of choice
		if button_text:
			var button:DialogueChoice = dialogue_choice_scene.instantiate();
			
			button.build(button_text);
			button.pressed.connect(response_chosen.bind(response))
			
			choices_container.add_child(button);

	choices_box.show()


func display_line()->void:
	expose_avatar(current_speaking_sprite);
	var speaker:String = current_line.character;
	var line_text:String = current_line.text;
	if speaker:
		speaker_name_label.text = speaker;
	text_label.text = parse_dialogue_text(line_text);
	if line_text[0] != "[":
		type_out_text();
	else:
		text_label.visible_ratio = 1;
	

func expose_avatar(target:Sprite2D)->void:
	if current_exposed != target:
		current_exposed = target;
		if target == current_speaking_sprite:
			var vanish_tween: = create_tween();
			vanish_tween.tween_property(player_sprite, "modulate:v", .2, .1);
			vanish_tween.parallel().tween_property(player_sprite, "scale", Vector2(7, 7), .1)
		else:
			var vanish_tween: = create_tween();
			vanish_tween.tween_property(current_speaking_sprite, "modulate:v", .2, .1);
			vanish_tween.parallel().tween_property(current_speaking_sprite, "scale", Vector2.ONE, .1);
		
		var expose_tween: = create_tween();
		expose_tween.tween_property(target, "modulate:v", 1, .2);
		expose_tween.set_trans(Tween.TRANS_BOUNCE)
		expose_tween.parallel().tween_property(target, "scale", target.scale * 1.1, .2);


func type_out_text()->void:
	text_label.visible_ratio = 0;
	blip.play()
	var tween:Tween = create_tween();
	tween.tween_property(text_label, "visible_ratio", 1, len(text_label.text) * .025)
	tween.tween_interval(.2)
	tween.finished.connect(blip.stop)
	
func get_next_line()->void:
	current_line = await manager.get_next_dialogue_line(current_dialogue, current_line.next_id);
	if current_line:
		display_line()



func response_chosen(response:DialogueResponse)->void:
	choices_box.hide();
	if "#roll" in response.text:
		var key:String;
		if "#roll_intimidate" in response.text:
			Entities.current_speaking_party.intimidate_attempted = true;
			if Entities.in_map_player.roll_intimidate(Entities.current_speaking_party):
				key = "intimidate_success";
			else:
				key = "intimidate_fail"
		elif "#roll_convince" in response.text:
			Entities.current_speaking_party.persuade_attempted = true;
			if Entities.in_map_player.roll_convince(Entities.current_speaking_party):
				key = "convince_success";
			else:
				key = "convince_fail"
		current_line = await manager.get_next_dialogue_line(current_dialogue, key)
		if current_line and  current_line.text:
			display_line();
	else:
		var key:String = response.next_id;
		current_line = await manager.get_next_dialogue_line(current_dialogue, key);
		if current_line and  current_line.text:
			display_line();
		
	
func parse_dialogue_text(text:String)->String:
	var final_text:String = text;
	if "#start_battle" in final_text:
		final_text = final_text.replace("#start_battle", "[color=red]Engage in Battle[/color]")
	if "#roll_intimidate" in final_text:
		if Entities.current_speaking_party.intimidate_attempted:
			return "";
		final_text = final_text.replace("#roll_intimidate", roll_intimidate_odds())
	if "#roll_convince" in final_text:
		if Entities.current_speaking_party.persuade_attempted:
			return "";
		final_text = final_text.replace("#roll_convince", roll_convince_odds())
	
	if "#yield" in final_text:
		final_text = final_text.replace("#yield", "[color=dark_red]Lose half of all your resources.");
	if "#angry" in final_text:
		final_text = final_text.replace("#angry", "");
		final_text = wrap_in_bbcode_tag(final_text, "shake rate=50.0 level=40.0")
		play_effect("angry");
	if "#scared " in final_text:
		final_text = final_text.replace("#scared", "");
		final_text = wrap_in_bbcode_tag(final_text, "shake rate=10.0 level=10.0")
		play_effect("scared");
	if "#persuaded" in final_text:
		final_text =  final_text.replace("#persuaded", "")
		
		play_effect("persuaded");
	
	return final_text


func play_effect(effect:String)->void:
	## plays both visual and sound effecrts
	match effect:
		"angry":
			Tweens.color_blink(current_speaking_sprite, Color.RED, .5);
			Tweens.y_shake(current_speaking_sprite, 2, 10);
			dialogue_sfx.play_sound_by_key("angry")
		"scared":
			dialogue_sfx.play_sound_by_key("success")
		"persuaded":
			dialogue_sfx.play_sound_by_key("success");
	
func wrap_in_bbcode_tag(text:String, tag:String )->String:
	return "[" + tag + "]" + text + "[/" + tag.split(" ")[0] + "]"
	
func roll_intimidate_odds()->String:
	var odds_string:String = "[color=red]Intimidate - ";
	var odds:float = Entities.in_map_player.intimidate_odds(Entities.current_speaking_party);
	if odds > 1:
		odds = 1;
	odds_string += str(snapped(odds * 100, .01)) + "%[/color]"
	return odds_string;

func roll_convince_odds()->String:
	var odds_string: = "[color=yellow]Convince - "
	var odds:float = Entities.in_map_player.convince_odds(Entities.current_speaking_party);
	odds_string += str(snapped(odds * 100, .01)) + "%[/color]"
	return odds_string


		

func _on_animation_ticker_timeout() -> void:
	await get_tree().create_timer(.25).timeout;
	
	if current_speaking_sprite.frame:
		current_speaking_sprite.frame = 0;
	else:
		current_speaking_sprite.frame = 1;




func _on_speech_blip_finished() -> void:
	blip.play();

func start_trade()->void:
	suspended = true;
	Tweens.ui_fade_out(self)
	Tweens.ui_fade_in(trade_menu);
	trade_menu.start_trade(Entities.current_speaking_party);

func after_trade()->void:
	suspended = false;
	Tweens.ui_fade_out(trade_menu);
	Tweens.ui_fade_in(self)
	current_line = await manager.get_next_dialogue_line(current_dialogue, "after_trade")
	display_line()
