extends Control

@export var hp_bar:TextureProgressBar;
@export var hp_bar_trail:TextureProgressBar;
@export var charge_bar:TextureProgressBar;
@export var floating_icon_anchor:Node2D

@export var cooldown_timer:Timer;
@export var unit:ActiveFighter


var trail_tween:Tween;


func _ready()->void:
	await unit.ready;
	charge_bar.max_value = cooldown_timer.wait_time;
	
	hp_bar.max_value = unit.max_hp;
	hp_bar.value = unit.hp;

	hp_bar_trail.max_value = unit.max_hp;
	hp_bar_trail.value = unit.hp;


func _on_fighter_status_applied(_source: ActiveFighter, data:Dictionary) -> void:
	## VFX from statuses will be handled here
	match data.type:
		"stat_change":
			if data.amount < 0:
				stat_debuff_vfx(data.stat)

func stat_debuff_vfx(stat:String)->void:
	var icon:StatIcon = Index.stat_icon_scene.instantiate();
	icon.stat = stat;
	icon.position = Vector2.ZERO
	icon.custom_minimum_size = Vector2(16, 16)
	icon.size = Vector2(16, 16)
	icon.get_node("panel").hide()
	floating_icon_anchor.add_child(icon);
	icon.material.set_shader_parameter("base_color", Color.PURPLE)
	
	var tween:Tween = create_tween();
	tween.tween_property(icon, "position:y", 30, 1);
	tween.parallel().tween_property(icon, "modulate:a", 0, 1)
	tween.tween_callback(icon.queue_free)
	


func _on_fighter_damage_taken(damage: float) -> void:
	floating_number(int(damage))
	hp_bar.value = unit.hp;


func floating_number(value:int, damage :bool= true)->void:
	var floating_n:Label = Label.new();
	if damage:
		floating_n.modulate = Color.RED
	else:
		floating_n.modulate = Color.GREEN
	
	floating_n.text = str(value);
	floating_icon_anchor.add_child(floating_n);
	
	var fn_tween:Tween = create_tween();
	fn_tween.tween_property(floating_n, "position:y", -50, .5)
	fn_tween.parallel().tween_property(floating_n, "modulate:a", 0, .5);
	fn_tween.tween_callback(floating_n.queue_free)
	


func refresh_charge_bar() -> void:
	charge_bar.value = cooldown_timer.wait_time - cooldown_timer.time_left


func _on_hp_bar_value_changed(value: float) -> void:
	if not trail_tween or not trail_tween.is_running():
		hp_bar_trail.self_modulate.a = 1;

		trail_tween = create_tween();
		trail_tween.tween_property(hp_bar_trail, "self_modulate:a", 0, .5)
		trail_tween.tween_callback(hp_bar_trail.set_value.bind(hp_bar.value))


func _on_npc_fighter_healing_received(value: float) -> void:
	floating_number(value, false);
	hp_bar.value = unit.hp;
	
func refresh_charge_bar_max(_stat:String="")->void:
	charge_bar.max_value = cooldown_timer.wait_time;
