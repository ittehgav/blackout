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
@export var movement_ticker:Timer;


@export var overlay:FighterOverlay


var target_unit:ActiveFighter;
var target_in_range:bool = false;
## for the skill_hit signal to not repeat itself

## cooldown that gets checked when the cooldown timer is changed 
## and is playing on a different wait time
var true_cooldown:float;



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


func set_direction()->void:
	var direction_index:int = Index.isometric_rad_indexes.bsearch(direction_to_target.angle());
	print(direction_index)
	base.frame_coords.x = direction_index;


## storing these throughout check_move calls
## to reduce processing load
## (by an amount which i think will start to become bigger and bigger as 
## the movement system becomes more complex)
var current_cell:Vector2i
var movement_target:Vector2
var target_cell_distance:int;
var direction_to_target:Vector2

var current_path:PackedVector2Array;
func refresh_target()->void:
	## also refreshes all geometric data that takes a bit of math to call
	## every movement refresh
	var target:ActiveFighter=null;
	match base.skill.targetting:
		## maybe only ever need to target allies otherwise?
		## make this a simpler code expression if so?
		SkillComponent.TargetType.nearest_enemy:
			target = nearest_enemy();
			
			
	if target != target_unit:
		target_unit = target;
		target_changed.emit();
	if target_unit:
		Entities.arena.grid.assign_path(self)
		## only ever doesn't get here when the last unit dies and everyone was targeting it?
		target_cell_distance = Entities.arena.grid.cell_distance(position, target.position)
		target_in_range = target_cell_distance <= base.skill.skill_range


func check_move()->void:
	if not len(enemy_team.units):
		return
	refresh_target();
	if base.movement == FighterBase.MovementPattern.none:
		return
	
	if not target_in_range or (base.movement == FighterBase.MovementPattern.chase and target_cell_distance > 1):
		move_toward_target(current_path[1]);
	else:
		if base.movement == FighterBase.MovementPattern.hover:
			check_flee()
		else:
			stop()
	set_direction()

func check_flee()->void:
	var cell_distance:int = Entities.arena.grid.cell_distance(position, target_unit.global_position);
	if cell_distance - 2 < base.skill.skill_range:
		flee_from_target();

func flee_from_target()->void:
	## just goes to the farthest from the target vague cell
	## can result in silly behavior when cornered? (which might be fine?)
	var direction:Vector2i = direction_to_target * -1;
	var farthest_cell_index:int = Index.isometric_angle_indexes.bsearch(direction);
	
	direction = Index.isometric_angle_indexes[farthest_cell_index];
	
	var grid:NavigationGrid = Entities.arena.grid;
	const shifts:Array[int] = [0, -1, 1, 2, -2, 3, -3, 4];
	for s:int in shifts:
		var neighbor:Vector2i = Index.isometric_angle_indexes[farthest_cell_index + s];
		if not grid.spot_taken(neighbor):
			move_toward_target(neighbor);
			return
			
			
	

func move_toward_target(target:Vector2i)->void:
	movement_target = target;
	
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
	
	await base.skill.impact
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
