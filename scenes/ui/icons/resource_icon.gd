extends Icon

class_name ResourceIcon
@export_enum("food", "fuel", "money", "juice", "scrap", "chips") var resource:String="food";

@export var panel:Panel;
var tooltip_name_color:Color;
var description:String;
@export var show_tooltip:bool;

@export var match_player_inventory:bool=true;
@export var adjacent_items:Array[CanvasItem];

var source:Inventory;

func _ready()->void:
	setup();
	

func setup()->void:
	texture = Index.textures.icons[resource];
	material.set_shader_parameter("base_color", Index.resource_colors[resource])
	
	if show_tooltip:
		name = resource.capitalize();
		tooltip_name_color = Index.resource_colors[resource];
		description = Index.resource_descriptions[resource];
	
	elif get_node_or_null("Tooltip"):
		$Tooltip.free();
	
	if not source:
		setup_adjacent_items();

func setup_adjacent_items()->void:
	for item:Node in adjacent_items:

		if item is Label:
			item.add_theme_color_override("font_color", Index.resource_colors[resource]);
			if match_player_inventory:

				Entities.player.resource_changed.connect(set_count_label.bind(item))
				set_count_label(resource, 0, item);
	

func set_count_label(r:String, _change:float, target:Label)->void:
	if r == resource:
		var value:int
		if match_player_inventory:
			value = Entities.player.inventory[r];
		target.text = str(value);
