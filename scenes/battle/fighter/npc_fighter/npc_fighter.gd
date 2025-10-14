extends ActiveFighter;

class_name NpcFighter


signal target_changed;

signal skill_attempted;
signal skill_used;
signal skill_hit(target_hit:ActiveFighter);



var unit:FighterUnit;

@export var npc_sfx:AudioStreamPlayer2D;

@export var cooldown_timer:Timer;
@export var skill_retry_timer:Timer;


@export var overlay:FighterOverlay



var target_unit:ActiveFighter;
var target_in_range:bool = false;
## for the skill_hit signal to not repeat itself

## cooldown that gets checked when the cooldown timer is changed 
## and is playing on a different wait time
var true_cooldown:float;

## player can be taunted?
## just force the movement maybe?
var taunted:bool=false;



func load_fighter(new_unit:FighterUnit)->void:
	unit = new_unit
	if unit.base.special:
		load_special();
		return
	level = new_unit.level
	unit = new_unit
	base = unit.base.duplicate(DUPLICATE_USE_INSTANTIATION);
	## NPC fighters bases are visible sprites so this is the only context where fighter bases need to be in the tree
	base.fighter = self;
	add_child(base)
	base.set_owner(self)
	base.get_node("hurtbox").reparent(self)
	
	load_unit_stats();
		
	var accessory:Accessory = new_unit.equipped_accessory;
	if accessory and accessory.application == "battle_start":
			if not accessory.apply_during_battle:
				accessory.battle_start_apply(self);
			else:
				## TODO probably some signal that gets fetched from global scope
				## instead of this
				ally_team.arena.battle_started.connect(accessory.battle_start_apply.bind(self))
	

	refresh_all_stats()
	hp = max_hp;
	true_cooldown = unit.final_skill_cooldown()
	cooldown_timer.wait_time = true_cooldown
	
	started_moving.connect(base.fighter_started_moving)
	stopped_moving.connect(base.fighter_stopped_moving)

func load_special()->void:
	level = unit.level
	base = unit.base.duplicate(DUPLICATE_USE_INSTANTIATION);
	## NPC fighters bases are visible sprites so this is the only context where fighter bases need to be in the tree
	base.fighter = self;
	add_child(base)
	base.set_owner(self)
	base.get_node("hurtbox").reparent(self)
	
	load_unit_stats();
	
	refresh_all_stats()
	hp = max_hp;
	
	## will make this an option in fighter_base if i ever need special
	## fighters that use skill
	 
	timers.get_node("skill_cooldown").stop()


func load_unit_stats()->void:
	var stats:CombatStats = unit.final_stats();
	for stat:String in Index.all_combat_stats:
		initial_stats[stat] = stats[stat];

func adjust_collisions()->void:
	## needs to run after load_unit and assign_team
	if base.global_hit_scan:
		base.hit_scan.global_position = Vector2.ZERO;
	
	$skill_range/shape.shape.radius = base.skill_range;
	
	if "projectile" in base:
		base.projectile.setup(self);


func find_target()->void:
	## overrideable?
	if taunted: return;
	
	var target:ActiveFighter=null;
	match base.target_type:
		"nearest_enemy":
			target = nearest_enemy();
			
	if target != target_unit:
		target_unit = target;
		target_changed.emit();
	
	target_in_range = target_unit in $skill_range.get_overlapping_bodies();


func _physics_process(_delta: float) -> void:
	if target_unit and is_instance_valid(target_unit):
		if not target_in_range:
			velocity = (target_unit.position - position).normalized() * move_speed;

			move_and_slide()
		else:
			velocity = Vector2.ZERO
		if base.scale.x < 0:
			if target_unit.position.x > position.x:
				base.scale.x *= -1;
		elif base.scale.x > 0:
			if target_unit.position.x < position.x:
				base.scale.x *= -1;
				
	if velocity != Vector2(0.0, 0.0) and not moving:
		moving = true;
		started_moving.emit()
	elif velocity == Vector2(0.0, 0.0) and moving:
		moving = false
		stopped_moving.emit();


func _on_skill_range_body_entered(body: Node2D) -> void:
	if body == target_unit:
		target_in_range = true;


func _on_skill_range_body_exited(body: Node2D) -> void:
	if body == target_unit:
		target_in_range = false;


func skill_cooldown() -> void:
	skill_attempted.emit();
	if target_in_range or not base.need_target:
		use_skill()
		skill_retry_timer.stop()
		cooldown_timer.start()
	else:
		skill_retry_timer.start();


func use_skill()->void:
	hit_targets = [];
	base.skill();

	skill_used.emit();
	
	await base.skill_finished
	for target:ActiveFighter in hit_targets:
		skill_hit.emit(target);
	




func _on_stat_changed(stat:String)->void:
	## some of these are the same for npcs and the player?
	refresh_stat(stat);
	match stat:
		"agility":
			var previous_wait_time: = true_cooldown;
			true_cooldown = unit.final_skill_cooldown(agility)
			
			var advance:float = previous_wait_time - true_cooldown + (cooldown_timer.wait_time - cooldown_timer.time_left);
			var redone_time_left:float = cooldown_timer.wait_time - advance;

			cooldown_timer.start(redone_time_left)
			if cooldown_timer.timeout.is_connected(correct_cooldown_timer):
				cooldown_timer.timeout.disconnect(correct_cooldown_timer);
			cooldown_timer.timeout.connect(correct_cooldown_timer, CONNECT_ONE_SHOT);
func correct_cooldown_timer()->void:
	cooldown_timer.wait_time = true_cooldown;

	cooldown_timer.start()
	overlay.refresh_charge_bar_max();


func _on_death(_killer: ActiveFighter) -> void:
	dead = true;
	ally_team.units.erase(self);
	await base.fighter_died().finished
	hide();
	set_process_mode(PROCESS_MODE_DISABLED)
