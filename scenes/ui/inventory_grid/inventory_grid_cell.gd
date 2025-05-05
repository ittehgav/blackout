extends ReferenceRect

class_name InventoryGridCell

@export var held_item_shadow_bg_color:Color;


var filling_item:ItemMirror;

var filled:bool;
@onready var original_color:Color = border_color;
var original_bg_color;
 
@export var bg:ColorRect;
@export var extension_bg:ColorRect;

func _ready()->void:
	var bg_color:Color = border_color - Color(0,0,0,.6);
	bg.color = bg_color;
	original_bg_color = bg_color
	release()


func _on_mouse_entered() -> void:
	hover();

func hover():
	z_index = 1;

	border_color = Color.WHITE

func _on_mouse_exited() -> void:
	release();

func held_item_shadow(item_mirror:ItemMirror):
	bg.color = held_item_shadow_bg_color;

func release()->void:
	z_index = 0;
	bg.color = original_bg_color;
	border_color = original_color

func fill_cell(item_mirror:ItemMirror)->void:
	filling_item = item_mirror;
	var item = filling_item.item;

	filled = true;
	
func empty_cell()->void:
	filled = false
