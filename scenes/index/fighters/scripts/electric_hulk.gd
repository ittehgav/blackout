extends FighterBase

@export var damage_lightning:CombatVFX;
@export var heal_lightning:CombatVFX;

func full_skill_description(unit:FighterUnit)->String:
	var damage_string:String = Index.colored_text("attack", unit.final_stat("attack"), " damage")
	var heal_string:String = Index.colored_text("heal", Scaling.technique_scaled_value(unit.final_stat("attack"), unit.final_stat("technique"), "heal"), " health");
	var electrified_tag:String = Index.get_color_tag("electrify") + "Electrified[/color]";
	var f:Dictionary = {
		"elec":electrified_tag,
		"damage":damage_string,
		"heal":heal_string
	}

	var final_string:String = "{elec}Electrifies[/color] all nearby units, then deals {damage} to all {elec}Electrified[/color] enemies and restores {heal} to all {elec} allies.".format(f);
	return final_string

func special_skill_effect()->void:
	var all_elec:Array[Node] = get_tree().get_nodes_in_group("electrified");
	## they stay sorted when filtered into friend/foe
	all_elec.sort_custom(proximity_sort);

	var to_heal:Array[ActiveFighter];
	var to_damage:Array[ActiveFighter];
	for target:ActiveFighter in all_elec:
		if target in fighter.ally_team.fighters and target != fighter:
			to_heal.append(target)
		else:
			to_damage.append(target);
	
	var healing:float = Scaling.technique_scaled_value(fighter.attack, fighter.technique, "heal");
	Combat.heal_target(fighter, fighter, healing)

	chain_healing(to_heal, healing);
	chain_damage(to_damage)

func chain_healing(targets:Array[ActiveFighter], healing:float)->void:
	var bolt_origin:ActiveFighter = fighter;
	for t:ActiveFighter in targets:
		Combat.heal_target(fighter, t, healing)
		heal_lightning.bolt_animation(bolt_origin, t)
		await heal_lightning.animation_player.animation_finished;
		bolt_origin = t;

func chain_damage(targets:Array[ActiveFighter])->void:
	var bolt_origin:ActiveFighter = fighter;
	
	for t:ActiveFighter in targets:
		if is_instance_valid(bolt_origin) and is_instance_valid(t):
			Combat.deal_damage(fighter, t)
			damage_lightning.bolt_animation(bolt_origin, t)
			await damage_lightning.animation_player.animation_finished;
			bolt_origin = t;
		
		if is_instance_valid(t):
			bolt_origin = t;
