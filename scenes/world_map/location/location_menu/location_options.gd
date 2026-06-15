extends HBoxContainer

class_name LocationOptions;

signal option_chosen(building:Building, option:Building.Option);

@export var buttons:Array[Button]

@export var option_textures:Dictionary[Building.Option, Texture];
@export var option_colors:Dictionary[Building.Option, Color]

var current_options:Array[Building.Option]

var building:Building;

func load_building(target:Building)->void:
	for b:Button in buttons:
		b.hide()
	current_options.clear()
	building = target;
	opt1_extra_arg = null;
	opt2_extra_arg = null;
	opt3_extra_arg = null;
	
	var i:int = 0;
	for option:Building.Option in building.options:
		var button:Button = buttons[i];
		i += 1;
		if "opt_"+str(i)+'_arg' in building: 

			## make this a less ugly way to do this? 
			self["opt"+str(i)+"_extra_arg"] = building["opt_"+str(i)+"_arg"]
		
		current_options.append(option)
		button.show();
		
		
		button.get_node("option_image").texture = option_textures[option]
		if not building.has_use(option):
			button.get_node("option_image").modulate.v = .5
			button.disabled = true
		else:
			button.get_node("option_image").modulate = option_colors[option]

		button.self_modulate.v = 1
		
		var tooltip:Tooltip = button.get_node("Tooltip");
		tooltip.hardcoded_name = Building.Option.keys()[option].capitalize();
		tooltip.hardcoded_description = building.option_descriptions[option];
		tooltip.refresh();


var opt1_extra_arg:Variant
func _on_button_pressed() -> void:
	if opt1_extra_arg:
		option_chosen.emit(building, current_options[0], opt1_extra_arg);
	else:
		option_chosen.emit(building, current_options[0])

var opt2_extra_arg:Variant
func _on_button_2_pressed() -> void:
	if opt2_extra_arg:
		option_chosen.emit(building, current_options[1], opt2_extra_arg);
	else:
		option_chosen.emit(building, current_options[1])

var opt3_extra_arg:Variant
func _on_button_3_pressed() -> void:
	if opt3_extra_arg:
		option_chosen.emit(building, current_options[2], opt3_extra_arg);
	else:
		option_chosen.emit(building, current_options[2])
