extends Control
class_name InventoryDisplay

signal item_picked_up;
signal item_dropped(mirror:ItemMirror);
signal invalid_move(message:String);

signal extension_shown;
signal extension_hidden;

@export_enum("player_sheet", "trade")var context:String="player_sheet";

@export var resource_picker:Control;

@export var item_mirrors_node:Control;

@export var grid_cell_scene:PackedScene;
@export var item_mirror_scene:PackedScene;

@export var grid:GridContainer;
@export var sfx:AudioStreamPlayer;
@export var hover_sfx:AudioStreamPlayer;
@export var warning_label:Label;

@export var trade_rect:ColorRect;
var size_x:int;
var size_y:int;

@export var x_extension:int=0;
@export var y_extension:int=0;

var extended_size_x:int;
var extended_size_y:int;

var current_inventory:Inventory;

const grid_cell_size = 48;

var grid_cols:Array[Array];

@onready var original_position:Vector2 = position;

@export var from_player:bool=true;

var extending_elements:bool;
var extending_projection:bool;

@export var trading_display:InventoryDisplay;

@export var trade_excess:PanelContainer;
@export var trade_excess_container:VBoxContainer;

@export var trade_excess_label_panel:PanelContainer;
@export var trade_excess_label:Label;


@export_group("Resource Icons")
@export var resources_vbox:VBoxContainer;

@export var money_icon:ResourceIcon;
@export var money_hbox:HBoxContainer;

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

var held_item_mirror:ItemMirror;


var traded_in_items:Array[Item];

var grid_set:bool=false;

var traded_back:int;

func _ready()->void:
	if context == "player_sheet":
		current_inventory = Entities.player.inventory;
		set_grid();

func set_grid()->void:
	if not grid_set:
		size_x = current_inventory.capacity_x;
		size_y = current_inventory.capacity_y;
		extended_size_x = size_x + x_extension;
		extended_size_y = size_y + y_extension;
		
		grid.columns = size_x;
		var rows:Array[Array];
		for y in extended_size_y:
			## gotta add them left-to-right because that's the order the gridContainer aligns them
			rows.append([]);
			for x in extended_size_x:
				var cell:InventoryGridCell = grid_cell_scene.instantiate();
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
				
		trade_rect.size = Vector2(size_x * grid_cell_size, size_y * grid_cell_size);
		if not from_player:
			trade_rect.position = grid.position - Vector2(size_x * grid_cell_size, 0);

		if from_player:
			trade_rect.get_node("operation").text = "BUY";
		else:
			trade_rect.get_node("operation").text = "SELL";
		grid_set = true;
		
		
	for r:String in Index.all_resources:
		var icon:ResourceIcon = self[r+"_icon"];
		icon.source = current_inventory;
		icon.setup_adjacent_items(current_inventory[r]);
		if r != "money":
			icon.mouse_entered.connect(highlight_resource_containers.bind(r))
			icon.mouse_exited.connect(clear_resource_container_highlights.bind(r))
			


func refresh_data(hard_reset:bool=false)->void:
	if hard_reset:
		clear_item_mirrors();
		var unplaced:Array[Item];
		for item:Item in current_inventory.get_children():
			mirror_item(item, unplaced);
		for item:Item in unplaced:
			throw_in_inventory(item);

	
	for col:Array in grid_cols:
		for cell:InventoryGridCell in col:
			cell.empty_cell();
			
	extending_elements = false;
	extending_projection = false;
	
	if context == "trade":
		## one display uses  the other one's trade rect 
		trading_display.trade_rect.hide()
		var excess:int = trade_excess_container.get_child_count();
		if excess:
			trade_excess_label_panel.show()
			trade_excess_label.text = "+" + str(excess);
		else:
			trade_excess_label_panel.hide();
	
	for r:String in Index.all_resources:
		if r != "money":
			var hbox:HBoxContainer = self[r+"_hbox"]
			if not current_inventory[r] and not (trading_display and trading_display.current_inventory[r]):
				hbox.hide()
			else:
				hbox.show();
	
	for item_mirror:ItemMirror in item_mirrors_node.get_children():
		item_mirror.refresh()
	
	refresh_extension()

func clear_item_mirrors()->void:
	for r:String in Index.all_resources:
		if r != "money":
			var array:Array[ItemMirror] = self[r+"_containers"];
			array.clear();

	for c:ItemMirror in item_mirrors_node.get_children() + trade_excess_container.get_children():
		c.free();
	for item:Item in current_inventory.get_children():
		item.mirror = null;

