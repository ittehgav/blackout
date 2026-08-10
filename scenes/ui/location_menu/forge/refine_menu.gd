extends UIRoot

class_name RefinementMenu

signal refinement_finished

@export var r1_sfx:AudioStream;
@export var r2_sfx:AudioStream;
@export var r3_sfx:AudioStream;

@export var modifier_sfx:AudioStream

@export var item_chosen_sfx:AudioStream;

@export_subgroup("refinement")
@export var refine_view:VBoxContainer;
@export var refine_sfx:SfxPlayer;
@export var equipment_view_scrap_icon:ResourceIcon
@export var equipment_view_chips_icon:ResourceIcon

@export var inventory_display:InventoryDisplay

@export var equipped_display_vbox:VBoxContainer;
@export var content_hbox:HBoxContainer

@export var refinement_level_label:Label

@export var to_refine_sample:ItemSample;
@export var anvil:TextureRect
@export var anvil_panel:PanelContainer

@export var current_weapon_description_label:RichTextLabel;

@export var refine_btn:Button
@export var scrap_cost_hbox:HBoxContainer
@export var scrap_cost_label:Label;

var current_scrap_cost:int;
@export_subgroup("Module Modifying")

var current_chips_cost:int;
@export var modify_view:VBoxContainer;

@export var to_modify_name:Label;

@export var to_modify_sample:ItemSample;
@export var m1_description:RichTextLabel;
@export var m1_button:Button;

@export var m2_description:RichTextLabel;
@export var m2_button:Button

@export var chips_cost_label:Label





var item_to_refine:Item;
## keeping this loosely referring to items rather
## than just weapons because maybe we make other stuff refineable
## in the future

@onready var player:Player = Entities.player;

var equipped_samples:Array[ItemSample]

func start_refinement_menu()->void:
	inventory_display.open()
	for mirror:ItemMirror in inventory_display.all_mirrors:
		if not (mirror.item is Weapon or mirror.item is Module):
			mirror.modulate.v -= .5
	
	for c:Node in equipped_display_vbox.get_children():
		if c is HBoxContainer and c.name != "resource_counters":
			c.queue_free();
	equipped_samples = []

	equipped_display_vbox.add_child(load_equipped_items());
			
	for sample:ItemSample in equipped_samples:
		sample.clicked.connect(equipped_item_chosen)

	equipment_view_scrap_icon.update()
	equipment_view_chips_icon.update()
	slide_in()

func load_equipped_items()->HBoxContainer:
	to_refine_sample.load_blank()
	var hbox:HBoxContainer = HBoxContainer.new()
	
	var sample_scene:PackedScene = Index.scenes.ui.item_sample;
	
	var main_weapon_sample:ItemSample = sample_scene.instantiate();
	main_weapon_sample.load_item(player.equipped_weapon, 4, true);
	equipped_samples.append(main_weapon_sample)
	hbox.add_child(main_weapon_sample);
	
	if player.alternative_weapon:
		var alt_weapon_sample:ItemSample = sample_scene.instantiate();
		alt_weapon_sample.load_item(player.alternative_weapon, 4, true);
		equipped_samples.append(alt_weapon_sample)
		hbox.add_child(alt_weapon_sample)
	
	var equipped_module_sample:ItemSample = sample_scene.instantiate();
	equipped_module_sample.load_item(player.equipped_module, 4, true)
	equipped_samples.append(equipped_module_sample)
	hbox.add_child(equipped_module_sample)

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
	if not mirror.item is Weapon and not mirror.item is Module:
		inventory_display.invalid_move.emit("CHOOSE A WEAPON OR A MODULE")
		return
	inventory_display.board_shake()
	set_item_to_refine(mirror.item)

func equipped_item_chosen(item:Item)->void:
	set_item_to_refine(item)
	
func set_item_to_refine(target:Item)->void:
	refine_sfx.play_sound_obj(item_chosen_sfx)
	to_refine_sample.load_item(target, 4)
	item_to_refine = target;
	refresh_view()


