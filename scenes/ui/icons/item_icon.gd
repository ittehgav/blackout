extends TextureRect

class_name ItemIcon;

@export var tooltip:Tooltip;
## item gets assigned before loading into scene.
@export var item:Item;

var description:String;


func _ready():
	texture = item.texture.duplicate();
	tooltip.target = item;
	
	var base_color:Color = Icons.item_rarity_colors[item.rarity];
	material.set_shader_parameter("base_color", base_color)
