extends Node


func trade_with_speaking_party()->void:
	Entities.dialogue_player.start_trade();

func improve_speaking_party_prices()->void:
	pass

func strain_speaking_party_prices()->void:
	pass

func battle_speaking_party()->void:
	Entities.pre_battle.start_pre_battle();

func battle_lost()->void:
		print("L");

	
func yield_resources(to_lose:Array=["fuel","money","food"], fraction:float=.5)->void:
	for r:String in to_lose:
		var change:int = int(Entities.player.inventory[r]*fraction);
		if not change:
			change = -1;
		Entities.player.inventory.change_resource(r, -change);

	pacify_speaking_party();


func scare_speaking_party()->void:
	Entities.current_speaking_party.feared_entity = Entities.in_map_player;


func pacify_speaking_party()->void:
	Entities.current_speaking_party.leader.behavior = "passive";
