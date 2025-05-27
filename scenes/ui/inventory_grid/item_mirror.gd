extends TextureRect

class_name ItemMirror;

var display:InventoryDisplay;
@export var outline:ReferenceRect;
@export var bg:ColorRect;
@export var being_traded_rect:ColorRect;

@export var tooltip:Tooltip;
@export var stack_size_label:Label;
@export var price_tag:Label;

var item:Item;
var item_under:ItemMirror;

var inventory_position:Vector2i;
var projection_position:Vector2i;
## when it's being traded, uses these coords that will be set when it gets thrown in
var trader_inventory_position:Vector2i;
var origin_position:Vector2;
var just_picked_up:bool;

var cursor_offset:Vector2;
var held:bool;
var droppable:bool;
var being_highlighted:bool;
var vacant_spot_offset:Vector2i;
var trade_on_drop:bool = false;

var shader_color:Color;
var outline_color:Color;
var highlighted_outline_color:Color

## only matters when trading
var price:float;
var being_traded:bool = false;
## only matters when trading with resource containers;
var traded_resource_amount:int=0;

@onready var original_stack_label_font_size:int = stack_size_label.get_theme_font_size("font_size");

func load_item(target:Item, new_item:bool=false)->void:
	## only ever added as a child of an InventoryDisplay's item_mirrors node;
	item = target;
	texture = item.texture;
	custom_minimum_size = Vector2.ZERO;
	size = Vector2.ZERO;
	custom_minimum_size = Vector2(item.size_x, item.size_y) * display.grid_cell_size;
	tooltip.target = item;
	
	var item_color:Color;
	if item is ResourceContainer:
		item_color = Index.get_color(item.resource)
	else:
		item_color = Index.item_rarity_colors[item.rarity];
	
	material.set_shader_parameter("base_color", item_color)
	var dark_color:Color = item_color.darkened(.8);
	var light_color:Color = item_color.lightened(.4);
	
	stack_size_label.add_theme_color_override("font_outline_color", dark_color)
	price_tag.add_theme_color_override("font_outline_color", dark_color)
	bg.color = light_color
	
	shader_color = item_color;
	outline_color = shader_color * Color(.25, .25, .25);
	outline.border_color = outline_color;
	highlighted_outline_color = item_color;
	
	var labels:Array[Label] = [stack_size_label, price_tag]
	if item.size_x >= 2:
		for l:Label in labels:
			l.add_theme_font_size_override("font_size", 32)
			
	else:
		for l:Label in labels:
			l.add_theme_font_size_override("font_size", 16);
		
	if display.context == "player_sheet":
		if item is ResourceContainer:
			if not "raw_stack" in item:
				tooltip.hint.text = "[right-click] to empty";
			else:
				tooltip.hint.text = "[right-click] to store"
		if item is Weapon or item is Module:
			tooltip.hint.text = "[right-click] to equip"

	else:
		if display.current_inventory.holder is Settlement:
			if item is ResourceContainer:
				if item in display.current_inventory.non_sellable_items:
					tooltip.hint.text = "[right-click] to buy resources";
				else:
					if "raw_stack" in item:
						tooltip.hint.text = "[right-click] to buy"
					else:
						tooltip.hint.text = "[right-click] to buy container"
			else:
				tooltip.hint.text = "[right-click] to buy"
		else:
			tooltip.hint.text = "[right-click] to sell"
	item.tree_exiting.connect(item_freed.bind(item));
	item.mirror = self;


	if not new_item:
		refresh()


func _process(_delta:float)->void:
	if held:
		global_position = get_global_mouse_position() - cursor_offset;
		
		var cell_size:int = display.grid_cell_size;
		var cell:Vector2i = Vector2i((position + Vector2(cell_size/2, cell_size/2))/cell_size);
		
		if cell != projection_position:
			if item_under.being_highlighted:
				item_under.undo_container_highlight();
	
			item_under = self;
			droppable = true;

			projection_position = cell
			modulate.a = 1;
			
			display.project_item_mirror(self);
			
			if item_under != self and item is ResourceContainer\
			and item_under.item is ResourceContainer\
			and item.resource == item_under.item.resource:
				item_under.highlight_item();

