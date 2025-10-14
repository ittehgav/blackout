extends FighterBase

const skill_name =  "Accelerate"
const description = "Deals damage to surrounding enemies that speeds up over time."
const flavor = "He was trying to build a lawnmower.";

const skill_range = MELEE_RANGE;
const skill_cooldown = 5;

func full_skill_description(unit:FighterUnit)->String:
	var damage_str:String = Index.get_unit_damage_string(unit);
	var acceleration:String = Index.get_color_tag("technique") + str(snapped((base_acceleration_frac * unit.stats.technique/2)*100, .01))+"%[/color]"
	var string:String = "Spins a wheel that deals " + damage_str + " to surrounding enemies every second.\n"\
	+ "Each additional activation makes the wheel go " + acceleration + " faster.";
	return string


@export var projection_animation:AnimationPlayer

const base_acceleration_frac = .1

func damage_modifier(damage:float, _unit:FighterUnit=null)->float:
	return damage/10

@export var blur:Sprite2D;
@export var dmg_timer:Timer;
@export var sfx_player:AudioStreamPlayer2D;

func skill()->void:
	animation_player.play("wheelguy/skill")
	animation_player.queue("wheelguy/idle")

var circle_size:= Vector2.ONE
const circle_growth = Vector2(.1, .1)

func skill_impact()->void:
	if fighter.dead:
		return;
	if not dmg_timer.is_stopped():
		sfx_player.pitch_scale += .1
		dmg_timer.wait_time -= dmg_timer.wait_time * base_acceleration_frac;
		projection_animation.speed_scale += .1
	else:
		dmg_timer.start();
		projection_animation.play("wheel_projection")


func _on_aoe_dmg_timeout() -> void:
	Combat.aoe_damage(fighter);


var blur_blink_tween:Tween;
func _on_animation_player_animation_changed(old_name: StringName, _new_name: StringName) -> void:
	if old_name == "wheelguy/skill":
		blur.modulate = Color.WHITE
		circle_size += circle_growth
		blur.scale = circle_size;
		blur.offset.y -= circle_size.y;
		blur_blink_loop()


func _on_animation_player_current_animation_changed(animation_name: String) -> void:
	if animation_name == "wheelguy/skill":
		if blur_blink_tween and blur_blink_tween.is_running():
			blur_blink_tween.kill();

var blink_latency:= .45
func blur_blink_loop()->void:
	var tween:Tween = create_tween();
	tween.tween_property(blur, "modulate:a", 0, blink_latency);
	tween.tween_property(blur, "modulate:a", 1, blink_latency);
	tween.tween_callback(blur_blink_loop);
