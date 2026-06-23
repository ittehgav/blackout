extends Node

class_name SceneIndex
## breaking them down in unique scripts so they can be autocompleted/asserted more easily
@export var ui:UISceneIndex
@export var items:ItemSceneIndex;


## TODO unexport full-scenario scenes and make them load in-context from paths
## unless it doesn't take up that much more RAM?

@export var fighter_unit:PackedScene;
