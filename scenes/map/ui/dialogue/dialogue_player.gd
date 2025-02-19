extends Control

@onready var manager:DialogueManager=DialogueManager;

@export var current_dialogue:DialogueResource;

@export var dialogue_choice_scene:PackedScene;

@export var choices_box:PanelContainer;
@export var choices_container:VBoxContainer;

@export var speaker_name_label:Label;
@export var text_label:RichTextLabel;

var current_line:DialogueLine;

func _ready()->void:
	Entities.dialogue_player = self;
	start_dialogue()



func start_dialogue():
	choices_box.hide();
	show()
	current_line = await manager.get_next_dialogue_line(current_dialogue, "start")
	display_line()
	

func _process(_delta:float):
	if Input.is_action_just_pressed("dialogue_next") and not choices_box.visible:
		dialogue_next();
		
func dialogue_next():
	if len(current_line.responses):
		show_responses();
	else:
		next_line()

func show_responses():
	for response:DialogueResponse in current_line.responses:
		var button:Button = dialogue_choice_scene.instantiate();
		button.build(response.text);
		
		button.pressed.connect(response_chosen.bind(response.next_id))
		
		choices_container.add_child(button);
		
		
	
	choices_box.show()


func display_line():
	var speaker:String = current_line.character;
	var line_text:String = current_line.text;
	if speaker:
		speaker_name_label.text = speaker;
	text_label.text = line_text
	
	type_out_text();
	
func type_out_text():
	text_label.visible_ratio = 0;
	var tween:Tween = create_tween();
	tween.tween_property(text_label, "visible_ratio", 1, len(text_label.text) * .025)
	
func next_line():
	current_line = await manager.get_next_dialogue_line(current_dialogue, current_line.next_id);
	display_line()



func response_chosen(key):
	choices_box.hide();
	current_line = await manager.get_next_dialogue_line(current_dialogue, key);
	if current_line and  current_line.text:
		display_line();
	
