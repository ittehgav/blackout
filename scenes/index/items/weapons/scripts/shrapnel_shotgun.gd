extends Weapon

const rarity = 3;

const size_x = 4;
const size_y = 3;

@export var shrapnel:CPUParticles2D
var knockback_strength:int = 2;

func get_description()->String:
	return "Consumes %s to deal %s and knock back all enemies in a cone area in front of you."

func use(_alt:bool=false)->void:
	consume_ammo();
	animation_player.play(get_animation_key("attack"));
	shrapnel.emitting = true;

	Combat.aoe_damage(Entities.player_fighter, hit_scan);
	Combat.aoe_knockback(Entities.player_fighter, hit_scan, knockback_strength)
	if refinement_level == 3:
		Combat.aoe_status(Entities.player_fighter, status, hit_scan)

const r2_improvement = "-5 scrap cost."
const r1_improvement = "Doubled knockback distance";
const r3_improvement = "Hit enemies are stunned for 1.5 seconds.";

func apply_r1()->void:
	knockback_strength *= 2
func apply_r2()->void:
	ammo_cost -= 10;
func apply_r3()->void:
	use_sfx.pitch_scale *= 1.5
