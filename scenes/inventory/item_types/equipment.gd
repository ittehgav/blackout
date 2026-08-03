@abstract 
class_name Equipment
extends Item

@onready var player:Player = Entities.player;
@export var status:Status;

signal equipped
