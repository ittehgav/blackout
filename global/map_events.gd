extends Node


func trade_with_speaking_party()->void:
	Entities.dialogue_player.start_trade();

func improve_speaking_party_prices()->void:
	var inventory:Inventory = Entities.current_speaking_party.leader.inventory;
	for r:String in Index.all_resources:
		if r != "money":
			## RESOURCE SELLING PRICES = PLAYER SELLING
			inventory.resource_selling_prices[r] *= 1.1;
			## RESOUREC BUYING PRICES = PLAYER BUYING
			inventory.resource_buying_prices[r] *= .9


func strain_speaking_party_prices()->void:
	var inventory:Inventory = Entities.current_speaking_party.leader.inventory;
	for r:String in Index.all_resources:
		if r != "money":
			## RESOURCE BUYING PRICES = PLAYER BUYING
			inventory.resource_buying_prices[r] *= 1.1;
			## RESOUREC SELLING PRICES = PLAYER SELLING
			inventory.resource_selling_prices[r] *= .9

func battle_speaking_party()->void:
	Entities.pre_battle.start_pre_battle();
	## TODO follow-up dialogues from battles will have to reset the dialogue player
	Entities.dialogue_player.end_dialogue();



	
func yield_resources(to_lose:Array=["fuel","money","food"], fraction:float=.5)->void:
	for r:String in to_lose:
		var change:int = int(Entities.player.inventory[r]*fraction);
		if not change:
			change = -1;
		Entities.player.inventory.change_resource(r, -change);

	pacify_speaking_party();


func scare_speaking_party()->void:
	Entities.current_speaking_party.feared_entity = Entities.in_map_player;
	Entities.current_speaking_party.apply_party_status\
	("scared", 24, Entities.current_speaking_party.clear_feared_entity)
	Entities.current_speaking_party.find_target();


func pacify_speaking_party()->void:
	Entities.current_speaking_party.pacified = true;
	Entities.current_speaking_party.apply_party_status\
	("pacified", 25, Entities.current_speaking_party.depacify);
