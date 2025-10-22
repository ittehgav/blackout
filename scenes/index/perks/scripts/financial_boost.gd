extends Perk

@export var money_label:Label;
var money_gain:int
func _ready()->void:
	if not (get_parent() is Control):
		return
	## happens after player gains money from the fight
	print("_R??? ", name)
	money_gain = int(Entities.player.inventory.money/3);
	description = "Gain "+Index.get_color_tag("money")+str(money_gain) + " money.";
	title_color = Index.get_color("money");
	


func set_label_text(target:int)->void:
	money_label.text = str(target);


func animation_callback(display:Control)->void:
	panel.reparent(display)
	panel.show();

	await get_tree().create_timer(.5).timeout
	sfx.play()
	var current:int = int(money_label.text); ## it was set before the change applied
	var target:int = current + money_gain;
	
	var tween:Tween = create_tween()
	tween.tween_method(set_label_text, current, target, 1);


func apply()->void:
	Entities.player.inventory.money += money_gain;
