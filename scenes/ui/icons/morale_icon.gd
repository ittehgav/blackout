extends TextureRect

@export var low_morale_icon:Texture;
@export var mid_morale_icon:Texture;
@export var high_morale_icon:Texture;
@export var very_high_morale_icon:Texture;


@export var bar:TextureProgressBar;

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
	modulate = target_color;
	if bar:
		bar.value = morale;

func icon_change_animation()->void:
	custom_minimum_size = custom_minimum_size * 1.5;
	var tween := create_tween();
	tween.tween_property(self, "custom_minimum_size", custom_minimum_size/1.5, .2)


func _on_player_morale_changed() -> void:
	update()
