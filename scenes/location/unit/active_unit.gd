extends CharacterBody2D;

class_name ActiveUnit

signal started_moving;
signal stopped_moving;

@export var sprite:Sprite2D;

## combat stats will be in ActiveFighter
var move_speed:float = 500.0;

var moving:bool=false;
