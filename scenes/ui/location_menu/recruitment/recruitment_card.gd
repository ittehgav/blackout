extends Button

class_name RecruitmentCard;

@export var sprite:Sprite2D;
@export var hired_overlay:ColorRect;

@export var sprite_anchor:Control;

@export var recruit_name_label:Label;
@export var price_tag:Label;

@export var recruit_max_hp_label:Label;
@export var recruit_attack_label:Label;

@export var recruit_defense_label:Label;
@export var recruit_agility_label:Label;
@export var recruit_technique_label:Label;

var unit:FighterUnit;
var unit_price:int;

func setup(target:FighterUnit)->void:
	unit = target;
	var level_multiplier:int;
	if unit.level <= 6:
		level_multiplier = unit.level * 7;
	else:
		level_multiplier = unit.level ** 2
	
	
	sprite.texture = unit.base.texture
	sprite.hframes = unit.base.hframes;

	
	unit_price = len(unit.base.tags) * level_multiplier;

	refresh_affordability()
	
	recruit_name_label.text = "Lvl. " + str(unit.level) + " " + unit.base.name
	
	var final_stats:CombatStats = unit.final_stats()
	for stat:String in CombatStats.all_stats:
		self["recruit_"+stat+"_label"].text = str(final_stats[stat]);

func refresh_affordability()->void:
	price_tag.text = "$"+str(unit_price)
	if Entities.player.inventory.money >= unit_price:
		price_tag.modulate = Color.WHITE;
	else:
		price_tag.modulate = Color.GRAY - Color(0, 0, 0, .45)

func unit_hired()->void:
	disabled = true;
	hired_overlay.show();
	hired_overlay.scale = Vector2(2, 2);
	var tween:Tween = Tweens.ui_fade_in(hired_overlay)
	tween.parallel().tween_property(hired_overlay, "scale", Vector2.ONE, .5)
