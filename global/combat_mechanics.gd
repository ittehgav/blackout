extends Node

func deal_damage(source:ActiveFighter, target:ActiveFighter)->void:
	var damage:float = source.attack;
	var mitigation:float = defense_mitigation(target);
	damage -= damage * mitigation;
	
	target.hp -= damage;
	target.damage_taken.emit(damage)

	if target.hp <= 0:
		target.death.emit(source);
		
		target.ally_team.erase(target);
		var tween:Tween = Tweens.death_vfx(target);
		tween.tween_callback(target.queue_free);

func heal_unit(_source:ActiveFighter, target:ActiveFighter, value:float)->void:
	target.hp += value;
	if target.hp > target.max_hp:
		target.hp = target.max_hp;

	target.healing_received.emit(value)
	Tweens.heal_vfx(target);

func stun_target(source:ActiveFighter, target:ActiveFighter, duration:float = source.base.stun_duration)->void:
	if target.stun_timer.is_stopped() or target.stun_timer.time_left < duration:
			target.stun_timer.wait_time = duration;
			target.stun_timer.start()
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
	10.0:1,
	20.0:.75,
	50.0:.5,
	150.0:.25,
	250.0:.1,
}

const final_def_point_mitigation_value = .05;

func defense_mitigation(unit:ActiveFighter)->float:
	var total_mitigation:float = 0.0
	var def_acm:float = unit.defense;


	var breakpoints:Array = def_mitigation_breakpoints.keys();
	for key:float in breakpoints:
		def_acm -= key;
		if def_acm >= 0:
			total_mitigation += def_mitigation_breakpoints[key] * key
		else:
			## ACM will turn to a negative number that gets subtracted from the
			## breakpoint in order to get the value of the last few points
			total_mitigation += def_mitigation_breakpoints[key] * (key + def_acm)
			break
			
	
	# Handle the case for DEF values above the highest breakpoint
	if def_acm >= 0:
		total_mitigation += final_def_point_mitigation_value * def_acm;
	
	## mitigation = pecentage reduction to damage
	## (only by defense stat rn)
	return total_mitigation/100

func recurring_effect(target:ActiveFighter, effect:Callable, interval:float, repetitions_left:int)->void:
	effect.call();
	repetitions_left -= 1;
	if repetitions_left:
		await get_tree().create_timer(interval).timeout;
		if is_instance_valid(target):
			recurring_effect(target, effect, interval, repetitions_left)
