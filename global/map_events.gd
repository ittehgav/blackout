extends Node


func battle_speaking_party():
	var enemy_party:MapParty = Entities.current_speaking_party;
	
	var arena:Arena = Entities.world_map.arena_scene.instantiate();
	arena.start_battle(enemy_party.leader)
	## figure out how this will show up on top of map
	## prob just a mask?

	

	
func yield_resources(to_lose:Array=["fuel","money","food"], fraction:float=.5):
	print("yield")
	pass
