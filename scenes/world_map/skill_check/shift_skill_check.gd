extends Control
class_name ShiftSkillCheck

signal started;

signal fail_hit;
signal good_hit;
signal perfect_hit

@export var sfx:AudioStreamPlayer;

@export var fail_sound:AudioStream;
@export var good_sound:AudioStream;
@export var perfect_sound:AudioStream;


@export var needle_bar:TextureProgressBar;
@export var region_good:TextureProgressBar;
@export var region_perfect:TextureProgressBar

@export var fail_color:Color;
@export var good_color:Color;
@export var perfect_color:Color;

@export var outcome_container:Control
@export var outcome_image:TextureRect;
@export var outcome_text:Label

var good_range:int;

func _ready()->void:
	set_process_input(false)

func play()->void:
	modulate = Color.WHITE
	Engine.time_scale = .1
	show()
	roll_values()
	start_motion_tween()
	set_process_input(true)
	started.emit()

func roll_values()->void:
	good_range = randi_range(25, 65);
	
	region_good.value = good_range;
	
	var bars_offset:int = randi_range(0, 20);
	region_good.radial_initial_angle = bars_offset;
	region_good.radial_fill_degrees = 90 - bars_offset;
	
	var region_good_offset:float = good_range * (region_good.radial_fill_degrees/90)
	region_perfect.radial_initial_angle = bars_offset + region_good_offset
	region_perfect.radial_fill_degrees = 90 - region_perfect.radial_initial_angle

var motion_tween:Tween;
func start_motion_tween()->void:
	needle_bar.value = 10;
	var time_roll:float = randf_range(1.5, 3)
	
	motion_tween = create_tween();
	motion_tween.set_ignore_time_scale(true)
	motion_tween.tween_property(needle_bar, "value", 180, time_roll)
	motion_tween.tween_callback(fail_hit.emit)

func _input(e:InputEvent)->void:
	if e.is_action_pressed("shift_press"):
		shift_press()

func shift_press() -> void:
	var hit:float = needle_bar.value - 90;
	var perfect_start:float = region_perfect.radial_initial_angle;
	var perfect_end:float = perfect_start + 10;
	
	var good_start:float = region_good.radial_initial_angle;
	var good_end:float = perfect_start;
	if hit >= perfect_start and hit <= perfect_end:
		perfect_hit.emit();
	elif hit >= good_start and hit <= good_end:
		good_hit.emit();
	else:
		fail_hit.emit();
	
	sfx.play()

func _on_fail_hit() -> void:
	var tween:Tween = create_tween();
	tween.tween_property(self, "modulate", Color(0.6, 0.24, 0.24, 1.0), 1)
	if motion_tween and motion_tween.is_running():
		motion_tween.kill()
	set_process_input(false)
	sfx.stream = fail_sound
	outcome_animation("fail", 4)

func _on_good_hit() -> void:
	var tween:Tween = create_tween();
	tween.tween_property(self, "modulate", Color(0.27, 0.6, 0.24, 1.0), .75)
	motion_tween.kill()
	set_process_input(false)
	sfx.stream = good_sound
	outcome_animation("good", 3);
	
func _on_perfect_hit() -> void:
	var tween:Tween = create_tween();
	tween.tween_property(self, "modulate", Color(1.0, 0.947, 0.6, 1.0), .25)
	motion_tween.kill()
	set_process_input(false)
	sfx.stream = perfect_sound;
	outcome_animation("perfect", 1.5)


@onready var outcome_origin:Vector2 = outcome_container.position;
func outcome_animation(key:String, tween_duration:float)->void:
	Engine.time_scale = 1
	var outcome_color:Color = self[key+"_color"]
	outcome_text.text = key.capitalize();
	outcome_text.add_theme_color_override("font_color", outcome_color);
	
	outcome_image.modulate = outcome_color
	outcome_container.show()
	var tween:Tween = create_tween();
	
	tween.tween_property(outcome_container, "position:y", outcome_origin.y - 50, tween_duration);
	tween.parallel().tween_property(outcome_container, "modulate:a", 0, tween_duration)
	tween.tween_callback(outcome_container.set_position.bind(outcome_origin));
	tween.tween_callback(outcome_container.set_modulate.bind(Color.WHITE));
	tween.tween_callback(outcome_container.hide)
	tween.tween_callback(hide)


func _on_world_map_half_hour_passed() -> void:
	play()
