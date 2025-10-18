extends Control
class_name InventoryDisplay

signal warnings_shown;
signal warnings_attended(clear:bool)

signal item_received;

signal item_picked_up;
signal item_dropped(mirror:ItemMirror);
signal invalid_move(message:String);

signal accessory_equipped_on_unit;

signal opened





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
@export var unit_selector:UnitSelector;
@export var item_selector:ItemSelector;

@export var item_mirrors_node:Control;

@export var cargo:Control;

@export var grid_cell_scene:PackedScene;
@export var cargo_space:Control

@export var grid:GridContainer;
@export var sfx:AudioStreamPlayer;
@export var hover_sfx:AudioStreamPlayer;
@export var warning_label:Label;

@export var send_rect:ColorRect;
var size_x:int;
var size_y:int;





var inventory:Inventory;

const grid_cell_size = 48;

var grid_cols:Array[Array];

@onready var original_position:Vector2 = position;

@export var from_player:bool=true;



@export var exchanging_display:InventoryDisplay;

@export var trade_excess:PanelContainer;
@export var trade_excess_container:VBoxContainer;

@export var trade_excess_label_panel:PanelContainer;
@export var trade_excess_label:Label;


@export var resources_dropdown:ResourcesDropdown;


var all_mirrors:Array[ItemMirror];

var food_containers:Array[ItemMirror]
var fuel_containers:Array[ItemMirror]

var juice_containers:Array[ItemMirror]
var scrap_containers:Array[ItemMirror]
var chips_containers:Array[ItemMirror]

var held_item_mirror:ItemMirror;

var grid_set:bool=false;

@export var food_icon:ResourceIcon

func _ready()->void:
	if context == "player_sheet":
		inventory = Entities.player.inventory
		hard_reset()

var pre_trade_inventory:Inventory
var pre_trade_stack_sizes:Dictionary[ResourceContainer, int]
var pre_trade_inventory_positions:Dictionary[Item, Vector2]
func set_reset_state()->Inventory:
	## mirrors here are already properly positioned and set to just get
	## added into the display as freshly-loaded mirrors
	pre_trade_inventory = inventory.duplicate()

	
	for c:ResourceContainer in pre_trade_inventory.containers:
		pre_trade_stack_sizes[c] = c.stack_size;
	for item:Item in pre_trade_inventory.items:
		pre_trade_inventory_positions[item] = item.inventory_position
	## returns the pre trade inventory for resource count comparisons in trade
	return pre_trade_inventory

func reset_inventory()->void:
	## items are still referenced in the backup so won't be 
	## lost when they get unindexed from the inventyory
	
	
	inventory.empty_inventory();

	while len(pre_trade_inventory.items):
		var item:Item = pre_trade_inventory.items[0]
		pre_trade_inventory.send_item(item, inventory)
		
		item.inventory_position = pre_trade_inventory_positions[item];

	for c:ResourceContainer in inventory.containers:
		c.stack_size = pre_trade_stack_sizes[c];
	hard_reset()


func set_grid()->void:
	while grid.get_child_count():
		grid.get_child(0).free()

	grid_cols.clear();
	size_x = inventory.capacity_x;
	size_y = 12 ## non-player inventories can be infinitely flexible 
	grid.columns = size_x;
	var rows:Array[Array];
	for y in size_y:
		## gotta add them left-to-right because that's the order the gridContainer aligns them
		rows.append([]);
		for x in size_x:
			var cell:InventoryGridCell = grid_cell_scene.instantiate();
			grid.add_child(cell);
			cell.mouse_entered.connect(hover_sfx.play)
			rows[y].append(cell);

	for i in size_x:
		grid_cols.append([]);
	
	for row in rows:
		for i in len(grid_cols):
			grid_cols[i].append(row[i])
			
	send_rect.set_size.call_deferred(Vector2(size_x * grid_cell_size, size_y * grid_cell_size))
	if not from_player:
		send_rect.position = Vector2.ZERO 


func load_inventory()->void:
	## INVENTORY IS ALREADY SET HERE FROM OUTSIDE CALL
	resources_dropdown.target_inventory = inventory
	resources_dropdown.setup()
	
	var unplaced:Array[Item];
	for item:Item in inventory.items:
		if not (item is Equipment) or item not in Entities.player.equipment:
			if item.inventory_position == Vector2(-1, -1):
				unplaced.append(item);
			else:
				mirror_item(item)

	for item:Item in unplaced:
		throw_in_inventory(item);

	
	refresh_data();
	
