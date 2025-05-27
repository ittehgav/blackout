extends Node


var main:Node;
var main_bgm:AudioStreamPlayer;

var player:Player;
var in_fight_player:InFightPlayer;
var in_map_player:InMapPlayer;

var player_sheet:PlayerSheet;

var arena:Arena;
var world_map:WorldMap;

var current_settlement:Settlement;
var current_speaking_party:NpcMapParty;
## either a Leader or a Settlement
var current_trading_party:Node;

var pre_battle:UIRoot
var dialogue_player:DialoguePlayer;

var map_entity_under_mouse:MapEntity;


func clear_map_entity_under_mouse()->void:
	map_entity_under_mouse = null
