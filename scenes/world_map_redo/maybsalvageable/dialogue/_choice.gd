extends Button

class_name DialogueChoice;

@export var label:RichTextLabel

func build(new_text:String)->void:
	const line_height = 50;
	label.text = new_text;
	await label.draw
	var line_count:int = label.get_line_count();

	custom_minimum_size.y = line_height * line_count + 5
