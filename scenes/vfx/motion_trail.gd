@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/icon_animation.png")
extends Node2D
class_name MotionTrail

var enabled:bool;
var clearing:bool

@export var trail:Line2D;

@export var weapon:Weapon
var placed_points:int
@export var target_position:Vector2
@export var anchor_offset:Vector2 = Vector2.ZERO

@onready var base_position:Vector2 = position;

func start_trailing()->void:
	if weapon:
		if weapon.scale.y < 0:
			position = base_position * -1;
		else:
			position = base_position;
		
	enabled = true
	
const clear_delay = .2
func stop_trailing()->void:
	enabled = false
	await get_tree().create_timer(clear_delay).timeout;
	clearing = true

func _process(_delta:float)->void:
	if Engine.is_editor_hint():
		trail.add_point(global_position);
		if trail.get_point_count() >= 20:
			trail.remove_point(0);
	else:
		if enabled:
			trail.add_point(global_position);
		elif clearing:
			trail.remove_point(0);
			if !trail.get_point_count():
				clearing = false
		
func trail_jump(origin:Vector2, target:Vector2, duration:float = .5)->Tween:
	global_position = origin;
	start_trailing.call_deferred();
	var t:= create_tween();
	t.set_trans(Tween.TRANS_CUBIC)
	t.tween_property(self, "global_position", target, duration);
	t.tween_callback(stop_trailing)
	return t

func _on_weapon_animation_started(anim_name: StringName) -> void:
	if anim_name == "melee/attack":
		start_trailing()
	else:
		stop_trailing();
