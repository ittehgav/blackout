extends Node2D

class_name Settlement;



## assigned before roads are generated
var neighbors:Array[Settlement];

## used for pathfinding 
var neighbor_paths:Dictionary[Settlement, PackedVector2Array];

@export var sprite:Sprite2D;
var buildings:Array[Building];
@export var hover_box:Control;

func _ready()->void:
	name = NameDatabase.generate_name();

func _on_child_entered_tree(node: Node) -> void:
	if node is Building:
		remove_child.call_deferred(node)
		buildings.append(node)


func _on_hover_box_mouse_entered() -> void:
	Entities.world_map.settlement_hovered.emit(self)


func _on_hover_box_mouse_exited() -> void:
	Entities.world_map.settlement_mouse_exited.emit();

func player_started_moving()->void:
	hover_box.hide();

func player_stopped_moving()->void:
	hover_box.show();


func _on_hover_box_pressed() -> void:
	Entities.player_party.move_to_settlement(self);
