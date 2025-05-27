extends TextureRect

var x_acm:int

func _input(e:InputEvent)->void:
	if e.is_action_pressed("move_right"):
		x_acm += texture.width;
		var clone:TextureRect = duplicate();
		clone.position.x = x_acm;
		add_child(clone)
	
