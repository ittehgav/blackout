extends ActiveFighter;

class_name NpcFighter


signal target_changed;

signal skill_attempted;
signal skill_used;
## WHEN THE BASE STARTS THE WINDUP
signal skill_hit(target_hit:ActiveFighter);


var unit:FighterUnit;

@export var dummy:bool=false;

@export_subgroup("visuals")
@export var dust:Dust;
@export var skill_dust:Dust
@export var overlay:FighterOverlay

@export_subgroup("timers")
@export var cooldown_timer:Timer;
@export var skill_retry_timer:Timer;
@export var movement_ticker:Timer;



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
		movement_ticker.queue_free()
		cooldown_timer.queue_free()
		overlay.charge_bar.hide()
		hp = max_hp

func load_fighter(new_unit:FighterUnit)->void:
	unit = new_unit
	level = new_unit.level
	unit = new_unit
	base = unit.base.duplicate();
	load_base()
	## NPC fighters bases are visible sprites so this is the only context where fighter bases need to be in the tree
	
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

func load_base()->void:
	body_type = base.body_type
	
	dust.reparent(base)
	dust.position = Vector2.ZERO
	skill_dust.reparent(base);
	skill_dust.position = Vector2.ZERO;
	skill_dust.setup_impact_dust(self);

	if base.skill.status:
		base.skill.status.source = self;
	
	sprite = base
	sprite.scale = Vector2(2, 2)
	sprite.position.y = 10
	## sprite is a pointer to base only in NPC fighters
	## (unlike for player and props)
	base.skill.reparent(self);
	base.skill.fighter = self;
	
	if base.skill.technique_scaled_damage:
		damage_modifier = Scaling.technique_scaled_damage;
	elif base.skill.own_damage_modifier:
		assert(base.damage_modifier)
		damage_modifier = base.damage_modifier;

	started_moving.connect(base.started_moving.emit)
	stopped_moving.connect(base.stopped_moving.emit)

	if base.hit_scan:
		base.hit_scan.reparent(self)
		if base.skill.aoe_projection and ally_team.team_n == 2:
			var shape:CollisionShape2D = base.hit_scan.get_node("shape");
			if not base.skill.special_aoe_projection:
				show_aoe_projection = true;
			setup_aoe_projection(shape);
	
	base.fighter = self;
	add_child(base)
	base.set_owner(self)
	base.get_node("hurtbox").reparent(hurtbox);

func setup_aoe_projection(shape:CollisionShape2D)->void:
	## NOT WORKING AT ALL?
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
	move_speed = base.base_stats['move_speed']


## storing these throughout check_move calls
## to reduce processing load
## (by an amount which i think will start to become bigger and bigger as 
## the movement system becomes more complex)
var current_cell:Vector2i = Vector2(-1, -1); 
## shorthand for unallocated/invalid spot everywhere sice no V2s evaluate as false?
var movement_target:Vector2: ## ALREADY A POSITION IN SPACE RATHER THAN THE GRIDS
	set(value):
		movement_target = value
		refresh_velocity();

var target_cell_distance:int;
func target_direction()->Vector2:
	return position.direction_to(target_fighter.position)
func _physics_process(_delta: float) -> void:
	move_and_slide()
func refresh_velocity()->void:
	## only when cell changes?
	
	var direction:Vector2 = position.direction_to(movement_target);
	if direction == Vector2.ZERO:
		if moving:
			moving = false;
			stopped_moving.emit();
	else:
		if not moving:
			moving = true;
			started_moving.emit()

	velocity = direction * move_speed

func check_move()->void:
	refresh_target();
	if stunned:
		stop();
		return;
	if flying:
		## override velocity val at source until kb stops
		return

	if base.movement == FighterBase.MovementPattern.none:
		return

	if not target_in_range:
		movement_target = target_fighter.position
	else:
		if base.movement == FighterBase.MovementPattern.hover:
			check_flee();
		else:
			stop()
	
	set_direction()



func set_direction()->void:
	var angle:float;
	
	if base.animation_player.current_animation == base.skill_animation_path:
		## plays this outside of ticker when skill starts being 
		## used so it instantly turns to the targer
		angle = position.angle_to_point(target_fighter.position);
	elif moving:
		angle = velocity.angle()
	else:
		angle = position.angle_to_point(target_fighter.position);
	var direction_index:int = get_sector_full(angle)
	sprite.frame_coords.x = direction_index;


func refresh_target()->void:

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
		target_cell_distance = position.distance_to(target_fighter.position)/64;
		target_in_range = target_cell_distance < base.skill_range;
	

const hover_space = 3
func check_flee()->void:
	if target_cell_distance < base.skill_range - hover_space:
		flee_from_target();
	else:
		stop()
func flee_from_target()->void:
	var direction:Vector2 = position + target_fighter.position.direction_to(position)
	movement_target = direction
func stop()->void:
	movement_target = position;
	## find a way to make this a slowdown instead of a full stop?


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
	skill_used.emit();
	
	base.skill_windup()
	base.skill.lineup()
	
	if show_aoe_projection:
		## TODO this should all be controlled by SkillComponent/animationplayer
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
	hide();

	
	var tween:Tween = create_tween();
	tween.tween_property(self, "modulate:a", 0, .7);
	tween.parallel().tween_property(self, "modulate:v", 0, .7)
	tween.tween_callback(queue_free);
