extends TileMapLayer

@export var buffer:TileMapLayer;

const off_road_sight = 3;
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

func reveal_path(path:PackedVector2Array)->void:
	var to_clear:PackedVector2Array
	for cell:Vector2i in path:
		for x in range(-off_road_sight, off_road_sight):
			for y in range(-off_road_sight, off_road_sight):
				var target_cell:Vector2i = Vector2i(cell.x + x, cell.y + y)
				erase_cell(target_cell);
				to_clear.append(target_cell);
	var tween:Tween = create_tween();
	tween.tween_property(buffer, "modulate:a", 0, 1);
	tween.tween_callback(refresh_buffer.bind(to_clear))

func refresh_buffer(to_clear:PackedVector2Array)->void:
	for cell:Vector2i in to_clear:
		buffer.erase_cell(cell);
	buffer.modulate.a = 1;