func mirror_item(item:Item, unplaced:Array[Item]=[])->void:
	if item.inventory_position == Vector2(-1, -1):
		if item != Entities.player.equipped_weapon and\
		item != Entities.player.alternative_weapon and\
		item != Entities.player.equipped_module:
			unplaced.append(item);
		return;

	var mirror:ItemMirror = item_mirror_scene.instantiate();
	mirror.display = self;
	mirror.load_item(item, true)
	mirror.inventory_position = item.inventory_position;
	item_mirrors_node.add_child(mirror)
	
	if item is ResourceContainer:
		self[item.resource+"_containers"].append(mirror);
	mirror.refresh()

func highlight_resource_containers(resource:String)->void:
	for mirror:ItemMirror in self[resource+"_containers"]:
		if mirror.is_inside_tree():
			mirror.highlight_item()

func clear_resource_container_highlights(resource:String)->void:
	for mirror:ItemMirror in self[resource+"_containers"]:
		mirror.undo_container_highlight();


func refresh_extension()->void:
	if extending_projection or extending_elements:
		show_extension();
	else:
		hide_extension()

	
func hide_extension()->void:
	resources_vbox.show()
	grid.columns = size_x
	for i in range(extended_size_x - size_x):
		var col:Array = grid_cols[i + size_x];
		for cell:ReferenceRect in col:
			cell.hide();
		for i2:int in range(extended_size_y - size_y):
			col[i2 + size_y].hide();
	extension_hidden.emit()

func show_extension()->void:
	resources_vbox.hide();
	grid.columns = extended_size_x
	for col:Array in grid_cols:
		for cell:InventoryGridCell in col:
			cell.show();
	extension_shown.emit();


func throw_in_inventory(item:Item)->void:
	## finds the top-left-most spot where the item fits
	## if there's no room it just skips it rn
	for x in len(grid_cols):
		for y in len(grid_cols[x]):
			if check_item_fit(item, Vector2(x, y)):
				item.inventory_position = Vector2(x, y);
				mirror_item(item);
				return

func throw_mirror(item_mirror:ItemMirror, allow_extend:bool=true)->void:
	var x_limit:int;
	var y_limit:int;
	if allow_extend:
		x_limit = extended_size_x;
		y_limit = extended_size_y;
	else:
		x_limit = size_x;
		y_limit = size_y;
	
	for x:int in x_limit:
		for y:int in y_limit:
			if check_item_fit(item_mirror.item, Vector2i(x, y)):
				item_mirror.inventory_position = Vector2i(x, y)
				return;


func collect_resource(resource:String, amount:int)->Array[ItemMirror]:
	## INTERACT WITH INV DISPLAY NOT WITH THE NUMBER ITSELF
	var mirrors:Array[ItemMirror]
	var containers:Array[ItemMirror]
	for c in item_mirrors_node.get_children() + trade_excess_container.get_children():
		if c.item is ResourceContainer and c.item.resource == resource:
			containers.append(c);

	var to_collect:int = amount;
	
	containers.sort_custom(sort_container_mirrors);
	containers.reverse()
	
	## picks up from traded in containers first
	containers = containers.filter(func(c:ItemMirror)->bool:return c.being_traded) + containers.filter(func(c:ItemMirror)->bool:return not c.being_traded);
	traded_back = 0;
	var i:int = 0;
	## CAN ONLY RUN IF THERE'S ENOUGH
	while to_collect:
		## item stacks may turn to 0 here and be cleared when refreshed
		var mirror:ItemMirror = containers[i];
		i += 1;
		mirrors.append(mirror)
		if mirror.item.stack_size - mirror.traded_resource_amount >= to_collect:
			if mirror.being_traded:
				traded_back += to_collect
			mirror.traded_resource_amount += to_collect;
			to_collect = 0;
		else:
			if mirror.being_traded:
				traded_back += mirror.item.stack_size - mirror.traded_resource_amount
			to_collect -= mirror.item.stack_size - mirror.traded_resource_amount;
			mirror.item.check_empty();
			mirror.traded_resource_amount = mirror.item.stack_size;

	return mirrors;

