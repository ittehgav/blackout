extends Weapon


@export var smoke:CPUParticles2D;
const rarity = 2;

const size_x = 4;
const size_y = 3

const r1_imrpovement = "+10% defense reduction";
const r2_improvement = "30% area of effect";
const r3_improvement = "Deals 100% bonus damage to enemies over 5 seconds."

func get_description()->String:
	var damage_str:String = damage_string();
	var cost_str:String = ammo_cost_string();
	return "Consumes %s to deal %s to enemies in a cone area and reduce their defense."%[ammo_cost, damage_str];
	
func use(_alt:bool=false)->void:
	use_sfx.play()
	consume_ammo()
	smoke.emitting = true
	Combat.aoe_damage(Entities.player_fighter, hit_scan);
	Combat.aoe_status(Entities.player_fighter, status, hit_scan)