func _on_gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton:
		if e.pressed:
			if e.button_index == MOUSE_BUTTON_LEFT:
				pick_up()
			elif e.button_index == MOUSE_BUTTON_RIGHT:
				if display.context == "player_sheet":
					if item is ResourceContainer:
						if "raw_stack" in item:
							var clear:bool = item.send_to_containers(display.sfx);
							display.item_dropped.emit(self);
							if clear:
								queue_free();
						else:
							var new_stacks:Array[ResourceContainer] = item.empty_storage(display.sfx);
							for stack in new_stacks:
								display.throw_in_inventory(stack)
							display.item_dropped.emit(self)
							
							
					elif item is Weapon:
						var current_weapon:Weapon = Entities.player.equipped_weapon;
						display.clear_cells(self);
						Entities.player.equip_weapon(item);
						item.mirror = null;
						
						current_weapon.inventory_position = inventory_position;
						load_item(current_weapon, true)
		
						if not display.check_item_fit(item, inventory_position, true):
							display.throw_mirror(self);
						display.item_dropped.emit(self)
						
						display.sfx.play_sound_by_key("weapon_equipped")
						refresh()
					elif item is Module:
						var current_module:Module = Entities.player.equipped_module;
						display.clear_cells(self);
						Entities.player.equip_module(item);
						item.mirror = null;
						
						current_module.inventory_position = inventory_position;
						load_item(current_module, true);
						## doesn't have to refit since all modules are the same size;
						display.item_dropped.emit(self);
						display.sfx.play_sound_by_key("module_equipped");
						refresh()
					
				elif display.context == "trade":
					trade_command()
					return
		else:
			if e.button_index == MOUSE_BUTTON_LEFT:
				put_down();


func pick_up()->void:
	z_index += 1;
	display.item_picked_up.emit();
	item_under = self;
	display.sfx.play_sound_by_key("pick_up");
	tooltip.disable()
	just_picked_up = true

	var cell_size:int = display.grid_cell_size;
	origin_position = position;
	display.clear_cells(self)
	
	cursor_offset = (Vector2i((get_global_mouse_position() - global_position)/cell_size)*cell_size) + Vector2i(cell_size/2, cell_size/2);
	held = true;
	display.held_item_mirror = self;

func put_down()->void:
	modulate.a = 1;
	z_index -= 1
	tooltip.enable();
	
	if item_under != self:
		## only validates if there's exactly one item under this one
		if display.context != "trade" and item is ResourceContainer and item_under.item is ResourceContainer\
			and item.resource == item_under.item.resource:
			var free:bool = item.drop_on_container(item_under.item, display.sfx);
			if free:
				queue_free();
				await tree_exited;
				display.item_dropped.emit(self);
				return
	
	if not droppable:
		position = origin_position;
	else:
		if trade_on_drop:
			trade_command();
			return
		else:
			place_on_spot()

	display.item_dropped.emit(self);

func place_on_spot()->void:
	if vacant_spot_offset:
		projection_position += vacant_spot_offset
	display.sfx.play_sound_by_key("drop")
	inventory_position = projection_position;

func trade_command()->void:
	if item is ResourceContainer:
		if "raw_stack" in item:
			display.trade_resource(item.resource, item.stack_size - traded_resource_amount);
			return
		elif item.stack_size - traded_resource_amount:
			await get_tree().create_timer(.15).timeout;
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				display.show_resource_picker(item);
				tooltip.disable();
				display.resource_picker.operation_finished.connect(tooltip.enable, CONNECT_ONE_SHOT)
				return
			else:
				if item.stack_size - traded_resource_amount:
					display.trade_resource(item.resource, item.stack_size - traded_resource_amount);
					return
				else:
					if display.from_player or not item in display.current_inventory.non_sellable_items:
						display.trade_resource(item.resource, item.stack_size);
						return
					else:
						if held:
							refresh();
						display.invalid_move.emit("CONTAINER NOT FOR SALE")
						return
		else:
			if display.from_player or not item in display.current_inventory.non_sellable_items:
				display.trade_item(self);
				return
			else:
				if held:
					refresh();
				display.invalid_move.emit("CONTAINER NOT FOR SALE")
				return
	else:
		display.trade_item(self);


