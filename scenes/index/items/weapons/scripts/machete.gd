extends Weapon

var previous_target:ActiveFighter;
var hit_count:int = 0;

func get_description()->String:
	return "Deals damage to one enemy, damage is increased the more times you hit the same target.";
	

const size_x = 1;
const size_y = 3;

const rarity = 1;

func use(_alt:bool=false)->void:
	use_sfx.play()
	animation_player.play("weapon_generic/swing")


func impact()->void:
	var in_range:Array[Node2D] = hit_scan.get_overlapping_bodies()
	if len(in_range):
		hit_sfx.play()
		var target:ActiveFighter;
		if previous_target in in_range:
			target = previous_target;
		else:
			hit_count = 0;
			target = in_range[0];
			var target_distance:int = target.position.distance_to(Entities.player_fighter.position)
			for fighter:Node2D in in_range:
				var distance:int = fighter.position.distance_to(Entities.player_fighter.position);
				if distance < target_distance:
					target_distance = distance;
					target = fighter
		previous_target = target
		Combat.deal_damage(Entities.player_fighter, target, hit_count_bonus)
		hit_count += 1;
		hit.emit()

func hit_count_bonus(damage:int)->int:
	return int(float(damage) + float(damage) * float(hit_count) * .1)
