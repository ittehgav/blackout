extends PanelContainer

@export var food_label:Label;
@export var fuel_label:Label;
@export var money_label:Label;
@export var juice_label:Label;
@export var scrap_label:Label;
@export var chips_label:Label;

func _ready()->void:
	refresh_counters();
	

func refresh_counters()->void:
	for r:String in Index.all_resources:
		var label:Label = self[r+"_label"];
		var current_amount:int = int(label.text);
		if current_amount != Entities.player.inventory[r]:
			Tweens.tween_count_label(label, Entities.player.inventory[r])
