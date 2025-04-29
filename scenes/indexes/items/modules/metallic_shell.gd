extends Module

const rarity = 2;

const size_x = 1;
const size_y = 1;

const cooldown = 5;
const scrap_cost = 5;

const sfx_key = "metallic_shell";

@export var aoe_range:Area2D;

@onready var description:String = "Consumes " + str(scrap_cost) + Index.get_color_tag("scrap") + " Scrap[/color] and"\
			+Index.get_color_tag("shield") + " shields[/color] you and nearby allies for 20% of your " + Index.get_color_tag("max_hp") + "Max HP.";

func check_availability():
	return Entities.player.inventory.scrap >= scrap_cost;

func use()->void:
	Entities.player.inventory.scrap -= scrap_cost;
	var shield_value = Entities.in_fight_player.max_hp/2;
	Combat.shield_unit(Entities.in_fight_player, Entities.in_fight_player, shield_value);
	for target in aoe_range.get_overlapping_bodies():
		Combat.shield_unit(Entities.in_fight_player, target, shield_value);


func _on_equipped() -> void:
	aoe_range.reparent(Entities.in_fight_player, false);
