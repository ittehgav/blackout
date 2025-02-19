extends Button

class_name DialogueChoice;

@export var label:RichTextLabel

func build(new_text):
	const line_height = 48;
	const chars_per_line = 38;
	label.text = new_text;
	var total_lines = len(new_text)/chars_per_line
	if total_lines == 0:total_lines = 1;
	custom_minimum_size.y = line_height * total_lines + 5
