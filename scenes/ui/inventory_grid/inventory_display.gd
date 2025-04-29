extends Control



@export var item_mirrors_node:Control;

@export var grid_cell_scene:PackedScene;
@export var item_mirror_scene:PackedScene;

@export var grid:GridContainer;
@export var sfx:AudioStreamPlayer;

@export var size_x:int;
@export var size_y:int;

var current_inventory:Inventory;

const grid_cell_size = 48;

var grid_rows:Array[Array];

func _ready()->void:
	grid.columns = size_x;
	for y in size_y:
		grid_rows.append([])
		for x in size_x:
			var cell = grid_cell_scene.instantiate();
			grid.add_child(cell);
			cell.mouse_entered.connect(sfx.play_sound_by_key.bind("cell_hover"))
			grid_rows[y].append(cell);



func refresh_data():
	if not current_inventory:
		current_inventory = Entities.player.inventory;
	load_inventory(current_inventory)

func load_inventory(inventory:Inventory=Entities.player.inventory)->void:
	if not current_inventory:
		current_inventory = inventory;
	## loaded inventories are guaranteed to fit in the space when loaded in here
	## and to have an their inventory_spot set properly
	for cell in grid.get_children():
		cell.empty_cell();
	
	for c in item_mirrors_node.get_children():
		c.queue_free();
	
	var unplaced:Array[Item]
	for item in inventory.get_children():
		add_item(item, unplaced);
	
	for item:Item in unplaced:
		throw_in_inventory(item);

func throw_in_inventory(item:Item):
	## finds the top-left-most spot where the item fits
	## if there's no room it just skips it rn
	for y in len(grid_rows):
		for x in len(grid_rows[y]):
			var cell = grid_rows[y][x]
			if not cell.filled:
				if check_item_fit(item, Vector2(x, y)):
					item.inventory_position = Vector2(x, y);
					add_item(item);
					return



func check_item_fit(item:Item, spot:Vector2)->bool:
	for x in range(item.size_x):
		for y in range(item.size_y):
			var cell = grid_rows[spot.y + y][spot.x + x];
			if cell.filled:
				return false;
	return true

func add_item(item:Item, unplaced:Array[Item]=[])->void:

	if item.inventory_position == Vector2(-1, -1):
		unplaced.append(item);
		return;
		
	var mirror:TextureRect = item_mirror_scene.instantiate();
	mirror.load_item(item)
	item_mirrors_node.add_child(mirror)
	mirror.position = item.inventory_position * grid_cell_size
	fill_cells(mirror)

func fill_cells(item_mirror:ItemMirror)->void:
	var item = item_mirror.item;
	for x in item.size_x:
		for y in item.size_y:
			grid_rows[y + item.inventory_position.y][x + item.inventory_position.x].fill_cell(item_mirror)

func clear_cells(item:Item)->void:
	for x in item.size_x:
		for y in item.size_y:
			grid_rows[y + item.inventory_position.y][x + item.inventory_position.x].empty_cell()

func project_item_mirror(item_mirror:ItemMirror, silent=false):
	if not item_mirror.just_picked_up:
		sfx.play_sound_by_key("cell_hover")
	else:
		item_mirror.just_picked_up = false;
	clear_hovered_cells()
	
	var to_hover:Array = [];
	var origin:Vector2i = item_mirror.inventory_position;
	var items_under:Array[ItemMirror];
	for x in item_mirror.item.size_x:
		for y in item_mirror.item.size_y:
			var coords_x = origin.x + x;
			var coords_y = origin.y + y
			
			
			if coords_x < size_x and coords_y < size_y:
				var cell = grid_rows[coords_y][coords_x]
				if not cell.filled:
					to_hover.append(cell);
				else:
					var filling_item = cell.filling_item;
					if not filling_item in items_under:
						items_under.append(cell.filling_item);
					item_mirror.droppable = false;
			else:
				item_mirror.droppable = false

	if len(items_under) == 1:
		item_mirror.item_under = items_under[0]

	for cell in to_hover:
		cell.hover();



func clear_hovered_cells():
	for row in grid_rows:
		for cell in row:
			cell.release();
	
