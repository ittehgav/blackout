extends Node

func deal_damage(source:CharacterBody2D, target:CharacterBody2D)->void:
	var damage:float = source.attack;
	target.hp -= source.attack;
	target.damage_taken.emit(damage)

	if target.hp <= 0:
		target.death.emit(source);

func stun_target(source:CharacterBody2D, target:CharacterBody2D):
	var duration = source.base.stun_duration
	if target.stun_timer.is_stopped() or target.stun_timer.time_left < duration:
			target.stun_timer.wait_time = duration;
			target.stun_timer.start()
	target.status_applied.emit(source, "stun")
	Tweens.stun_vfx(target);
