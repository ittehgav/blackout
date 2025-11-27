extends TileMapLayer

func check_target_in_range(source:IsoFighter)->bool:
	var source_hex:Vector2i = local_to_map(source.global_position);
	var target_hex:Vector2i = local_to_map(source.target.global_position);
	return hex_distance(source_hex, target_hex) <= source.range;

func hex_distance(pos_a: Vector2i, pos_b: Vector2i) -> int:
	# Godot’s hex layout is axial:
	#   q = pos.x
	#   r = pos.y
	#   s = -q - r   (cube coordinate)
	var aq:int = pos_a.x
	var ar:int = pos_a.y
	var as_:int = -aq - ar

	var bq:int = pos_b.x
	var br:int = pos_b.y
	var bs:int = -bq - br

	# Cube distance
	return (abs(aq - bq) + abs(ar - br) + abs(as_ - bs)) / 2
