extends Node2D;

## gets extended by arena?
## makes it so you can fight in settlements for whatever reason
class_name Location

var building_offset:int = 0;

@export var ui:Control;

@export var buildings_node:Node2D;
@export var reloationship_data:Node;

func _ready()->void:
	## because this enters the tree from the world map when the player is 
	## in a settlement
	Entities.main.state = "location"
	get_tree().paused = false;
	Entities.current_location = self;

func load_settlement(settlement:Settlement)->void:
	for building:Building in settlement.buildings:
		## buildings are loaded in order
		load_building(building);



var previous_building:FrontPorch;
func load_building(building:Building)->void:
	var key:String = building.front_porch_key;
	var front_porch:FrontPorch = Index.scenes.front_porches[key].instantiate();
	front_porch.building = building;
	var back_side_offset:int = front_porch.position.x * -1;
	front_porch.position.x += building_offset
	if previous_building:
		front_porch.position.x += previous_building.right_side_trailing_space;
	
	buildings_node.add_child(front_porch);
	## so the left-most buildings show on top and overlap the back side of their siblings properly
	buildings_node.move_child(front_porch, 0)
	building_offset += front_porch.size.x - back_side_offset
	
	previous_building = front_porch;
