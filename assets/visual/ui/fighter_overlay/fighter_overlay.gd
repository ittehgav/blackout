extends Control

class_name FighterOverlay

@export var outline:ReferenceRect;
@export var bg:ColorRect

@export var hp_bar:TextureProgressBar;
@export var hp_bar_trail:TextureProgressBar;

@export var shield_bar:TextureProgressBar;


@export var charge_bar:TextureProgressBar;
@export var floating_icon_anchor:Node2D

@export var cooldown_timer:Timer;
@export var fighter:ActiveFighter

@export var status_icons:HBoxContainer;

@export var status_display:TextureProgressBar
@export var special_statuses_container:HBoxContainer;


var trail_tween:Tween;


func _ready()->void:
	await fighter.ready;
	charge_bar.max_value = cooldown_timer.wait_time;
	
	hp_bar.max_value = fighter.max_hp;
	hp_bar.value = fighter.hp;

	hp_bar_trail.max_value = fighter.max_hp;
	hp_bar_trail.value = fighter.hp;

	shield_bar.max_value = fighter.max_hp;

func on_status_applied(_source:ActiveFighter, status:Status, quiet:bool)->void:
	match status.type:
		"stun":
			display_stun_timer(status.duration)
		"stat_change":
			if not quiet:
				generate_floating_icon(status.stat, status.value > 0);
		"special":
			assert(status.special_status_texture);
			add_special_status_icon(status)

func add_special_status_icon(status:Status)->void:
	var icon:TextureRect = TextureRect.new();
	icon.custom_minimum_size = Vector2(16, 16);
	icon.texture = status.special_status_texture;
	special_statuses_container.add_child(icon);
	status.removed.connect(icon.queue_free)
	


func generate_floating_icon(key:String, positive:bool)->void:
	var icon:StatIcon = Index.scenes.ui.stat_icon.instantiate();
	icon.stat = key
	icon.floating = true;
	icon.positive = positive
	floating_icon_anchor.add_child(icon);



func display_stun_timer(duration:float)->void:
	var bar:TextureProgressBar = status_display.duplicate();
	status_icons.add_child(bar)
	bar.show()
	var tween:Tween = create_tween();
	## doesnt really need to change the max value of the texture?
	tween.tween_property(bar, "value", 0, duration)
	tween.tween_callback(bar.queue_free)
	bar.modulate = Color.PURPLE




func _on_fighter_damage_taken(damage: float, source:ActiveFighter, quiet:bool) -> void:
	floating_number(int(damage))
	hp_bar.value = fighter.hp;
	
	if not quiet and source is PlayerFighter:
		player_hit_feedback()
		

@onready var initial_position:Vector2 = position
var player_hit_tween:Tween
func player_hit_feedback()->void:
	Tweens.shader_color_blink(fighter.sprite, Color.WHITE)
	if player_hit_tween and not player_hit_tween.is_running():
		const shake_range = 10
		player_hit_tween = create_tween();
		var target:Vector2 = Vector2(
			randi_range(-shake_range, shake_range),
			randi_range(-shake_range, shake_range)
		)
		position = target;
		player_hit_tween.tween_property(self, "position", initial_position,.25 )

func floating_number(value:int, type:String = "damage")->void:
	var floating_n:Label = Label.new();
	match type:
		"damage":
			floating_n.modulate = Color.RED
		"heal":
			floating_n.modulate = Color.GREEN
		"block":
			floating_n.modulate = Color.YELLOW.darkened(.2);
		"shield":
			floating_n.modulate = Color.YELLOW

	
	floating_n.text = str(value);
	floating_icon_anchor.add_child(floating_n);
	
	Tweens.fade_up(floating_n);


func refresh_charge_bar() -> void:
	charge_bar.value = cooldown_timer.wait_time - cooldown_timer.time_left


func _on_hp_bar_value_changed(value: float) -> void:
	if not trail_tween or not trail_tween.is_running():
		hp_bar_trail.self_modulate.a = 1;
		
		trail_tween = create_tween();
		trail_tween.tween_property(hp_bar_trail, "self_modulate:a", 0, .5)
		trail_tween.tween_callback(hp_bar_trail.set_value.bind(hp_bar.value))


func _on_npc_fighter_healing_received(value: float, _quiet:bool) -> void:
	floating_number(value, "heal");
	hp_bar.value = fighter.hp;
	
func refresh_charge_bar_max(_stat:String="")->void:
	charge_bar.max_value = cooldown_timer.wait_time;


func _on_npc_fighter_damage_blocked(_source: ActiveFighter, value: float, quiet:bool) -> void:
	shield_bar.value = fighter.shield
	
	if not quiet:
		floating_number(value, "block");
		Tweens.squish_bar(shield_bar);


func _on_npc_fighter_shield_gained(_source: ActiveFighter, value: float, quiet:bool) -> void:
	shield_bar.value = fighter.shield
	if not quiet:
		floating_number(value, "shield");
		Tweens.stretch_bar(shield_bar);
