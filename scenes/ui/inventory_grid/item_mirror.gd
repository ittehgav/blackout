extends TextureRect

class_name ItemMirror;

var inventory_display:InventoryDisplay;
@export var outline:ReferenceRect;
@export var bg:ColorRect;

@export var tooltip:Tooltip;
@export var stack_size_label:Label;
var item:Item;
var item_under:ItemMirror;

var inventory_position:Vector2i;
var origin_position:Vector2;
var just_picked_up:bool;

var cursor_offset:Vector2;
var held:bool;
var droppable:bool;
var being_highlighted:bool;
var vacant_spot_offset:Vector2i;

var shader_color:Color;
var outline_color:Color;
var highlighted_outline_color:Color


@onready var original_stack_label_font_size:int = stack_size_label.get_theme_font_size("font_size")


func load_item(target:Item, new_item:bool=false)->void:
	## only ever added as a child of an InventoryDisplay's item_mirrors node;
	item = target;
	texture = item.texture;
	custom_minimum_size = Vector2.ZERO;
	size = Vector2.ZERO;
	custom_minimum_size = Vector2(item.size_x, item.size_y) * inventory_display.grid_cell_size;
	tooltip.target = item;
	var item_color:Color;
	if item is ResourceContainer:
		item_color = Index.get_color(item.resource)
	else:
		item_color = Index.item_rarity_colors[item.rarity];
	
	material.set_shader_parameter("base_color", item_color)
	var dark_color = item_color.darkened(.8);
	var light_color = item_color.lightened(.4);
	
	stack_size_label.add_theme_color_override("font_outline_color", dark_color)
	bg.color = light_color
	
	shader_color = item_color;
	outline_color = shader_color * Color(.25, .25, .25);
	outline.border_color = outline_color;
	highlighted_outline_color = item_color;
	
	if inventory_display.context == "player_sheet":
		if item is ResourceContainer:
			if not "raw_stack" in item:
				tooltip.hint.text = "[right-click] to empty";
			else:
				tooltip.hint.text = "[right-click] to store"
		if item is Weapon or item is Module:
			tooltip.hint.text = "[right-click] to equip"
	else:
		if inventory_display.current_inventory.holder is Settlement:
			if item is ResourceContainer:
				if item in inventory_display.current_inventory.holder.non_sellable_items:
					tooltip.hint.text = "[right-click] to buy resources";
				else:
					if "raw_stack" in item:
						tooltip.hint.text = "[right-click] to buy"
					else:
						tooltip.hint.text = "[right-click] to buy container"
			else:
				tooltip.hint.text = "[right-click] to buy"
	item.tree_exiting.connect(item_freed.bind(item));
	item.mirror = self;


	
	if not new_item:
		refresh()


func _process(_delta:float)->void:
	if held:
		global_position = get_global_mouse_position() - cursor_offset;
		
		var cell_size:int = inventory_display.grid_cell_size;
		var cell = Vector2i((position + Vector2(cell_size/2, cell_size/2))/cell_size);
		
		if cell != inventory_position:
			if item_under.being_highlighted:
				item_under.undo_container_highlight();
	
			item_under = self;
			droppable = true;

			inventory_position = cell
			modulate.a = 1;
			
			inventory_display.project_item_mirror(self);
			
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
				if item is ResourceContainer:
					if "raw_stack" in item:
						var clear = item.send_to_containers(inventory_display.sfx);
						inventory_display.item_dropped.emit();
						if clear:
							queue_free();
					else:
						item.empty_storage(inventory_display.sfx);
						inventory_display.item_dropped.emit()
						
				elif item is Weapon:
					var current_weapon:Weapon = Entities.player.equipped_weapon;
					inventory_display.clear_cells(item);
					Entities.player.equip_weapon(item);
					item.mirror = null;
					
					current_weapon.inventory_position = inventory_position;
					load_item(current_weapon, true)

					if not inventory_display.check_item_fit(item, inventory_position, true):
						inventory_display.throw_in_inventory(item);
					refresh()
					inventory_display.item_dropped.emit()
					inventory_display.sfx.play_sound_by_key("weapon_equipped")
		else:
			if e.button_index == MOUSE_BUTTON_LEFT:
				put_down();
				
				
