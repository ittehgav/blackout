extends FighterBase

func full_skill_description(unit:FighterUnit)->String:
	var damage_string:String = Index.colored_text("attack", unit.final_stat("attack"), " damage")
	var heal_string:String = Index.colored_text("heal", Scaling.technique_scaled_value(unit.final_stat("attack"), unit.final_stat("technique"), "heal"), " health");
	var electrified_tag:String = Index.get_color_tag("electrify");
	var f:Dictionary = {
		"elec":electrified_tag,
		"damage":damage_string,
		"heal":heal_string
	}

	
	var final_string:String = "{elec}Electrifies[/color] all nearby units, then deals {damage} to all {elec}Electrified[/color] enemies and retores {heal} to all {elec}Electrified[/color] allies.".format(f);
	return final_string

func special_skill_effect()->void:
	var all_elec:Array[Node] = get_tree().get_nodes_in_group("electrified");
	
	for target:ActiveFighter in all_elec:
		if target in fighter.ally_team.units:
			Combat.heal_unit(fighter, target)
		else:
			Combat.deal_damage(fighter, target);
