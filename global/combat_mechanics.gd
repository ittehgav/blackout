extends Node

func deal_damage(source:ActiveFighter, target:ActiveFighter, modifier:Callable=Callable())->void:
	var damage:float = source.attack;
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
		if not target is InFightPlayer:
			target.ally_team.remove_child(target);
			var tween:Tween = Tweens.death_vfx(target);
			tween.tween_callback(target.queue_free);
		else:
			Entities.arena.player_died()
			
		target.death.emit(source);

func heal_unit(_source:ActiveFighter, target:ActiveFighter, value:float)->void:
	target.hp += value;
	if target.hp > target.max_hp:
		target.hp = target.max_hp;

	target.healing_received.emit(value)
	Tweens.heal_vfx(target);

func stun_target(source:ActiveFighter, target:ActiveFighter, duration:float = source.base.stun_duration * source.technique)->void:
	if source is NpcFighter:
		if not target in source.hit_targets:
			source.hit_targets.append(target);

	if target.stun_timer.is_stopped() or target.stun_timer.time_left < duration:
			target.stun_timer.wait_time = duration;
			target.stun_timer.start()
			
			target.set_physics_process(false);
			if target is NpcFighter:
				target.stunnable_timers.set_process_mode(NOTIFICATION_DISABLED);

			target.timers.display_stun();
	target.status_applied.emit(source, "stun")
	Tweens.stun_vfx(target);

func apply_stat_change(source:ActiveFighter, target:ActiveFighter, value:float, stat:String)->void:
		## a single stat change only reduces a single stat at a time
		target[stat] += value;
		Tweens.stat_change_vfx(target,stat, value > 0);
		## may need to be less generalized?
		target.status_applied.emit(source, "stat_down");
		
		if "applied_status_duration" in source.base:
			var timer:Timer = target.status_timer.duplicate();
			timer.wait_timer = source.applied_duration
			timer.timeout.connect(clear_stat_change.bind(target, stat, value * -1, timer))
		

func clear_stat_change(target:ActiveFighter, stat:String, value:float, status_timer:Timer)->void:
	target[stat] += value;
	status_timer.queue_free()
	

const def_mitigation_breakpoints = {
	## DEF value has diminishing returns, each breakpoint makes the value of each 
	## subsequent DEF point yield less damage mitigation
	20.0:1,
	50.0:.5,
	100:.25,
	200:.2
}

## after 200, every 100 def points make the next 100 yield half as much, towards infinity
const excess_def_falloff_divider = 2;
## value the player gets from the first 200 points of defense
const base_excess_mitigation = 42.5

func defense_mitigation(unit:ActiveFighter)->float:
	var def_left:int = unit.defense;
	var total_mitigation:float = 0.0
	var previous_point:int=0;

	if unit.defense < 200:
		for point in def_mitigation_breakpoints.keys():
			var point_range = point - previous_point;
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
		var point_value = def_mitigation_breakpoints[200];
		
		while def_left > 100:
			def_left -= 100
			total_mitigation += 100 * point_value;
			point_value /= excess_def_falloff_divider;
		
		total_mitigation += def_left * point_value

	## mitigation = pecentage reduction to damage
	## (only by defense stat rn)
	return total_mitigation/100
