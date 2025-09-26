extends Icon

class_name ResourceIcon
@export_enum("food", "fuel", "money", "juice", "scrap", "chips") var resource:String="food";

@export var match_player_inventory:bool=true;

var source:Inventory;

func _ready()->void:
	super()
	if floating:
		return
	if match_player_inventory:
		source = Entities.player.inventory;
	if resource == "money":
		bg.hide();
	if source:
		update();

func update()->void:
	label.text = str(source[resource]);

func get_icon_texture()->Texture2D:
	return Index.textures.icons[resource];

func get_color()->Color:
	return Index.get_color(resource);
