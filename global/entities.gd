extends Node


var main:Main;
var main_bgm:AudioStreamPlayer;
var current_camera:Camera2D;

var main_hud:UIRoot

var current_area:Node2D;

var player:Player;
var player_unit:CombatEntity;
var player_fighter:PlayerFighter;
var player_party:PlayerParty;

var loading_screen:LoadingScreen;

var player_sheet:PlayerSheet;

var current_dungeon:Dungeon;

var arena:Arena;
var world_map:WorldMap;
var road:RoadGrid;


var pre_battle:UIRoot
var dialogue_player:DialoguePlayer;
