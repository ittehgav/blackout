extends Sprite2D;

class_name FighterBase

var fighter:ActiveFighter;


@export var need_target:bool=true;

const MELEE_RANGE = 50

func fighter_died()->void:
	modulate.v = .5;
	modulate.a = .5;
	var tween:Tween = Tweens.ui_fade_out(self, false, .3)
	tween.parallel().tween_property(self, "position:x", 20, .3);
	await tween.finished;
	fighter.queue_free()
