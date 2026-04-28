extends UIRoot
class_name UnitSheet;



@export_group("data_nodes")
@export var showing_unit:FighterUnit
@export var unit_sprite:Sprite2D;


@export var unit_name_label:Label;
@export var skill_name_label:Label;
@export var skill_description_label:RichTextLabel;
@export var flavor_label:Label;

@export var experience_bar:ExperienceBar;
@export var accessory_sample:ItemSample

@export var tags_label:Label;

@export var unit_level_label:Label;
@export var stats_dropdown:StatsDropdown

@export var skill_range_label:Label;
@export var skill_cooldown_label:Label;


func display_unit(unit:FighterUnit)->void:

	showing_unit = unit;
	
	unit_sprite.texture = showing_unit.base.texture;
	
	stats_dropdown.source = unit;
	stats_dropdown.update()
	refresh_data();
	fade_in()


func refresh_data()->void:
	unit_name_label.text = showing_unit.base.name;

	for tag:FighterBase.Tag  in showing_unit.base.tags:
		tags_label.text += str(tag).capitalize() + "\n"
	
	unit_level_label.text = "Level " + str(showing_unit.level);
	experience_bar.build(showing_unit);
	
	if showing_unit.equipped_accessory:
		accessory_sample.load_item(showing_unit.equipped_accessory, 2);
	else:
		accessory_sample.load_blank(2);
	
	skill_name_label.text = "Skill: " + showing_unit.base.skill.name;
	skill_description_label.text = showing_unit.base.full_skill_description(showing_unit);

	
	skill_cooldown_label.text = "Cooldown: " + str(snapped(showing_unit.final_skill_cooldown(),.01)) + "s";
	skill_range_label.text = get_skill_range(showing_unit.base);


func get_skill_range(fighter:FighterBase)->String:
	if fighter.skill.skill_range == fighter.MELEE_RANGE:
		return "Melee";
	elif fighter.skill_range < 750:
		return "Short Range";
	else:
		return "Long Range"


func fade_in()->void:
	modulate.a = 0;
	show();
	Tweens.ui_fade_in(self, .35)

var fading_out:bool=false;
func fade_out()->void:
	ui_sfx.play_stream("cancel")
	var tween:Tween = Tweens.ui_fade_out(self, .35);
	await tween.finished;
	queue_free();



func _on_item_sample_gui_input(e: InputEvent) -> void:
	if e.is_action_pressed("use_item") and accessory_sample.item:
		var item:Item = accessory_sample.item
		var display:InventoryDisplay = Entities.player_sheet.player_inventory;
		if not display.has_room(item):
			showing_unit.unequip_accessory()
			display.throw_in_inventory(item);
			display.refresh_data();
			accessory_sample.load_blank(2);
			Entities.player_sheet.party_view.unit_accessories_changed.emit();
			Entities.player.roster.equipped_accessories.erase(item);
			
		else:
			display.invalid_move.emit("NOT ENOUGH ROOM")


func _on_gui_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_exit") and not fading_out:
		fading_out = true;
		fade_out();