func sort_container_mirrors(a:ItemMirror, b:ItemMirror)->bool:
	if a.item.capacity > b.item.capacity:
		return true
	elif a.item.capacity <= b.item.capacity:
		return false;

	return a.item.stack_size - a.traded_resource_amount > b.item.stack_size - b.traded_resource_amount;

func trade_resource(resource:String, amount:int)->void:
	var mirrors:Array[ItemMirror] = collect_resource(resource, amount);
	for mirror:ItemMirror in mirrors:
		mirror.refresh();
	
	amount -= traded_back;
	while traded_back:
		var mirror:ItemMirror = generate_container_mirror(resource, traded_back, true);
		traded_back -= mirror.item.stack_size - mirror.traded_resource_amount;
		trade_item(mirror, true);
	
	while amount:
		var mirror:ItemMirror = generate_container_mirror(resource, amount)
		amount -= mirror.item.stack_size - mirror.traded_resource_amount;
		trade_item(mirror, true)

func generate_container_mirror(resource:String, amount:int, being_traded:bool=false)->ItemMirror:
	var raw_stack:ResourceContainer = Index[resource+"_stack_scene"].instantiate();
	if "mirror_only" in raw_stack:
		raw_stack.stack_size = amount;
	else:
		if raw_stack.capacity >= amount:
			raw_stack.stack_size = amount;
		else:
			raw_stack.stack_size = raw_stack.capacity;
	
	var mirror:ItemMirror = item_mirror_scene.instantiate();
	mirror.display = self;
	mirror.load_item(raw_stack, true);
	mirror.being_traded = being_traded
	mirror.set_price()
	return mirror;
	
		
func trade_item(item_mirror:ItemMirror, new_instance:bool=false)->void:
	if item_mirror.being_traded:
		traded_in_items.erase(item_mirror.item);
	trading_display.recieve_traded_item(item_mirror, new_instance)
	refresh_data()


	
func recieve_traded_item(item_mirror:ItemMirror, new_instance:bool)->void:
	item_mirror.display = self;
	item_mirror.being_traded = not item_mirror.being_traded;
	
	if item_mirror.being_traded:
		traded_in_items.append(item_mirror.item);
	
	var spot:Vector2i = find_clear_cell(item_mirror.item)
	if spot == Vector2i(-1, -1):
		if new_instance: 
			trade_excess_container.add_child(item_mirror);
		else:
			item_mirror.reparent(trade_excess_container);
	else:
		if not new_instance:
			item_mirror.reparent(item_mirrors_node, false);
		else:
			item_mirrors_node.add_child(item_mirror);

	item_mirror.inventory_position = spot
	item_dropped.emit(item_mirror, "trade");

func find_clear_cell(item:Item, allow_expand:bool=true)->Vector2i:
	## traded items are anchored at the bottom of the inventory display
	if not from_player:
		for x:int in len(grid_cols):
			var col:Array = grid_cols[len(grid_cols) - x - 1];
			for y:int in len(col):
				var spot:Vector2i;
				if item.mirror.being_traded:
					spot = Vector2i(len(grid_cols)-x-1, len(col)-y-1)
				else:
					spot = Vector2i(len(grid_cols)-x-1, y)
				if check_item_fit(item, spot, allow_expand):
					return spot
	else:
		for x:int in len(grid_cols):
			var col:Array= grid_cols[x];
			for y:int in len(col):
				
				var spot:Vector2i;
				if item.mirror.being_traded:
					spot = Vector2i(x, len(col)-y-1)
				else:
					spot = Vector2i(x, y)
				if check_item_fit(item, spot, false):
					return spot;
	return Vector2i(-1, -1);
	

func check_item_fit(item:Item, spot:Vector2, allow_expand:bool=true)->bool:
	for x:int in range(item.size_x):
		for y:int in range(item.size_y):
			var cell_x:int = spot.x + x;
			var cell_y:int = spot.y + y;
			if not inside_grid(Vector2(cell_x, cell_y), allow_expand):
				return false;
			var cell:InventoryGridCell = grid_cols[cell_x][cell_y];

			if cell.filled and is_instance_valid(cell.filling_item_mirror) and cell.filling_item_mirror.item != item:
				return false;
	return true



func fill_cells(item_mirror:ItemMirror)->void:
	var item:Item = item_mirror.item;
	for x:int in item.size_x:
		for y:int in item.size_y:
			grid_cols[x + item_mirror.inventory_position.x][y + item_mirror.inventory_position.y].fill_cell(item_mirror)

