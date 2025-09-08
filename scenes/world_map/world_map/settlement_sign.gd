extends HBoxContainer

class_name SettlementSign;

@export var current_icons:Array[TextureRect]
@export var placeholder:Control

func load_settlement(target:Settlement)->void:
	while len(current_icons):
		current_icons[0].free()
		current_icons.remove_at(0);
	
	if target.data.seen:
		placeholder.hide();
		for building:Building in target.buildings:
			var icon:Texture = building.icon_texture;
			var rect:TextureRect = TextureRect.new();
			rect.texture = icon;
			rect.custom_minimum_size = Vector2(building.size * 64, 64);
			add_child(rect);
			current_icons.append(rect);
	else:
		placeholder.show();
		
