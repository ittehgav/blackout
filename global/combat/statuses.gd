extends Node

func apply_status(source:ActiveFighter, target:ActiveFighter,  type:String, duration:float=0, data:Dictionary={})->void:
	var status_data:Dictionary = {"type":type, "duration":duration}

	match type:
		"stun":
			assert(status_data.duration);
			target.stunned = true;
			if target is NpcFighter:
				target.timers.set_process_mode(Node.PROCESS_MODE_DISABLED)
			target.move_speed = 0;

			target.stun_stack += 1;

		"stat_change":
			status_data["amount"] = data.amount;
			status_data["stat"] = data.stat;
			target[data.stat] += data.amount;
		"taunt":
			assert(status_data.duration)
			target.taunted = true;
			target.target_unit = source;
			
	
	if duration:
		var timer:Timer = Timer.new();
		timer.wait_time = duration;
		timer.timeout.connect(remove_status.bind(target, type, data, timer))
		target.status_timers.add_child(timer)
		timer.start()

	target.status_applied.emit(source, status_data)



func remove_status(target:ActiveFighter, status_type:String, status_data:Dictionary, timer:Timer)->void:
	timer.queue_free();
	match status_type:
		"stun":
			target.stun_stack -= 1;
			if not target.stun_stack:
				remove_stun(target)
		"taunt":
			target.taunted = false;
			target.find_target();
	
	target.status_removed.emit(status_type, status_data);
	

		
func remove_stun(target:ActiveFighter)->void:
	target.stunned = false;
	## for now only stuns change movement speed so just roll back to origianl value
	if target is NpcFighter:
		target.move_speed = target.unit.stats.move_speed;
		target.timers.set_process_mode(PROCESS_MODE_INHERIT)
	else:
		target.move_speed = 500;