func clear_cells(item_mirror:ItemMirror)->void:
	for x:int in item_mirror.item.size_x:
		for y:int in item_mirror.item.size_y:
			grid_cols[x + item_mirror.inventory_position.x][y + item_mirror.inventory_position.y].empty_cell()


func project_item_mirror(item_mirror:ItemMirror)->void:
	if not item_mirror.just_picked_up:
		## doesn't play sound for the first projection
		hover_sfx.play()
	else:
		item_mirror.just_picked_up = false;

	clear_hovered_cells()
	var inventory_position:Vector2 = item_mirror.inventory_position;
	
	## place shadow on origin cells
	for x:int in item_mirror.item.size_x:
		for y:int in item_mirror.item.size_y:
			grid_cols[x + inventory_position.x][y + inventory_position.y].held_item_shadow()
	
	var to_hover:Array[Vector2] = [];
	var origin:Vector2i = item_mirror.projection_position;
	var items_under:Array[ItemMirror];
	
	extending_projection = false;
	
	if trading_display:
		trading_display.trade_rect.hide();
		item_mirror.trade_on_drop = false;
	for x:int in item_mirror.item.size_x:
		for y:int in item_mirror.item.size_y:
			## sweep region occupied by item, checking if it's possble 
			## to place it on that exact spot
			var coords_x:int = origin.x + x;
			var coords_y:int = origin.y + y
			
			if inside_grid(Vector2(coords_x, coords_y)):
				if coords_x >= size_x or coords_y >= size_y:
					extending_projection = true;
				
				var cell:InventoryGridCell = grid_cols[coords_x][coords_y]
				if not cell.filled or cell.filling_item_mirror == item_mirror:
					## fills an array with the cells that will be highlighted if droppable
					var coords:Vector2 = Vector2(coords_x, coords_y)
					to_hover.append(coords);
	
				else:
					item_mirror.droppable = false;
					## catches all overlapping items
					var filling_item_mirror:ItemMirror = cell.filling_item_mirror;
					
					if not filling_item_mirror in items_under:
						items_under.append(cell.filling_item_mirror);
			else:
				if trading_display:
					var mirror_shape:Rect2 = Rect2(item_mirror.global_position, item_mirror.size);
					var trading_display_shape:Rect2 = Rect2(trading_display.trade_rect.global_position, trading_display.trade_rect.size);
					if mirror_shape.intersects(trading_display_shape):
						item_mirror.droppable = true;
						item_mirror.trade_on_drop = true;
						trading_display.trade_rect.show();
					else:
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
		var vacant_spot:Vector2i = find_adjacent_vacant_spot(item_mirror);
		if vacant_spot != Vector2i(-1, -1):
			item_mirror.droppable = true;
			item_mirror.vacant_spot_offset = vacant_spot - item_mirror.projection_position;
			for x:int in item_mirror.item.size_x:
				for y:int in item_mirror.item.size_y:
					var cell_x:int = vacant_spot.x + x;
					var cell_y:int = vacant_spot.y + y
					if cell_x >= size_x or cell_y >= size_y:
						extending_projection = true;
					var cell:InventoryGridCell = grid_cols[cell_x][cell_y];
					cell.hover();
	else:
		for cell:Vector2 in to_hover:
			grid_cols[cell.x][cell.y].hover()
	refresh_extension()

