extends TileMapLayer

@export var buffer:TileMapLayer;
@export var over_horizon:TileMapLayer

@export var road:TileMapLayer

@export var player_party:PlayerParty;
@export var world_map:WorldMap

func _ready()->void:
	await world_map.ready;
	refresh_fog();

func refresh_fog(current_settlement:Settlement=player_party.current_settlement)->void:
	for settlement:Settlement in current_settlement.neighbor_paths.keys():
		reveal_path(current_settlement.neighbor_paths[settlement])
		if not settlement.data.seen:
			settlement.reveal();

const off_road_sight = 8;
const horizon_gap:int = 2;
@onready var horizon_limits: = set_horizon_limits();
func set_horizon_limits()->Array[int]:
	var limits:Array[int];
	for i in range(off_road_sight - horizon_gap, off_road_sight + 1):
		limits.append(i)
		limits.append(-i)
	return limits;
func reveal_path(path:PackedVector2Array)->void:
	var to_clear:PackedVector2Array
	for cell:Vector2i in path:
		var converted_cell:Vector2i = local_to_map(road.map_to_local(cell) * road.scale.x) /scale.x
		for x in range(-off_road_sight, off_road_sight):
			for y in range(-off_road_sight, off_road_sight):
				var target_cell:Vector2i = Vector2i(converted_cell.x + x, converted_cell.y + y)
				over_horizon.erase_cell(target_cell)
				if not (x in horizon_limits) and not (y in horizon_limits):
					erase_cell(target_cell);
					to_clear.append(target_cell);

					
				
	var tween:Tween = create_tween();
	tween.tween_property(buffer, "modulate:a", 0, 1);
	tween.tween_callback(refresh_buffer.bind(to_clear))

func refresh_buffer(to_clear:PackedVector2Array)->void:
	for cell:Vector2i in to_clear:
		buffer.erase_cell(cell);
	buffer.modulate.a = 1;
