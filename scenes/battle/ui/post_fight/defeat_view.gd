extends Control

@export var morale_icon:MoraleIcon
@export var money_icon:ResourceIcon

func play_animation()->void:
	await Tweens.ui_fade_in(self).finished
	morale_icon.animated_update();
	money_icon.animated_update()
	
	