func refinement_scrap_cost(item:Item)->int:
	return 10 * item.rarity * (item.refinement_level + 1)

func refresh_scrap_cost(target:Item)->void:
	current_scrap_cost = refinement_scrap_cost(target);
	scrap_cost_hbox.show()
	scrap_cost_label.text = str(current_scrap_cost)

func refresh_chips_cost(target:Module)->void:
	current_chips_cost = modify_chips_cost(target);
	chips_cost_label.text = str(current_chips_cost)

func modify_chips_cost(target:Module)->int:
	return 4 ** target.rarity

func _on_button_pressed() -> void:
	assert(player.inventory.scrap >= current_scrap_cost);
	refine_item();


func refine_item()->void:
	item_to_refine.refinement_level += 1;

	player.inventory.change_resource("scrap", -current_scrap_cost)
	
	refine_feedback()
	refresh_view()

func has_item(sample:ItemSample, item:Item)->bool:
	return sample.item == item;

func refresh_view()->void:
	if item_to_refine:
		if item_to_refine.mirror:
			item_to_refine.mirror.refresh()
		if item_to_refine is Weapon:
			refine_view.show();
			modify_view.hide()
			
			refinement_level_label.text = "Refinement\nLevel: " + str(item_to_refine.refinement_level);
			refresh_description_label();
	
			refinement_level_label.remove_theme_color_override("font_color")
			anvil_panel.self_modulate = Color.WHITE
			refresh_scrap_cost(item_to_refine)
			
			var sample_index:int = equipped_samples.find_custom(has_item.bind(item_to_refine)) 
			if sample_index != -1:
				equipped_samples[sample_index].refresh()
					
			to_refine_sample.refresh();
			equipment_view_scrap_icon.update()
			equipment_view_chips_icon.update()
			refine_btn.disabled = player.inventory.scrap < current_scrap_cost or item_to_refine.refinement_level == 3
			
			var rcolor:Color = Index.refinement_level_colors[item_to_refine.refinement_level-1]

			anvil.modulate = rcolor

		else:
			assert(item_to_refine is Module);
			to_modify_name.text = item_to_refine.unique_name
			refine_view.hide();
			modify_view.show()
			
			to_modify_sample.load_item(item_to_refine, 4);
			
			m1_description.text = "[color=cyan]"+item_to_refine.m1_prefix + ":[/color] "+item_to_refine.m1_description
			m2_description.text = "[color=cyan]"+item_to_refine.m2_prefix + ":[/color] "+item_to_refine.m2_description
			refresh_chips_cost(item_to_refine);
			
			m1_button.text = "APPLY " + item_to_refine.m1_prefix.to_upper()
			m2_button.text = "APPLY " + item_to_refine.m2_prefix.to_upper()
			
			var disable_buttons:bool = Entities.player.inventory.chips < current_chips_cost or item_to_refine.modifier;
			m1_button.disabled = disable_buttons
			m2_button.disabled = disable_buttons
			
			match item_to_refine.modifier:
				1:
					m1_description.text = "[pulse][color=white]" + m1_description.text;
					m2_description.modulate = Color.from_hsv(0, 0, .4, .4)
					m1_description.modulate = Color.WHITE;
				2:
					m2_description.text = "[pulse][color=white]" + m1_description.text;
					m1_description.modulate = Color.from_hsv(0, 0, .4, .4)
					m2_description.modulate = Color.WHITE;
				0:
					m1_description.modulate = Color.WHITE;
					m2_description.modulate = Color.WHITE;
					
