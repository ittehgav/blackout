extends Control

@export var hp_bar:TextureProgressBar;
@export var charge_bar:TextureProgressBar;
@export var floating_icon_anchor:Node2D

@export var cooldown_timer:Timer;
@export var unit:ActiveFighter

@export var stat_icon_scene:PackedScene;


func _ready():
	await unit.ready;
	if not unit is InFightPlayer:
		charge_bar.max_value = cooldown_timer.wait_time;
		
		hp_bar.max_value = unit.max_hp;
		hp_bar.value = unit.hp;
	else:
		hp_bar.queue_free();
		charge_bar.queue_free();
		$refresh_bars.queue_free()


func refresh_bars() -> void:
	charge_bar.value = cooldown_timer.wait_time - cooldown_timer.time_left
	hp_bar.value = unit.hp;


func _on_fighter_status_applied(source: ActiveFighter, data:Dictionary) -> void:
	## VFX from statuses will be handled here
	match data.type:
		"stun":
			unit.base.modulate = Color.PURPLE
			Tweens.stun_vfx(unit);
		"stat_change":
			if data.amount < 0:
				Tweens.stat_debuff_vfx(unit);
				stat_debuff_vfx(data.stat)

func stat_debuff_vfx(stat:String)->void:
	var icon:StatIcon = stat_icon_scene.instantiate();
	icon.stat = stat;
	icon.position = Vector2.ZERO
	icon.custom_minimum_size = Vector2(16, 16)
	icon.size = Vector2(16, 16)
	icon.get_node("panel").hide()
	floating_icon_anchor.add_child(icon);
	icon.material.set_shader_parameter("base_color", Color.PURPLE)
	var tween = create_tween();
	tween.tween_property(icon, "position:y", 30, 1);
	tween.parallel().tween_property(icon, "modulate:a", 0, 1)
	tween.tween_callback(icon.queue_free)
	


func _on_fighter_damage_taken(damage: float) -> void:
	var floating_n = Label.new();
	#floating_n.add_theme_constant_override("font_size", 16);
	floating_n.modulate = Color.RED
	floating_n.text = str(int(damage));
	floating_icon_anchor.add_child(floating_n);
	
	var fn_tween = create_tween();
	fn_tween.tween_property(floating_n, "position:y", -50, .5)
	fn_tween.parallel().tween_property(floating_n, "modulate:a", 0, .5);
	fn_tween.tween_callback(floating_n.queue_free)
	
	hp_bar.scale = Vector2(.5, 2)
	var tween = create_tween()
	tween.tween_property(hp_bar, "scale", Vector2.ONE, .15)


func _on_status_removed(status_type: String, data: Dictionary) -> void:
	match status_type:
		"stun":
			unit.modulate = Color.WHITE;


func _on_weapon_used() -> void:
	pass # Replace with function body.
