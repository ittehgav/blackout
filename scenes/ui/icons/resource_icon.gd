extends Icon

class_name ResourceIcon
@export_enum("food", "fuel", "money", "juice", "scrap", "chips") var resource:String="food";

@export var panel:Panel;
var tooltip_name_color:Color;
var description:String;
@export var show_tooltip:bool;
@export var in_trade:bool;

@export var adjacent_items:Array[CanvasItem];



func _ready()->void:
	texture = Index.icons[resource];
	material.set_shader_parameter("base_color", Index.resource_colors[resource])
	
	if show_tooltip:
		name = resource.capitalize();
		tooltip_name_color = Index.resource_colors[resource];
		description = Index.resource_descriptions[resource]
	else:
		$Tooltip.queue_free();
	
	setup_adjacent_items();
	

func setup_adjacent_items(value:int=Entities.player.inventory[resource]):
	for item in adjacent_items:
		item.modulate = Index.resource_colors[resource]
		if item is Label:
			if value == Entities.player.inventory[resource]:
				Entities.player.resources_changed.connect(set_count_label.bind(item))
			set_count_label(item, value);
	

func set_count_label(target:Label, value:int)->void:
	target.text = str(value);
