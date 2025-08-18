extends Control

@export var hp_bar:TextureProgressBar;
@export var hp_bar_trail:TextureProgressBar;

@export var shield_bar:TextureProgressBar;


@export var vfx_control:Node;
@export var charge_bar:TextureProgressBar;
@export var floating_icon_anchor:Node2D

@export var cooldown_timer:Timer;
@export var fighter:ActiveFighter


var trail_tween:Tween;


func _ready()->void:
	await fighter.ready;
	charge_bar.max_value = cooldown_timer.wait_time;
	
	hp_bar.max_value = fighter.max_hp;
	hp_bar.value = fighter.hp;

	hp_bar_trail.max_value = fighter.max_hp;
	hp_bar_trail.value = fighter.hp;

	shield_bar.max_value = fighter.max_hp;



func _on_fighter_damage_taken(damage: float, source:ActiveFighter) -> void:
	if source is PlayerFighter:
		Tweens.shader_color_blink(fighter.base, Color.WHITE)
	floating_number(int(damage))
	hp_bar.value = fighter.hp;


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


func _on_npc_fighter_healing_received(value: float) -> void:
	floating_number(value, "heal");
	hp_bar.value = fighter.hp;
	
func refresh_charge_bar_max(_stat:String="")->void:
	charge_bar.max_value = cooldown_timer.wait_time;


func _on_npc_fighter_damage_blocked(_source: ActiveFighter, value: float) -> void:
	floating_number(value, "block");
	shield_bar.value = fighter.shield
	
	Tweens.squish_bar(shield_bar);


func _on_npc_fighter_shield_gained(_source: ActiveFighter, value: float) -> void:
	floating_number(value, "shield");
	shield_bar.value = fighter.shield
	Tweens.stretch_bar(shield_bar);
