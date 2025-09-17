extends TextureRect

class_name ItemSample;

var clickable:bool=false;

signal clicked;

@export var modifier_sign:Label;
@export var outline:ReferenceRect;
@export var tooltip:Tooltip;
@export var bg:ColorRect;
@export var blank:TextureRect

var item:Item;
@export var button:TextureButton


func load_item(new_item:Item, sample_scale:int=2.5)->void:
	item = new_item;
	blank.hide();
	texture = item.texture;
	var sample_size:Vector2 = Vector2(item.size_x, item.size_y) * 16 * sample_scale
	custom_minimum_size = sample_size;
	size = sample_size;
	
	tooltip.load_target(self);
	tooltip.enable()
	
	modifier_sign.hide()
	if item.applied_modifier:
		modifier_sign.show()
	
	modulate = new_item.get_mirror_color();
	self_modulate.a = 1;
	self_modulate.v = 1;
	
	if clickable:
		button.show()



func load_blank(sample_scale:int = 1)->void:
	modifier_sign.hide()
	blank.show();
	modulate = Color.WHITE
	self_modulate.a = 0;
	
	outline.border_width = sample_scale * 2

	var sample_size:Vector2 = Vector2(sample_scale * 32, sample_scale * 32);
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


func _on_texture_button_pressed() -> void:
	clicked.emit()
