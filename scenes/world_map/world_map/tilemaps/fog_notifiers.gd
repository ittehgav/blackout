extends Node2D
class_name FogNotifierContainer;
## idk it was slow and buggy and this isnt that urgent we just leave it like it was before


## doesnt even need to see the camera?
## use a dictionary to keep track of cells for each layer of fog
## refresh quadrant on position of notifier
## notifiers need to be bigger than regions they cover


@export var tilemaps:Array[TileMapLayer];

var tilemaps_maps:Dictionary[TileMapLayer, Array];## Dictionary[TileMapLayer, Array[Vector2]];
## Array containing which fog cells are NOT FILLED
var loaded_spots:Array[Vector2i]
const fog_cell_coords = Vector2.ZERO

func _enter_tree() -> void:
	## initiating this before entering tree so theres no race conditions
	## and it automatically matches the exported arrays
	for map:TileMapLayer in tilemaps:
		tilemaps_maps[map] = []

func load_fog(notifier:VisibleOnScreenNotifier2D)->void:
	const x_range = 120;
	const y_range = 68;
	var grid_spot:Vector2i = tilemaps[0].local_to_map(notifier.position);
	var spots:PackedVector2Array = []
	for x:int in x_range:
		for y:int in y_range:
			var spot:Vector2i = Vector2(grid_spot) - Vector2(x - x_range/2, y - y_range/2)
			if not spot in loaded_spots:
				spots.append(spot);
				loaded_spots.append(spot);

	for tilemap:TileMapLayer in tilemaps:
		var map:Array = tilemaps_maps[tilemap]
		for spot:Vector2i in spots:
			if not map.has(spot):
				tilemap.set_cell(spot, 0, fog_cell_coords);


@onready var base_notifier_size:Vector2 = get_window().size * 4
const base_notifier_position = Vector2(-2560, -1440)
const notifier_spacing = Vector2(3840, 2160)

@export var notifiers:Dictionary[Vector2i, VisibleOnScreenNotifier2D]
func notifier_seen(spot: Vector2i) -> void:
	const spot_deltas = [
		Vector2i(-1, -1),
		Vector2i(0, -1),
		Vector2i(1, -1),
		Vector2i(1, 0),
		Vector2i(1, 1),
		Vector2i(0, 1),
		Vector2i(-1, 1),
		Vector2i(-1, 0),
	]
	var notifier:VisibleOnScreenNotifier2D = notifiers[spot];
	load_fog(notifier)
	for delta:Vector2i in spot_deltas:
		var new_spot:= spot + delta;
		if not notifiers.has(new_spot):
			var new_notifier:= VisibleOnScreenNotifier2D.new()
			new_notifier.rect = notifier.rect;
			notifiers[new_spot] = new_notifier;
			new_notifier.position = base_notifier_position + (notifier_spacing * Vector2(new_spot));
			new_notifier.screen_entered.connect(notifier_seen.bind(new_spot))
			new_notifier.name = "notifier "+str(new_spot.x) + " " +str(new_spot.y)
			add_child.call_deferred(new_notifier)

func clear_cells(target:TileMapLayer, cells:PackedVector2Array)->void:
	## catches cleanly all clearance of cells in and out of loaded array?
	var map:Array = tilemaps_maps[target];
	for cell:Vector2 in cells:
		if not map.has(cell):
			map.append(cell);
			if cell in loaded_spots and target.get_cell_atlas_coords(cell) != Vector2i(-1, -1):
				target.erase_cell(cell)
