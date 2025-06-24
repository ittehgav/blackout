extends ActiveFighter;

class_name NpcFighter

signal target_changed;
signal skill_used;
signal skill_hit(target_hit:ActiveFighter);

var unit:FighterUnit;
@export var hit_scan:Area2D;


@export var cooldown_timer:Timer;
@export var skill_retry_timer:Timer;
@export var skill_windup_timer:Timer;
@export var aim_sprite:Sprite2D

@export var animation_timer:Timer;

@export var stunnable_timers:Node;

@export var overlay:Control;


var current_animation:String = "idle";

var target_unit:ActiveFighter;
var target_in_range:bool = false;

## for the skill_hit signal to not repeat itself
var hit_targets:Array[ActiveFighter]

## cooldown that gets checked when the cooldown timer is changed 
## and is playing on a different wait time
var true_cooldown:float;

func _ready() -> void:
	$npc_timers/find_target.start()
	aim_tween();

func aim_tween()->void:
	var tween:Tween = create_tween();
	tween.tween_property(aim_sprite, "modulate:a", 0, .5);
	tween.tween_property(aim_sprite, "modulate:a", .5, .5);
	tween.tween_callback(aim_tween);

func load_fighter(new_unit:FighterUnit, in_player_party:bool)->void:
	in_player_team = in_player_party;
	unit = new_unit
	base = unit.base.duplicate();
	add_child(base)
	base.fighter = self;

	$hitbox.shape.radius = base.hitbox_radius;
	$hitbox.shape.height = base.hitbox_height;

	
	if "hit_scan_radius" in base or "hit_scan_type" in base:
		if "hit_scan_type" in base:
			## hit scans other than the circle shaped one will be generated when the fight starts
			match base.hit_scan_type:
				"line":
					var shape:SegmentShape2D = SegmentShape2D.new();
					shape.b = Vector2(base.hit_scan_length, 0);
					$hit_scan/shape.shape = shape;
				"rectangle":
					var shape:RectangleShape2D = RectangleShape2D.new();
					shape.size = Vector2(base.hit_scan_length, base.hit_scan_width);
					$hit_scan/shape.shape = shape;
				"surrounding":
					var shape:CollisionShape2D = $hit_scan/shape;
					shape.shape.radius = base.hit_scan_radius;
					shape.position.x = 0;
		else:
			hit_scan.get_node("shape").shape.radius = base.hit_scan_radius
	else:
		hit_scan.queue_free();
	$skill_range/shape.shape.radius = base.skill_range;
	
	max_hp = unit.stats.max_hp;
	hp = unit.stats.max_hp;
	
	attack = unit.stats.attack;
	defense = unit.stats.defense;
	
	agility = unit.stats.agility;
	
	technique = unit.stats.technique
	move_speed = unit.stats.move_speed
	
	true_cooldown = unit.final_skill_cooldown()
	cooldown_timer.wait_time = true_cooldown
	
	skill_windup_timer.wait_time = true_cooldown - true_cooldown/6;

	
	if "special_setup" in base:
		base.special_setup();


func find_target()->void:
	## overrideable?
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
		if target == Entities.player_fighter:
			aim_sprite.show();
		else:
			aim_sprite.hide();
		target_unit = target;
		target_changed.emit();
	
	target_in_range = target_unit in $skill_range.get_overlapping_bodies();


func _physics_process(_delta: float) -> void:
	if target_unit and is_instance_valid(target_unit):
		if not target_in_range:
			base.flip_h = target_unit.position.x < position.x;
			set_current_animation("walk")
			
			var direction:Vector2 = (target_unit.position - position).normalized();
			velocity = direction * move_speed
			move_and_slide()
		else:
			set_current_animation("idle");
		

func _on_skill_range_body_entered(body: Node2D) -> void:
	if body == target_unit:
		target_in_range = true;


func _on_skill_range_body_exited(body: Node2D) -> void:
	if body == target_unit:
		target_in_range = false;
			
func skill_cooldown() -> void:
	if target_in_range or not base.need_target:
		use_skill()
		skill_retry_timer.stop()
		$fighter_timers/stunnable/skill_cooldown.start()
		skill_windup_timer.start();
	else:
		skill_retry_timer.start();


func _on_windup_timer_timeout() -> void:
	if target_in_range:
		base.frame_coords = Vector2(1, 2);
		set_current_animation("windup")



func use_skill()->void:
	hit_targets = []
	set_current_animation("skill")
	base.skill();
		
	for visual:String in base.skill_visuals:
		## also afflicted by the useless chain reference 
		## that was going on in the skill effects 
		match visual:
			"lunge_forward":
				Tweens.lunge_forward_tween(self)
			"recoil":
				Tweens.recoil_tween(self)
			"recoil_target":
				Tweens.recoil_target(self)
			"grow":
				Tweens.growth_tween(self)
			"shrink_target":
				Tweens.shrink_target(self)
			"shake":
				Tweens.shake_fighter(self)
			"overhead":
				overlay.vfx_control.particle_animation("overhead");
			"hook":
				overlay.vfx_control.particle_animation("hook")
			"beam":
				overlay.vfx_control.particle_animation("beam")
			_:
				assert(false);
				

	skill_used.emit();
	
	for target:ActiveFighter in hit_targets:
		skill_hit.emit(target);
	

func catch_hit_target(hit_unit:ActiveFighter)->void:
	if not hit_unit in hit_targets:
		hit_targets.append(hit_unit);


func set_current_animation(target:String, force:bool = false)->void:
	const walk_cycle_time = .2;
	const idle_cycle_time = .5;
	const skill_frame_hold_time = .3
	if current_animation != target:
		match target:
			"walk":
				## idle and skill animation only have priority over eachother
				if current_animation == "idle":
					current_animation = target;
					base.frame_coords = Vector2(0, 1);
					animation_timer.wait_time = walk_cycle_time;
					animation_timer.start()
			"idle":
				## idle and skill animation only have priority over eachother
				if current_animation == "walk" or force:
					current_animation = target;
					base.frame_coords = Vector2(0, 0);
					animation_timer.wait_time = idle_cycle_time;
					animation_timer.start();
			"skill":
				current_animation = target;
				base.frame_coords = Vector2(0, 2)
				animation_timer.wait_time = skill_frame_hold_time;
				animation_timer.start();
			"windup":
				## held until skill fires, when this set function will run again
				current_animation = target;
				base.frame_coords = Vector2(1, 2);
				animation_timer.stop();

func next_frame() -> void:
	match current_animation:
		"walk":
			if base.frame_coords.x == base.hframes - 1:
				base.frame_coords.x = 0;
			else:
				base.frame_coords.x += 1;
		"idle":
			if base.frame == 0:
				base.frame = 1;
			else:
				base.frame = 0;
		"skill":
			## runs AFTER the skill animation frame
			## runs AFTER the skill animation frame
			set_current_animation("idle", true);


func _on_stat_changed(stat:String)->void:
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
	skill_windup_timer.wait_time = true_cooldown - true_cooldown/6;

		
	cooldown_timer.start()
	overlay.refresh_charge_bar_max();


func _on_death(_killer: ActiveFighter) -> void:
	ally_team.units.erase(self);
	base.fighter_died()
