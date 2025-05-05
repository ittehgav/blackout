extends Control
class_name InventoryDisplay

signal item_picked_up;
signal item_dropped;

signal extension_shown;
signal extension_hidden;

@export_enum("player_sheet", "trade")var context:String="player_sheet";

@export var item_mirrors_node:Control;

@export var grid_cell_scene:PackedScene;
@export var item_mirror_scene:PackedScene;

@export var grid:GridContainer;
@export var sfx:AudioStreamPlayer;
@export var hover_sfx:AudioStreamPlayer;

var size_x:int;
var size_y:int;

var extended_size_x:int;
var extended_size_y:int;

var current_inventory:Inventory;

const grid_cell_size = 48;

var grid_cols:Array[Array];

@onready var original_position = position;

var extending_elements:bool;
var extending_projection:bool;

@export_group("Resource Icons")
@export var resources_vbox:VBoxContainer;

@export var money_icon:ResourceIcon;

@export var food_icon:ResourceIcon;
@export var food_hbox:HBoxContainer;

@export var fuel_icon:ResourceIcon;
@export var fuel_hbox:HBoxContainer;

@export var juice_icon:ResourceIcon;
@export var juice_hbox:HBoxContainer;

@export var scrap_icon:ResourceIcon;
@export var scrap_hbox:HBoxContainer;

@export var chips_icon:ResourceIcon;
@export var chips_hbox:HBoxContainer;

var food_containers:Array[ItemMirror]
var fuel_containers:Array[ItemMirror]

var juice_containers:Array[ItemMirror]
var scrap_containers:Array[ItemMirror]
var chips_containers:Array[ItemMirror]

func _ready()->void:
	if context == "player_sheet":
		current_inventory = Entities.player.inventory;
		set_grid();

func set_grid()->void:
	size_x = current_inventory.capacity_x;
	size_y = current_inventory.capacity_y;
	extended_size_x = size_x * 2;
	extended_size_y = size_y;
	
	grid.columns = size_x;
	var rows:Array[Array];
	for y in extended_size_y:
		## gotta add them left-to-right because that's the order the gridContainer aligns them
		rows.append([]);
		for x in extended_size_x:
			var cell = grid_cell_scene.instantiate();
			grid.add_child(cell);
			cell.mouse_entered.connect(hover_sfx.play)
			rows[y].append(cell);
			if x >= size_x or y > size_y:
				cell.extension_bg.show();

	for i in extended_size_x:
		grid_cols.append([]);
	
	for row in rows:
		for i in len(grid_cols):
			grid_cols[i].append(row[i])
			
	
	for r in Index.all_resources:
		var icon:ResourceIcon = self[r+"_icon"];
		icon.source = current_inventory;
		icon.setup_adjacent_items(current_inventory[r]);
		if r != "money":
			icon.mouse_entered.connect(highlight_resource_containers.bind(r))
			icon.mouse_exited.connect(clear_resource_container_highlights.bind(r))
			


func refresh_data():
	if not current_inventory:
		## gets called again after load_inventory
		current_inventory = Entities.player.inventory;
	for col in grid_cols:
		for cell in col:
			cell.empty_cell();
	extending_elements = false;

	
	for r in Index.all_resources:
		if r != "money":
			var hbox = self[r+"_hbox"]
			if not current_inventory[r]:
				hbox.hide()
			else:
				hbox.show();

	var unplaced:Array[Item]
	for item in current_inventory.get_children():
		mirror_item(item, unplaced);

	for item:Item in unplaced:
		throw_in_inventory(item);

	refresh_extension()

func highlight_resource_containers(resource:String)->void:
	for mirror:ItemMirror in self[resource+"_containers"]:
		mirror.highlight_item()

func clear_resource_container_highlights(resource:String)->void:
	for mirror:ItemMirror in self[resource+"_containers"]:
		mirror.undo_container_highlight();


