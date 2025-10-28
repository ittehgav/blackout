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

func build_option(label_text:String)->void:
	icon_rect.show();
	label.add_theme_font_size_override("normal_font_size", 64);
	var option_color:Color = Color.WHITE
	match label_text:
		"#trade_menu":
			option_color = Color.LIGHT_GREEN + Color.from_hsv(0, 0, .2)
			
			icon_rect.texture = Index.textures.icons.trade;
			label.text = "Trade"
			callback = Dialogue.start_trade;
		"#recruitment_menu":
			option_color = Color.GREEN
			
			icon_rect.texture = Index.textures.icons.recruit
			label.text = "Recruit Units"
			callback = Dialogue.start_recruitment;
		"#leave":
			modulate.v = .5;
			
			icon_rect.texture = Index.textures.icons.exit
			label.text = "Leave"
			## no callback so just advances the dialogue
		"#evolution_menu":
			var tag_to_evolve:String = Dialogue.current_speaker.evolve_option;
			var tag_color:Color = Index.primary_tag_colors[tag_to_evolve]
			option_color = tag_color

			icon_rect.texture = Index.textures.icons.evolve;
			label.text = "Evolve your " + tag_to_evolve + "s";
			callback = Dialogue.evolution_menu;
			
			if len(Entities.player.roster.units.filter(func(unit:FighterUnit)->bool:return "evolutions" in unit.base and tag_to_evolve in unit.base.tags)) == 0:
				disabled = true;
				
	if option_color != Color.WHITE:
		icon_rect.self_modulate = option_color;
		label.add_theme_color_override("default_color", option_color)
		
		self_modulate = option_color
