extends TextureRect

class_name ItemMirror;

var display:InventoryDisplay;
@export var modifier_sign:Label
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


var origin_position:Vector2;
var just_picked_up:bool;

var cursor_offset:Vector2;
var held:bool;
var droppable:bool;
var being_highlighted:bool;
var vacant_spot_offset:Vector2i;
var send_on_drop:bool = false;

var shader_color:Color;
var outline_color:Color;
var highlighted_outline_color:Color

## only matters when trading
var price:float;
var being_traded:bool = false;


## ITEM MIRRORS WILL TAKE AFTER ITEMS AND BEHAVE ON THEIR OWN UNTIL THEY CAN REPLACE ITEMS
var stack_size:int=0;

@onready var original_stack_label_font_size:int = stack_size_label.get_theme_font_size("font_size");

func load_item(target:Item, new_item:bool=false)->void:
	## only ever added as a child of an InventoryDisplay's item_mirrors node;
	item = target;
	item.mirror = self;
	texture = item.texture;
	custom_minimum_size = Vector2.ZERO;
	size = Vector2.ZERO;
	custom_minimum_size = Vector2(item.size_x, item.size_y) * display.grid_cell_size;
	tooltip.load_target(self);
	if item is ResourceContainer:
		stack_size = item.stack_size

	
	modifier_sign.hide()
	if item.applied_modifier:
		modifier_sign.show()
	
	var item_color:Color = item.get_mirror_color();
	self_modulate = item_color;

	var dark_color:Color = item_color.darkened(.8);
	var light_color:Color = item_color.lightened(.4);
	
	stack_size_label.add_theme_color_override("font_outline_color", dark_color)
	stack_size_label.add_theme_color_override("font_color", light_color)
	

	price_tag.add_theme_color_override("font_outline_color", dark_color)
	bg.color = item_color.darkened(.2);
	

	bg.color.s = min(.7, bg.color.s)

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
				return
			elif e.button_index == MOUSE_BUTTON_RIGHT:
				if display.context == "player_sheet":
					if item is ResourceContainer:
						if item.raw_stack:
							var clear:bool = send_to_containers();
							if clear:
								display.remove_mirror(self)
								display.item_dropped.emit(self)
						else:
							empty_storage();

					elif item is Equipment:
						equip_command()
					elif item is Consumable:
						use_consumable_command()
				elif display.context == "trade":
					trade_command()
					return
				elif display.context == "loot":
					loot_command();
					return;
		else:
			if e.button_index == MOUSE_BUTTON_LEFT and\
			(not display.inventory is NpcInventory or not item in display.inventory.fixed_items):
				put_down();

func empty_storage()->void:
	var moved:int=0;
	var to_throw:Array[ItemMirror];

	while stack_size:
		var raw_stack:ResourceContainer = Index.scenes.items[item.resource+"_stack"].instantiate();
		if raw_stack.mirror_only:
			raw_stack.stack_size = stack_size;
			stack_size = 0;
		else:
			if stack_size <= raw_stack.capacity:
				raw_stack.stack_size = stack_size;
				stack_size = 0;
			else:
				raw_stack.stack_size = raw_stack.capacity;
				stack_size -= raw_stack.capacity;

		var mirror:ItemMirror = display.generate_mirror(raw_stack);
		to_throw.append(mirror);
	for mirror:ItemMirror in to_throw:
		moved += mirror.stack_size
		
		if display.find_clear_cell(mirror.item) != Vector2i(-1, -1):
			display.throw_mirror(mirror, true);
		else:
			stack_size += mirror.stack_size;
			moved -= mirror.stack_size
			display.remove_mirror(mirror, true)
	
	highlight_stack_label()
	display.item_dropped.emit(self)
	
	display.play_deposit_sfx(moved, item.resource)



func pick_up()->void:
	if not display.inventory is NpcInventory or not item in display.inventory.fixed_items:
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

func drop_on_container(target:ItemMirror)->bool:
	var deposited: = 0;
	target.highlight_stack_label();
	if target.space_left() >= stack_size:
		target.stack_size += stack_size;
		deposited = stack_size
		stack_size = 0;
	else:
		deposited = target.space_left();
		stack_size -= target.space_left();
		target.stack_size = target.item.capacity;
		
	display.play_deposit_sfx(deposited, item.resource);
	
	if not stack_size and item.raw_stack:
		return true;
	return false

func put_down()->void:
	modulate.a = 1;
	z_index -= 1
	tooltip.enable();
	
	if item_under != self:
		## only validates if there's exactly one item under this one
		if display.context != "trade" and item is ResourceContainer and item_under.item is ResourceContainer\
			and item.resource == item_under.item.resource:
			var free:bool = drop_on_container(item_under);
			if free:
				display.remove_mirror(self)
				display.item_dropped.emit(self);
				return
	
	if not droppable:
		position = origin_position;
	else:
		if send_on_drop:
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

