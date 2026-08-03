extends UIRoot

class_name DialoguePlayer;

signal dialogue_started;



@export var current_dialogue:DialogueResource;

@export_group("Scenes")
@export var input_hold_timer:Timer;

@export var dialogue_choice_scene:PackedScene;

@export_group("Elements")
@export var speaker_sprite:Sprite2D;
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
var previous_substate:State.Substate

var speaker_texture:Texture; ## may or may not be used in a dialogue
func _ready()->void:
	super();
	#manager.mutated.connect(check_end)
	#manager.dialogue_ended.connect(end_dialogue)
	start_dialogue();
	previous_substate = State.current_substate
	State.set_substate(State.Substate.dialogue)
	
func _process(_delta:float)->void:
	if Input.is_action_just_pressed("dialogue_next") and visible and not choices_box.visible:
		dialogue_next();


func start_dialogue(_starting_line:String = "start")->void:
	Tweens.ui_fade_in(self);
	choices_box.hide();
	if speaker_texture:
		speaker_sprite.texture = speaker_texture;
	
	#current_line = await manager.get_next_dialogue_line(current_dialogue, starting_line);
	display_line()
	dialogue_started.emit()
	State.set_substate(State.Substate.dialogue)

func load_speaker_sprite(sprite:Sprite2D)->void:
	var speaker_anchor:Control = speaker_sprite.get_parent();
	speaker_sprite.queue_free();
	speaker_sprite = sprite.duplicate()
	speaker_sprite.scale = Vector2(4, 4)
	speaker_anchor.add_child(speaker_sprite)

func end_dialogue(_manager:DialogueResource=null)->void:
	State.revert_substate()
	queue_free()

func check_end()->void:
	#var next_line:DialogueLine = await manager.get_next_dialogue_line(current_dialogue, current_line.next_id);
	#if not next_line is DialogueLine:
		end_dialogue()


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
			
			button.build(response);
			if button.callback:
				button.pressed.connect(button.callback);
			else:
				button.pressed.connect(response_chosen.bind(response))
			
			choices_container.add_child(button);
	recursive_connect_ui_feedback(choices_container);
	choices_box.show()


func display_line()->void:
	if current_speaking_sprite:
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
	#current_line = await manager.get_next_dialogue_line(current_dialogue, current_line.next_id);
	if current_line:
		display_line()



func response_chosen(_response:DialogueResponse)->void:
	choices_box.hide();

	#var key:String = response.next_id;
	#current_line = await manager.get_next_dialogue_line(current_dialogue, key);
	if current_line and current_line.text:
		display_line();
		
	
func parse_dialogue_text(text:String)->String:
	var final_text:String = text;

	
	if "#yield" in final_text:
		final_text = final_text.replace("#yield", "[color=dark_red]Lose half of your food, fuel and money.");
	
	if "#angry" in final_text:
		final_text = final_text.replace("#angry", "");
		final_text = wrap_in_bbcode_tag(final_text, "shake rate=50.0 level=20.0")
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
			#Tweens.y_shake(current_speaking_sprite, 2, 10);
			dialogue_sfx.play_sound_by_key("angry")
		"scared":
			dialogue_sfx.play_sound_by_key("success")
		"persuaded":
			dialogue_sfx.play_sound_by_key("success");
	
func wrap_in_bbcode_tag(text:String, tag:String )->String:
	return "[" + tag + "]" + text + "[/" + tag.split(" ")[0] + "]"
	
func roll_intimidate_odds()->String:
	var odds_string:String = "[color=red]Intimidate - ";
	var odds:float = Entities.player_map_party.intimidate_odds(Entities.current_speaking_party);
	if odds > 1:
		odds = 1;
	odds_string += str(snapped(odds * 100, .01)) + "%[/color]"
	return odds_string;

func roll_convince_odds()->String:
	var odds_string: = "[color=yellow]Convince - "
	var odds:float = Entities.player_map_party.convince_odds(Entities.current_speaking_party);
	odds_string += str(snapped(odds * 100, .01)) + "%[/color]"
	return odds_string


func _on_speech_blip_finished() -> void:
	blip.play();