func pick_up():
	z_index += 1;
	inventory_display.item_picked_up.emit();
	item_under = self;
	inventory_display.sfx.play_sound_by_key("pick_up");
	tooltip.disable()
	just_picked_up = true

	var cell_size:int = inventory_display.grid_cell_size;
	origin_position = position;
	inventory_display.clear_cells(item)
	
	cursor_offset = (Vector2i((get_global_mouse_position() - global_position)/cell_size)*cell_size) + Vector2i(cell_size/2, cell_size/2);
	held = true;

func put_down()->void:
	modulate.a = 1;
	z_index -= 1
	tooltip.enable();
	
	if item_under != self:
		## only validates if there's exactly one item under this one
		if item is ResourceContainer and item_under.item is ResourceContainer\
			and item.resource == item_under.item.resource:
			var free:bool = item.drop_on_container(item_under.item, inventory_display.sfx);
			if free:
				queue_free();
				await tree_exited;
				inventory_display.item_dropped.emit();
				return
	
	if not droppable:
		position = origin_position;
		
	else:
		place_on_spot()

	held = false;
	inventory_display.clear_hovered_cells()
	inventory_display.item_dropped.emit();

func place_on_spot()->void:
	if vacant_spot_offset:
		inventory_position += vacant_spot_offset
	inventory_display.sfx.play_sound_by_key("drop")
	item.inventory_position = inventory_position;

func highlight_stack_label()->void:
	highlight_item();
	undo_container_highlight(true)
	
	stack_size_label.add_theme_font_size_override("font_size", original_stack_label_font_size * 1.5);
	var tween = create_tween();
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(stack_size_label, "theme_override_font_sizes/font_size", original_stack_label_font_size, .5)



func highlight_item()->void:
	being_highlighted = true
	material.set_shader_parameter("base_color", shader_color + Color.from_hsv(0, .5, .8))
	

func undo_container_highlight(smooth=false)->void:
	being_highlighted = false;
	if not smooth:
		material.set_shader_parameter("base_color", shader_color);
	else:
		var tween = create_tween();
		tween.tween_property(self, "material:shader_parameter/base_color", shader_color, .5);







func inside_grid():
	if inventory_position.x <  0:
		return false;
	if inventory_position.x + item.size_x >= inventory_display.extended_size_x:
		return false;
	if inventory_position.y < 0:
		return false
	if inventory_position.y + item.size_y > inventory_display.extended_size_y:
		return false;
	return true;

func _on_mouse_entered() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)\
	and item is ResourceContainer and "raw_stack" in item:
		inventory_display.item_dropped.emit();
		var clear = item.send_to_containers(inventory_display.sfx);
		if clear:
			queue_free();
	outline.border_color = highlighted_outline_color;


func _on_mouse_exited() -> void:
	outline.border_color = outline_color;


func item_freed(freed_item) -> void:
	if freed_item is ResourceContainer:
		inventory_display[item.resource + "_containers"].erase(self);

func extending_fade()->void:
	self_modulate.a = .5;



func refresh()->void:
	stack_size_label.modulate.a = 1
	if "capacity" in item:
		if "mirror_only" in item:
			stack_size_label.modulate.a = .5
			stack_size_label.text = str(item.stack_size);
		else:
			stack_size_label.text = str(item.stack_size) + "/" + str(item.capacity);
	else:
		stack_size_label.text = str(item.stack_size);

	inventory_position = item.inventory_position;
	position = inventory_position * inventory_display.grid_cell_size;

	inventory_display.fill_cells(self)
