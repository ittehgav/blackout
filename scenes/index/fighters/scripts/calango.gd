extends FighterBase

@export var tail:Area2D;

func full_skill_description(unit:FighterUnit)->String:
	var poison_str:String = Index.colored_text("debuff", "Poisoned")
	var damage_str:String = Index.colored_text("attack", unit.final_stat("attack"), " damage")
	var poison_total_dmg:int = skill.status.value * skill.status.duration
	var poison_dmg_string:String = Index.colored_text("debuff", poison_total_dmg, " damage" )
	return "Sweeps its tail, dealing %s to nearby enemies, then sheds its tail and throws it at a random location, enemies who touch the tail are %s, taking %s damage over 5 seconds."\
			%[damage_str, poison_str, poison_dmg_string];


func special_skill_effect()->void:
	## BUG making 2 tails some times
	## every other time?
	var new_tail:Area2D = tail.duplicate();
	new_tail.area_entered.connect(detonate_tail.bind(new_tail))

	
	fighter.ally_team.projectiles.add_child(new_tail);
	
	new_tail.global_position = fighter.global_position
	new_tail.show()
	
	var x_shift:int = randi_range(-500, 500);
	var y_shift:int = randi_range(-500, 500)
	
	var target_position:Vector2 = fighter.global_position + Vector2(x_shift, y_shift)
	new_tail.get_node("tail/wiggle").play("wiggle")
	
	var tween:Tween = create_tween();
	tween.tween_property(new_tail, "global_position", target_position, 1);
	tween.tween_callback(new_tail.set_collision_mask_value.bind(fighter.enemy_team.team_n, true))
	

func detonate_tail(area:Area2D, source:Area2D)->void:
	assert(area is HurtBox)
	var animation:AnimationPlayer = source.get_node("tail/wiggle")
	animation.play("detonate");
	skill.status.apply_on_target(area.source)
	await animation.animation_finished;
	source.queue_free()
