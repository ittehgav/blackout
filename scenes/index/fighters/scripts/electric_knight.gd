extends FighterBase

@export var lightning_vfx:LightningVFX

const elec_count_bonus = .5
const elec_count_bonus_technique_amp = .1

func full_skill_description(unit:FighterUnit)->String:
	var damage_string:String = Index.colored_text("attack", unit.final_stat("attack"), " damage")
	var electrified_tag:String = Index.get_color_tag("electrify");
	var elec_count_increase:String = Index.colored_text("technique", Scaling.technique_scaled_value(
		elec_count_bonus, unit.final_stat("technique"), "", elec_count_bonus_technique_amp),"%")
	
	var f:Dictionary = {
		"elec":electrified_tag,
		"damage":damage_string,
		"bonus":elec_count_increase
	}
	var final_string:String = "{elec}Electrifies[/color] and deals {damage} to the nearest non-electrified enemy, then fires a bolt that deals {damage} to all {elec}Electrified[/color] enemies, each electrified unit increases the bolt's damage by {bonus}.".format(f);
	return final_string

func special_skill_effect()->void:
	var non_elec_targets:Array[CombatEntity];
	for target:CombatEntity in fighter.enemy_team.fighters:
		if not target.is_in_group("electrified"):
			non_elec_targets.append(target);

	if len(non_elec_targets):
		## extra hit on freshly electrified target and thats kinda cool and spicy?
		## TODO weapons/modules that interact with the mechanic as well?
		if len(non_elec_targets) > 1:
			non_elec_targets.sort_custom(proximity_sort);
		var to_electrify:ActiveFighter = non_elec_targets[0]
		skill.status.apply_on_target(to_electrify);
	
	var to_hit:Array[ActiveFighter]
	for target:ActiveFighter in get_tree().get_nodes_in_group("electrified"):
		if target in fighter.enemy_team.fighters:
			to_hit.append(target);
	to_hit.sort_custom(proximity_sort)
	chain_lightning(to_hit)
	
func chain_lightning(targets:Array[ActiveFighter])->void:
	var bolt_origin:CombatEntity = fighter;
	
	for t:ActiveFighter in targets:
		Combat.deal_damage(fighter, t)
		lightning_vfx.shoot_bolt(bolt_origin, t)
		await lightning_vfx.animation_player.animation_finished;
		bolt_origin = t;

func damage_modifier(damage:float, source:ActiveFighter)->float:
	var elec_count:int = get_tree().get_node_count_in_group("electrified");
	var per_elec_bonus:float = Scaling.technique_scaled_value\
	(elec_count_bonus, source.technique, "", elec_count_bonus_technique_amp);
	return damage * elec_count * per_elec_bonus;
