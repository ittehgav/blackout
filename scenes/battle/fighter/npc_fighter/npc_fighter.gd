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


@export var overlay:Control;



var target_unit:ActiveFighter;
var target_in_range:bool = false;
## for the skill_hit signal to not repeat itself
var hit_targets:Array[ActiveFighter]

## cooldown that gets checked when the cooldown timer is changed 
## and is playing on a different wait time
var true_cooldown:float;

## player can be taunted?
## just force the movement maybe?
var taunted:bool=false;


func _ready() -> void:
	if not base:
		## for testing, otherwise base will be loaded by the time this enters the tree
		var children:Array[Node] = get_children();
		var i:int = children.find_custom(func(n:Node)->bool:return n is FighterUnit)
		var fighter:FighterUnit = children[i];
		fighter.update_stats()
		load_fighter(fighter, get_parent().name == "team_1")
	elif base.special:
		base.get_node("hurtbox").reparent(self);
		$timers/find_target.stop();
		max_hp = 500000;
		hp = max_hp


func load_fighter(new_unit:FighterUnit, in_player_party:bool)->void:
	in_player_team = in_player_party;
	unit = new_unit
	base = unit.base.duplicate(DUPLICATE_USE_INSTANTIATION);
	## NPC fighters bases are visible sprites so this is the only context where fighter bases need to be in the 
	base.fighter = self;
	add_child(base)
	base.get_node("hurtbox").reparent(self)


	
	$skill_range/shape.shape.radius = base.skill_range;
	
	if "projectile" in base:
		base.projectile.setup(self);
	
	max_hp = unit.stats.max_hp;
	hp = unit.stats.max_hp;
	
	attack = unit.stats.attack;
	defense = unit.stats.defense;
	
	agility = unit.stats.agility;
	
	technique = unit.stats.technique
	move_speed = unit.stats.move_speed
	
	true_cooldown = unit.final_skill_cooldown()
	cooldown_timer.wait_time = true_cooldown
	
	started_moving.connect(base.fighter_started_moving)
	stopped_moving.connect(base.fighter_stopped_moving)
	


	## need to start it manually after assignin the cooldown
	cooldown_timer.start()


func find_target()->void:
	## overrideable?
	if taunted: return;
	
	var target:ActiveFighter=null;
	match base.target_type:
		"nearest_enemy":
			var current_distance:float;
			for enemy in enemy_team.units:
				var distance:float = position.distance_to(enemy.position)
				if not target or distance < current_distance:
					target = enemy;
					current_distance = distance;

		"least_hp_ally":
			for ally in ally_team.units:
				if not target or target.max_hp - target.hp < ally.max_hp - ally.hp:
					target = ally;
	if target != target_unit:
		target_unit = target;
		target_changed.emit();
	
	target_in_range = target_unit in $skill_range.get_overlapping_bodies();


func _physics_process(delta: float) -> void:
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
	hit_targets = []
	base.skill();

	skill_used.emit();
	
	await base.skill_finished
	for target:ActiveFighter in hit_targets:
		skill_hit.emit(target);
	

func catch_hit_target(hit_unit:ActiveFighter)->void:
	if not hit_unit in hit_targets:
		hit_targets.append(hit_unit);


func _on_stat_changed(stat:String)->void:
	## some of these are the same for npcs and the player?
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
	queue_free()
