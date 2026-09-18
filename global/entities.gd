extends Node

## ENTITIES
## UNIQUE NODES THAT WILL ONLY BE REACHED FOR WHEN READY
## ONLY ONE OF EACH EVER
## PLAYER NODE IS NOT AN ENTITY BC IT'S CALLED FOR ALL THE TIME
## AND CAN MAKE RACE CONDITIONS

## use for holding on to references of nodes
## that don't stay in the tree all the time?
## therefore never used on f6 runs
## only for simplifying state transitions?

var main:Main;

var player:Player:
	get():
		if not player:
			player = get_tree().get_first_node_in_group("player");
		return player

var player_fighter:PlayerFighter:
	get():
		if not player_fighter:
			player_fighter = get_tree().get_first_node_in_group("player_fighter")
		return player_fighter

var player_party:PlayerParty;


var player_sheet:PlayerSheet;

var current_dungeon:Dungeon;

var arena:Arena:
	get():
		if not arena or not is_instance_valid(arena):
			arena = get_tree().get_first_node_in_group("arena");
		return arena
var world_map:WorldMap:
	get():
		if not world_map:
			world_map = get_tree().get_first_node_in_group("world_map")
		return world_map
var road:RoadGrid;


var pre_battle:UIRoot
var dialogue_player:DialoguePlayer;
