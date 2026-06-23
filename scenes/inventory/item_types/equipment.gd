@abstract 
class_name Equipment
extends Item

@onready var player:Player = get_tree().get_first_node_in_group("player")
@export var status:Status;

signal equipped
