extends Node


func battle_speaking_party()->void:
	Entities.pre_battle.start_pre_battle();

	

	
func yield_resources(to_lose:Array=["fuel","money","food"], fraction:float=.5)->void:
	Entities.world_map.unpause_map()
	print("yield")
	pass


func scare_speaking_party()->void:
	pass


func pacify_speaking_party()->void:
	pass
