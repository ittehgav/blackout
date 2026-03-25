extends PanelContainer

@export var equipment:EquipmentControl

@export var main_weapon_cd_timer:Timer;
@export var alt_weapon_cd_timer:Timer;

@export var alt_weapon_container:PanelContainer

@export var cooldown_bar:TextureProgressBar;
@export var alt_cooldown_bar:TextureProgressBar;

@export var main_weapon_ammo_hbox:HBoxContainer
@export var alt_weapon_ammo_hbox:HBoxContainer

var ammo_labels:Dictionary[String, Array];

var displaying_weapon:Weapon;
var displaying_alt_weapon:Weapon;

func _ready() -> void:
	display_weapon(Entities.player.equipped_weapon)
	cooldown_bar.max_value = main_weapon_cd_timer.wait_time;
	
	if Entities.player.alternative_weapon:
		display_alt_weapon(Entities.player.alternative_weapon)
		alt_cooldown_bar.max_value = alt_weapon_cd_timer.wait_time;
	else:
		alt_weapon_container.hide()
	
func _process(_delta:float)->void:
	cooldown_bar.value = main_weapon_cd_timer.wait_time - main_weapon_cd_timer.time_left;
	alt_cooldown_bar.value = alt_weapon_cd_timer.wait_time - alt_weapon_cd_timer.time_left;

func display_weapon(target:Weapon)->void:
	displaying_weapon = target;
	load_weapon_to_bar(target, cooldown_bar);

func display_alt_weapon(target:Weapon)->void:
	displaying_alt_weapon = target;
	load_weapon_to_bar(target, alt_cooldown_bar, true);

func load_weapon_to_bar(weapon:Weapon, bar:TextureProgressBar, alt:bool=false)->void:
	var weapon_texture:Texture;
	if weapon.active_texture:
		weapon_texture = weapon.item_texture;
	else:
		weapon_texture = weapon.texture

	bar.texture_under = weapon_texture;
	bar.texture_progress = weapon_texture;
	
	var target_size:Vector2 = weapon_texture.get_size();
	

	
	if not alt:
		target_size *= 2

	var ammo_hbox:HBoxContainer = main_weapon_ammo_hbox if not alt else alt_weapon_ammo_hbox;
	for c:Node in ammo_hbox.get_children():
		## does nothing the first time but it's simpler this way
		c.queue_free()
		
	if weapon.ammo_type:
		var icon:ResourceIcon = Index.scenes.ui.resource_icon.instantiate();
			
		icon.bg.hide()
		icon.custom_minimum_size = Vector2(16, 16)
		icon.size = Vector2(16, 16)

		var label:Label = Label.new();
		icon.resource = weapon.ammo_type;
		icon.label = label;
		if not ammo_labels.has(weapon.ammo_type):
			ammo_labels[weapon.ammo_type] = []
		ammo_labels[weapon.ammo_type].append(label)
		
		if alt:
			icon.size = Vector2(8, 8);
			label.add_theme_font_size_override("font_size", 16)
		
		
		ammo_hbox.add_child(icon);
		ammo_hbox.add_child(label)
			
	
	bar.custom_minimum_size = target_size;
	bar.size = target_size;
	
	bar.tint_progress = weapon.get_mirror_color();

	
func _on_equipment_weapon_changed() -> void:
	ammo_labels = {};
	
	display_weapon(equipment.equipped_weapon);
	display_alt_weapon(equipment.alt_weapon)
		
	cooldown_bar.max_value = main_weapon_cd_timer.wait_time;
	alt_cooldown_bar.max_value = alt_weapon_cd_timer.wait_time;

	check_weapon_disabled();
	
func check_weapon_disabled()->void:
	if equipment.equipped_weapon.check_disabled():
		cooldown_bar.modulate.a = .5;
		cooldown_bar.modulate.v = .5;
	else:
		cooldown_bar.modulate = Color.WHITE;
	
	if equipment.alt_weapon:
		if equipment.alt_weapon.check_disabled():
			alt_cooldown_bar.modulate.a = .5;
			alt_cooldown_bar.modulate.v = .5;
		else:
			alt_cooldown_bar.modulate = Color.WHITE


func _on_equipment_ammo_consumed(ammo_type: String, _amount: int) -> void:
	if ammo_labels.has(ammo_type):
		for label:Label in ammo_labels[ammo_type]:
			label.text = str(Entities.player.inventory[ammo_type])
	
	if ammo_type == displaying_weapon.ammo_type:
		main_weapon_ammo_hbox.modulate.a = .25;
		var tween:Tween = create_tween();
		tween.tween_property(main_weapon_ammo_hbox, "modulate:a", 1, .5)
	
	if ammo_type == displaying_alt_weapon.ammo_type:
		alt_weapon_ammo_hbox.modulate.a = .25;
		var tween:Tween = create_tween();
		tween.tween_property(alt_weapon_ammo_hbox, "modulate:a", 1, .5)


func _on_weapon_cd_timeout() -> void:
	self_modulate.v = 1
	self_modulate.a = 1


func _on_equipment_weapon_used() -> void:
	await get_tree().create_timer(.01).timeout
	self_modulate.v = .5
	self_modulate.a = .5