func loot_command()->void:
	display.send_item(self);

func equip_command()->void:
	display.clear_cells(self);
	if item is Weapon:
		if not Entities.player.alternative_weapon:
			equip_weapon_command(true)
		else:
			if Input.is_key_pressed(KEY_ALT):
				equip_weapon_command(true);
			else:
				equip_weapon_command()
	elif item is Module:
		equip_module_command()
	elif item is Accessory:
		equip_accessory_command();

func equip_weapon_command(alt:bool=false)->void:
	var current_weapon:Weapon;
	if alt:
		current_weapon = Entities.player.alternative_weapon;
		Entities.player.equip_alt_weapon(item);
	else:
		current_weapon = Entities.player.equipped_weapon;
		Entities.player.equip_weapon(item);
		
	if current_weapon:
		item.mirror = null;
		current_weapon.inventory_position = inventory_position;
		load_item(current_weapon, true)

		display.throw_mirror(self);
		
		if inventory_position == Vector2i(-1, -1):
			display.sort_inventory();
		else:
			display.item_dropped.emit(self);
			refresh();
	else:
		## only ever happens in player sheet so it's ok to emit drop with freed mirror?
		display.remove_mirror(self)
		display.item_dropped.emit(self)
	

func equip_accessory_command()->void:
	assert(item is Accessory);
	if item.equippable.player and not item.equippable.unit:
		equip_accessory_on_player();
	else:
		display.unit_selector.show_options(item);

func equip_accessory_on_player()->void:
	var just_unequipped:Accessory;
	if not Entities.player.equipped_accessory_1:
		just_unequipped = Entities.player.equip_accessory(item, 1);
	elif not Entities.player.equipped_accessory_2:
		just_unequipped = Entities.player.equip_accessory(item, 2);
	else:
		var new_ac2:Accessory = Entities.player.equipped_accessory_1
		if display.find_clear_cell(new_ac2, false, item) == Vector2i(-1, -1):
			display.invalid_move.emit("NOT ENOUGH ROOM")
			return;
			
		just_unequipped = Entities.player.equip_accessory(new_ac2, 2);
		Entities.player.equip_accessory(item, 1)
		
	if just_unequipped:
		load_item(just_unequipped, true);
		item.match_mirror()
		if not display.check_item_fit(item, inventory_position):
			display.throw_mirror(self);
		refresh()
	
	else:
		display.remove_mirror(self);
	
	display.item_dropped.emit(self);

func equip_accessory_on_unit(unit:FighterUnit)->void:
	var previous:Accessory = unit.equipped_accessory;
	if previous:
		if not display.find_clear_cell(previous, false, item):
			display.invalid_move.emit("NOT ENOUGH ROOM");
			return;
	
	unit.equip_accessory(item);
	Entities.player.roster.equipped_accessories.append(item);

	if previous:
		load_item(previous, true);
		if not display.check_item_fit(item, inventory_position):
			display.throw_mirror(self);
		refresh()
	else:
		display.remove_mirror(self, false);
	display.accessory_equipped_on_unit.emit();
	display.item_dropped.emit(self)


func equip_module_command()->void:
	var unequipped_module:Module = Entities.player.equipped_module;
	Entities.player.equip_module(item);
	
	item.mirror = null;
	unequipped_module.inventory_position = inventory_position;
	
	load_item(unequipped_module, true);
	## doesn't have to refit since all modules are the same size;
	display.item_dropped.emit(self);
	refresh()


func use_consumable_command()->void:
	match item.use_type:
		"instant":
			if item.special_graphics:
				var graphics:ItemSpecialGraphics = item.special_graphics.instantiate();
				Entities.player_sheet.add_child(graphics)
				var tween:Tween = Tweens.ui_fade_in(graphics)
				tween.tween_callback(graphics.play);
				await graphics.finished;
				Tweens.ui_fade_out(graphics)
				return
			if item.use_sfx:
				display.sfx.play_sound_obj(item.use_sfx)
			item.use();
			display.board_shake()
			display.remove_mirror(self)
			
		"unit":
			if item.tag_target:
				if not len(Entities.player.roster.units.filter(func(f:FighterUnit)->bool:return item.tag_target in f.base.tags)):
					display.invalid_move.emit("NO MATCHING UNITS IN PARTY")
					return
			display.unit_selector.show_options(item)
	
		"item":
			var item_pool:Array;
			if item.item_target:
				match item.item_target:
					"weapon":
						item_pool = Entities.player.inventory.weapons;
					"module":
						item_pool = Entities.player.inventory.modules;
					"accessory":
						item_pool = Entities.player.inventory.accessories;
					"consumable":
						item_pool = Entities.player.inventory.consumables;
					"container":
						item_pool = Entities.player.inventory.containers;
			else:
				item_pool = Entities.player.inventory.items;

			if "item_filter" in item:
				item_pool = item_pool.filter(item.item_filter);

			if not len(item_pool):
				display.invalid_move.emit("NO MATCHING ITEMS IN INVENTORY")
				return
			

			var selector:ItemSelector = display.item_selector;
			selector.show_options(item_pool, item);

			
	Entities.player_sheet.refresh_data()


