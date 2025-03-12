extends Icon

class_name ItemIcon;

@export var tooltip:Tooltip;
## item gets assigned before loading into scene.
@export var item:Item;
@export var in_trade:bool;


var description:String;


func _ready():
	if item is Weapon:
		## forces the item into a square frame where it fits
		var size = item.texture.get_size();
		var target_size = max(size.x, size.y)
		var panel_size = Vector2(target_size, target_size);
		$panel.custom_minimum_size = panel_size;
		custom_minimum_size = panel_size;
	texture = item.texture.duplicate();
	tooltip.target = item;

	var base_color:Color = Icons.item_rarity_colors[item.rarity];
	material.set_shader_parameter("base_color", base_color)