func mirror_item(item:Item)->ItemMirror:
	var mirror:ItemMirror = generate_mirror(item);
	mirror.set_inventory_position(item.inventory_position)
	add_mirror(mirror)
	return mirror

func generate_mirror(item:Item)->ItemMirror:
	var mirror:ItemMirror = Index.scenes.ui.item_mirror.instantiate();
	item.mirror = mirror
	mirror.display = self;
	mirror.load_item(item, true);
	return mirror;


func add_mirror(mirror:ItemMirror)->void:
	item_mirrors_node.add_child(mirror);
	all_mirrors.append(mirror);
	
func clear_all_mirrors(from_inventory:bool=true)->void:
	while len(all_mirrors):
		remove_mirror(all_mirrors[0], from_inventory)

func remove_mirror(mirror:ItemMirror, from_inventory:bool=true)->void:
	if from_inventory and mirror.item in inventory.items:
		inventory.remove_item(mirror.item);
	
	if mirror.item and mirror.item is ResourceContainer:
		self[mirror.item.resource +"_containers"].erase(mirror)
	
	if is_instance_valid(mirror.item):
		mirror.item.mirror = null
	
	
	all_mirrors.erase(mirror)
	mirror.queue_free();

func hard_reset()->void:
	clear_all_mirrors(false);
	set_grid()
	load_inventory();
	board_shake(5)

func get_unallocated_items()->Array[Item]:
	## for items that just got into the inventory and haven't been mirrored properly
	var items:Array[Item]
	for item:Item in inventory.items:
		if not is_equipped(item) and (not item.mirror or item.mirror not in all_mirrors):
			items.append(item);
	return items

func is_equipped(item:Item)->bool:
	if not item is Equipment:
		return false;
	else:
		return (item in Entities.player.equipment or item in Entities.player.roster.equipped_accessories);

func refresh_data()->void:
	var concurring_inventory:Array[Inventory];
	if exchanging_display and exchanging_display.inventory:
		concurring_inventory.append(exchanging_display.inventory)

	resource_picker.hide();
	if context != "trade":
		## keep the original resource counters to make change more readable
		resources_dropdown.update(concurring_inventory);

	for col:Array in grid_cols:
		for cell:InventoryGridCell in col:
			cell.empty_cell();

	
	if context == "trade":
		## one display uses  the other one's trade rect 
		exchanging_display.send_rect.hide()
	
	
	liquid_item_mirrors = []
	reset_warnings();
	if context == "player_sheet":
		## unallocated items in player sheet are those that came from trade/loot
		var unallocated:Array[Item] = get_unallocated_items();
		for item:Item in unallocated:
			mirror_item(item)

	for item_mirror:ItemMirror in all_mirrors:
		if is_instance_valid(item_mirror):
			item_mirror.refresh()
			item_mirror.item.mirror = item_mirror ## not sure where this gets lost
			

			if not warnings["liquid_discard"]:
				if item_mirror.item is ResourceContainer and \
				item_mirror.item.raw_stack and item_mirror.item.mirror_only:
					liquid_item_mirrors.append(item_mirror);
					warnings["liquid_discard"] = true;
		
	if context == "loot":
		if inventory == Entities.player.inventory:
			if len(exchanging_display.all_mirrors):
				warnings["loot_discard"] = true;
		else:
			if len(all_mirrors):
				exchanging_display.warnings["loot_discard"] = true;
	
	inventory.refresh_resource_counts()
	refresh_container_mirrors();


func refresh_container_mirrors()->void:
	for r:String in Index.all_resources:
		if r != "money": 
			self[r+"_containers"].clear()

	for c:Node in all_mirrors:
		assert(c is ItemMirror)
		if c.item is ResourceContainer:
			self[c.item.resource+"_containers"].append(c);




func highlight_resource_containers(resource:String)->void:	
	for mirror:ItemMirror in self[resource+"_containers"]:
		mirror.highlight_item()

func clear_resource_container_highlights(resource:String)->void:
	for mirror:ItemMirror in self[resource+"_containers"]:
		mirror.undo_container_highlight();




func throw_in_inventory(item:Item, replacing:Item = null)->void:
	## finds the top-left-most spot where the item fits
	## if there's no room it just skips it rn
	for x in len(grid_cols):
		for y in len(grid_cols[x]):
			if check_item_fit(item, Vector2(x, y), replacing):
				item.inventory_position = Vector2(x, y)
				if item not in inventory.items:
					inventory.add_item(item);
				mirror_item(item).refresh();
				return

