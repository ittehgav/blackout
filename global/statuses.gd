extends Node

func apply_status(source:ActiveFighter, target:ActiveFighter,  type:String, duration:float=0, data:Dictionary={})->void:
	var status_data:Dictionary = {"type":type}
	match type:
		"stun":
			target.stunned = true;
			target.set_physics_process(false)
			if target is NpcFighter:
				target.stunnable_timers.set_process_mode(Node.PROCESS_MODE_DISABLED)

			target.stun_stack += 1;
			
		"stat_change":
			status_data["amount"] = data.amount;
			status_data["stat"] = data.stat;
			target[data.stat] += data.amount;
	
	if duration:
		var timer:Timer = Timer.new();
		timer.wait_time = duration;
		target.timers.add_child(timer);
		timer.timeout.connect(remove_status.bind(target, type, data, timer))
		timer.start()
		
	target.status_applied.emit(source, status_data)



func remove_status(target:ActiveFighter, status_type:String, status_data:Dictionary, timer:Timer)->void:
	timer.queue_free();
	
	match status_type:
		"stun":
			target.stun_stack -= 1;
			if not target.stun_stack:
				remove_stun(target)
	
	target.status_removed.emit(status_type, status_data);
	

		
func remove_stun(target:ActiveFighter)->void:
	target.stunned = false;
	target.set_physics_process(true);
	if target is NpcFighter:
		target.stunnable_timers.set_process(PROCESS_MODE_PAUSABLE)
