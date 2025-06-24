extends Button

class_name SaveFileDisplay;

signal game_saved;
signal game_loaded(data:Dictionary);

@export var delete_btn:Button;

@export var save_file_name:Label;
@export var save_file_play_time:Label;
@export var save_file_money:Label;
@export var save_file_party_size:Label;
@export var save_file_morale:Label;
@export var save_file_leadership_level:Label;
@export var save_file_combat_level:Label;

var file:String;
var file_path:String
var operation:String;

var data:Dictionary;

func load_save_file(path:String, target_operation:String = "")->void:
	file_path = path
	operation = target_operation
	file = FileAccess.get_file_as_string(path);
	if file:
		$save_data.show()
		data = JSON.parse_string(file)
		
		
		save_file_name.text = data.player.name;
		save_file_play_time.text = parse_play_time();
		
		save_file_money.text = str(int(data.player.inventory.money));
		save_file_party_size.text = str(len(data.player.roster));
		save_file_morale.text = str(data.player.morale);
		
		save_file_leadership_level.text = str(int(data.player.leadership_level));
		save_file_combat_level.text = str(int(data.player.combat_level))
	else:
		## freeing the data node so it doesn't run the ready 
		## functions of party data related nodes
		$save_data.free();
		$placeholder.show();
	match operation:
		"save":
			if file:
				delete_btn.show();
			pressed.connect(save_game);
		"load":
			disabled = not file
			pressed.connect(load_game)
		
func save_game()->void:
	if file:
		Tweens.ui_fade_out($save_data);
		Tweens.ui_fade_in($overwrite_confirmation);
	else:
		SaveSystem.save_data(file_path)
		game_saved.emit();

func parse_play_time()->String:
	var total_seconds:int = data.world.play_time;
	var total_minutes:int =0;
	var total_hours:int = 0;
	while total_seconds > 60:
		total_seconds -= 60;
		total_minutes += 1;
		if total_minutes == 60:
			total_minutes = 0;
			total_hours += 1;

	
	var final_string:String = "Play Time: ";

	if total_hours:
		final_string += str(total_hours) + "h, ";

	final_string += str(total_minutes) +"m";
	if not total_hours:
		final_string += ", " + str(total_seconds) + "s"
	
	return final_string

func load_game()->void:
	## button is disabled if there's no data to load
	Tweens.ui_fade_out($save_data);
	Tweens.ui_fade_in($load_confirmation)



func _on_pressed() -> void:
	self[operation+"_game"].call();


func _on_overwrite_pressed() -> void:
	file = "";
	save_game();


func _on_cancel_overwrite_pressed() -> void:
	Tweens.ui_fade_out($overwrite_confirmation);
	Tweens.ui_fade_in($save_data)


func _on_button_pressed() -> void:
	Tweens.ui_fade_out($save_data);
	Tweens.ui_fade_in($delete_confirmation)


func _on_delete_pressed() -> void:
	SaveSystem.delete_file(file_path)
	game_saved.emit();


func _on_cancel_delete_pressed() -> void:
	Tweens.ui_fade_out($delete_confirmation);
	Tweens.ui_fade_in($save_data)


func _on_load_pressed() -> void:
	## all of the load operation needs to be done in-context
	game_loaded.emit(data)
	

func _on_cancel_load_pressed() -> void:
	Tweens.ui_fade_in($save_data);
	Tweens.ui_fade_out($load_confirmation)
