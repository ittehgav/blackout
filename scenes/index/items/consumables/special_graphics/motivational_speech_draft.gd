extends ItemSpecialGraphics

@export var morale_icon:MoraleIcon
@export var sound:AudioStreamPlayer

func play()->void:
	var target_value:float = (5 - Entities.player.morale)/3
	Entities.player.morale += target_value
	await morale_icon.animated_update(Entities.player.morale).finished;
	finished.emit();
	Entities.player.morale_changed.emit();
	sound.play()
