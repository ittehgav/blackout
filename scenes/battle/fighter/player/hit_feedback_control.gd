extends Node
class_name HitFeedbackControl

@export var player_fighter:PlayerFighter;

@export var melee_feedback:Sprite2D;
@export var projectile_feedback:Sprite2D;


func _on_equipment_weapon_hit(weapon: Weapon) -> void:
	if weapon.melee:
		for target:ActiveFighter in player_fighter.hit_targets:
			var f:Sprite2D = play_feedback(melee_feedback, target.global_position);
			var tween := create_tween();
			tween.tween_property(f, "offset:x", 5, .35);
	else:
		for target:ActiveFighter in player_fighter.hit_targets:
			play_feedback(projectile_feedback, target.global_position)

func play_feedback(target:Sprite2D, spot:Vector2)->Sprite2D:
	var feedback:Sprite2D = target.duplicate();
	player_fighter.ally_team.projectiles.add_child(feedback);
	feedback.show()
	feedback.global_position = spot
	var rr:Array[int];
	const offset_range = 40
	if player_fighter.global_position.x > spot.x:
		rr = [-offset_range, offset_range];
	else:
		rr = [180 - offset_range, 180 + offset_range]
	feedback.rotation_degrees = randi_range(rr[0], rr[1]);
		
	var animation:AnimationPlayer = feedback.get_node("animation")
	animation.play("feedback");
	animation.animation_finished.connect(feedback.queue_free)
	return feedback
