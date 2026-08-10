@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/icon_flag.png")
@tool
extends Node2D

class_name Location;

signal player_visited;

@export_tool_button("Refresh Sprite")var refresh_command:Callable = refresh_sprite;

@export var data:LocationData;
@export var street_texture:Texture;
@export var street_modulate:Color;

@onready var world_map:WorldMap = get_tree().get_first_node_in_group("world_map")

## assigned before roads are generated
@export var neighbors:Array[Location];
@export var max_neighbors:int = 3;
## if any neighbors are assigne in editor, dosnt auto-assign any

## used for pathfinding 
var neighbor_paths:Dictionary[Location, PackedVector2Array];

@export var cleared_color:Color;

@export var sprite:Sprite2D;
@export var shadow_sprite:Sprite2D
@export var settlements:Array[Settlement];

@export var hover_box:Control;
@export var hint:Label;

@export var flag:Sprite2D


## because siblings with the same name get enumerated
var unique_name:String;

func _ready()->void:
	refresh_sprite()


func refresh_sprite()->void:
	settlements.clear()
	flag.hide()
	for c:Node in get_children():
		if c is Settlement:
			settlements.append(c)
			if c.size == 3:
				sprite.texture = c.map_texture;
				shadow_sprite.texture = c.map_texture
				sprite.modulate = c.map_texture_modulate
				name = c.name
				unique_name = c.name
				if c is Dungeon and c.cleared:
					sprite.modulate = cleared_color;
					flag.show();
			else:
				if sprite.modulate != street_modulate:
					sprite.texture = street_texture
					shadow_sprite.texture = street_texture;
					sprite.modulate = street_modulate
					name = "Street"
					unique_name = "Street"

func _on_hover_box_mouse_entered() -> void:
	if Entities.player_party.current_location:
		material.set_shader_parameter("width", 1)
		world_map.location_hovered.emit(self)


func _on_hover_box_mouse_exited() -> void:
	material.set_shader_parameter("width", 0)
	world_map.location_mouse_exited.emit();

func player_started_moving()->void:
	hover_box.hide();

func player_stopped_moving()->void:
	hover_box.show();


func reveal()->void:
	hint.hide();
	hover_box.show();
	data.seen = true;
	for neighbor:Location in neighbor_paths.keys():
		if neighbor != Entities.player_party.current_location:
			if not neighbor.data.seen:
				neighbor.hint.show()


func _on_hover_box_pressed() -> void:
	Entities.player_party.move_to_location(self)


func _on_player_visited() -> void:
	refresh_settlements()
	data.seen = true;
	hover_box.hide()

func refresh_settlements()->void:
	## ONLY PLACE WHERE REFRESHES GET CALLED?
	for l:Settlement in settlements:
		if l.pending_refresh:
			l.refresh()

func room_for_neighbors()->int:
	return max_neighbors - len(neighbors)
