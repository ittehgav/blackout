extends "res://scenes/active_fighter/active_fighter.gd";


@export var hit_scan:Area2D;
@export var cooldown_timer:Timer;
@export var skill_retry_timer:Timer;


var current_animation:String = "idle";

var target_unit:CharacterBody2D;
var target_in_range:bool = false;

func _ready()->void:
	load_base(base);

func load_base(new_base):
	base = new_base;
	$hitbox.shape.radius = base.hitbox_radius;
	$hitbox.shape.height = base.hitbox_height;
	
	if "hit_scan_radius" in base or "hit_scan_type" in base:
		if "hit_scan_type" in base:
			## hit scans other than the circle shaped one will be generated when the fight starts
			match base.hit_scan_type:
				"line":
					var shape = SegmentShape2D.new();
					shape.b = Vector2(base.hit_scan_length, 0);
					$hit_scan/shape.shape = shape;
		else:
			hit_scan.get_node("shape").shape.radius = base.hit_scan_radius
	else:
		hit_scan.queue_free();
	$skill_range/shape.shape.radius = base.skill_range;
	ColorCoder.color_code_fighter(base);
	
	## eventually will add persistant values from leveling/other modifiers;
	max_hp = base.stats.max_hp;
	hp = base.stats.max_hp;
	
	attack = base.stats.attack;
	
	defense = base.stats.defense;
	move_speed = base.stats.move_speed;
	
	cooldown_timer.wait_time = base.skill_cooldown;
	
	update_overlay();


func find_target()->void:
	match base.target_type:
		"nearest_enemy":
			var target:CharacterBody2D;
			var current_distance:float;
			for unit in enemy_team:
				var distance = position.distance_to(unit.position)
				@warning_ignore("unassigned_variable")
				if not target or distance > current_distance:
					target = unit;
					current_distance = distance;
			target_unit = target;

			target_in_range =  target_unit in $skill_range.get_overlapping_bodies();


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


func use_skill():
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
				$timers/animation_timer.wait_time = .2;
				$timers/animation_timer.start()
				base.frame += 1;
				if base.frame_coords.y == 2:
					base.frame_coords.y = 1;
			else:
				$timers/animation_timer.wait_time = .2
				base.frame_coords = Vector2(0, 1);
		"idle":
			if base.frame_coords.y:
				$timers/animation_timer.wait_time = .5;
				base.frame = 0;
			else:
				if base.frame == 0:
					base.frame = 1;
				else:
					base.frame = 0;
		"skill":
			if base.frame_coords.y != 2:
				$timers/animation_timer.wait_time = .3;
				$timers/animation_timer.start()
				base.frame_coords = Vector2(0, 2);
			else:
				current_animation = "idle";
				next_frame();
			
func skill_cooldown() -> void:
	if target_in_range and stun_timer.is_stopped():
		use_skill()
		skill_retry_timer.stop()
		$timers/skill_cooldown.start()
	else:
		skill_retry_timer.start();





func damage_overlay_shake(damage:float):
	var intensity:float = .1;
	if damage > max_hp/2:
		intensity = 1;
	elif damage > max_hp/3:
		intensity = .75;
	Tweens.damage_overlay_tween($overlay/hp, intensity);
