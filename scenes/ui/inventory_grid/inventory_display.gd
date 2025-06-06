extends Control
class_name InventoryDisplay

signal warnings_shown;
signal warnings_attended(clear:bool)

signal item_picked_up;
signal resources_changed(resource:String, amount:int)
signal item_dropped(mirror:ItemMirror);
signal invalid_move(message:String);

signal extension_shown;
signal extension_hidden;

@export_enum("player_sheet", "trade", "loot")var context:String="player_sheet";

## warning takes up the whole screen so it needs to be the immediate child of a control
## that does that
@export var warnings_popup:Control;
var liquid_item_mirrors:Array[ItemMirror];
var warnings:Dictionary[String, bool] = {
	"liquid_discard":false,
	"loot_discard":false
}


@export var resource_picker:Control;

@export var item_mirrors_node:Control;

@export var grid_cell_scene:PackedScene;
@export var item_mirror_scene:PackedScene;

@export var grid:GridContainer;
@export var sfx:AudioStreamPlayer;
@export var hover_sfx:AudioStreamPlayer;
@export var warning_label:Label;

@export var send_rect:ColorRect;
var size_x:int;
var size_y:int;

@export var x_extension:int=0;
@export var y_extension:int=0;

var extended_size_x:int;
var extended_size_y:int;

var inventory:Inventory;

const grid_cell_size = 48;

var grid_cols:Array[Array];

@onready var original_position:Vector2 = position;

@export var from_player:bool=true;

var extending_elements:bool;
var extending_projection:bool;

@export var exchanging_display:InventoryDisplay;

@export var trade_excess:PanelContainer;
@export var trade_excess_container:VBoxContainer;

@export var trade_excess_label_panel:PanelContainer;
@export var trade_excess_label:Label;


@export_group("Resource Icons")
@export var resources_vbox:VBoxContainer;

@export var money_icon:ResourceIcon;
@export var money_hbox:HBoxContainer;
@export var money_label:Label

@export var food_icon:ResourceIcon;
@export var food_hbox:HBoxContainer;
@export var food_label:Label;

@export var fuel_icon:ResourceIcon;
@export var fuel_hbox:HBoxContainer;
@export var fuel_label:Label;

@export var juice_icon:ResourceIcon;
@export var juice_hbox:HBoxContainer;
@export var juice_label:Label;

@export var scrap_icon:ResourceIcon;
@export var scrap_hbox:HBoxContainer;
@export var scrap_label:Label;

@export var chips_icon:ResourceIcon;
@export var chips_hbox:HBoxContainer;
@export var chips_label:Label;

var all_mirrors:Array[ItemMirror];

var food_containers:Array[ItemMirror]
var fuel_containers:Array[ItemMirror]

var juice_containers:Array[ItemMirror]
var scrap_containers:Array[ItemMirror]
var chips_containers:Array[ItemMirror]

var held_item_mirror:ItemMirror;



var grid_set:bool=false;

var traded_back:int;

func add_mirror(mirror:ItemMirror)->void:
	item_mirrors_node.add_child(mirror);
	all_mirrors.append(mirror);

func remove_mirror(mirror:ItemMirror)->void:
	all_mirrors.erase(mirror)
	mirror.queue_free();



func _ready()->void:
	if context == "player_sheet":
		inventory = Entities.player.inventory;
		set_grid();
		
			
		
	for r:String in Index.all_resources:
		var icon:ResourceIcon = self[r+"_icon"];
		if r != "money":
			icon.mouse_entered.connect(highlight_resource_containers.bind(r))
			icon.mouse_exited.connect(clear_resource_container_highlights.bind(r))

func set_grid()->void:
	if not grid_set:
		size_x = inventory.capacity_x;
		size_y = inventory.capacity_y;
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
				
		send_rect.size = Vector2(size_x * grid_cell_size, size_y * grid_cell_size);
		if not from_player:
			send_rect.position = grid.position - Vector2(size_x * grid_cell_size, 0);

		grid_set = true;
		
		
	for r:String in Index.all_resources:
		var icon:ResourceIcon = self[r+"_icon"];


			


