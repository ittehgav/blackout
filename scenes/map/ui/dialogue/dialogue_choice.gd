extends Button

class_name DialogueChoice;

@export var text_label:RichTextLabel;

func load_text(choice_text:String):
	text_label.text = choice_text;
	await get_tree().process_frame;
	custom_minimum_size = text_label.get_rect().end;

	
