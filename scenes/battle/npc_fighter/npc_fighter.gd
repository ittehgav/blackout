extends ActiveFighter;

class_name NpcFighter

signal target_change;

@export var fighter:Fighter;
@export var hit_scan:Area2D;
@export var cooldown_timer:Timer;
@export var skill_retry_timer:Timer;



var current_animation:String = "idle";

var target_unit:ActiveFighter;
var target_in_range:bool = false;

func _ready()->void:
	load_fighter();

func load_fighter()->void:
	if not fighter:
		fighter = Fighter.new();
		var new_base:FighterBase = Index.random_fighter_base();
		fighter.base = new_base

	base = fighter.base.duplicate()
	## fighter bases are instantiated as the fight begins
	## Fighter nodes are not children of the ActiveFighters
	add_child(base)

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
		else:
			hit_scan.get_node("shape").shape.radius = base.hit_scan_radius
	else:
		hit_scan.queue_free();
	$skill_range/shape.shape.radius = base.skill_range;
	
	## eventually will add persistant values from leveling/other modifiers;
	max_hp = fighter.stats.max_hp;
	hp = fighter.stats.max_hp;
	
	attack = fighter.stats.attack;
	defense = fighter.stats.defense;
	
	technique = fighter.stats.technique
	move_speed = fighter.stats.move_speed
	
	cooldown_timer.wait_time = base.skill_cooldown;
	
	
	if "special_setup" in base:
		base.special_setup(self);
	
	update_overlay();


func find_target()->void:
	var target:ActiveFighter;
	match base.target_type:
		"nearest_enemy":
			var current_distance:float;
			for unit in enemy_team:

				var distance:float = position.distance_to(unit.position)
				@warning_ignore("unassigned_variable")
				if not target or distance < current_distance:
					target = unit;
					current_distance = distance;

		"least_hp_ally":
			for unit in ally_team:
				if not target or target.hp < unit.hp:
					target = unit;
	if target != target_unit:
		target_unit = target;
		target_change.emit();

	target_in_range = target_unit in $skill_range.get_overlapping_bodies();


func _physics_process(_delta: float) -> void:
	if target_unit and is_instance_valid(target_unit):
		if not target_in_range and stun_timer.is_stopped():
			base.flip_h = target_unit.position.x < position.x;
			current_animation = "walk";
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
	current_animation = "skill";
	next_frame()
	for effect in base.skill_effects:
		Combat.skill_effect(self, effect)
		
	for visual in base.skill_visuals:
		match visual:
			"lunge_forward":
				Tweens.lunge_forward_tween(self)
			"recoil":
				Tweens.recoil_tween(self)

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
	if target_in_range and stun_timer.is_stopped():
		use_skill()
		skill_retry_timer.stop()
		$npc_timers/skill_cooldown.start()
	else:
		skill_retry_timer.start();


func _on_death(_killer: ActiveFighter) -> void:
	if ally_team == Entities.in_fight_player.ally_team:
		sfx.play_sfx_by_key("ally_death");
	else:
		sfx.play_sfx_by_key("enemy_death")
