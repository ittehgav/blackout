extends ItemSpecialGraphics

@export var morale_icon:MoraleIcon
@export var sound:AudioStreamPlayer

func play()->void:
	var player:Player = get_tree().get_first_node_in_group("player")

	var target_value:float = (5 - player.morale)/3
	player.morale += target_value
	await morale_icon.animated_update(player.morale).finished;
	finished.emit();
	player.morale_changed.emit();
	sound.play()