func refresh_data(hard_reset:bool=false)->void:
	if hard_reset:
		for r:String in Index.all_resources:
			self[r+"_label"].text = str(inventory[r]);
		clear_item_mirrors();
		
		var unplaced:Array[Item];
		for item:Item in inventory.items:
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
		exchanging_display.send_rect.hide()
		var excess:int = trade_excess_container.get_child_count();
		if excess:
			trade_excess_label_panel.show()
			trade_excess_label.text = "+" + str(excess);
		else:
			trade_excess_label_panel.hide();
	
		for r:String in Index.all_resources:
			if r != "money":
				var hbox:HBoxContainer = self[r+"_hbox"]
				if not inventory[r] and not (exchanging_display and exchanging_display.inventory[r]):
					hbox.hide()
				else:
					hbox.show();
	
	liquid_item_mirrors = []
	reset_warnings();

	for item_mirror:ItemMirror in all_mirrors:
		item_mirror.refresh()
		if "raw_stack" in item_mirror.item and "mirror_only" in item_mirror.item:
			liquid_item_mirrors.append(item_mirror);
			warnings["liquid_discard"] = true;
	
	if context == "loot":
		if inventory == Entities.player.inventory:
			if len(exchanging_display.all_mirrors):
				warnings["loot_discard"] = true;
		else:
			if len(all_mirrors):
				exchanging_display.warnings["loot_discard"] = true;
	refresh_container_mirrors();
	refresh_extension()

func refresh_container_mirrors()->void:
	for r:String in Index.all_resources:
		if r != "money": 
			self[r+"_containers"].clear()

	for c:Node in all_mirrors:
		assert(c is ItemMirror)
		if c.item is ResourceContainer:
			self[c.item.resource+"_containers"].append(c);


			
func clear_item_mirrors()->void:
	for r:String in Index.all_resources:
		if r != "money":
			var array:Array[ItemMirror] = self[r+"_containers"];
			array.clear();
	
	while len(all_mirrors):
		remove_mirror(all_mirrors[0])
	
	for item:Item in inventory.items:
		item.mirror = null;

func mirror_item(item:Item, unplaced:Array[Item]=[])->void:
	if item.inventory_position == Vector2(-1, -1):
		if item != Entities.player.equipped_weapon and\
		item != Entities.player.alternative_weapon and\
		item != Entities.player.equipped_module:
			unplaced.append(item);
		return;

	var mirror:ItemMirror = generate_mirror(item);
	mirror.inventory_position = item.inventory_position;
	add_mirror(mirror)
	mirror.refresh()

func generate_mirror(item:Item)->ItemMirror:
	var mirror:ItemMirror = item_mirror_scene.instantiate();
	mirror.display = self;
	mirror.load_item(item, true);
	return mirror;
	
		
func highlight_resource_containers(resource:String)->void:
	for mirror:ItemMirror in self[resource+"_containers"]:
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

func throw_mirror(item_mirror:ItemMirror, add_to_grid:bool=false, allow_extend:bool=false)->void:
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
				if add_to_grid:
					add_mirror(item_mirror)
					item_mirror.refresh();
					return
				return;
	item_mirror.inventory_position = Vector2(-1, -1)

func receive_resource(amount:int, resource:String)->void:
	resources_changed.emit(resource, amount);
	amount = store_resource(amount, resource);
	while amount:
		var raw_stack:ResourceContainer = Index[resource+"_stack_scene"].instantiate();
		if raw_stack.capacity >= amount or "mirror_only" in raw_stack:
			raw_stack.stack_size = amount;
			amount = 0;
		else:
			raw_stack.stack_size = raw_stack.capacity;
			amount -= raw_stack.capacity;
			
		var mirror:ItemMirror = generate_mirror(raw_stack);
		throw_mirror(mirror, true);
		item_dropped.emit(mirror, "trade")




func send_resource(source:ItemMirror, amount:int)->void:
	if amount == source.stack_size and "raw_stack" in source.item:
		send_item(source, true);
		exchanging_display.resources_changed.emit(source.item.resource, source.stack_size);
	else:
		source.stack_size -= amount;
		source.highlight_stack_label()
		item_dropped.emit(source, "trade");
		exchanging_display.receive_resource(amount, source.item.resource);
	resources_changed.emit(source.item.resource, amount * -1);
		
