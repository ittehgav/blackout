extends PanelContainer

@export var inventory_space_label:Label;
@export var level_label:Label;

@onready var player:Player = get_tree().get_first_node_in_group("player")

func _ready()->void:
	await player.ready;
	player.inventory.changed.connect(refresh)
	refresh()

func refresh()->void:
	var inventory:Inventory = Entities.player.inventory;
	var total_space:int = inventory.capacity_x * inventory.capacity_y
	var space_taken:int = inventory.taken_space()
	inventory_space_label.text = str(space_taken) + "/" + str(total_space)
	

	var level:int = Entities.player.get_party_level()
	level_label.text = str(level)
