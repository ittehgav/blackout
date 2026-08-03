extends Control

@export var sfx:AudioStreamPlayer;

@export var player_inventory_display:InventoryDisplay;

@export var weapon_sample:ItemSample;
@export var alt_weapon_sample:ItemSample;
@export var module_sample:ItemSample;

@export var accessory_1_sample:ItemSample;
@export var accessory_2_sample:ItemSample;

@export var artifice_1_sample:ItemSample;
@export var artifice_2_sample:ItemSample;
@export var artifice_3_sample:ItemSample;

@onready var all_samples: = [
	weapon_sample, alt_weapon_sample, module_sample,
	accessory_1_sample, accessory_2_sample,
	artifice_1_sample, artifice_2_sample, artifice_3_sample
	]

@export var switch_alt_button:Button;

@export var gear_color:Color;

var current_tween:Tween;
var first_refresh:bool=true;
var first_alt_refresh:bool=true;

	
func enable_switch_btn()->void:
	switch_alt_button.disabled = false;
	switch_alt_button.modulate = Color.WHITE;

func disable_switch_btn()->void:
	switch_alt_button.disabled = true;
	switch_alt_button.modulate = Color.from_hsv(0, 0, .5, .75)

func refresh_samples(just_changed:Equipment=null)->void:
	## just_changed = from Player equipment_changed signal
	if Entities.player.alternative_weapon:
		enable_switch_btn()
	else:
		disable_switch_btn()

	weapon_sample.load_item(Entities.player.equipped_weapon, 3)
	module_sample.load_item(Entities.player.equipped_module, 3);
	
	for i:int in 3:
		var sample:ItemSample = self["artifice_"+str(i+1)+"_sample"]
		var equipped:Artifice = Entities.player.equipped_artifices[i+1];
		if equipped:
			sample.load_item(equipped, 3);
		else:
			sample.load_blank();
		
	if Entities.player.alternative_weapon:
		alt_weapon_sample.load_item(Entities.player.alternative_weapon, 2);
	else:
		alt_weapon_sample.load_blank()
	
	for i:int in 2:
		var accessory:Accessory = Entities.player["equipped_accessory_"+str(i+1)];
		var sample:ItemSample = self["accessory_"+str(i+1)+"_sample"]
		if accessory:
			sample.load_item(accessory, 3)
		else:
			sample.load_blank(1);
	
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


		if just_changed is Artifice:
			sfx.play_sound_by_key("artifice_equipped");
			var key:Variant= Entities.player.equipped_artifices.find_key(just_changed)
			if key:
				self["artifice_"+str(key)+"_sample"].highlight_blink()
	
	first_refresh=false;

func _on_inventory_display_extension_shown() -> void:
	hide()

func _on_inventory_display_extension_hidden() -> void:
	show();


func _on_switch_alt_pressed() -> void:
	sfx.play_sound_by_key("weapon_equipped")
	Entities.player.switch_weapons()

	weapon_sample.highlight_blink();
	alt_weapon_sample.highlight_blink()

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
		elif not player_inventory_display.has_room(Entities.player.equipped_weapon):
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
		if not player_inventory_display.has_room(Entities.player.alternative_weapon):
			invalid_move("NOT ENOUGH ROOM IN INVENTORY");
		else:
			sfx.play_sound_by_key("weapon_equipped")
			send_item_to_inventory(Entities.player.alternative_weapon)
			Entities.player.equipment.erase(Entities.player.alternative_weapon)
			Entities.player.alternative_weapon = null;
			alt_weapon_sample.load_blank(1)
			refresh_samples()


func send_item_to_inventory(item:Item)->void:
	player_inventory_display.throw_in_inventory(item);
	player_inventory_display.refresh_data()
	player_inventory_display.board_shake();
	
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
	var ac_key:String = "equipped_accessory_"+str(which)
	var sample:ItemSample = self["accessory_"+str(which)+"_sample"]
	var to_unequip:Accessory=Entities.player[ac_key]
	if not player_inventory_display.has_room(to_unequip):
		invalid_move("NOT ENOUGH ROOM");
		return;
		
	Entities.player.unequip_accessory(to_unequip, which);
	sample.load_blank(2)
	

	player_inventory_display.throw_in_inventory(to_unequip)

	
	sfx.play_sound_by_key("accessory_equipped")

func unequip_artifice(slot:int)->void:
	var to_unequip:Artifice = Entities.player.equipped_artifices[slot]
	
	if not player_inventory_display.has_room(to_unequip):
		invalid_move("NOT ENOUGH ROOM")
		return
		
	Entities.player.unequip_artifice(slot)
	self["artifice_"+str(slot)+"_sample"].load_blank()
	for item:Artifice in Entities.player.inventory.artifices:
		if item.unique_name == to_unequip.unique_name:
			item.mirror.refresh()
	to_unequip.mirror.display.board_shake(5)


func _on_accessory_1_sample_gui_input(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_RIGHT\
		and Entities.player.equipped_accessory_1:
			unequip_accessory(1)



func _on_accessory_2_sample_gui_input(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_RIGHT\
		and Entities.player.equipped_accessory_2:
			unequip_accessory(2)


func _on_inventory_display_accessory_equipped_on_unit() -> void:
	sfx.play_sound_by_key("accessory_equipped")


func _on_artifice_1_gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_RIGHT\
		and Entities.player.equipped_artifices[1]:
			unequip_artifice(1)
func _on_artifice_2_gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_RIGHT\
		and Entities.player.equipped_artifices[2]:
			unequip_artifice(2)
func _on_artifice_3_gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_RIGHT\
		and Entities.player.equipped_artifices[3]:
			unequip_artifice(3)