func send_item(item_mirror:ItemMirror, trade:bool = false, new_instance:bool=false)->void:
	all_mirrors.erase(item_mirror)

	if not exchanging_display.receive_item(item_mirror,trade, new_instance):
		all_mirrors.append(item_mirror)


func receive_item(item_mirror:ItemMirror,trade:bool, new_instance:bool)->bool:
	## make this only apply to empty containers and non-resources?


	var spot:Vector2i = find_clear_cell(item_mirror.item)
	if spot == Vector2i(-1, -1):
		if inventory == Entities.player.inventory:
			if context == "loot":
				send_item(item_mirror);
				## NOTWORKDSADPIOJAPF´~IAJWEF´~OPEAIWJ
				invalid_move.emit("NOT ENOUGH ROOM");
				return false
			else:
				if new_instance: 
					trade_excess_container.add_child(item_mirror);
				else:
					item_mirror.reparent(trade_excess_container);
	else:
		if not new_instance:
			item_mirror.reparent(item_mirrors_node, false);
			all_mirrors.append(item_mirror)
		else:
			add_mirror(item_mirror)

	item_mirror.display = self;
	item_mirror.being_traded = not item_mirror.being_traded;
	
	item_mirror.inventory_position = spot
	if trade:
		item_dropped.emit(item_mirror, "trade");
	else:
		sfx.play_sound_by_key("loot")
		item_dropped.emit(item_mirror, "loot");
	return true

func find_clear_cell(item:Item, allow_expand:bool=false)->Vector2i:
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
	

func check_item_fit(item:Item, spot:Vector2, allow_expand:bool=false)->bool:
	for x:int in range(item.size_x):
		for y:int in range(item.size_y):
			var cell_x:int = spot.x + x;
			var cell_y:int = spot.y + y;
			if not inside_grid(Vector2(cell_x, cell_y), allow_expand):
				return false;
			var cell:InventoryGridCell = grid_cols[cell_x][cell_y];

			if cell.filled and is_instance_valid(cell.filling_item_mirror) and cell.filling_item_mirror != item.mirror:
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
	
	if exchanging_display:
		exchanging_display.send_rect.hide();
		item_mirror.send_on_drop = false;
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
				if exchanging_display:
					var mirror_shape:Rect2 = Rect2(item_mirror.global_position, item_mirror.size);
					var exchanging_display_shape:Rect2 = Rect2(exchanging_display.send_rect.global_position, exchanging_display.send_rect.size);
					if mirror_shape.intersects(exchanging_display_shape):
						item_mirror.droppable = true;
						item_mirror.send_on_drop = true;
						exchanging_display.send_rect.show();
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
	


func inside_grid(coords:Vector2, extended:bool = false)->bool:
	if coords.x < 0 or coords.y < 0:
		return false;
	if extended:
		if coords.x >= extended_size_x or coords.y >= extended_size_y:
			return false;
	else:
		if coords.x >= size_x or coords.y >= size_y:
			return false;
	return true;



func sort_inventory()->void:
	inventory.sort_items();
	
	refresh_data(true)
	sfx.play_sound_by_key("reset")
	board_shake(10, .5)

func store_resource(amount:int, resource:String)->int:
	var initial_amount:int = amount;
	var remaining:int = amount;
	if inventory.holder is Settlement or inventory.holder is NpcLeader:
		var storage:ResourceContainer = inventory.holder[resource+"_storage"];
		storage.mirror.stack_size += amount;
		storage.mirror.highlight_stack_label();
		return 0;
		
	var containers:Array[ItemMirror] = self[resource+"_containers"].filter(\
		func(mirror:ItemMirror)->bool:return not "raw_stack" in mirror.item);

	containers.sort_custom(sort_container_mirrors);

	for container_mirror:ItemMirror in containers:
		if remaining:
			if container_mirror.space_left():
				if container_mirror.space_left() >= remaining:
					container_mirror.stack_size += remaining;
					container_mirror.highlight_stack_label();
					play_deposit_sfx(remaining, resource);
					if context == "trade":
						item_dropped.emit(container_mirror, "trade")
					elif context == "loot":
						item_dropped.emit(container_mirror, "loot")
					elif context == "player_sheet":
						item_dropped.emit(container_mirror);
					remaining = 0;
				else:
					var to_add:int = container_mirror.space_left();
					container_mirror.stack_size += to_add
					container_mirror.highlight_stack_label();
					remaining -= to_add
					if context == "trade":
						item_dropped.emit(container_mirror, "trade")
					elif context == "loot":
						item_dropped.emit(container_mirror, "loot")
					elif context == "player_sheet":
						item_dropped.emit(container_mirror);

	if initial_amount != remaining:
		play_deposit_sfx((remaining - initial_amount) * -1, resource)
	return remaining;
		
