extends Control


@export var display:InventoryDisplay;
@export var trade_menu:Control

@export var slider:HSlider;

@export var add_1_btn:Button
@export var add_5_btn:Button;
@export var add_max_btn:Button
@export var add_custom:Button

var current_mirror:ItemMirror;

var base_text:String;
var unitary_price:float

var from_player:bool;

func show_picker(mirror:ItemMirror)->void:
	from_player  = display.inventory == Entities.player.inventory;
	if from_player:
		unitary_price = display.exchanging_display.inventory.resource_selling_prices[mirror.item.resource]
		base_text = "SELL ";
	else:
		unitary_price = display.inventory.resource_buying_prices[mirror.item.resource]
		base_text = "BUY ";
		
	for item:Button in [add_1_btn, add_5_btn, add_max_btn, add_custom]:
		item.add_theme_color_override("font_color", Index.get_color(mirror.item.resource))
	global_position = get_global_mouse_position() - Vector2(5, 5);
	Tweens.ui_fade_in(self);
	
	current_mirror = mirror;
	
	slider.max_value = mirror.stack_size;
	slider.value = 10;
	
	refresh();

func refresh()->void:
	add_1_btn.text = base_text + "1\n$" + str(int(unitary_price))
	add_5_btn.text = base_text + "5\n$" + str(int(unitary_price * 5));
	add_max_btn.text = base_text+str(current_mirror.stack_size) +  "\n$" + str(int(current_mirror.stack_size * unitary_price));

	
	

func check_finished()->void:
	if not Input.is_action_pressed("persist_command"):
		Tweens.ui_fade_out(self)
	else:
		refresh()
		
func _on_pick_1_pressed() -> void:
	display.send_resource(current_mirror, 1);
	check_finished()


func _on_pick_5_pressed() -> void:
	display.send_resource(current_mirror, 5);
	check_finished()


func _on_pick_max_pressed() -> void:
	display.send_resource(current_mirror, current_mirror.stack_size);
	check_finished()



func _on_add_custom_pressed() -> void:
	display.send_resource(current_mirror, slider.value)
	check_finished()


func _on_slider_value_changed(value: float) -> void:
	add_custom.text = base_text + " " + str(int(slider.value)) + "\n$" + str(int(slider.value * unitary_price))
	


func _on_panel_container_mouse_exited() -> void:
	if modulate.a == 1:
		$disappear.start();


func _on_disappear_timeout() -> void:
	Tweens.ui_fade_out(self)


func _on_panel_container_mouse_entered() -> void:
	$disappear.stop();
