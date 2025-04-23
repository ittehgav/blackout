extends Control


@export var morale_icon:TextureRect;

func defeat_animation()->void:
	show()
	Entities.player.battle_defeat_morale();
	morale_icon.update();
	modulate.a = 0;
	var tween: = create_tween();
	tween.tween_property(self, "modulate:a", 1, 1);
	
func _input(e:InputEvent)->void:
	if visible and e is InputEventMouseButton and e.pressed:
		get_parent().end_post_fight()
