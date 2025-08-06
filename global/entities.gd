extends Node


var main:Node;
var main_bgm:AudioStreamPlayer;
var current_camera:Camera2D;

var current_location:Location;

var player:Player;
var player_unit:ActiveUnit;
var player_fighter:InFightPlayer;
var player_party:PlayerParty;

var loading_screen:UIRoot;

var player_sheet:PlayerSheet;

var arena:Arena;
var world_map:WorldMap;
var road:RoadGrid;


var pre_battle:UIRoot
var dialogue_player:DialoguePlayer;
