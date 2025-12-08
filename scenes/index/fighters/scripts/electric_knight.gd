extends FighterBase

func full_skill_description(unit:FighterUnit)->String:
	var damage_string:String = Index.colored_text("attack", unit.final_stat("attack"), " damage")
	var electrified_tag:String = Index.get_color_tag("electrify");
	var jump_increase:String = Index.colored_text("technique", Scaling.technique_scaled_value(skill.base_special_values["jump_bonus"], unit.final_stat("technique"), "", .1),"%")
	
	var f:Dictionary = {
		"elec":electrified_tag,
		"damage":damage_string,
		"bonus":jump_increase
	}
	var final_string:String = "{elec}Electrifies[/color] and deals {damage} to the nearest non-electrified enemy, then fires a bolt that deals {damage} to all {elec}Electrified[/color] enemies, each jump increases the bolt's damage by {bonus}.".format(f);
	return final_string

func special_skill_effect()->void:
	var non_elec_targets:Array[ActiveFighter];
	for target:ActiveFighter in fighter.enemy_team.units:
		if not target.is_in_group("electrified"):
			non_elec_targets.append(target);

	if len(non_elec_targets):
		## extra hit on freshly electrified target and thats kinda cool and spicy?
		## TODO weapons/modules that interact with the mechanic as well?
		if len(non_elec_targets) > 1:
			non_elec_targets.sort_custom(proximity_sort)
		var to_electrify:ActiveFighter = non_elec_targets[0]
		Combat.deal_damage(fighter, to_electrify);
		status.apply_on_target(to_electrify);
	
	for target:ActiveFighter in get_tree().get_nodes_in_group("electrified"):
		## TODO make these work with the lighning mechanic like befor
		if target in fighter.enemy_team.units:
			Combat.deal_damage(fighter, target);
	
func proximity_sort(a:ActiveFighter, b:ActiveFighter)->bool:
	return a.position.distance_to(fighter.position) < b.position.distance_to(fighter.position)
