extends Node

class_name Status

signal applied;
signal removed;

var original:bool=true

## CHAIN STATUSES ARE APPLIED AND REMOVED TOGETHER
@export var chain_root:bool=false
var chain:Array[Status]

@export_enum("stun", "stat_change", "special") var type:String;
@export var duration:float=0;

@export var value:float;

@export var unique:bool=false;

var source:ActiveFighter

var host:ActiveFighter

var timer:Timer;

@export_enum("attack", "defense", "agility", "technique", "move_speed") var stat:String;
@export var special_status_texture:Texture;

func _ready() -> void:
	if original and Entities.main.scenario == "battle":
		set_source()

func set_source()->void:
	var target_source:Node = get_parent();

	while not (target_source is ActiveFighter):
		if target_source is FighterUnit or not target_source:
			return
		target_source = target_source.get_parent();
	source = target_source;


func generate_status()->Status:
	const properties_to_clone:Array[String] = ["type", "source", "duration", "value", "chain_root"]
	var new_status:Status = duplicate();
	for key:String in properties_to_clone:
		new_status[key] = self[key]
	return new_status;


func apply_on_target(target:ActiveFighter=source.target_unit, hard_value:float=0, propagated:bool=false)->Status:
	if unique:
		var current_statuses:Array[Node] = target.statuses.get_children();
		for s:Status in current_statuses:
			if s.name == name:
				return
	var new_status:Status = generate_status();

	if hard_value:
		new_status.value = hard_value

	new_status.host = target
	new_status.original = false
	
	if chain_root:
		for c:Node in get_children():
			assert(c is Status);
			var chained_status:Status = c.apply_on_target(target)
			new_status.chain.append(chained_status)
	new_status.apply(propagated);
	return new_status

func apply(propagated:bool)->void:
	## TECHNIQUE SCALING IS APPLIED HERE
	source.catch_hit_target(host);
	match type:
		"stun":
			assert(duration);
			duration += Scaling.technique_mechanic_multipliers["stun"] * source.technique * duration
			host.stunned = true;
			if host is NpcFighter:
				host.timers.set_process_mode(PROCESS_MODE_DISABLED);
			host.move_speed = 0;
			host.stun_stack += 1;
		
		"stat_change":
			assert(value)
			var technique_bonus:float = Scaling.technique_mechanic_multipliers["stat_change"] * source.technique * value;
			value += technique_bonus
			
			## catches buffs and debuffs by whether the value is negative of positive
			host.stat_modifiers[stat] += value
			
			host.stat_changed.emit(stat)
			
	
	host.statuses.add_child(self)
	if type == "special":
		## needs to be inside tree
		host.add_to_group(name)
	if duration:
		timer = Timer.new();
		timer.wait_time = duration;
		timer.autostart = true;
		add_child(timer);
		timer.timeout.connect(remove);
		timer.start();

	if not propagated:
		## status_applied signal only for vfx
		## propagations don't emit to prevent VFX bloating?
		host.status_applied.emit(source, self)
	
func remove()->void:
	if not is_instance_valid(host):
		return;
	match type:
		"stun":
			host.stun_stack -= 1;
			if not host.stun_stack:
				host.stunned = false;
				if host is NpcFighter:
					host.timers.set_process_mode(PROCESS_MODE_INHERIT);

				host.move_speed = 500;
		"stat_change":
			## works with negative values just fine
			host.stat_modifiers[stat] -= value;
			host.stat_changed.emit(stat);
			
	if chain_root:
		for status:Status in chain:
			status.remove();
				
	queue_free()
