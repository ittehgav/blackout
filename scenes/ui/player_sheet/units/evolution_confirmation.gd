extends Panel

@export var title:RichTextLabel;
@export var evolution_animation:ColorRect;

@export_group("before")
@export var before_sprite:TextureRect;
@export var before_max_hp_label:Label;
@export var before_attack_label:Label;

@export var before_defense_label:Label;
@export var before_agility_label:Label;
@export var before_technique_label:Label;

@export_group("after")
@export var after_sprite:TextureRect;
@export var after_max_hp_label:Label;
@export var after_attack_label:Label;

@export var after_defense_label:Label;
@export var after_agility_label:Label;
@export var after_technique_label:Label;

@export var after_name:Label;
@export var after_skill_name:Label;
@export var after_skill_description:RichTextLabel;

var unit:FighterUnit;
var new_base:FighterBase;

var resource_costs:Dictionary[String, int];


func generate_confirmation(target_unit:FighterUnit, target_base:FighterBase, resource_1:String, cost_1:int, resource_2:String, cost_2:int)->void:
	unit = target_unit;
	new_base = target_base
	
	resource_costs = {
		resource_1:cost_1,
		resource_2: cost_2
	}
	
	title.text = "Spend " + Index.get_color_tag(resource_1) + str(cost_1) + " " + resource_1 + "[/color] and "\
	 + Index.get_color_tag(resource_2) + str(cost_2) + " " + resource_2 + "[/color] to turn " + unit.base.name +\
	" into " + new_base.name + "?"

	
	var texture:Texture = ColorCoder.color_code_fighter_base_texture(unit.base, Entities.player.color_scheme_index)
	before_sprite.texture.atlas = texture
	after_sprite.texture.atlas = texture
	
	for stat:String in Index.all_combat_stats:
		self["before_" + stat + "_label"].text = str(unit.stats[stat]);	
	
	var after:FighterUnit = Index.scenes.fighter_unit.instantiate();
	after.base = new_base;
	after.level = unit.level;
	after.update_stats();
	
	
	for stat:String in Index.all_combat_stats:
		self["after_" + stat + "_label"].text = str(after.stats[stat]);
	
	after_name.text = new_base.name;
	after_skill_name.text = "Skill: " +  new_base.skill_name
	after_skill_description.text = new_base.full_skill_description(after);
	var bg:ColorRect = get_parent();
	bg.show()
	Tweens.ui_fade_in(bg);
	



func _on_confirm_btn_pressed() -> void:
	Tweens.ui_fade_out(get_parent(),false, .1)
	evolution_animation.play_animation(unit.base, new_base);
	unit.change_base(new_base)
	for r:String in resource_costs.keys():
		Entities.player.inventory.change_resource(r, -resource_costs[r]);


func _on_return_btn_pressed() -> void:
	Tweens.ui_fade_out(get_parent())
