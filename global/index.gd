extends Node

var all_fighter_base_scenes:Array[PackedScene] = [
	preload("res://scenes/indexes/fighters/armguy.tscn"),
	preload("res://scenes/indexes/fighters/coilguy.tscn"),
	preload("res://scenes/indexes/fighters/crossbowguy.tscn"),
	
	preload("res://scenes/indexes/fighters/crowbarguy.tscn"),
	preload("res://scenes/indexes/fighters/doorguy.tscn"),
	preload("res://scenes/indexes/fighters/doublearmguy.tscn"),
	
	preload("res://scenes/indexes/fighters/gravityguy.tscn"),
	preload("res://scenes/indexes/fighters/mecharmguy.tscn"),
	preload("res://scenes/indexes/fighters/tailpipeguy.tscn"),
	
	preload("res://scenes/indexes/fighters/taserguy.tscn"),
	preload("res://scenes/indexes/fighters/tetherguy.tscn"),
	preload("res://scenes/indexes/fighters/wheelguy.tscn")
]

func random_fighter_base()->FighterBase:
	var base = all_fighter_base_scenes.pick_random();
	return base.instantiate();