func trade_command()->void:
	if item is ResourceContainer:
		if item.raw_stack:
			display.send_resource(self, stack_size);
			return
		elif stack_size:
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				display.resource_picker.show_picker(self);
				return
			else:
				if stack_size:
					display.send_resource(self, stack_size);
					return
				else:
					if display.from_player or not item in display.inventory.non_sellable_items:
						display.send_resource(self, stack_size);
						return
					else:
						if held:
							refresh();
						display.invalid_move.emit("CONTAINER NOT FOR SALE")
						return
		else:
			if display.from_player or not item in display.inventory.fixed_items:
				display.send_item(self, true);
				if display.context == "trade" or display.context == "loot":
					## sending the raw stack through here goes over the usual way the 
					## resources_changed signal is emitted
					display.resources_changed.emit(item.resource, stack_size * -1);
					display.exchanging_display.resources_changed.emit(item.resource, stack_size) 
				return
			else:
				if held:
					refresh();
				display.invalid_move.emit("CONTAINER NOT FOR SALE")
				return
	else:
		display.send_item(self, true);


func highlight_stack_label()->void:
	stack_size_label.add_theme_font_size_override("font_size", original_stack_label_font_size * 1.5);
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(stack_size_label, "theme_override_font_sizes/font_size", original_stack_label_font_size, .5)



var original_modulate:Color=Color.BLACK
func highlight_item()->void:
	if original_modulate == Color.BLACK:
		original_modulate = modulate;
	being_highlighted = true
	original_modulate = modulate;
	modulate.v *= 2;
	modulate.s /= 1.25;
	

func undo_container_highlight(smooth:bool=false)->void:
	being_highlighted = false;
	if not smooth:
		modulate = original_modulate
	else:
		var tween:Tween = create_tween();
		tween.tween_property(self, "modulate",original_modulate, .5);


func _on_mouse_entered() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)\
	and item is ResourceContainer and item.raw_stack and display.context == "player_sheet":
		display.item_dropped.emit(self);
		var clear:bool = send_to_containers();
		if clear:
			display.remove_mirror(self)


	outline.border_color = highlighted_outline_color;

func send_to_containers()->bool:
	var amount_deposited:int=0;
	var containers:Array = display[item.resource+"_containers"].filter(
		func(c:ItemMirror)->bool:return not (c.item.raw_stack)
	)
	containers.sort_custom(display.sort_container_mirrors);
	for c:ItemMirror in containers:
		if stack_size:
			if c.space_left():
				if c.space_left() >= stack_size:
					
					c.stack_size += stack_size;
					c.highlight_stack_label();
					c.refresh();
					amount_deposited += stack_size;
					display.play_deposit_sfx(amount_deposited, item.resource)
					return true
				else:
					amount_deposited += c.space_left();
					stack_size -= c.space_left();
					c.stack_size = c.item.capacity;
					c.highlight_stack_label();
					c.refresh();
	display.item_dropped.emit(self)
	return false
			
func _on_mouse_exited() -> void:
	outline.border_color = outline_color;


func extending_fade()->void:
	self_modulate.a = .5;


func set_price()->void:
	price_tag.show();
	if not being_traded:
		if item is ResourceContainer and stack_size:
			
		
			if display.from_player:
				## in player inventory = selling price
				price = display.exchanging_display.inventory.resource_selling_prices[item.resource];
			else:
				## in trader's inventory = buying price
				price = display.inventory.resource_buying_prices[item.resource];
			price *= stack_size;
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
	tooltip.load_target(self)
	
	if display.context == "trade":
		set_price();
		
	modifier_sign.hide()
	if item.applied_modifier:
		modifier_sign.show()
	
	if item is ResourceContainer and item.raw_stack and stack_size == 0:
		display.remove_mirror(self)
		return
	stack_size_label.modulate.a = 1
	
	if "capacity" in item:
		stack_size_label.text = str(stack_size) + "/" + str(item.capacity);
		if item.mirror_only:
			stack_size_label.modulate.a = .5
			stack_size_label.text = stack_size_label.text.split("/")[0];
		elif item.capacity == 0:
			stack_size_label.text = str(stack_size);
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

func space_left()->int:
	return item.capacity - stack_size;

func update_item()->void:
	item.inventory_position = inventory_position;
