extends Weapon

const rarity = 3;

const size_x = 4;
const size_y = 3;

@export var shrapnel:CPUParticles2D

const r1_improvement = "+30% knockback distance";
const r2_improvement = "-10 scrap cost."
const r3_improvement = "Enemies hit lose 5 defense for the rest of the fight";

func get_description()->String:
	var damage_str:String = damage_string();
	return "Consumes %s to deal %s and knock back all enemies in a cone area in front of you."

func use(_alt:bool=false)->void:
	consume_ammo();
	animation_player.play(animation_root_key+"/attack");
	shrapnel.emitting = true;

	Combat.aoe_damage(Entities.player_fighter, hit_scan);
	for t:CombatEntity in Entities.player_fighter.hit_targets:
		Combat.knock_back_target(Entities.player_fighter, t, 200)
