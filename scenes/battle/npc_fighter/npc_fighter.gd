extends ActiveFighter;

class_name NpcFighter

signal target_changed;
signal skill_used;
signal skill_hit(target_hit:ActiveFighter);

@export var unit:FighterUnit;
@export var hit_scan:Area2D;
@export var cooldown_timer:Timer;
@export var skill_retry_timer:Timer;

@export var stunnable_timers:Node;

var current_animation:String = "idle";

var target_unit:ActiveFighter;
var target_in_range:bool = false;

## for the skill_hit signal to not repeat itself
var hit_targets:Array[ActiveFighter]

func load_fighter(new_unit:FighterUnit)->void:
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
				"surounding":
					var shape:CollisionShape2D = $hit_scan/shape;
					shape.shape.radius = base.hit_scan_radius;
					shape.position.x = 0;
		else:
			hit_scan.get_node("shape").shape.radius = base.hit_scan_radius
	else:
		hit_scan.queue_free();
	$skill_range/shape.shape.radius = base.skill_range;
	
	## eventually will add persistant values from leveling/other modifiers;
	max_hp = unit.stats.max_hp;
	hp = unit.stats.max_hp;
	
	attack = unit.stats.attack;
	defense = unit.stats.defense;
	
	agility = unit.stats.agility;
	
	technique = unit.stats.technique
	move_speed = unit.stats.move_speed
	
	
	var skill_cooldown = unit.final_skill_cooldown()
	cooldown_timer.wait_time = base.skill_cooldown;
	
	
	if "special_setup" in base:
		base.special_setup();
	update_overlay();


func find_target()->void:
	var target:ActiveFighter;
	match base.target_type:
		"nearest_enemy":
			var current_distance:float;
			for enemy in enemy_team.units:
				var distance:float = position.distance_to(enemy.position)
				@warning_ignore("unassigned_variable")
				if not target or distance < current_distance:
					target = enemy;
					current_distance = distance;

		"least_hp_ally":
			for ally in ally_team.units:
				if not target or target.hp < ally.hp:
					target = ally;
	if target != target_unit:
		target_unit = target;
		target_changed.emit();

	target_in_range = target_unit in $skill_range.get_overlapping_bodies();


func _physics_process(_delta: float) -> void:
	if target_unit and is_instance_valid(target_unit):
		if not target_in_range:
			base.flip_h = target_unit.position.x < position.x;
			if not current_animation == "walk":
				current_animation = "walk";
				next_frame();
				$npc_timers/animation_timer.start()
			var direction:Vector2 = (target_unit.position - position).normalized();
			velocity = direction * move_speed
			move_and_slide()
		else:
			if current_animation != "skill":
				current_animation = "idle";
		

func _on_skill_range_body_entered(body: Node2D) -> void:
	if body == target_unit:
		target_in_range = true;


func _on_skill_range_body_exited(body: Node2D) -> void:
	if body == target_unit:
		target_in_range = false;


func use_skill()->void:
	hit_targets = []
	current_animation = "skill";
	next_frame()
	for effect:String in base.skill_effects:
		Combat.skill_effect(self, effect)
		
	for visual:String in base.skill_visuals:
		match visual:
			"lunge_forward":
				Tweens.lunge_forward_tween(self)
			"recoil":
				Tweens.recoil_tween(self)
			"recoil_target":
				Tweens.recoil_target(self)
			"grow":
				Tweens.growth_tween(self)
	skill_used.emit();
	for target:ActiveFighter in hit_targets:
		skill_hit.emit(target);
	


func next_frame() -> void:
	match current_animation:
		"walk":
			if base.frame_coords.y == 1:
				$npc_timers/animation_timer.wait_time = .2;
				$npc_timers/animation_timer.start()
				base.frame += 1;
				if base.frame_coords.y == 2:
					base.frame_coords.y = 1;
			else:
				$npc_timers/animation_timer.wait_time = .2
				base.frame_coords = Vector2(0, 1);
		"idle":
			if base.frame_coords.y:
				$npc_timers/animation_timer.wait_time = .5;
				base.frame = 0;
			else:
				if base.frame == 0:
					base.frame = 1;
				else:
					base.frame = 0;
		"skill":
			if base.frame_coords.y != 2:
				$npc_timers/animation_timer.wait_time = .3;
				$npc_timers/animation_timer.start()
				base.frame_coords = Vector2(0, 2);
			else:
				current_animation = "idle";
				next_frame();
			
func skill_cooldown() -> void:
	if target_in_range:
		use_skill()
		skill_retry_timer.stop()
		$fighter_timers/stunnable/skill_cooldown.start()
	else:
		skill_retry_timer.start();


func _on_stun_timeout() -> void:
	set_physics_process(true);
	stunnable_timers.set_process_mode(PROCESS_MODE_PAUSABLE);
	
