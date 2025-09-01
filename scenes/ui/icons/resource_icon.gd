extends Icon

class_name ResourceIcon
@export_enum("food", "fuel", "money", "juice", "scrap", "chips") var resource:String="food";

@export var bg:ColorRect
@export var show_tooltip:bool=true;

@export var match_player_inventory:bool=true;

var source:Inventory;

func _ready()->void:
	if match_player_inventory:
		source = Entities.player.inventory;
	
	texture = Index.textures.icons[resource];
	
	default_color = Index.get_color(resource)
	highlight_color = default_color;
	highlight_color.a += .3
	
	modulate = default_color
	label.add_theme_color_override("font_color", default_color);
	
	
	if resource == "money":
		bg.hide()

	if not show_tooltip and get_node_or_null("Tooltip"):
		$Tooltip.free();
	
	if source:
		update();


func update()->void:
	label.text = str(source[resource]);

	
