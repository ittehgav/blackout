extends Control

signal recruit_hired;

@export var recruitment_card_scene:PackedScene;
@export var recruit_panel:Panel;


@export var cards_container:VBoxContainer;

@export var settlement_ui:UIRoot;
var settlement:Settlement;

@export var hire_btn:Button;

var current_unit_price:int;

@export_group("Showing Recruit Data")
var showing_recruit:FighterUnit;
var showing_recruit_card:RecruitmentCard;

@export var recruit_name_label:Label;
@export var recruit_level_label:Label
@export var tags_label:Label;

@export var recruit_skill_name_label:Label;
@export var recruit_description_label:RichTextLabel;
@export var recruit_flavor_label:RichTextLabel;
@export var recruit_sprite:TextureRect;

@export_subgroup("Stats")
@export var recruit_max_hp_label:Label
@export var recruit_attack_label:Label

@export var recruit_defense_label:Label
@export var recruit_agility_label:Label
@export var recruit_technique_label:Label

func start()->void:
	recruit_panel.hide();
	for c:Node in cards_container.get_children():
		if c.name != "exit":
			c.free();
	
	settlement = settlement_ui.current_settlement;
	for r:FighterUnit in settlement.available_recruits:
		var card:RecruitmentCard = recruitment_card_scene.instantiate();
		card.setup(r)
		cards_container.add_child(card);
		card.pressed.connect(card_clicked.bind(card, card.unit_price))
		recruit_hired.connect(card.refresh_affordability)


func card_clicked(card:RecruitmentCard, hire_price:int)->void:
	display_recruit(card.unit, hire_price, card);

func display_recruit(unit:FighterUnit, hire_price:int, card:RecruitmentCard)->void:
	showing_recruit_card = card
	showing_recruit = unit;
	settlement_ui.ui_sfx.play_stream("button_click");
	current_unit_price = hire_price;
	recruit_name_label.text = unit.base.name;
	recruit_level_label.text = "Level " + str(unit.level);
	
	var tags_text: = "";
	for tag:String in unit.base.tags:
		tags_text += tag.capitalize() + "\n"
	tags_label.text = tags_text
	
	
	hire_btn.disabled = Entities.player.inventory.money < hire_price;
	hire_btn.text = "Hire - $" + str(hire_price)
	
	recruit_skill_name_label.text = "Skill: "+  unit.base.skill_name
	recruit_description_label.text = unit.base.full_skill_description(unit)
	recruit_flavor_label.text = unit.base.flavor;
	
	
	var pairs:Dictionary[Color,Color] = ColorCoder.scheme_to_sprite_color_pairs(Entities.player)
	recruit_sprite.texture.atlas = ColorCoder.color_code_texture(unit.base.texture, pairs);
	
	for stat:String in Index.all_combat_stats:
		self["recruit_" + stat + "_label"].text = str(unit.stats[stat]);
	
	recruit_panel.show()


func _on_exit_pressed() -> void:
	settlement_ui.show_main_view();
	settlement_ui.recruitment_ended.emit();


func _on_hire_btn_pressed() -> void:
	showing_recruit_card.hired_overlay.show()
	Tweens.ui_fade_in(showing_recruit_card.hired_overlay)
	
	Entities.current_settlement.inventory.money += current_unit_price;
		
	hire_btn.disabled = true;
	hire_btn.text = "HIRED";
	
	Entities.player.roster.add_child(showing_recruit);

	Entities.player.party_changed.emit();
	Entities.player.inventory.change_resource("money", current_unit_price * -1);
	settlement.available_recruits.erase(showing_recruit);
	