func sort_by_capacity(a:ResourceContainer, b:ResourceContainer)->bool:
	return a.capacity > b.capacity;


func update_inventory()->void:
	## applies the movements/changes to the inventory itself
	## right now also auto-sorts it because it covers a lot of problems i dont wanna think of
	var new_inventory:Array[Item];
	
	for item_mirror:Node in all_mirrors:
		
		item_mirror.item.inventory_position = item_mirror.inventory_position;
		new_inventory.append(item_mirror.item);
		if item_mirror.item in inventory.items:
			item_mirror.item.stack_size = item_mirror.stack_size;
		else:
			item_mirror.item.reparent(inventory);

	var to_remove:Array[Item];
	for item:Item in inventory.items:
		## an array for equipped items instead of this?
		if not item in new_inventory and not(\
		item == Entities.player.equipped_weapon\
		or item == Entities.player.equipped_module\
		or item == Entities.player.alternative_weapon):
			## if item is mirrored in the other display, it will be 
			## sent over when that inventory is updated
			to_remove.append(item);

	for item:Item in to_remove:
		inventory.remove_item(item)
	inventory.refresh_resource_counts("", 0, true);

	
		
			
func _on_item_dropped(_mirror:ItemMirror, from:String="move") -> void:
	if held_item_mirror:
		held_item_mirror.held = false;
		held_item_mirror = null;
		
	if from == "trade" or from == "loot":
		if exchanging_display.held_item_mirror:
			exchanging_display.held_item_mirror.held = false;
			exchanging_display.held_item_mirror = null
		if from == "trade":
			sfx.play_sound_by_key("trade")
	
			
	clear_hovered_cells()
	
	if exchanging_display:
		exchanging_display.refresh_data()
	refresh_data(from=="sort");
	board_shake(5)

func _on_item_picked_up() -> void:
	board_shake(3)

func board_shake(intensity:int, return_duration:float=.1)->void:
	var to_shake:Array = [item_mirrors_node, grid]
	
	var x_shift:int = randi_range(-intensity, intensity)
	var y_shift:int = randi_range(-intensity, intensity)
	var shift: = Vector2(x_shift, y_shift);
	var tween:Tween = create_tween();
	for node:Control in to_shake:
		node.position += shift;
		tween.parallel().tween_property(node, "position", Vector2(0, 0), return_duration )
	send_rect.hide();


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

func pending_warnings()->bool:
	for key:String in warnings.keys():
		if warnings[key]:
			return true;
	return false

func warn_player()->void:
	warnings_popup.show_warnings();
	warnings_shown.emit();
	
func reset_warnings()->void:
	for key:String in warnings.keys():
		warnings[key] = false;
		
		
func play_deposit_sfx(amount_deposited:int, resource:String)->void:
	match resource:
		"food":
			if amount_deposited <= 10:
				sfx.play_sound_by_key("deposit_food_small");
			else:
				sfx.play_sound_by_key("deposit_food_big");
		"fuel", "juice":
			if amount_deposited <= 10:
				sfx.play_sound_by_key("deposit_liquid_small");
			else:
				sfx.play_sound_by_key("deposit_liquid_big");
		"scrap":
			if amount_deposited <= 10:
				sfx.play_sound_by_key("deposit_scrap_small");
			else:
				sfx.play_sound_by_key("deposit_scrap_big")
		"chips":
			sfx.play_sound_by_key("deposit_chips")



func sort_container_mirrors(a:ItemMirror, b:ItemMirror)->bool:
	if a.item.capacity > b.item.capacity:
		return true;
	elif b.item.capacity > a.item.capacity:
		return false;
	return a.stack_size > b.stack_size;
