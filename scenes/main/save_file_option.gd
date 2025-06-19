extends Button

@export var save_file_name:Label;
@export var save_file_play_time:Label;
@export var save_file_money:Label;
@export var save_file_party_size:Label;
@export var save_file_morale:Label;
@export var save_file_leadership_level:Label;
@export var save_file_combat_level:Label;

var data:Dictionary;

func load_save_file(path:String)->void:
	var file:String = FileAccess.get_file_as_string(path);
	data = JSON.parse_string(file)
	
	save_file_name.text = data.player.name;
	save_file_play_time.text = "erm";
	
	save_file_money.text = str(int(data.player.inventory.money));
	save_file_party_size.text = str(len(data.player.roster));
	save_file_morale.text = str(int(data.player.morale));
	
	save_file_leadership_level.text = str(int(data.player.leadership_level));
	save_file_combat_level.text = str(int(data.player.combat_level))
	show()
