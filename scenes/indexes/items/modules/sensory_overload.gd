extends Module

const rarity = 3;

const cooldown = 5;
const chips_cost = 5;

const sfx_key = "overload"

@export var aoe_range:Area2D;


@onready var description :String = "Consumes " + str(chips_cost) + Index.get_color_tag("chips") + \
			" Chips[/color] to stun all nearby enemies for 1 second and double the "\
			 + Index.get_color_tag("technique") + \
			"Technique[/color] of nearby allies for the rest of the battle.";

func check_availability()->bool:
	return Entities.player.inventory.chips >= chips_cost;

func use()->void:
	Entities.player.inventory.chips -= chips_cost;
	var player:InFightPlayer = Entities.in_fight_player;
	for target in aoe_range.get_overlapping_bodies():
		if target in player.ally_team.units:
			print(target.technique)
			Combat.apply_stat_change(player, target, target.technique, "technique");
			print(target.technique)
		else:
			Combat.stun_target(player, target, 1)


func _on_equipped() -> void:
	aoe_range.reparent(Entities.in_fight_player, false)
