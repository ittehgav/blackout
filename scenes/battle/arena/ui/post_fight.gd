extends Control


func show_post_fight(winner_n:int)->void:
	get_tree().paused = true
	$winner.text = "Team "+ str(winner_n)+ " Wins!";
	
	show();
	Tweens.ui_fade_in(self)
	
