extends Module

const rarity = 2;

func get_description()->String:
	return "Consumes " + str(scrap_cost) +" "+ Index.resource_colored_name("scrap") + " and"\
			+Index.get_color_tag("shield") + " shields[/color] you and nearby allies for a percentage of your " + Index.stat_colored_name("max_hp") + ".";


const scrap_cost = 5;

const base_hp_frac = .2;


@export var aoe_range:Area2D;



func check_availability()->bool:
	return Entities.player.inventory.scrap >= scrap_cost;

func use()->void:
	var hp_frac := base_hp_frac;
	var technique: = Entities.player_fighter.technique;
	if technique > 1:
		hp_frac *= technique
	var shield_value:float = Entities.player_fighter.max_hp * hp_frac;
	
	Entities.player.inventory.scrap -= scrap_cost;
	
	Combat.shield_unit(Entities.player_fighter, Entities.player_fighter, shield_value);
	for target in aoe_range.get_overlapping_bodies():
		Combat.shield_unit(Entities.player_fighter, target, shield_value);


func _on_equipped() -> void:
	aoe_range.reparent(Entities.player_fighter, false);
