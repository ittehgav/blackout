extends ActiveFighter;

class_name NpcFighter


signal target_changed;

signal skill_attempted;
signal skill_used;
signal skill_hit(target_hit:ActiveFighter);



var unit:FighterUnit;

@export var dummy:bool=false;

@export var npc_sfx:AudioStreamPlayer2D;

@export var cooldown_timer:Timer;
@export var skill_retry_timer:Timer;
@export var movement_ticker:Timer;


@export var overlay:FighterOverlay

@export_subgroup("aoe projection")
var aoe_projection:Sprite2D;
@export var circle_projection_texture:Texture;
@export var rectangle_projection_texture:Texture;

@export var aoe_projection_color:Color;

var show_aoe_projection:bool=false;

var target_fighter:ActiveFighter;
var target_in_range:bool = false;
## for the skill_hit signal to not repeat itself

## cooldown that gets checked when the cooldown timer is changed 
## and is playing on a different wait time
var true_cooldown:float;

func _ready()->void:
	if dummy:
		timers.free();
		hp = max_hp

func load_fighter(new_unit:FighterUnit)->void:
	unit = new_unit
	level = new_unit.level
	unit = new_unit
	base = unit.base.duplicate(DUPLICATE_USE_INSTANTIATION);
	body_type = base.body_type
	
	sprite = base
	## sprite is a pointer to base only in NPC fighters
	## (unlike for player and props)
	sprite.scale = Vector2(2, 2);
	base.skill.reparent(self);
	base.skill.fighter = self;
	
	if base.skill.technique_scaled_damage:
		damage_modifier = Scaling.technique_scaled_damage;
	elif base.skill.own_damage_modifier:
		assert(base.damage_modifier)
		damage_modifier = base.damage_modifier;
	
	if base.skill.lifesteal:
		assert(base.lifesteal_frac);
		assert(base.lifesteal_technique_amp)
		damage_dealt.connect(Combat.lifesteal_heal.bind(self))

	started_moving.connect(base.started_moving.emit)
	stopped_moving.connect(base.stopped_moving.emit)
	
	if base.hit_scan:
		base.hit_scan.reparent(self)
		if base.skill.aoe_projection and ally_team.team_n == 2:
			var shape:CollisionShape2D = base.hit_scan.get_node("shape");
			if not base.skill.special_aoe_projection:
				show_aoe_projection = true;
			setup_aoe_projection(shape);
			

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

func setup_aoe_projection(shape:CollisionShape2D)->void:
	aoe_projection = Sprite2D.new();
	var aoe_shape:Shape2D = shape.shape;
	
	if aoe_shape is CircleShape2D:
		aoe_projection.texture = circle_projection_texture;
		var diameter:int = aoe_shape.radius * 2;
		## 32x32 pixel circle
		var size:float;
		size = diameter/32;
		aoe_projection.scale = Vector2(size, size)
	elif aoe_shape is RectangleShape2D:
		aoe_projection.texture = rectangle_projection_texture;
		aoe_projection.scale = aoe_shape.size/2 ## /2 because texture is a 2x2 square
	elif aoe_shape is SegmentShape2D:
		aoe_projection.texture = rectangle_projection_texture;
		aoe_projection.scale = Vector2( aoe_shape.b.x/2, 1); ## 
		aoe_projection.centered = false;
	
	aoe_projection.modulate = aoe_projection_color
	aoe_projection.self_modulate.a = 0;
	shape.add_child(aoe_projection)
	aoe_projection.z_index -= 1;

func load_unit_stats()->void:
	var stats:CombatStats = unit.final_stats();
	for stat:String in Index.all_combat_stats:
		initial_stats[stat] = stats[stat];
	## leaving move_speed out of the index stats call
	## because it's hardly ever used

	move_speed = stats.move_speed


func set_direction()->void:
	var direction_index:int = Index.isometric_rad_indexes.bsearch(direction_to_target.angle());
	sprite.frame_coords.x = direction_index;


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
			
			
	if target != target_fighter:
		target_fighter = target;
		target_changed.emit();
	if target_fighter:
		Entities.arena.grid.assign_path(self)
		## only ever doesn't get here when the last unit dies and everyone was targeting it?
		target_cell_distance = Entities.arena.grid.cell_distance(position, target.position)
		target_in_range = target_cell_distance <= base.skill.skill_range


func check_move()->void:
	if not len(enemy_team.fighters):
		return
	refresh_target();
	if base.movement == FighterBase.MovementPattern.none:
		return
	if not target_in_range or (base.movement == FighterBase.MovementPattern.chase and target_cell_distance > 2):
		move_toward_target(current_path[1]);
	else:
		if base.movement == FighterBase.MovementPattern.hover:
			check_flee()
		else:
			stop()
	set_direction()

func check_flee()->void:
	if target_cell_distance - 2 > base.skill.skill_range:
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
		var neighbor:Vector2i = current_cell + Index.isometric_angle_indexes[farthest_cell_index + s];
		if not grid.spot_taken(neighbor):
			var target_position:Vector2 = grid.map_to_local(neighbor)
			move_toward_target(target_position);
			return
			
			
	
@onready var movement_interval:float = movement_ticker.wait_time;
## movement speed gets edited here eventually?
func move_toward_target(target:Vector2i)->void:
	## MOVEMENT TARGET = REGULAR POSITION
	movement_target = target;
	
	if Entities.arena.grid.spot_taken(movement_target):
		printerr("takenshouldneverhappen??")
		return
		## to prevent two units from overlapping
		## when they move towards eachother at the exact same time
		## otherwise will respect the taken cells by only
		## moving through astar pathfinding
		
		## BUG seems like melee units can't properly target enemies that are on the 
		## cell to their bottom-right?
		movement_target = Entities.arena.grid.next_closer_cell(self)

	var tween:Tween = create_tween();
	tween.tween_property(self, "position", movement_target, movement_interval);
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
	
	if show_aoe_projection:
		## TODO this should all be controlled by SkillComponent
		## TODO make the projection tweren time dynamic
		## right now it's just the hardcoded time that all skill animations
		## take between start and impact
		var tween:Tween = create_tween();
		tween.tween_property(aoe_projection, "self_modulate:a",  1, .65);
		tween.tween_callback(aoe_projection.set_self_modulate.bind(Color.from_rgba8(255, 255, 255, 0)))
	
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

func die(killer:ActiveFighter)->void:
	death.emit(killer)
	dead = true;
	
	var cell_to_clear:Vector2i = current_cell;
	var grid:TileMapLayer = Entities.arena.grid
	grid.set_cell(cell_to_clear, 0, grid.CELL_FREE)
	hide();

	
	var tween:Tween = create_tween();
	tween.tween_property(self, "modulate:a", 0, .7);
	tween.parallel().tween_property(self, "modulate:v", 0, .7)
	tween.tween_callback(queue_free);
