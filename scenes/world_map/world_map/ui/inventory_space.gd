extends TextureRect

@export var label:Label;
@export var player_sheet:PlayerSheet;
@export var player:Player

func _ready()->void:
	await player_sheet.ready
	refresh();
	
func refresh()->void:
	var taken_space:int = 0;
	for item:Item in player.inventory.items:
		if item not in player.equipment\
		and item not in player.roster.equipped_accessories:
			taken_space += item.size_x * item.size_y;
	
	var display:InventoryDisplay = player_sheet.player_inventory;
	var total_space:int = display.size_x * display.size_y;
	assert(total_space > taken_space);
	label.text = str(taken_space) + "/" + str(total_space)
