extends Control

@export var current_dialogue:DialogueResource;

@export var choice_button:Button;

@export var choices_box:PanelContainer;
@export var choices_container:VBoxContainer;

@export var speaker_name_label:Label;
@export var text_label:RichTextLabel;

var current_line_index:int = -1;
var lines:Array[Array]

func _ready()->void:
	Entities.dialogue_player = self;
	next_line()
	

func load_lines(init_lines:Array[Array])->void:
	## a dialogue is only an individual sequence of speech lines 
	## that ands in either a prompt or in 
	## returning to the previous view
	## prompts will result in initializing a different dialogue or 
	## in a function such as starting a battle or changing inventory items
	current_line_index = -1;
	lines = init_lines


func fork(fork_lines:Array[Array]):
	current_line_index = -1;
	lines = fork_lines;
	next_line();

func start_dialogue():
	choices_box.hide();
	show()
	next_line()

func next_line():
	var next_line:DialogueLine = await current_dialogue.get_next_dialogue_line("start")
	print(next_line.responses);
	while next_line:
		next_line = await current_dialogue.get_next_dialogue_line(next_line.next_id)
		if "responses" in next_line:
			print(next_line.responses);
		
