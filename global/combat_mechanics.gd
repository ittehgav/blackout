extends Node

func deal_damage(source:ActiveFighter, target:ActiveFighter, modifier:Callable=Callable(), hard_value:float=0)->void:
	var damage:float
	if not hard_value:
		damage = source.attack;
	else:
		## hard value only overrides the source's attack stat, 
		## not the modifier function that may come in
		damage = hard_value;
	if not modifier.is_null():
		damage = modifier.bind(damage).call();
	## there may be both i suppose but theres no case of that atm
	if "damage_modifier" in source.base:
		damage = source.base.damage_modifier(damage);
	
	var mitigation:float = defense_mitigation(target);
	damage -= damage * mitigation;
	
	target.hp -= damage;
	target.damage_taken.emit(damage)
	if target.hp <= 0:
		target.death.emit(source);


func heal_unit(_source:ActiveFighter, target:ActiveFighter, value:float)->void:
	target.hp += value;
	if target.hp > target.max_hp:
		target.hp = target.max_hp;

	target.healing_received.emit(value)

func stun_target(source:ActiveFighter, target:ActiveFighter, duration:float = source.base.status_duration * source.technique)->void:
	if source is NpcFighter:
		source.catch_hit_target(target);

	Statuses.apply_status(source, target, "stun", duration)


func apply_stat_change(source:ActiveFighter, target:ActiveFighter, value:float, stat:String)->void:
		var duration:float = 0;
		if "status_duration" in source.base:
			duration = source.base.status_duration * source.technique;
		var status_data := {
			"stat":stat,
			"amount":value
		}
		target.stat_changed.emit(stat);
		Statuses.apply_status(source, target, "stat_change", duration, status_data)




const def_mitigation_breakpoints = {
	## DEF value has diminishing returns, each breakpoint makes the value of each 
	## subsequent DEF point yield less damage mitigation
	20.0:1,
	50.0:.5,
	100.0:.25,
	200.0:.2
}

## after 200, every 100 def points make the next 100 yield half as much, towards infinity
const excess_def_falloff_divider = 2;
## value the player gets from the first 200 points of defense
const base_excess_mitigation = 42.5

func defense_mitigation(unit:ActiveFighter)->float:
	var def_left:float = unit.defense;
	var total_mitigation:float = 0.0
	var previous_point:float=0;

	if unit.defense < 200:
		for point:float in def_mitigation_breakpoints.keys():
			var point_range:float = point - previous_point;
			if def_left > point_range:
				def_left -= point - previous_point;
				total_mitigation += (point - previous_point) * def_mitigation_breakpoints[point];
				previous_point = point
			else:
				total_mitigation += def_left * def_mitigation_breakpoints[point]
				break;
	else:
		def_left -= 200;
		total_mitigation += base_excess_mitigation;
		var point_value:float = def_mitigation_breakpoints[200.0];
		
		while def_left > 100:
			def_left -= 100
			total_mitigation += 100 * point_value;
			point_value /= excess_def_falloff_divider;
		
		total_mitigation += def_left * point_value

	## mitigation = pecentage reduction to damage
	## (only by defense stat rn)
	return total_mitigation/100


func turn_ellusive(unit:ActiveFighter, duration:float)->void:
	var team_n:int;
	if unit.get_collision_layer_value(1) == true:
		team_n = 1;
	else:
		team_n = 2;

	unit.set_collision_layer_value(team_n, false)
	await get_tree().create_timer(duration).timeout;

	unit.set_collision_layer_value(team_n, true)
