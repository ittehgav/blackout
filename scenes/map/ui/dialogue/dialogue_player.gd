extends UIRoot

class_name DialoguePlayer;

@onready var manager:DialogueManager=DialogueManager;

@export var current_dialogue:DialogueResource;

@export var dialogue_choice_scene:PackedScene;

@export var choices_box:PanelContainer;
@export var choices_container:VBoxContainer;

@export var speaker_name_label:Label;
@export var text_label:RichTextLabel;

var current_line:DialogueLine;

func _ready()->void:
	manager.mutated.connect(check_end)
	manager.dialogue_ended.connect(dialogue_ended);
	Entities.dialogue_player = self;

func check_end()->void:
	var next_line:DialogueLine = await manager.get_next_dialogue_line(current_dialogue, current_line.next_id);
	if not next_line is DialogueLine:
		dialogue_ended()

func dialogue_ended()->void:
	hide()

func start_dialogue(dialogue:DialogueResource)->void:
	Entities.world_map.pause_map()
	get_tree().paused = true;
	show()
	choices_box.hide();
	
	current_dialogue = dialogue;
	current_line = await manager.get_next_dialogue_line(current_dialogue, "start")
	display_line()
	

func _process(_delta:float)->void:
	if Input.is_action_just_pressed("dialogue_next") and visible and not choices_box.visible:
		dialogue_next();

func dialogue_next()->void:
	if len(current_line.responses):
		show_responses();
	else:
		get_next_line()

func show_responses()->void:
	for response:DialogueResponse in current_line.responses:
		var button:Button = dialogue_choice_scene.instantiate();
		button.build(response.text);
		button.pressed.connect(response_chosen.bind(response.next_id))
		choices_container.add_child(button);

	choices_box.show()

func display_line()->void:
	var speaker:String = current_line.character;
	var line_text:String = current_line.text;
	if speaker:
		speaker_name_label.text = speaker;
	text_label.text = line_text
	
	type_out_text();
	
func type_out_text()->void:
	text_label.visible_ratio = 0;
	var tween:Tween = create_tween();
	tween.tween_property(text_label, "visible_ratio", 1, len(text_label.text) * .025)
	
func get_next_line()->void:
	current_line = await manager.get_next_dialogue_line(current_dialogue, current_line.next_id);
	if current_line:
		display_line()
	else:
		print("notcl??")


func response_chosen(key:String)->void:
	choices_box.hide();
	current_line = await manager.get_next_dialogue_line(current_dialogue, key);
	if current_line and  current_line.text:
		display_line();
	
