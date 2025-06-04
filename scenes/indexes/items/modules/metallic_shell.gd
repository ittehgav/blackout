extends Module

const rarity = 2;

const size_x = 1;
const size_y = 1;

const cooldown = 5;
const scrap_cost = 5;

const base_hp_frac = .2;

const sfx_key = "metallic_shell";

@export var aoe_range:Area2D;

@onready var description:String = "Consumes " + str(scrap_cost) +" "+ Index.resource_colored_name("scrap") + " and"\
			+Index.get_color_tag("shield") + " shields[/color] you and nearby allies for a percentage of your " + Index.stat_colored_name("max_hp") + ".";

func check_availability()->bool:
	return Entities.player.inventory.scrap >= scrap_cost;

func use()->void:
	var hp_frac := base_hp_frac;
	var technique: = Entities.in_fight_player.technique;
	if technique > 1:
		hp_frac *= technique
	var shield_value:float = Entities.in_fight_player.max_hp * hp_frac;
	
	Entities.player.inventory.scrap -= scrap_cost;
	
	Combat.shield_unit(Entities.in_fight_player, Entities.in_fight_player, shield_value);
	for target in aoe_range.get_overlapping_bodies():
		Combat.shield_unit(Entities.in_fight_player, target, shield_value);


func _on_equipped() -> void:
	aoe_range.reparent(Entities.in_fight_player, false);
