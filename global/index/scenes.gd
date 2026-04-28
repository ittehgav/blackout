extends Node

class_name SceneIndex
## breaking them down in unique scripts so they can be autocompleted/asserted more easily
@export var ui:UISceneIndex
@export var items:ItemSceneIndex;


## TODO unexport full-scenario scenes and make them load in-context from paths
## unless it doesn't take up that much more RAM?
@export_group("Scenarios")
#@export var in_settlement:PackedScene;
@export var arena:PackedScene;
@export var world_map:PackedScene;


@export_group("Units/Fighters")
@export var fighter_unit:PackedScene;
@export var npc_fighter:PackedScene;

@export_group("Misc")
@export var combat_stats:PackedScene
@export var vehicles:Array[PackedScene]
@export var player_body:PackedScene;
