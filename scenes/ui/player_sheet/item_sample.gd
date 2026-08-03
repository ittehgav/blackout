extends TextureRect

class_name ItemSample;

var clickable:bool=false;

signal clicked(item:Item);

@export var outline:ReferenceRect;
@export var tooltip:Tooltip;
@export var bg:ColorRect;
@export var blank:TextureRect
@export var hover_sfx:AudioStreamPlayer;


#@export var modifier_icon:ItemModifierIcon

var item:Item;
@export var button:TextureButton



func refresh(animated:bool=true)->void:
	## push more stuff from load_item to here when need be?
	#if item:
		#modifier_icon.refresh(item)
	if animated:
		highlight_blink()

func load_item(new_item:Item, sample_scale:int=2, make_clickable:bool=false)->void:
	clickable = make_clickable
	item = new_item;
	blank.hide();
	texture = item.texture;
	var sample_size:Vector2 = Vector2(item.size_x, item.size_y) * 16 * sample_scale
	custom_minimum_size = sample_size;
	size = sample_size;
	
	tooltip.enable()
	
	modulate = Index.get_color(item.color_tag);
	self_modulate.a = 1;
	self_modulate.v = 1;
	
	if clickable:
		button.show()
	refresh(false)


func load_blank(sample_scale:int = 2)->void:
	#modifier_icon.hide()
	texture = null
	blank.show();
	modulate = Color.WHITE
	self_modulate.a = 0;
	
	outline.border_width = sample_scale * 2

	var sample_size:Vector2 = Vector2(16, 16) * sample_scale * 2;
	custom_minimum_size = sample_size;
	size = sample_size;
	
	tooltip.disable();

func highlight_blink()->void:
	modulate =  Color.WHITE;
	var tween:Tween = create_tween();
	tween.tween_property(self, "modulate", Index.get_color(item.color_tag), .5);


func _on_mouse_entered() -> void:
	Tweens.mouseover_shake(self, PI/24, .03)
	hover_sfx.play()
	outline.modulate.v = .6;

@onready var initial_outline_v:float = outline.modulate.v
func _on_mouse_exited() -> void:
	outline.modulate.v = initial_outline_v


func _on_texture_button_pressed() -> void:
	clicked.emit(item)
	
