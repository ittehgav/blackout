extends ReferenceRect


var filling_item:ItemMirror;

var filled:bool;
@onready var original_color:Color = border_color;
@onready var original_bg_color = bg.color;
 
@export var bg:ColorRect;

func _on_mouse_entered() -> void:
	hover();
	

func hover():
	border_color = Color.WHITE

func _on_mouse_exited() -> void:
	release();

func release()->void:
	border_color = original_color

func fill_cell(item_mirror:ItemMirror)->void:
	filling_item = item_mirror;
	var item = filling_item.item;
	
	if item is ResourceContainer:
		bg.color = Index.get_color(item.resource);
	else:
		bg.color = Index.item_rarity_colors[item.rarity]
		
	filled = true;
	modulate = Color.WHITE;
	
func empty_cell()->void:
	filled = false
	bg.color = original_bg_color;
