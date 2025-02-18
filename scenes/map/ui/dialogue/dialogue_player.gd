extends Control

@export var choice_button:Button;

@export var choices_box:PanelContainer;
@export var choices_container:VBoxContainer;

@export var speaker_name_label:Label;
@export var text_label:RichTextLabel;

var current_line_index:int = -1;
var lines:Array[Array]

func _ready()->void:
	Entities.dialogue_player = self;
	

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
	current_line_index += 1;
	var line = lines[current_line_index]
	match line[0]:
		"T":
			## T = basic text, changes the text currently on display
			pass
		"S":
			## S = speaker name change, chanes the speaker's name on display,
			## and in the future also their visual?
			pass
		"P":
			## P = prompt
			load_prompt(line);
		"E":
			end_dialogue();
		## lots more to add on but keep it simple for the first demo


func load_prompt(line:Array):
	for i:int in len(line[1]):
		var choice_text:String = line[1][i];
		var choice_outcome:Callable = line[2][i]
		
		var choice = DialogueChoice.new()
		choice.load_text(choice_text);
		choice.pressed.conect(choice_outcome);
		
func end_dialogue():
	pass
