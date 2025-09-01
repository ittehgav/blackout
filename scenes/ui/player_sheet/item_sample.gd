extends TextureRect

class_name ItemSample;

@export var outline:ReferenceRect;
@export var tooltip:Tooltip;
@export var bg:ColorRect;
@export var blank:TextureRect

var item:Item;



func load_item(new_item:Item, color:Color, sample_scale:int=2.5)->void:
	item = new_item;
	blank.hide();
	texture = item.texture;
	var sample_size:Vector2 = Vector2(item.size_x, item.size_y) * 16 * sample_scale
	custom_minimum_size = sample_size;
	size = sample_size;
	
	tooltip.load_target(self);
	tooltip.enable()

	
	modulate = color;
	self_modulate.a = 1;
	self_modulate.v = 1;


func load_blank(blank_size:Vector2, blank_color:Color, sample_scale:int = 1)->void:
	blank.show();
	self_modulate.a = 0;
	outline.border_width = ((blank_size.x + blank_size.y)/2)
	
	var sample_size:Vector2 = blank_size * 16 * sample_scale
	custom_minimum_size = sample_size;
	size = sample_size;
	
	tooltip.disable();

func highlight_blink()->void:
	var original_color:Color = modulate;
	modulate =  Color.WHITE;
	var tween:Tween = create_tween();
	tween.tween_property(self, "modulate", original_color, .5);
	


func _on_mouse_entered() -> void:
	outline.modulate.v = .6;


func _on_mouse_exited() -> void:
	outline.modulate.v = .196
