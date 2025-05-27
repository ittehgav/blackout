extends Node2D
class_name WorldMapQuadrant;

@export var quadrant_n:int;

@export var small_props_node:Node2D;
@export var props_node:Node2D;

@export var tile_map:TileMapLayer;
@export var fog_tile_map:TileMapLayer
@export var off_sight_tile_map:TileMapLayer;

@export_group("boundaries")
@export var top_boundary:Area2D
@export var right_boundary:Area2D

@export var top_boundary_shape:CollisionShape2D;
@export var right_boundary_shape:CollisionShape2D;


@export_group("relative quadrants")
@export var x_adjacent_quadrant:WorldMapQuadrant
@export var y_adjacent_quadrant:WorldMapQuadrant;
@export var diagonal_quadrant:WorldMapQuadrant;

func _ready()->void:
	## COLLISION LAYER 9 = WORLD MAP QUADRANT BORDER HITBOXES
	var map_size:Vector2 = get_parent().quarter_tile_map_size;
	var cell_size:float = get_parent().cell_size
	
	top_boundary.position = Vector2.ZERO;
	top_boundary_shape.shape.a = Vector2.ZERO;
	top_boundary_shape.shape.b = Vector2(map_size.x*cell_size,0);

	right_boundary.position = Vector2(map_size.x*cell_size, 0);
	right_boundary_shape.shape.b = Vector2(0, map_size.y*cell_size);


	for x in map_size.x:
		for y in map_size.y:
			fog_tile_map.set_cell(Vector2i(x, y), 0, Vector2.ZERO);
			off_sight_tile_map.set_cell(Vector2i(x, y), 0, Vector2.ZERO);
	



func _on_top_boundary_body_exited(body: Node2D) -> void:
	if body is MapParty:
		if is_ancestor_of(body):
			if body.global_position.y < top_boundary.global_position.y:
				## shifting up
				## exiting to quadrant above
				## signal fires BEFORE reparenting
				body.quadrant_changed.emit(y_adjacent_quadrant, Vector2.UP);
				body.call_deferred("reparent", y_adjacent_quadrant, false)
				adjust_position_quadrant_shift(body, Vector2.UP)
		else:
			if body.global_position.y > top_boundary.global_position.y:
				## shifting down
				## entering from quadrant above
				## signal fires BEFORE reparenting
				body.quadrant_changed.emit(self, Vector2.DOWN);
				body.call_deferred("reparent", self, false)
				adjust_position_quadrant_shift(body, Vector2.DOWN)


func _on_right_boundary_body_exited(body: Node2D) -> void:
	assert(body is MapParty)
	if body is MapParty:
		if is_ancestor_of(body):
			if body.global_position.x > right_boundary.global_position.x:
				## shifting left
				## exiting to the left quadrant
				## signal fires BEFORE reparenting
				body.quadrant_changed.emit(x_adjacent_quadrant, Vector2.RIGHT)
				body.call_deferred("reparent", x_adjacent_quadrant, false);
				adjust_position_quadrant_shift(body, Vector2.RIGHT)
		else:
			if body.global_position.x < right_boundary.global_position.x:
				## shifting right
				## entering from the left quadrant
				## signal fires BEFORE reparenting
				body.quadrant_changed.emit(self, Vector2.LEFT)
				body.call_deferred("reparent", self, false)
				adjust_position_quadrant_shift(body, Vector2.LEFT)


func adjust_position_quadrant_shift(target:MapParty, direction:Vector2)->void:
	## will make the unit move in the opposite direction until next target refresh if the quadrant makes them move around the map
	## which is not that big of a deal since it'll mostly happen off screen?
	var quadrants:WorldMapPlane = Entities.world_map.quadrants;
	match direction:
		Vector2.UP:
			var y_shift:float = quadrants.quarter_tile_map_size.y * quadrants.cell_size;
			target.position.y += y_shift;
		Vector2.RIGHT:
			var x_shift:float = quadrants.quarter_tile_map_size.x * quadrants.cell_size;
			target.position.x -= x_shift;
		Vector2.DOWN:
			var y_shift:float = quadrants.quarter_tile_map_size.y * quadrants.cell_size;
			target.position.y -= y_shift;
		Vector2.LEFT:
			var x_shift:float = quadrants.quarter_tile_map_size.x * quadrants.cell_size;
			target.position.x += x_shift;
