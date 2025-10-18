extends Weapon


func get_description()->String:
	return "Deals "+Index.get_color_tag("attack")+str(final_damage())+\
	" damage[/color] to enemies in front of you, if you only hit one enemy, the damage is tripled.";
	

const size_x = 1;
const size_y = 3;

const rarity = 1;

func use(_alt:bool=false)->void:
	use_sfx.play()
	animation_player.play("weapon_generic/swing")


func impact()->void:
	var in_range:Array[Area2D] = hit_scan.get_overlapping_areas()
	if len(in_range) != 1:
		Combat.aoe_damage(Entities.player_fighter, hit_scan);
	else:
		var target:ActiveFighter = in_range[0].fighter;
		Combat.deal_damage(Entities.player_fighter, target, single_target_bonus);
	
func single_target_bonus(damage:float)->float:
	return damage * 3
