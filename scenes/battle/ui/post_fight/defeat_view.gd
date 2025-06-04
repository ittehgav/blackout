extends Control


@export var morale_icon:TextureRect;
@export var morale_label:Label;


func defeat_animation()->void:
	show()
	var previous_morale:float=Entities.player.morale;
	set_morale_label_text(previous_morale)
	Entities.player.battle_defeat_morale();
	var tween:Tween = Tweens.ui_fade_in(self, 1);
	tween.tween_method(set_morale_label_text, previous_morale, Entities.player.morale, .75);
	tween.tween_callback(morale_icon.update);

	
func _input(e:InputEvent)->void:
	if visible and e is InputEventMouseButton and e.pressed:
		get_parent().end_post_fight()

func set_morale_label_text(value:float)->void:
	morale_label.text = str(snapped(value, .01));
