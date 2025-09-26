extends TextureRect

class_name MoraleIcon

@export var low_morale_icon:Texture;
@export var mid_morale_icon:Texture;
@export var high_morale_icon:Texture;
@export var very_high_morale_icon:Texture;


@export var bar:TextureProgressBar;

func _ready()->void:
	Entities.player.morale_changed.connect(update)
	update();

func animated_update(target_value:float)->Tween:
	var tween:Tween = create_tween();
	tween.tween_property(bar, "value", target_value, 1);
	tween.tween_callback(update)
	return tween


func update(from_animation:bool=false)->void:
	var previous_texture:Texture = texture;
	var morale:float = Entities.player.morale;
	
	texture = get_texture_for_morale(morale);
	modulate = get_color_for_morale(morale);

	if texture != previous_texture:
		icon_change_animation()
	if bar and not from_animation:
		bar.value = morale;


func get_texture_for_morale(morale:float)->Texture:
	if morale < 2:
		return low_morale_icon;
	elif morale < 3:
		return mid_morale_icon;
	elif morale < 4:
		return high_morale_icon;
	else:
		return very_high_morale_icon;


func get_color_for_morale(morale:float)->Color:
	if morale < 1:
		return Color.DARK_RED;
	elif morale < 2:
		return Color.RED
	elif morale < 3:
		return Color.SKY_BLUE;
	elif morale < 4:
		return Color.SEA_GREEN;
	else:
		return Color.GREEN;


func icon_change_animation()->void:
	custom_minimum_size = custom_minimum_size * 1.5;
	var tween := create_tween();
	tween.tween_property(self, "custom_minimum_size", custom_minimum_size/1.5, .2)


func _on_player_morale_changed() -> void:
	update()
