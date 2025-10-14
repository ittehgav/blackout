extends HBoxContainer

class_name SettlementSign;

var current_icons:Array[TextureRect]

@export var dungeon_data:HBoxContainer
@export var dungeon_level_label:Label

@export var skull_1:TextureRect
@export var skull_2:TextureRect
@export var skull_3:TextureRect

func load_settlement(target:Settlement)->void:
	reset()
	if target.locations[0] is Building:
		if target.data.seen:
			for location:Location in target.locations:
				var icon:Texture = location.icon_texture;
				var rect:TextureRect = TextureRect.new();
				rect.texture = icon;
				rect.custom_minimum_size = Vector2(location.size * 64, 64);
				add_child(rect);
				current_icons.append(rect);
	elif target.locations[0] is Dungeon:
		display_dungeon(target.locations[0])

func reset()->void:
	while len(current_icons):
		current_icons[0].free()
		current_icons.remove_at(0);
	dungeon_data.hide()

func display_dungeon(target:Dungeon)->void:
	dungeon_data.show();
	var danger_level:int = target.get_danger_level()
	dungeon_level_label.text = str(target.highest_level_target)
	match danger_level:
		1:
			skull_2.hide();
			skull_3.hide();
			
			skull_1.material.set_shader_parameter("color:a", 0);
		2:
			skull_2.show();
			skull_3.hide();
			
			skull_1.material.set_shader_parameter("color:a", 0);
		3:
			skull_2.show();
			skull_3.show();
			
			skull_1.material.set_shader_parameter("color:a", 0);
		_:
			skull_2.show();
			skull_3.show();
		
			skull_1.material.set_shader_parameter("color:a", 1);