func refresh_extension():
	if extending_projection or extending_elements:
		show_extension();
	else:
		hide_extension()

	
func hide_extension():
	resources_vbox.show()
	grid.columns = size_x
	for i in range(extended_size_x - size_x):
		var col = grid_cols[i + size_x];
		for cell:ReferenceRect in col:
			cell.hide();
		for i2 in range(extended_size_y - size_y):
			col[i2 + size_y].hide();
	extension_hidden.emit()

func show_extension():
	resources_vbox.hide();
	grid.columns = extended_size_x
	for col in grid_cols:
		for cell in col:
			cell.show();
	extension_shown.emit();





func throw_in_inventory(item:Item):
	## finds the top-left-most spot where the item fits
	## if there's no room it just skips it rn
	for x in len(grid_cols):
		for y in len(grid_cols[x]):
			var cell = grid_cols[x][y]
			if not cell.filled:
				if check_item_fit(item, Vector2(x, y)):
					item.inventory_position = Vector2(x, y);
					mirror_item(item);
					return
	


func check_item_fit(item:Item, spot:Vector2, allow_expand=true)->bool:
	var limit_x:int;
	var limit_y:int;
	if allow_expand:
		limit_x = extended_size_x;
		limit_y = extended_size_y;
	else:
		limit_x = size_x;
		limit_y = size_y;
	
	for x in range(item.size_x):
		for y in range(item.size_y):
			var cell_x = spot.x + x;
			var cell_y = spot.y + y;
			if cell_x == 3 and cell_y == 4:
				var cell = grid_cols[3][4];

			if cell_x >= limit_x or cell_y >= limit_y:
				return false;
			var cell = grid_cols[cell_x][cell_y];
			if cell.filled and cell.filling_item.item != item:
				return false;
	return true

func mirror_item(item:Item, unplaced:Array[Item]=[], first_open=false)->void:
	var new_mirror:bool;
	if item.inventory_position == Vector2(-1, -1):
		if item != Entities.player.equipped_weapon and\
		item != Entities.player.alternative_weapon and\
		item != Entities.player.equipped_module:
			unplaced.append(item);
		new_mirror = true;

		return;

	var mirror:ItemMirror
	if item.mirror:
		mirror = item.mirror;
	else:
		mirror = item_mirror_scene.instantiate();
		mirror.inventory_display = self;
		mirror.load_item(item)
		
		item_mirrors_node.add_child(mirror)
		new_mirror = true
	
	mirror.refresh()
	
	mirror.modulate.a = 1;
	if item.inventory_position.x + item.size_x > size_x or item.inventory_position.y > size_y:
		mirror.modulate.a = .75;
		extending_elements = true;
	
	if new_mirror:
		if item is ResourceContainer:
			self[item.resource+"_containers"].append(mirror);
	


func fill_cells(item_mirror:ItemMirror)->void:
	var item = item_mirror.item;
	for x in item.size_x:
		for y in item.size_y:
			grid_cols[x + item.inventory_position.x][y + item.inventory_position.y].fill_cell(item_mirror)

func clear_cells(item:Item)->void:
	for x in item.size_x:
		for y in item.size_y:
			grid_cols[x + item.inventory_position.x][y + item.inventory_position.y].empty_cell()

