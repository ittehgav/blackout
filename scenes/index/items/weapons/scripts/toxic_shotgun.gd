extends Weapon

@export var smoke:CPUParticles2D;
@export var agi_debuff:Status;
const rarity = 2;

const size_x = 4;
const size_y = 3

func get_description()->String:
	var damage_str:String = damage_string();
	var cost_str:String = ammo_cost_string();
	return "Consumes %s to deal %s to enemies in a cone area and poison them, dealing damage over time."%[ammo_cost, damage_str];
	
func use(_alt:bool=false)->void:
	use_sfx.play()
	consume_ammo()
	smoke.emitting = true
	Combat.aoe_damage(Entities.player_fighter, hit_scan);
	Combat.aoe_status(Entities.player_fighter, status, hit_scan)

const r1_improvement = "+25% poison damage";
const r2_improvement = "30% area of effect";
const r3_improvement = "Poisoned enemies have -20% agility."

func apply_r1()->void:
	status.value += status.value/4
func apply_r2()->void:
	hit_scan.scale *= 1.3;
	projections[0].scale *= 1.3;
func apply_r3()->void:
	agi_debuff.reparent(status);
	status.chain_root = true
	agi_debuff.source = Entities.player_fighter
