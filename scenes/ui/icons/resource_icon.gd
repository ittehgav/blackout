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

func animated_update()->void:
	var target:int = source[resource];
	var current:int = int(label.text)
	var tween:Tween = create_tween();
	tween.tween_method(set_label_text, current, target, .65)
	if target < current:
		label.modulate = Color.RED;
	elif target > current:
		label.modulate = Color.GREEN
	tween.parallel().tween_property(label, "modulate", Color.WHITE, 1);
		

func set_label_text(target:int)->void:
	label.text = str(target);

func update()->void:
	label.text = str(source[resource]);

func get_icon_texture()->Texture2D:
	return Index.textures.icons[resource];

func get_color()->Color:
	return Index.get_color(resource);
