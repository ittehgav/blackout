extends Control


func show_post_fight(winner:int)->void:
	
	$winner.text = "Team " + str(winner) + " Wins!"
	show();
	modulate.a = .1;
	var tween:Tween = create_tween();
	tween.tween_property(self, "modulate:a", 1, .5)
