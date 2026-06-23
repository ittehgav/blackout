extends FighterBase

@export var ticker:Timer;

const attack_scaling = .25

const acceleration = .1
const acceleration_technique_amp = .1

func full_skill_description(unit:FighterUnit)->String:
	var base_dps:String = Index.colored_text("attack", unit.final_stat("attack")*attack_scaling, " damage per second.");
	var final_accel:float = CombatStats.technique_scaled_value(acceleration, unit.final_stat("technique"), "", acceleration_technique_amp);
	var accel_string:String = Index.colored_text("technique", final_accel * 100, "%");
	var final_string:String = "Spins the wheel, dealing %s, each additional activation increases the damage speed by %s."%[base_dps, accel_string];
	return final_string

func special_skill_effect()->void:
	if not ticker.is_stopped():
		projection_loop_time -= projection_loop_time/10
		var reduction_frac:float = CombatStats.technique_scaled_value\
		(acceleration, fighter.technique, "",acceleration_technique_amp ) ;
		ticker.wait_time -= ticker.wait_time * reduction_frac;
	else:
		start_projection_animation()
		ticker.start()

func _on_ticker_timeout() -> void:
	Combat.aoe_damage(fighter);
	
func damage_modifier(damage:float, _unit:ActiveFighter)->float:
	return damage * attack_scaling


func start_projection_animation()->void:
	projection = fighter.aoe_projection;
	projection.show();
	projection_loop();

var projection:Sprite2D;
var projection_loop_time:float = .75
func projection_loop()->void:
	var tween:Tween = create_tween();
	tween.tween_property(projection, "self_modulate:a", .75, projection_loop_time/2);
	tween.tween_property(projection, "self_modulate:a", 0, projection_loop_time/2);
	tween.tween_callback(projection_loop)
