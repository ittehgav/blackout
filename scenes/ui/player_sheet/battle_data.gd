extends MarginContainer

@export var player_party_power_icon:PartyPowerIcon;
@export var enenmy_party_power_icon:PartyPowerIcon;
@export var enemy_name_label:Label;



func _on_player_sheet_pre_battle_started(enemy_name:String, enemy_roster:NpcRoster) -> void:
	enemy_name_label.text = enemy_name
	player_party_power_icon.refresh();
	
	enenmy_party_power_icon.source = enemy_roster
	enenmy_party_power_icon.refresh();

	
