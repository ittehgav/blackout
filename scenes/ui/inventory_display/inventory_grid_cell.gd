extends ReferenceRect

class_name InventoryGridCell

@export var held_item_shadow_bg_color:Color;


var filling_item_mirror:ItemMirror;

var filled:bool;
@onready var original_color:Color = border_color;
@onready var original_bg_color:Color = bg.color;
 
@export var bg:ColorRect;
@export var extension_bg:ColorRect;

func _ready()->void:

	release()


func _on_mouse_entered() -> void:
	hover();

func hover()->void:
	z_index = 1;

	border_color = border_color.lightened(.25)

func _on_mouse_exited() -> void:
	release();

func held_item_shadow()->void:
	bg.color = held_item_shadow_bg_color;

func release()->void:
	z_index = 0;
	bg.color = original_bg_color;
	border_color = original_color

func fill_cell(item_mirror:ItemMirror)->void:
	filling_item_mirror = item_mirror;
	filled = true;
	
func empty_cell()->void:
	filled = false
