extends FighterBase

@export var damage_lightning:LightningVFX;

func fight_start_setup()->void:
	for enemy:ActiveFighter in fighter.enemy_team.fighters:
		var bolt:LightningVFX = damage_lightning.duplicate();
		fighter.ally_team.projectiles.add_child(bolt)
		enemy.collided.connect(collision_hit.bind(enemy, bolt))
		fighter.death.connect(enemy.collided.disconnect.bind(collision_hit))

func collision_hit(_t:ActiveFighter, target:ActiveFighter, bolt:LightningVFX)->void:
	bolt.shoot_bolt(fighter, target)
	Combat.deal_damage(fighter, target);

func full_skill_description(_unit:FighterUnit)->String:
	var final_string:String = "Passive: whenever enemies collide with eachother, Electric Hulk deals damage to them.\nSkill: Damages and sends all nearby enemies flying.";
	return final_string
