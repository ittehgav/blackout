extends Node2D

class_name Settlement;

signal player_visited;

@export var data:SettlementData;


## assigned before roads are generated
var neighbors:Array[Settlement];

## used for pathfinding 
var neighbor_paths:Dictionary[Settlement, PackedVector2Array];

@export var sprite:Sprite2D;
var locations:Array[Location];

@export var hover_box:Control;
@export var hint:Label;

@export var flag:Sprite2D

## because siblings with the same name get enumerated
var unique_name:String;

func _ready()->void:
	refresh()


func refresh()->void:
	if len(locations) == 1:
		sprite.texture = locations[0].map_texture
		name = locations[0].name
		unique_name = locations[0].name
		if locations[0] is Dungeon and locations[0].cleared:
			flag.show();
			sprite.modulate.v = .5
	else:
		## TODO somehow give them unique names?
		name = "Street"
		unique_name = "Street"

func _on_child_entered_tree(node: Node) -> void:
	if node is Location and not node in locations:
		locations.append(node)


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


func reveal()->void:
	hint.hide();
	hover_box.show();
	data.seen = true;
	for neighbor:Settlement in neighbor_paths.keys():
		if neighbor != Entities.player_party.current_settlement:
			if not neighbor.data.seen:
				neighbor.hint.show()


func _on_hover_box_pressed() -> void:
	Entities.player_party.move_to_settlement(self)


func _on_player_visited() -> void:
	refresh_buildings()
	data.seen = true;
	hover_box.hide()

func refresh_buildings()->void:
	## ONLY PLACE WHERE REFRESHES GET CALLED?
	for l:Location in locations:
		if l.pending_refresh:
			l.refresh()
