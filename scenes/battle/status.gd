@icon("res://assets/visual/editor_ui/IconGodotNode/node/icon_card.png")
extends Node

class_name Status

signal applied;
signal removed;

var original:bool=true

## CHAIN STATUSES ARE APPLIED AND REMOVED TOGETHER
var chain:Array[Status]

@export_enum("stun", "stat_change", "dot", "special") var type:String;
@export var value:float;
@export var duration:float=0;
@export var chain_root:bool=false

@export_enum("attack", "defense", "agility", "technique", "move_speed") var stat:String;
@export var stat_fractal_value:bool=false
## ONLY FOR ENEMY MOBS,
## projections generated dynamically based on the hitscan's shape
@export var force_quiet:bool=false;
@export var unique:bool=false;
@export var special_status_texture:Texture;


var source:ActiveFighter

var host:ActiveFighter

var timer:Timer;





func generate_status()->Status:
	const properties_to_clone:Array[String] = ["type", "source", "duration", "value", "chain_root"]
	var new_status:Status = duplicate();
	for key:String in properties_to_clone:
		new_status[key] = self[key]
	return new_status;


func apply_on_target(target:CombatEntity=source.target_fighter, hard_value:float=0, propagated:bool=false)->Status:
	if not(target is ActiveFighter):return 
	## simpler way to skip over props in AOE statuses
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
			chained_status.source = source;
			new_status.chain.append(chained_status)
			
	new_status.apply(propagated);
	return new_status

func apply(propagated:bool)->void:
	## TECHNIQUE SCALING IS APPLIED HERE FOR ALL STATUSES
	## ran by the duplicate that goes on the host
	source.catch_hit_target(host);
	match type:
		"stun":
			assert(duration);
			duration += CombatStats.technique_mechanic_multipliers["stun"] * source.technique * duration
			host.stunned = true;
			if host is NpcFighter and not host.dummy:
				host.cooldown_timer.paused = true;
			host.stun_stack += 1;
		
		"stat_change":
			assert(value)
			var final_value:float;
			if not stat_fractal_value:
				final_value = CombatStats.technique_scaled_value(value, source.technique, "stat_change");
			else:
				var val:float = host[stat] * value;
				final_value = CombatStats.technique_scaled_value(val, source.technique, "stat_change");
				
			## catches buffs and debuffs by whether the value is negative of positive
			host.stat_modifiers[stat] += final_value
			
			host.stat_changed.emit(stat)
		"dot":
			## DOT scaled with technique i guess
			## right now only on calango tail poison
			## always quiet?
			assert(value);
			var final_value:float = CombatStats.technique_scaled_value(value, source.technique, "damage")
			var tween:Tween = create_tween();
			for i:int in int(duration):
				tween.tween_interval(1);
				tween.tween_callback(Combat.deal_damage.bind(source, host, final_value, true))
	
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


	host.status_applied.emit(source, self, propagated or force_quiet)
	
func remove()->void:
	if not is_instance_valid(host):
		return;
	match type:
		"stun":
			host.stun_stack -= 1;
			if not host.stun_stack:
				host.stunned = false;
				if host is NpcFighter and not host.dummy:
					host.cooldown_timer.paused = false;

		"stat_change":
			## works with negative values just fine
			host.stat_modifiers[stat] -= value;
			host.stat_changed.emit(stat);
			
			
	if chain_root:
		for status:Status in chain:
			status.remove();
				
	queue_free()

func get_status_color()->Color:
	match type:
		"stun":
			return Index.combat_effect_colors.stun;
		"stat_change":
			var stat_color:Color = Index.get_color(stat);
			if value > 0:
				stat_color.s += .15;
			else:
				stat_color.s -= .1;
				stat_color.v -= .1;
			return stat_color;
		_:
			## never meant to happen?
			return Color.PINK
	
