extends FighterBase


@export var beam:Polygon2D

func full_skill_description(_unit:FighterUnit)->String:
	var final_string:String = "Knocks back and stuns an enemy, also stuns and damages any enemies they collide with.";
	return final_string


func _on_animation_player_animation_started(anim_name: StringName) -> void:
	## consistently stays attached to skill start signal btw
	if anim_name == "fighter_base/skill":
		const beam_purple = Color(0.38, 0.22, 0.659, 1.0)
		beam.get_parent().rotation = fighter.global_position.angle_to_point(fighter.target_fighter.global_position)-PI/2;
		beam.scale.y = (fighter.global_position.distance_to(fighter.target_fighter.global_position)- beam.position.y)/2 
		fighter.target_fighter.sprite.material.set_shader_parameter("target_color", beam_purple)
		
		var tween:Tween = create_tween();
		tween.tween_property(beam, "color", beam_purple, .55)
		tween.parallel().tween_property(fighter.target_fighter.sprite.material, "shader_parameter/grad", 1, .55)
		
		tween.tween_property(beam, "color:a", .2, .1);
		tween.parallel().tween_property(fighter.target_fighter.sprite.material, "shader_parameter/grad", .2, .1);
		tween.tween_callback(beam.set_color.bind(Color(0.38, 0.22, 0.659, 0)));
		tween.tween_callback(fighter.target_fighter.sprite.material.set_shader_parameter.bind("grad", 0));
		
#