func highlight_stack_label()->void:
	highlight_item();
	undo_container_highlight(true)
	
	stack_size_label.add_theme_font_size_override("font_size", original_stack_label_font_size * 1.5);
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(stack_size_label, "theme_override_font_sizes/font_size", original_stack_label_font_size, .5)



func highlight_item()->void:
	being_highlighted = true
	material.set_shader_parameter("base_color", shader_color + Color.from_hsv(0, .5, .8))
	

func undo_container_highlight(smooth:bool=false)->void:
	being_highlighted = false;
	if not smooth:
		material.set_shader_parameter("base_color", shader_color);
	else:
		var tween:Tween = create_tween();
		tween.tween_property(self, "material:shader_parameter/base_color", shader_color, .5);


func _on_mouse_entered() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)\
	and item is ResourceContainer and "raw_stack" in item and display.context == "player_sheet":
		display.item_dropped.emit(self);
		var clear:bool = item.send_to_containers(display.sfx);
		if clear:
			queue_free();
	outline.border_color = highlighted_outline_color;
	outline.border_color = highlighted_outline_color;


func _on_mouse_exited() -> void:
	outline.border_color = outline_color;


func item_freed(freed_item:Item) -> void:
	if freed_item is ResourceContainer:
		display[item.resource + "_containers"].erase(self);

func extending_fade()->void:
	self_modulate.a = .5;


func set_price()->void:
	price_tag.show();
	if not being_traded:
		if item is ResourceContainer and item.stack_size - traded_resource_amount:
			var inventory:Inventory = Entities.current_trading_party.inventory;
			if display.from_player:
				## in player inventory = selling price
				price = inventory.resource_selling_prices[item.resource];
			else:
				## in trader's inventory = buying price
				price = inventory.resource_buying_prices[item.resource];
			price *= item.stack_size - traded_resource_amount;
		else:
			## CURRENT NON-RESOURCE ITEM PRICE FORMULA
			## (rarity + 1)² * item.size.x * item.size.y
			price = (item.rarity + 1) ** 2
			price *= item.size_x * item.size_y

		## if it's being traded, it already had it's price set
		if price < 1:
			price = 1;
		price_tag.text = "$" + str(int(price));


func refresh()->void:
	tooltip.target = item;
	tooltip.setup(false);
	
	if display.context == "trade":
		set_price();
		if being_traded:
			tooltip.hint.text = "[right-click] to return"
		else:
			if display.from_player:
				tooltip.hint.text = "[right-click] to sell";
			else:
				tooltip.hint.text = "[right-click] to buy"
	
	if item is ResourceContainer and "raw_stack" in item and item.stack_size - traded_resource_amount == 0:
		item.queue_free();
		queue_free()
		return
	stack_size_label.modulate.a = 1
	
	if "capacity" in item:
		stack_size_label.text = str(item.stack_size - traded_resource_amount) + "/" + str(item.capacity);
		if "mirror_only" in item:
			stack_size_label.modulate.a = .5
			stack_size_label.text = stack_size_label.text.split("/")[0];
	else:
		stack_size_label.hide()
	
	position = inventory_position * display.grid_cell_size;
	size = Vector2(item.size_x, item.size_y) * display.grid_cell_size
	
	display.fill_cells(self);
	
	being_traded_rect.visible = being_traded;
	
	modulate.a = 1;
	if inventory_position.x + item.size_x > display.size_x or inventory_position.y + item.size_y > display.size_y:
		modulate.a = .75;
		display.extending_elements = true;