func throw_mirror(item_mirror:ItemMirror, add_to_grid:bool=false)->void:
	var x_limit:int = size_x
	var y_limit:int = size_y
	
	for x:int in x_limit:
		for y:int in y_limit:
			var target:Vector2i = Vector2i(x, y)
			if check_item_fit(item_mirror.item, target):
				item_mirror.set_inventory_position(target)
				if add_to_grid:
					add_mirror(item_mirror)
					item_mirror.refresh();
					return
				return;
	item_mirror.set_inventory_position(Vector2i(-1, -1))

func receive_resource(amount:int, resource:String)->int:
	var returned:int = 0;
	amount = store_resource(amount, resource);
	while amount:
		var raw_stack:ResourceContainer = Index.scenes.items[resource+"_stack"].instantiate();
		inventory.add_item(raw_stack);
		
		if raw_stack.capacity >= amount or raw_stack.mirror_only:
			raw_stack.stack_size = amount;
			amount = 0;
		else:
			raw_stack.stack_size = raw_stack.capacity;
			amount -= raw_stack.capacity;
		
		var mirror:ItemMirror = generate_mirror(raw_stack);
		throw_mirror(mirror, true);
		if mirror.inventory_position != Vector2i(-1, -1):
			raw_stack.match_mirror()
			item_dropped.emit(mirror, "trade")
		else:
			remove_mirror(mirror, true);
			returned += mirror.stack_size;

	return returned

func current_resource_amount(resource:String)->int:
	var count:int = 0;
	for c:ItemMirror in self[resource+"_containers"]:
		count += c.stack_size;
	return count

func send_resource_by_amount(resource:String, amount:int)->void:
	var mirrors:Array[ItemMirror] = self[resource+"_containers"];
	mirrors.sort_custom(sort_container_mirrors);

	for mirror:ItemMirror in mirrors:
		if mirror.stack_size >= amount:
			send_resource(mirror, amount);
			## always ends up here because this function will never run if there's not enough to send
			return
		else:
			send_resource(mirror, mirror.stack_size)

func send_resource(source:ItemMirror, amount:int)->void:
	var sent:int = amount;
	if(amount == source.stack_size and source.item.raw_stack) or context == "loot":
		send_item(source);
	else:
		var returned:int = exchanging_display.receive_resource(amount, source.item.resource);
		sent -= returned
		source.change_stack_size(-sent)
	
		source.highlight_stack_label()
		item_dropped.emit(source, "trade");
		
	inventory.refresh_resource_counts();
	exchanging_display.inventory.refresh_resource_counts()
	exchanging_display.item_received.emit()

		
func send_item(item_mirror:ItemMirror, trade:bool = false)->void:
	## needs to be erased prior to other display refreshing so warnings behave properly
	if exchanging_display.receive_item(item_mirror, trade):
		## remove_mirror doesn't have to remove item
		## because it's already removed by send_item if the receive passes
		remove_mirror(item_mirror, false)
	

func receive_item(item_mirror:ItemMirror, trade:bool)->bool:
	## make this only apply to empty containers and non-resources?
	var new_mirror:ItemMirror;
	var spot:Vector2i = find_clear_cell(item_mirror.item)
	if spot == Vector2i(-1, -1):
		invalid_move.emit("NOT ENOUGH ROOM", item_mirror);
		return false
	## EVERY MOVE IS APPLIED TO INVENTORIES RIGHT AWAY
	## RESETTING FUNCTIONS WILL BE RESET STATES GENERATED AS THE MENUS ARE OPENED
	## /TRADES ARE COMMITED
	item_mirror.display.inventory.send_item(item_mirror.item, inventory)
	if item_mirror.item is ResourceContainer:
		inventory.refresh_resource_counts();
		exchanging_display.inventory.refresh_resource_counts()
		
	new_mirror = mirror_item(item_mirror.item)
	new_mirror.traded_price = item_mirror.price;
	new_mirror.set_inventory_position(spot)

	item_received.emit();

	new_mirror.being_traded = not item_mirror.being_traded;
	
	if trade:
		item_dropped.emit(new_mirror, "trade");
	else:
		sfx.play_sound_by_key("loot")
		item_dropped.emit(new_mirror, "loot");

	return true

