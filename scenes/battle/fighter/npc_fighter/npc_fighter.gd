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

var current_cell:Vector2i
var movement_target:Vector2


func load_fighter(new_unit:FighterUnit)->void:
	unit = new_unit
	
	level = new_unit.level
	unit = new_unit
	base = unit.base.duplicate(DUPLICATE_USE_INSTANTIATION);
	base.scale = Vector2(2, 2);
	base.skill.reparent(self);
	base.skill.fighter = self;

	started_moving.connect(base.started_moving.emit)
	stopped_moving.connect(base.stopped_moving.emit)
	
	## NPC fighters bases are visible sprites so this is the only context where fighter bases need to be in the tree
	base.fighter = self;
	add_child(base)
	base.set_owner(self)
	base.get_node("hurtbox").reparent(hurtbox);
	
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
	true_cooldown = final_skill_cooldown()
	cooldown_timer.wait_time = true_cooldown
	if true_cooldown == 0:
		cooldown_timer.set_process(false)



func load_unit_stats()->void:
	var stats:CombatStats = unit.final_stats();
	for stat:String in Index.all_combat_stats:
		initial_stats[stat] = stats[stat];
	## leaving move_speed out of the index stats call
	## because it's hardly ever used

	move_speed = stats.move_speed



const angle_indexes = [
	## put this in a place where both player and npcs catch?
	Vector2i.UP,
	Vector2i(1, -1),
	Vector2i.RIGHT,
	Vector2i(1, 1),
	Vector2i.DOWN,
	Vector2i(-1, 1),
	Vector2i.LEFT,
	Vector2i(-1, -1)
]


func set_direction()->void:
	var direction:Vector2
	if moving:
		direction = position.direction_to(movement_target)
	else:
		direction = position.direction_to(target_unit.position)
	
	## to make ceil work on negative numbers
	if direction.x < 0 and direction.x > -1:
		direction.x -= 1;
	if direction.y < 0 and direction.y > -1:
		direction.y -= 1;
	var angle:Vector2i = direction.ceil()

	base.frame_coords.x = angle_indexes.find(angle);
	
func refresh_target()->void:
	find_target();
	
	if not target_in_range:
		move();
	else:
		stop()
	set_direction()

func move()->void:
	movement_target = Entities.arena.grid.get_next_cell_in_path(self);
	
	if Entities.arena.grid.spot_taken(movement_target):
		## to prevent two units from overlapping
		## when they move towards eachother at the exact same time
		## otherwise will respect the taken cells by only
		## moving through astar pathfinding
		## BUG seems like melee units can't properly target enemies that are on the 
		## cell to their bottom-right?
		movement_target = Entities.arena.grid.next_closer_cell(self)

	var tween:Tween = create_tween();
	tween.tween_property(self, "position", movement_target, .25);
	Entities.arena.grid.occupy_cell(self)
	
	if not moving:
		moving = true;
		started_moving.emit()

func stop()->void:
	if moving:
		moving = false;
		stopped_moving.emit()


func find_target()->void:
	var target:ActiveFighter=null;
	match base.skill.targetting:
		SkillComponent.TargetType.nearest_enemy:
			target = nearest_enemy();
			
	if target != target_unit:
		target_unit = target;
		target_changed.emit();
	if target_unit:
		## only ever doesn't get here when the last unit dies and everyone was targeting it?
		target_in_range = Entities.arena.grid.cell_distance(position, target.position) <= base.skill.skill_range




func skill_cooldown() -> void:
	skill_attempted.emit();
	if base.name == "Wheel":
		print("scd??? ", target_in_range)
	if target_in_range or not base.skill.need_target:
		use_skill()
		skill_retry_timer.stop()
		cooldown_timer.start()
	else:
		skill_retry_timer.start();


func use_skill()->void:
	hit_targets = [];
	base.skill_windup()
	base.skill.lineup()
	skill_used.emit();
	
	await base.skill.finished
	base.frame_coords.y = 0;
	for target:ActiveFighter in hit_targets:
		skill_hit.emit(target);



func _on_stat_changed(stat:String)->void:
	## some of these are the same for npcs and the player?
	refresh_stat(stat);
	match stat:
		"agility":
			true_cooldown = final_skill_cooldown()
			if true_cooldown:
				var previous_wait_time: = true_cooldown;

				var advance:float = previous_wait_time - true_cooldown + (cooldown_timer.wait_time - cooldown_timer.time_left);
				var redone_time_left:float = cooldown_timer.wait_time - advance;

				cooldown_timer.start(redone_time_left)
				if cooldown_timer.timeout.is_connected(correct_cooldown_timer):
					cooldown_timer.timeout.disconnect(correct_cooldown_timer);
				cooldown_timer.timeout.connect(correct_cooldown_timer, CONNECT_ONE_SHOT);

func final_skill_cooldown()->float:
	return base.skill.base_cooldown - Scaling.agility_cooldown_reduction(base.skill.base_cooldown, agility)

func refresh_skill_cooldown()->void:
	true_cooldown = final_skill_cooldown();
	cooldown_timer.wait_time = true_cooldown

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

func angle_to_target()->Vector2i:
	var direction:Vector2 = position.direction_to(target_unit.position);
	if direction.x < 0:
		direction.x -= 1;
	if direction.y < 0:
		direction.y -= 1;
	return direction.ceil()
