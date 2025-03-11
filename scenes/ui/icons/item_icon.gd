extends Icon

class_name ItemIcon;

@export var tooltip:Tooltip;
## item gets assigned before loading into scene.
@export var item:Item;

var description:String;


func _ready():
	texture = item.texture.duplicate();
	tooltip.target = item;
	if item is Consumable:
		gui_input.connect(use_item);
	var base_color:Color = Icons.item_rarity_colors[item.rarity];
	material.set_shader_parameter("base_color", base_color)


func use_item(e:InputEvent)->void:
	if e.is_action_pressed("use_item"):
		print("use?")
