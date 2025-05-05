extends Icon

class_name ResourceIcon
@export_enum("food", "fuel", "money", "juice", "scrap", "chips") var resource:String="food";

@export var panel:Panel;
var tooltip_name_color:Color;
var description:String;
@export var show_tooltip:bool;
@export var in_trade:bool;

@export var adjacent_items:Array[CanvasItem];

var source:Inventory;

func _ready()->void:
	texture = Index.icons[resource];
	material.set_shader_parameter("base_color", Index.resource_colors[resource])
	
	if show_tooltip:
		name = resource.capitalize();
		tooltip_name_color = Index.resource_colors[resource];
		description = Index.resource_descriptions[resource]
	else:
		$Tooltip.queue_free();
	
	if not source:
		setup_adjacent_items();


func setup_adjacent_items(value:int=Entities.player.inventory[resource])->void:
	for item:Node in adjacent_items:

		if item is Label:
			item.add_theme_color_override("font_color", Index.resource_colors[resource]);
			if source == Entities.player.inventory:
				Entities.player.resource_changed.connect(set_count_label.bind(item))
			set_count_label(resource, 0, item, value);
	

func set_count_label(r:String,_change:float, target:Label, value:int=Entities.player.inventory[resource])->void:
	if r == resource:
		target.text = str(value);
