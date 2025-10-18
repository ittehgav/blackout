extends Module

const rarity = 3;

func get_description()->String:
	return "Consumes " + str(chips_cost) +" " + Index.resource_colored_name("chips") + \
			" to stun all nearby enemies for second and greatly increase the "\
			 + Index.stat_colored_name("technique") + " of nearby allies for the rest of the battle.";



const chips_cost = 5;

const sfx_key = "overload"

@export var aoe_range:Area2D;

const base_stun_duration = 2;
const base_technique_frac = .5;



func check_availability()->bool:
	return Entities.player.inventory.chips >= chips_cost;

func use()->void:
	
	var technique_frac:= base_technique_frac;
	var stun_duration:= base_stun_duration;
	var player_technique := Entities.player_fighter.technique;
	
	if player_technique > 1:
		technique_frac *= player_technique;
		stun_duration *= player_technique
	
	Entities.player.inventory.chips -= chips_cost;
	var player:PlayerFighter = Entities.player_fighter;
	for area:Area2D in aoe_range.get_overlapping_areas():
		assert(area is HurtBox);
		var target:ActiveFighter = area.fighter;
		if target in player.ally_team.units:
			Combat.apply_stat_change(player, target, target.technique * technique_frac, "technique");
		else:
			Combat.stun_target(player, target, stun_duration)


func _on_equipped() -> void:
	aoe_range.reparent(Entities.player_fighter, false)
