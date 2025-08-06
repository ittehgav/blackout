extends Node2D

class_name Settlement;

@export var data:SettlementData;
@export var sprites:Dictionary[String, Texture];

## assigned before roads are generated
var neighbors:Array[Settlement];

## used for pathfinding 
var neighbor_paths:Dictionary[Settlement, PackedVector2Array];

@export var sprite:Sprite2D;
var buildings:Array[Building];

@export var hover_box:Control;
@export var hint:Label;

func _ready()->void:
	name = NameDatabase.generate_name();
	ColorCoder.color_code_settlement(self)

func _on_child_entered_tree(node: Node) -> void:
	if node is Building:
		remove_child.call_deferred(node)
		buildings.append(node)


func _on_hover_box_mouse_entered() -> void:
	material.set_shader_parameter("width", 1)
	Entities.world_map.settlement_hovered.emit(self)


func _on_hover_box_mouse_exited() -> void:
	material.set_shader_parameter("width", 0)
	Entities.world_map.settlement_mouse_exited.emit();

func player_started_moving()->void:
	hover_box.hide();

func player_stopped_moving()->void:
	hover_box.show();


func _on_hover_box_pressed() -> void:
	if self != Entities.player_party.current_settlement:
		Entities.player_party.move_to_settlement(self);

func reveal()->void:
	hint.hide();
	hover_box.show();
	data.seen = true;
	for neighbor:Settlement in neighbor_paths.keys():
		if neighbor != Entities.player_party.current_settlement:
			if not neighbor.data.seen:
				neighbor.hint.show()
