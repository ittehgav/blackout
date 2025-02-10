extends Control

class_name Tooltip;

@export var name_label:Label;
@export var thumbnail_image:TextureRect;

func _ready()->void:
	await get_parent().ready;
	var parent:Node2D = get_parent()
	if parent is Settlement:
		build_settlement_tooltip(parent);
			
func build_settlement_tooltip(settlement:Settlement)->void:
	## eventually will show more information based on the player's
	## tracking(?) skill
	name_label.text = settlement.name;
	var texture:Texture = settlement.get_node("sprite").texture;
	thumbnail_image.texture = texture.duplicate();