func refresh_description_label()->void:
	current_weapon_description_label.show()
	var weapon:Weapon = item_to_refine;

	var text:String = "+1: "+ weapon.r1_improvement;
	var r_color:Color;
	if weapon.refinement_level < 3:
		r_color = Index.refinement_level_colors[weapon.refinement_level]
	else:
		r_color = Index.refinement_level_colors[2]
	var tag:String="[color="+ r_color.to_html()+"]";
	refinement_level_label.add_theme_color_override("font_color", r_color)
	if weapon.refinement_level == 0:
		text = "[pulse]"+tag + text + "[/color][/pulse]"
		
	var r2_text:String = "+2: "+weapon.r2_improvement;
	if weapon.refinement_level == 1:
		r2_text = "[pulse]"+tag+r2_text+"[/color][/pulse]";
	text += "\n" + r2_text;
	
	
	var r3_text:String = "+3: " + weapon.r3_improvement;
	if weapon.refinement_level == 2:
		r3_text = "[pulse]"+tag+r3_text+"[/color][/pulse]"
	text += "\n" + r3_text; 
	if weapon.refinement_level == 3:
		text = "[pulse]"+tag+text
	
	current_weapon_description_label.text = text;
	
func _on_exit_btn_pressed() -> void:
	refinement_finished.emit();
	Entities.player.inventory.last_display = null;
	slide_out()

func refine_feedback()->void:
	Tweens.mouseover_shake(to_refine_sample)

	var rcolor:Color = Index.refinement_level_colors[item_to_refine.refinement_level-1]
	Tweens.floating_text("Refinement\nLevel "+str(item_to_refine.refinement_level), anvil, false, rcolor, item_to_refine.refinement_level * 32)

	var l:RichTextLabel = current_weapon_description_label;
	var tween:Tween = create_tween();
	tween.tween_property(l, "offset_transform_scale", Vector2(1.1, 1.1), .1);
	tween.parallel().tween_property(to_refine_sample, "offset_transform_scale", Vector2(1.25, 1.25), .1)
	
	tween.tween_property(l, "offset_transform_scale", Vector2.ONE, .1);
	tween.parallel().tween_property(to_refine_sample, "offset_transform_scale", Vector2.ONE, .1)
	
	var stream:AudioStream = self["r"+str(item_to_refine.refinement_level)+"_sfx"];
	refine_sfx.play_sound_obj(stream);


func apply_modifier(which:int)->void:
	item_to_refine.modifier = which;
	Entities.player.inventory.change_resource("chips", -current_chips_cost);
	refresh_view()
	modifier_feedback(which)

func modifier_feedback(mod_n:int)->void:
	refine_sfx.stream = modifier_sfx;
	refine_sfx.play()
	
	Tweens.mouseover_shake(to_modify_sample);
	Tweens.floating_text(item_to_refine["m"+str(mod_n)+"_prefix"], to_modify_sample, false, Color.BLACK, 256)
	
	var l:RichTextLabel = self["m"+str(mod_n)+"_description"];
	var tween:= create_tween();
	tween.tween_property(l, "offset_transform_scale", Vector2(1.2, 1.2), .1)
	tween.parallel().tween_property(to_modify_sample, "offset_transform_scale", Vector2(1.2, 1.2), .1)
	
	
	tween.tween_property(l, "offset_transform_scale", Vector2.ONE, .1)
	tween.parallel().tween_property(to_modify_sample, "offset_transform_scale", Vector2.ONE, .1)
	

func _on_apply_m_1_pressed() -> void:
	apply_modifier(1)

var m1_text_clear:String
func _on_apply_m_1_mouse_entered() -> void:
	m1_text_clear = m1_description.text;
	m1_description.text = "[pulse][color=white]" + m1_text_clear
func _on_apply_m_1_mouse_exited() -> void:
	m1_description.text = m1_text_clear

func _on_apply_m_2_pressed() -> void:
	apply_modifier(2)

var m2_text_clear:String
func _on_apply_m_2_mouse_entered() -> void:
	m2_text_clear = m2_description.text;
	m2_description.text = "[pulse][color=white]" + m2_text_clear
func _on_apply_m_2_mouse_exited() -> void:
	m2_description.text = m2_text_clear
