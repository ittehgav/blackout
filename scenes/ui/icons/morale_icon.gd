extends TextureRect

@export var low_morale_icon:Texture;
@export var mid_morale_icon:Texture;
@export var high_morale_icon:Texture;
@export var very_high_morale_icon:Texture;

## adjacent items need to be white/white adjacent to get the color properly
@export var adjacent_items:Array[CanvasItem];

func _ready()->void:
	Entities.player.morale_changed.connect(update)
	update();

func update()->void:
	var previous_texture:Texture = texture;
	var morale:float = Entities.player.morale;
	var target_color:Color
	if morale < 2:
		texture = low_morale_icon;
		if morale < 1:
			target_color = Color.DARK_RED
		else:
			target_color = Color.RED
	elif morale < 3.0:
		texture = mid_morale_icon;
		target_color = Color.SKY_BLUE;
	elif morale < 4:
		texture=high_morale_icon;
		target_color = Color.SEA_GREEN
	else:
		texture = very_high_morale_icon
		target_color = Color.GREEN;
	if texture != previous_texture:
		icon_change_animation()
	material.set_shader_parameter("base_color", target_color);
	
	for item in adjacent_items:
		item.modulate = target_color;
		if item.name == "morale_value":
			item.text = str(snapped(Entities.player.morale, .01));

func icon_change_animation()->void:
	custom_minimum_size = custom_minimum_size * 1.5;
	var tween := create_tween();
	tween.tween_property(self, "custom_minimum_size", custom_minimum_size/1.5, .2)
