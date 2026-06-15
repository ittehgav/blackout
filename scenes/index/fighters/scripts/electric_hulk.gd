extends FighterBase

@export var damage_lightning:LightningVFX;
@export var heal_lightning:LightningVFX;



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

var enemy_bolts:Dictionary[CombatEntity, LightningVFX];
var ally_bolts:Dictionary[CombatEntity, LightningVFX]
var current_bolts:Array[LightningVFX];
func skill_windup()->void:
	super();
	enemy_bolts = {};
	ally_bolts = {}
	## not that big a deal to generate a bunch of stuff that doesnt get used
	## instead of having to check for changes in the enemy team
	for e:CombatEntity in fighter.ally_team.fighters:
		if not (e in ally_bolts):
			var bolt:LightningVFX = heal_lightning.duplicate()
			ally_bolts[e] = bolt
			fighter.ally_team.projectiles.add_child(bolt)

	for e:CombatEntity in fighter.enemy_team.fighters:
		if not (e in enemy_bolts):
			var bolt:LightningVFX = damage_lightning.duplicate()
			enemy_bolts[e] = bolt;
			fighter.ally_team.projectiles.add_child(bolt)


func special_skill_effect()->void:
	var all_elec:Array[Node] = get_tree().get_nodes_in_group("electrified");
	## they stay sorted when filtered into friend/foe
	all_elec.sort_custom(proximity_sort);
	var healing:float = Scaling.technique_scaled_value(fighter.attack, fighter.technique, "heal");


	for target:ActiveFighter in all_elec:
		if target in fighter.enemy_team.fighters:
			Combat.deal_damage(fighter, target);
			if target in enemy_bolts:
				var bolt:LightningVFX = enemy_bolts[target];
				bolt.shoot_bolt(fighter, target)
		else:
			Combat.heal_target(fighter, target, healing)
			if target in ally_bolts:
				var bolt:LightningVFX = ally_bolts[target];
				bolt.shoot_bolt(fighter, target)

	
