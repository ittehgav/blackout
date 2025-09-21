extends Button

class_name DialogueChoice;

var callback:Callable;
 
@export var icon_rect:TextureRect;
@export var label:RichTextLabel

func build(response:DialogueResponse)->void:
	const line_height = 50;

	var new_text:String = response.text;
	if new_text[0] == "#":
		build_option(new_text)
	else:
		label.text = new_text;
	await label.draw
	var line_count:int = label.get_line_count();

	custom_minimum_size.y = line_height * line_count + 20
	

func parse_dialogue_response(response_text:String)->String:
	var final_text:String = response_text;
	return final_text

func build_option(text:String)->void:
	icon_rect.show();
	label.add_theme_font_size_override("normal_font_size", 64);
	var option_color:Color = Color.WHITE
	match text:
		"#trade_menu":
			option_color = Color.LIGHT_GREEN + Color.from_hsv(0, 0, .2)
			
			icon_rect.texture = Index.textures.icons.trade;
			callback = Dialogue.start_trade;
			label.text = "Trade"
		"#recruitment_menu":
			icon_rect.texture = Index.textures.icons.recruit
			label.text = "Recruit Units"
			callback = Dialogue.start_recruitment;
		"#leave":
			icon_rect.texture = Index.textures.icons.exit
			label.text = "Leave"
	
	if option_color != Color.WHITE:
		icon_rect.modulate = option_color;
		label.add_theme_color_override("default_color", option_color)
		self_modulate = Color.WHITE.blend(option_color) + Color.from_hsv(0, 0, .3)
