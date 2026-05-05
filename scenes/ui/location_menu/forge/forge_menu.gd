extends UIRoot

class_name ForgeMenu

signal forge_finished

@export var forge_t1_sfx:AudioStream;
@export var forge_t2_sfx:AudioStream;
@export var forge_t3_sfx:AudioStream;
@export var item_chosen_sfx:AudioStream;

@export var forge_sfx:SfxPlayer;
@export var equipment_view_scrap_icon:ResourceIcon

@export var inventory_display:InventoryDisplay

@export var equipped_display_vbox:VBoxContainer;
@export var content_hbox:HBoxContainer

@export var to_forge_sample:ItemSample;
@export var anvil:TextureRect
@export var anvil_panel:PanelContainer

@export var current_mod_label:Label
@export var current_mod_description_label:RichTextLabel;

@export var forge_btn:Button
@export var scrap_cost_label:Label;
var current_scrap_cost:int;

@export var accessory_mods:Node;
@export var module_mods:Node;
@export var weapon_mods:Node

var item_to_forge:Item;

var player:Player

var equipped_samples:Array[ItemSample]

func start_forge_menu()->void:
	scrap_cost_label.hide()
	player = get_tree().get_first_node_in_group("player");
	
	inventory_display.open()
	
	for c:Node in equipped_display_vbox.get_children():
		if c is HBoxContainer and c.name != "scrap_counter":
			c.queue_free();
	equipped_samples = []

	equipped_display_vbox.add_child(load_player_equipped_items());
	for unit:FighterUnit in player.roster.units:
		if unit.equipped_accessory:
			var hbox:HBoxContainer = HBoxContainer.new();
			
			var unit_sample:UnitSample = Index.scenes.ui.unit_sample.instantiate();
			unit_sample.load_unit(unit);
			hbox.add_child(unit_sample);
			
			
			var item_sample:ItemSample = Index.scenes.ui.item_sample.instantiate();
			item_sample.load_item(unit.equipped_accessory, 2, true);
			equipped_samples.append(item_sample)
			hbox.add_child(item_sample);
			equipped_display_vbox.add_child(hbox);
			
	for sample:ItemSample in equipped_samples:
		sample.clicked.connect(equipped_item_chosen)

	equipment_view_scrap_icon.update()
	slide_in()

func load_player_equipped_items()->HBoxContainer:
	to_forge_sample.load_blank()
	var hbox:HBoxContainer = HBoxContainer.new()
	var player_sample:UnitSample = Index.scenes.ui.unit_sample.instantiate();
	player_sample.load_player();
	hbox.add_child(player_sample);
	
	var sample_scene:PackedScene = Index.scenes.ui.item_sample;
	
	var main_weapon_sample:ItemSample = sample_scene.instantiate();
	main_weapon_sample.load_item(player.equipped_weapon, 2, true);
	equipped_samples.append(main_weapon_sample)
	hbox.add_child(main_weapon_sample);
	
	if player.alternative_weapon:
		var alt_weapon_sample:ItemSample = sample_scene.instantiate();
		alt_weapon_sample.load_item(player.alternative_weapon, 2, true);
		equipped_samples.append(alt_weapon_sample)
		hbox.add_child(alt_weapon_sample)
	
	var module_sample:ItemSample = sample_scene.instantiate();
	module_sample.load_item(player.equipped_module, 2, true);
	equipped_samples.append(module_sample)
	hbox.add_child(module_sample)
	
	if player.equipped_accessory_1:
		var accessory_1_sample:ItemSample = sample_scene.instantiate();
		accessory_1_sample.load_item(player.equipped_accessory_1, 2, true);
		equipped_samples.append(accessory_1_sample)
		hbox.add_child(accessory_1_sample)
	
	if player.equipped_accessory_2:
		var accessory_2_sample:ItemSample = sample_scene.instantiate();
		accessory_2_sample.load_item(player.equipped_accessory_2, 2, true);
		equipped_samples.append(accessory_2_sample)
		hbox.add_child(accessory_2_sample)
	return hbox

	

	
func slide_in()->void:
	show()
	content_hbox.add_theme_constant_override("separation", 400);
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_CUBIC);
	tween.tween_property(content_hbox, "theme_override_constants/separation", 10, .75)

