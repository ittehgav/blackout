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

var player:Player;

var player_fighter:PlayerFighter;
var player_party:PlayerParty;


var player_sheet:PlayerSheet;

var current_dungeon:Dungeon;

var arena:Arena;
var world_map:WorldMap;
var road:RoadGrid;


var pre_battle:UIRoot
var dialogue_player:DialoguePlayer;