func find_clear_cell(item:Item, replacing_item:Item=null)->Vector2i:
	for x:int in len(grid_cols):
		var col:Array= grid_cols[x];
		for y:int in len(col):
			
			var spot:Vector2i;
			if item.mirror and item.mirror.being_traded:
				spot = Vector2i(x, len(col)-y-1)
			else:
				spot = Vector2i(x, y)
			if check_item_fit(item, spot, replacing_item):
					return spot;

	return Vector2i(-1, -1);
	

func check_item_fit(item:Item, spot:Vector2,  replacing_item:Item=null)->bool:
	for x:int in range(item.size_x):
		for y:int in range(item.size_y):
			var cell_x:int = spot.x + x;
			var cell_y:int = spot.y + y;
			if not inside_grid(Vector2(cell_x, cell_y)):
				return false;
			var cell:InventoryGridCell = grid_cols[cell_x][cell_y];

			if replacing_item:
				if cell.filled and\
				 cell.filling_item_mirror != item.mirror and\
				 cell.filling_item_mirror.item != replacing_item:
					return false
			elif cell.filled and is_instance_valid(cell.filling_item_mirror) and cell.filling_item_mirror.item != item:
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

					var cell:InventoryGridCell = grid_cols[cell_x][cell_y];
					cell.hover();
	else:
		for cell:Vector2 in to_hover:
			grid_cols[cell.x][cell.y].hover()

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
		 size_x or spot.y >= size_y):
			if check_item_fit(item_mirror.item, spot):
				return spot
	return Vector2i(-1, -1);
	
func clear_hovered_cells()->void:
	for col in grid_cols:
		for cell:InventoryGridCell in col:
			cell.release();
	


func inside_grid(coords:Vector2)->bool:
	if coords.x < 0 or coords.y < 0:
		return false;
	if coords.x >= size_x or coords.y >= size_y:
		return false;
	return true;


func sort_inventory()->void:
	inventory.sort_items();
	
	refresh_data()
	sfx.play_sound_by_key("reset")
	board_shake(10, .5)

func store_resource(amount:int, resource:String)->int:
	var initial_amount:int = amount;
	var remaining:int = amount;
		
	var containers:Array[ItemMirror] = self[resource+"_containers"].filter(\
		func(mirror:ItemMirror)->bool:return not mirror.item.raw_stack);

	containers.sort_custom(sort_container_mirrors);

	for container_mirror:ItemMirror in containers:
		if remaining:
			if container_mirror.space_left():
				if container_mirror.space_left() >= remaining:
					container_mirror.change_stack_size(remaining)
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
					container_mirror.change_stack_size(to_add)
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



func _on_item_dropped(_mirror:ItemMirror, from:String="move") -> void:
	inventory.changed.emit();
	if held_item_mirror:
		held_item_mirror.z_index -= 20
		held_item_mirror.held = false;
		held_item_mirror = null;

	if from == "trade" or from == "loot":
		if exchanging_display.held_item_mirror:
			exchanging_display.held_item_mirror.held = false;
			exchanging_display.held_item_mirror = null
		if from == "trade":
			sfx.play_sound_by_key("trade")

	clear_hovered_cells()

	
	refresh_data();
	board_shake(5)

func _on_item_picked_up() -> void:
	board_shake()

var shake_tween:Tween;
func board_shake(intensity:int=3, return_duration:float=.1)->void:
	
	var x_shift:int = randi_range(-intensity, intensity)
	var y_shift:int = randi_range(-intensity, intensity)
	var shift: = Vector2(x_shift, y_shift);
	
	var origin:Vector2 = cargo.position;
	cargo.position += shift;
	
	if not shake_tween or not shake_tween.is_running():
		shake_tween= create_tween();
		shake_tween.tween_property(cargo, "position", origin, return_duration)
	
	
	send_rect.hide();


func _on_invalid_move(message:String="", _item_mirror:ItemMirror=null) -> void:
	sfx.play_sound_by_key("invalid")
	if held_item_mirror:
		held_item_mirror.held = false;
		held_item_mirror = null;
	if message:
		var label:Label = warning_label.duplicate()
		label.text = message;
		add_child(label);
		label.z_index = 50
		
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


func _on_inventory_grid_resized() -> void:
	cargo_space.custom_minimum_size.x = size_x * 48
	cargo_space.size.x = size_x * 48
	


func _on_opened() -> void:
	if from_player:
		inventory = Entities.player.inventory
	hard_reset();