func slide_out()->void:
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_CUBIC);
	tween.tween_property(content_hbox, "theme_override_constants/separation", 400, .5)
	tween.parallel().tween_property(self, "modulate:a", 0, .5);
	tween.tween_callback(hide);
	tween.tween_callback(set_modulate.bind(Color.WHITE))


func _on_inventory_display_item_chosen(mirror: ItemMirror) -> void:
	if mirror.item is Consumable or mirror.item is ResourceContainer:
		inventory_display.invalid_move.emit("ITEM CAN'T BE FORGED")
		return
	inventory_display.board_shake()
	set_item_to_forge(mirror.item)

func equipped_item_chosen(item:Item)->void:
	set_item_to_forge(item)
	
func set_item_to_forge(target:Item)->void:
	forge_sfx.play_sound_obj(item_chosen_sfx)
	to_forge_sample.load_item(target, 4)
	item_to_forge = target;
	
	current_scrap_cost = forge_scrap_cost(target);
	scrap_cost_label.show()
	scrap_cost_label.text = "Forge Cost: " + str(current_scrap_cost) + " Scrap"
	
	refresh_view()
		

func forge_scrap_cost(item:Item)->int:
	return 2 * item.size_x * item.size_y * item.rarity;


func _on_button_pressed() -> void:
	assert(player.inventory.scrap >= current_scrap_cost);
	forge_item();

func play_forge_sfx(tier:int)->void:
	var stream:AudioStream = self["forge_t"+str(tier)+"_sfx"];
	forge_sfx.play_sound_obj(stream);

func forge_item()->void:
	## 5% chance of t3
	## 30% chance of t2
	## 70% chance of t1
	var roll_tier:int = 1;
	
	var roll:float = randf_range(0, 1);
	if roll > .95:
		roll_tier = 3;
	elif roll > .7:
		roll_tier = 2;

	play_forge_sfx(roll_tier);

	var mods_node:Node = weapon_mods;
	if item_to_forge is Accessory:
		mods_node = accessory_mods;
	elif item_to_forge is Module:
		mods_node = module_mods;
	
	var options_node:Node = mods_node.get_node("t"+str(roll_tier));
	var mod_roll:int = randi_range(0, options_node.get_child_count() - 1);
	
	var modifier:ItemModifier = options_node.get_child(mod_roll)
	modifier.apply_to_item(item_to_forge);
	

	var roll_color:Color = Index.mod_tier_colors[roll_tier-1]
	Tweens.floating_text(modifier.name, anvil, false, roll_color, roll_tier * 32)
	anvil.modulate = roll_color
	player.inventory.change_resource("scrap", -current_scrap_cost)
	
	
	refresh_view()

func has_item(sample:ItemSample, item:Item)->bool:
	return sample.item == item;

func refresh_view()->void:
	if item_to_forge:
		if item_to_forge.mirror:
			item_to_forge.mirror.refresh()
		var mod:ItemModifier = item_to_forge.applied_modifier;
		if mod:
			var tier_color:Color = Index.mod_tier_colors[mod.tier-1];
			current_mod_label.text = "Current:\n" + mod.name;
			current_mod_label.add_theme_color_override("font_color", tier_color);
			
			current_mod_description_label.text = mod.get_description();
			current_mod_description_label.show();
			current_mod_description_label.add_theme_color_override("font_color", tier_color);
			
			anvil_panel.self_modulate = tier_color
		else:
			current_mod_label.text = "Current:\nnone";
			current_mod_description_label.hide();
			current_mod_label.remove_theme_color_override("font_color")
			anvil_panel.self_modulate = Color.WHITE

	var sample_index:int = equipped_samples.find_custom(has_item.bind(item_to_forge)) 
	if sample_index != -1:
		equipped_samples[sample_index].refresh()
			
	to_forge_sample.refresh();
	equipment_view_scrap_icon.update()
	forge_btn.disabled = player.inventory.scrap < current_scrap_cost


func _on_exit_btn_pressed() -> void:
	forge_finished.emit();
	Entities.player.inventory.last_display = null;
	slide_out()
