extends Control

@export var sfx:AudioStreamPlayer;

@export var player_inventory_display:InventoryDisplay;

@export var weapon_sample:ItemSample;
@export var alt_weapon_sample:ItemSample;
@export var module_sample:ItemSample;

@export var accessory_1_sample:ItemSample;
@export var accessory_2_sample:ItemSample;

@onready var all_samples: = [weapon_sample, alt_weapon_sample, module_sample, accessory_1_sample, accessory_2_sample]

@export var switch_alt_button:Button;

@export var gear_color:Color;

var current_tween:Tween;
var first_refresh:bool=true;
var first_alt_refresh:bool=true;

	

func refresh_samples(just_changed:Equipment=null)->void:
	if Entities.player.alternative_weapon:
		switch_alt_button.disabled = false;
	else:
		switch_alt_button.disabled = true
	
	

	weapon_sample.load_item(Entities.player.equipped_weapon, gear_color)
	module_sample.load_item(Entities.player.equipped_module, gear_color);

	if Entities.player.alternative_weapon:
		alt_weapon_sample.load_item(Entities.player.alternative_weapon, gear_color, 1);
	else:
		alt_weapon_sample.load_blank(Vector2(2, 3), gear_color)
	
	for i:int in 2:
		var accessory:Accessory = Entities.player["equipped_accessory_"+str(i+1)];
		var sample:ItemSample = self["accessory_"+str(i+1)+"_sample"]
		if accessory:
			sample.load_item(accessory, gear_color)
		else:
			sample.load_blank(Vector2(4, 4), gear_color);
	
	if just_changed:
		match just_changed:
			Entities.player.equipped_weapon:
				sfx.play_sound_by_key("weapon_equipped")
				weapon_sample.highlight_blink();
			Entities.player.alternative_weapon:
				sfx.play_sound_by_key("weapon_equipped")
				alt_weapon_sample.highlight_blink();
			Entities.player.equipped_module:
				sfx.play_sound_by_key("module_equipped")
				module_sample.highlight_blink();
			Entities.player.equipped_accessory_1:
				sfx.play_sound_by_key("accessory_equipped")
				accessory_1_sample.highlight_blink(); 
			Entities.player.equipped_accessory_2:
				sfx.play_sound_by_key("accessory_equipped")
				accessory_2_sample.highlight_blink();
			
	first_refresh=false;

func _on_inventory_display_extension_shown() -> void:
	hide()

func _on_inventory_display_extension_hidden() -> void:
	show();


func _on_switch_alt_pressed() -> void:
	shake_samples();
	sfx.play_sound_by_key("weapon_equipped")
	var new_main_weapon:Weapon = Entities.player.alternative_weapon;
	var new_alt_weapon:Weapon = Entities.player.equipped_weapon;
	
	Entities.player.equip_weapon(new_main_weapon);
	Entities.player.equip_alt_weapon(new_alt_weapon)
	weapon_sample.highlight_blink();

var shake_delay:Timer=Timer.new();
func shake_samples()->void:
	const shake_range:int = 5;
	var shift:Vector2 = Vector2(randi_range(-shake_range, shake_range), randi_range(-shake_range, shake_range));
	
	if shake_delay.is_stopped():
		shake_delay.wait_time = 1;
		shake_delay.start();
		for i:int in len(all_samples)-1:
			## so it doesn't send the shake to the accessories hbox twice
			var sample:ItemSample = all_samples[i]
			var target:Control = sample.get_parent();
			target.position += shift;
			var tween:Tween = create_tween();
			tween.tween_property(target, "position",target.position - shift, .15)

func _on_weapon_sample_gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_RIGHT:
		if not Entities.player.alternative_weapon:
			invalid_move("NEED AT LEAST 1 WEAPON EQUIPPED")
		elif player_inventory_display.find_clear_cell(Entities.player.equipped_weapon) == Vector2i(-1, -1):
			invalid_move("NOT ENOUGH ROOM IN INVENTORY");
		else:
			sfx.play_sound_by_key("weapon_equipped")
			send_item_to_inventory(Entities.player.equipped_weapon)
			var new_weapon:Weapon = Entities.player.alternative_weapon;
			Entities.player.alternative_weapon = null;
			
			Entities.player.equip_weapon(new_weapon);


func _on_alt_weapon_sample_gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_RIGHT\
		and Entities.player.alternative_weapon:
		if player_inventory_display.find_clear_cell(Entities.player.alternative_weapon) == Vector2i(-1, -1):
			invalid_move("NOT ENOUGH ROOM IN INVENTORY");
		else:
			sfx.play_sound_by_key("weapon_equipped")
			send_item_to_inventory(Entities.player.alternative_weapon)
			Entities.player.equipment.erase(Entities.player.alternative_weapon)
			Entities.player.alternative_weapon = null;
			alt_weapon_sample.load_blank(Vector2(2, 3), gear_color)


func send_item_to_inventory(item:Item)->void:
	player_inventory_display.throw_in_inventory(item);
	player_inventory_display.refresh_data()
	player_inventory_display.board_shake(3);
	
func invalid_move(message:String)->void:
	sfx.play_sound_by_key("invalid");
	
	var label:Label = Label.new();
	label.add_theme_font_size_override("font_size", 48)
	label.modulate = Color.RED;
	label.text = message;
	add_child(label);
	label.global_position = get_global_mouse_position();
	label.z_index = 1;
	
	var tween:= create_tween();
	tween.tween_property(label, "position:y", label.position.y - 30, 3);
	tween.parallel().tween_property(label, "modulate:a", 0, 3);
	
	tween.tween_callback(label.free);
	

func unequip_accessory(which:int)->void:
	var to_unequip:Accessory
	match which:
		1:
			to_unequip = Entities.player.equipped_accessory_1;
			var clear_cell:Vector2i = player_inventory_display.find_clear_cell(to_unequip)
			if clear_cell == Vector2i(-1, -1):
				invalid_move("NOT ENOUGH ROOM");
				return
			Entities.player.equipped_accessory_1 = null
			accessory_1_sample.load_blank(Vector2(4, 4), gear_color)
		2:
			to_unequip = Entities.player.equipped_accessory_2;
			if player_inventory_display.find_clear_cell(to_unequip) == Vector2i(-1, -1):
				invalid_move("NOT ENOUGH ROOM");
				return
			Entities.player.equipped_accessory_2 = null
			accessory_2_sample.load_blank(Vector2(4, 4), gear_color)

	Entities.player.equipment.erase(to_unequip);
	send_item_to_inventory(to_unequip)
	
	
	sfx.play_sound_by_key("accessory_equipped")
	
		

func _on_accessory_1_sample_gui_input(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_RIGHT\
		and Entities.player.equipped_accessory_1:
			unequip_accessory(1)



func _on_accessory_2_sample_gui_input(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_RIGHT\
		and Entities.player.equipped_accessory_2:
			unequip_accessory(2)
