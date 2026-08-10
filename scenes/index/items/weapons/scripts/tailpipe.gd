extends Weapon

## weapons can be weapons or tools with effects such as heals/buffs
const rarity = 1;

const size_x = 2;
const size_y = 4;

@export var stun_sfx:AudioStreamPlayer;


func get_description()->String:
	return "Short range, hits enemies in front of you, dealing "\
	+ Index.get_color_tag("attack") + str(final_damage()) + " damage.";



func use(_alt:bool=false)->void:
	animation_player.play("melee/attack")
	pending_impact = true;
	## ONLY ALL TO ANIM PLAYER IN WEAPON NODES IS THE ATTACK ANIMATION CALL
	## because it calls impact so it should be on each individual weapon node
	

var combo_tally:Dictionary[ActiveFighter, int];
func impact()->void:
	Combat.aoe_damage(Entities.player_fighter, hit_scan);
	if refinement_level >= 1:
		Combat.aoe_knockback(Entities.player_fighter, hit_scan, 1);
	pending_impact = false;
	if len(Entities.player_fighter.hit_targets):
		## projectiles do this on their own
		hit.emit();
	if refinement_level == 3:
		for target:ActiveFighter in Entities.player_fighter.hit_targets:
			if not target in combo_tally:
				combo_tally[target] = 1;
			else:
				combo_tally[target] += 1;
				if combo_tally[target] == 3:
					status.apply_on_target(target);
					stun_sfx.play()

const r1_improvement = "Knocks enemies back a short distance.";
const r2_improvement = "25% attack range.";
const r3_improvement = "+20% attack speed, hitting the same enemy 3 times stuns them for 1 second."


func apply_r1()->void:
	pass
func apply_r2()->void:
	hit_scan.position.x += 30
	var shape:CircleShape2D = hit_scan.get_node("shape").shape
	shape.radius *= 1.5;
	projections[0].scale *= 1.5;
func apply_r3()->void:
	cooldown -= cooldown/5
