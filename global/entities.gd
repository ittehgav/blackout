extends Node


var main:Node;
var main_bgm:AudioStreamPlayer;

var player:Player;
var in_fight_player:InFightPlayer;
var in_map_player:InMapPlayer;

var arena:Arena;
var world_map:WorldMap;

var current_settlement:Settlement;
var current_speaking_party:MapParty;

var dialogue_player:DialoguePlayer;

var map_entity_under_mouse:MapEntity;

func clear_map_entity_under_mouse():
	map_entity_under_mouse = null
