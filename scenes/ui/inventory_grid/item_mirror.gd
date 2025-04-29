extends TextureRect

class_name ItemMirror;

@onready var inventory_display:Control = get_parent().get_parent();
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

func load_item(target:Item)->void:
	## only ever added as a child of an InventoryDisplay's item_mirrors node;
	item = target;
	texture = item.texture;
	custom_minimum_size = Vector2(item.size_x, item.size_y) * 48;
	if item.size_x > 1:
		stack_size_label.add_theme_font_size_override("font_size", 32);
		
	tooltip.target = item;
	var item_color:Color;
	if item is ResourceContainer:
		item_color = Index.get_color(item.resource)
	else:
		item_color = Index.item_rarity_colors[item.rarity];
	
	material.set_shader_parameter("base_color", item_color)
	stack_size_label.add_theme_color_override("font_outline_color", item_color.darkened(.9))
	bg.color = item_color.darkened(.9);
	
	if "capacity" in item:
		stack_size_label.text = str(item.stack_size) + "/" + str(item.capacity);
	else:
		stack_size_label.text = str(item.stack_size);


func _process(_delta:float)->void:
	if held:
		global_position = get_global_mouse_position() - cursor_offset;
		var cell = Vector2i(position/inventory_display.grid_cell_size);
		if cell != inventory_position:
			item_under = self;
			droppable = true
			inventory_position = cell
			inventory_display.project_item_mirror(self)
		inventory_position = Vector2i(position/inventory_display.grid_cell_size)


func _on_gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton:
		if e.pressed:
			pick_up()
		else:
			put_down();
			

func pick_up():
	item_under = self;
	var cell_size:int = inventory_display.grid_cell_size;
	inventory_display.sfx.play_sound_by_key("pick_up");
	z_index += 1;
	origin_position = position;
	tooltip.disable()
	inventory_display.clear_cells(item)
	just_picked_up = true
	cursor_offset = (Vector2i((get_global_mouse_position() - global_position)/cell_size)*cell_size) + Vector2i(cell_size/2, cell_size/2);
	held = true;
	
func put_down()->void:
	inventory_display.sfx.play_sound_by_key("drop");
	z_index -= 1
	if not droppable:
		position = origin_position;
		if item_under != self:
			if item is ResourceContainer and item_under.item is ResourceContainer:
				var free = item.drop_on_container(item_under.item);
				if free:
					queue_free();
					await tree_exited;
					inventory_display.refresh_data();
					return
		
	else:
		item.inventory_position = inventory_position;
		position = inventory_position * inventory_display.grid_cell_size
	inventory_display.clear_hovered_cells()
	tooltip.enable()
	held = false;
	inventory_display.refresh_data();


func _on_mouse_entered() -> void:
	outline.show();


func _on_mouse_exited() -> void:
	outline.hide()