func find_adjacent_vacant_spot(item_mirror:ItemMirror)->Vector2i:
	var angles_to_check:Array[Vector2i] = [
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
		var spot:Vector2i = item_mirror.projection_position + angle;
		if not(spot.x < 0 or spot.y < 0 or spot.x >=\
		 extended_size_x or spot.y >= extended_size_y):
			if check_item_fit(item_mirror.item, spot, true):
				return spot
	return Vector2i(-1, -1);
	
func clear_hovered_cells()->void:
	for col in grid_cols:
		for cell:InventoryGridCell in col:
			cell.release();
	


func inside_grid(coords:Vector2, extended:bool = true)->bool:
	if coords.x < 0 or coords.y < 0:
		return false;
	if extended:
		if coords.x >= extended_size_x or coords.y >= extended_size_y:
			return false;
	else:
		if coords.x >= size_x or coords.y >= size_y:
			return false;
	return true;

func show_resource_picker(item:Item)->void:
	resource_picker.show_picker(item.resource);

func sort_inventory()->void:
	store_all_resources(false);
	current_inventory.sort_items();
	if current_inventory.get_child_count():
		item_dropped.emit(current_inventory.get_child(0).mirror, "sort")
	sfx.play_sound_by_key("reset")

func store_all_resources(from_command:bool=true)->void:
	for r:String in Index.all_resources:
		if r != "money":
			var total:int = current_inventory[r];
			var containers:Array[ResourceContainer] = current_inventory.containers.filter(func(c:ResourceContainer)->bool:return c.resource == r)
			containers.sort_custom(func(a:ResourceContainer, b:ResourceContainer)->bool:return a.capacity>b.capacity);
			for c:ResourceContainer in containers:
				if "raw_stack" in c:
					c.mirror.free();
					c.free();
					continue
				c.stack_size = 0;
				if total:
					if c.capacity >= total:
						c.mirror.highlight_stack_label()
						c.stack_size = total;
					else:
						c.mirror.highlight_stack_label()
						c.stack_size = c.capacity;
					total -= c.stack_size
			if total:
				## only ever gets here for non-liquids right:
				while total:
					var stack:ResourceContainer = Index[r + "_stack_scene"].instantiate();
					if stack.capacity >= total:
						stack.stack_size = total;
					else:
						stack.stack_size = stack.capacity;
					total -= stack.stack_size
					current_inventory.add_child(stack);
					throw_in_inventory(stack);
					
	if from_command and len(current_inventory.containers):
		item_dropped.emit(current_inventory.containers[0]);
		
func sort_by_capacity(a:ResourceContainer, b:ResourceContainer)->bool:
	return a.capacity > b.capacity;


func update_inventory()->void:
	var items:Array[Node] = current_inventory.get_children();
	var trading_party_items:Array = trading_display.item_mirrors_node.get_children() + trading_display.trade_excess_container.get_children()
	for item:Item in items:
		if item.mirror in trading_party_items:
			item.reparent(trading_display.current_inventory);

	for item_mirror:ItemMirror in item_mirrors_node.get_children() + trade_excess_container.get_children():
		item_mirror.item.inventory_position = item_mirror.inventory_position;
		if not item_mirror.item in items:
			item_mirror.item.reparent(current_inventory);
	sort_inventory();
		
			
func _on_item_dropped(_mirror:ItemMirror, from:String="move") -> void:
	if held_item_mirror:
		held_item_mirror.held = false;
		held_item_mirror = null;
	if trading_display.held_item_mirror:
		trading_display.held_item_mirror.held = false;
		trading_display.held_item_mirror = null
	
	if from == "trade":
		sfx.play_sound_by_key("trade")
	clear_hovered_cells()
	
	refresh_data(from=="sort");
	
	const shake_range = 5;
	var x_shift:int = randi_range(-shake_range, shake_range)
	var y_shift:int = randi_range(-shake_range, shake_range)
	var shift:Vector2 = Vector2(x_shift, y_shift);
	
	position += shift;
	
	var tween:Tween = create_tween();
	tween.tween_property(self, "position", original_position, .1);
	
	trade_rect.hide();


func _on_item_picked_up() -> void:
	const shake_range = 3
	var x_shift:int = randi_range(-shake_range, shake_range)
	var y_shift:int = randi_range(-shake_range, shake_range)
	
	var shift:Vector2 = Vector2(x_shift, y_shift)
	
	position += shift;
	
	var tween:Tween = create_tween();
	tween.tween_property(self, "position", original_position, .1);


func _on_invalid_move(message:String="") -> void:
	sfx.play_sound_by_key("invalid")
	if held_item_mirror:
		held_item_mirror.held = false;
		held_item_mirror = null;
	if message:
		var label:Label = warning_label.duplicate()
		label.text = message;
		add_child(label);
		
		label.global_position = get_global_mouse_position() - Vector2(0, 10);
		if label.global_position.x + label.size.x >= get_window().size.x:
			label.position.x -= label.size.x;

		var tween:Tween = create_tween();
		tween.tween_property(label, "position:y", label.position.y - 20, 1.5);
		tween.parallel().tween_property(label, "modulate:a", 0, 1.5);
		tween.tween_callback(label.free)
	
	refresh_data();

func _on_trade_excess_label_panel_mouse_entered() -> void:
	trade_excess.show()


func _on_trade_excess_label_panel_mouse_exited() -> void:
	trade_excess.hide()