func project_item_mirror(item_mirror:ItemMirror):
	if not item_mirror.just_picked_up:
		## doesn't play sound for the first projection
		hover_sfx.play()
	else:
		item_mirror.just_picked_up = false;

	clear_hovered_cells()
	var inventory_position = item_mirror.item.inventory_position;
	
	## place shadow on origin cells
	for x in item_mirror.item.size_x:
		for y in item_mirror.item.size_y:
			grid_cols[x + inventory_position.x][y + inventory_position.y].held_item_shadow(item_mirror)
	
	var to_hover:Array[Vector2] = [];
	var origin:Vector2i = item_mirror.inventory_position;
	var items_under:Array[ItemMirror];
	
	extending_projection = false;
	
	for x in item_mirror.item.size_x:
		for y in item_mirror.item.size_y:
			## sweep region occupied by item, checking if it's possble 
			## to place it on that exact spot
			var coords_x = origin.x + x;
			var coords_y = origin.y + y
			
			if coords_x < extended_size_x and coords_y < extended_size_y\
			 and coords_x > -1 and coords_y > -1:
			
				if coords_x >= size_x or coords_y >= size_y:
					extending_projection = true;
				
				var cell:InventoryGridCell = grid_cols[coords_x][coords_y]
				if not cell.filled:
					## fills an array with the cells that will be highlighted if droppable
					var coords = Vector2(coords_x, coords_y)
					to_hover.append(coords);
	
				else:
					## catches all overlapping items
					var filling_item = cell.filling_item;
					if not filling_item in items_under:
						items_under.append(cell.filling_item);
					item_mirror.droppable = false;
			else:
				item_mirror.droppable = false

	if len(items_under) == 1:
		item_mirror.item_under = items_under[0]

	elif len(items_under) > 1 and item_mirror.item is ResourceContainer:
		var same_resource_item_mirrors:Array = [];
		
		for item_mirror_under:ItemMirror in items_under:
			if item_mirror_under.item is ResourceContainer and\
			item_mirror_under.item.resource == item_mirror.item.resource:
				same_resource_item_mirrors.append(item_mirror_under)
				
		if len(same_resource_item_mirrors) == 1:
			item_mirror.item_under = same_resource_item_mirrors[0];
	
	item_mirror.vacant_spot_offset = Vector2.ZERO;
	if not item_mirror.droppable:
		item_mirror.modulate.a = .5
		var vacant_spot = find_adjacent_vacant_spot(item_mirror);
		if vacant_spot != Vector2i(-1, -1):
			item_mirror.droppable = true;
			item_mirror.vacant_spot_offset = vacant_spot - item_mirror.inventory_position ;
			for x in item_mirror.item.size_x:
				for y in item_mirror.item.size_y:
					var cell_x = vacant_spot.x + x;
					var cell_y = vacant_spot.y + y
					if cell_x >= size_x or cell_y >= size_y:
						extending_projection = true;
					var cell = grid_cols[cell_x][cell_y];
					cell.hover();
	else:
		for cell:Vector2 in to_hover:
			grid_cols[cell.x][cell.y].hover()
	refresh_extension()
	

func find_adjacent_vacant_spot(item_mirror:ItemMirror)->Vector2i:
	var angles_to_check = [
		Vector2i.UP,
		Vector2i.RIGHT,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i(-1, -1),
		Vector2i(1, -1),
		Vector2i(1, 1),
		Vector2i(-1, -1)
	];
	
	for angle in angles_to_check:
		var spot = item_mirror.inventory_position + angle;
		if not(spot.x < 0 or spot.y < 0 or spot.x >=\
		 extended_size_x or spot.y >= extended_size_y):
			if check_item_fit(item_mirror.item, spot, true):
				return spot
	return Vector2i(-1, -1);
	


func clear_hovered_cells():
	for col in grid_cols:
		for cell in col:
			cell.release();
	


func _on_item_dropped() -> void:
	clear_hovered_cells()
	refresh_data();
	
	const shake_range = 5;
	var x_shift = randi_range(-shake_range, shake_range)
	var y_shift = randi_range(-shake_range, shake_range)
	
	position += Vector2(x_shift, y_shift);
	var tween = create_tween();
	tween.tween_property(self, "position", original_position, .1);


func _on_item_picked_up() -> void:
	const shake_range = 3
	var x_shift = randi_range(-shake_range, shake_range)
	var y_shift = randi_range(-shake_range, shake_range)
	
	position += Vector2(x_shift, y_shift);
	var tween = create_tween();
	tween.tween_property(self, "position", original_position, .1);
