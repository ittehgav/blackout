extends UIRoot;


@export var sfx_icon:TextureButton;
@export var music_icon:TextureButton;

@export var sfx_muted_icon:TextureRect
@export var music_muted_icon:TextureRect;


@export var music_slider:HSlider;
@export var sfx_slider:HSlider;

@onready var initial_sfx_volume:float = AudioServer.get_bus_volume_db(2);
@onready var initial_music_volume:float = AudioServer.get_bus_volume_db(1);

@onready var initial_slider_value:float = music_slider.value;

var return_target:Control;


	
func show_settings(before:Control)->void:
	return_target = before
	Tweens.ui_fade_out(before);
	Tweens.ui_fade_in(self);

func return_from_settings()->void:
	Tweens.ui_fade_in(return_target);
	Tweens.ui_fade_out(self);

func _on_music_slider_value_changed(value: float) -> void:
	if value == 0:
		toggle_music()
	else:
		if music_muted_icon.visible:
			toggle_music()
		var db:float = db_to_linear(value - initial_slider_value + initial_music_volume);
		AudioServer.set_bus_volume_db(1, db)
	
func toggle_music(from_click:bool=false)->void:
	if music_muted_icon.visible:
		music_muted_icon.hide();
		if from_click:
			music_slider.value = initial_slider_value;
			_on_music_slider_value_changed(initial_slider_value)
			
	else:
		
		AudioServer.set_bus_volume_linear(1, 0);
		music_muted_icon.show()
		
func toggle_sfx(from_click:bool=false)->void:
	if sfx_muted_icon.visible:
		sfx_muted_icon.hide();
		if from_click:
			sfx_slider.value = initial_slider_value;
			_on_sfx_slider_value_changed(initial_slider_value)
	else:
		AudioServer.set_bus_volume_linear(2, 0);
		sfx_muted_icon.show()
		
func _on_sfx_slider_value_changed(value: float) -> void:
	if value == 0:
		toggle_sfx()
	else:
		if sfx_muted_icon.visible:
			sfx_muted_icon.hide()
		var db:float = db_to_linear(value - initial_slider_value + initial_sfx_volume);
		AudioServer.set_bus_volume_db(2, db)


func _on_reset_pressed() -> void:
	music_slider.value = initial_slider_value;
	_on_music_slider_value_changed(initial_slider_value)
	
	sfx_slider.value = initial_slider_value;
	_on_sfx_slider_value_changed(initial_slider_value)
