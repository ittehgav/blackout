extends Node

class_name SceneIndex
## breaking them down in unique scripts so they can be autocompleted/asserted more easily
@export var ui:UISceneIndex
@export var front_porches:FrontPorchSceneIndex
@export var items:ItemSceneIndex;


@export_group("Game States")
@export var location:PackedScene;
@export var arena:PackedScene;
@export var world_map:PackedScene;

@export_group("Units")
@export var fighter_unit:PackedScene;
@export var npc_fighter:PackedScene;

@export_group("Misc")
@export var combat_stats:PackedScene
@export var vehicles:Array[PackedScene]
@export var player_body:PackedScene;
