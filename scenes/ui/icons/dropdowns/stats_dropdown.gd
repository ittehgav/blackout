extends VBoxContainer

class_name StatsDropdown

## source right now is anything with the final_stats() method
## leader and FighterUnit
@export var source:Variant;

@export var from_player:bool=false;

@export var exp_bar:ExperienceBar;
@export var stat_labels:Dictionary[String, Label];

func _ready()->void:
	if from_player:
		Entities.player.level_up.connect(update)
		source = Entities.player;
	if exp_bar:
		exp_bar.level_up.connect(refresh_animation)
	## needs to have source set before entering tree
	if source:
		load_stats(source.final_stats())


func load_stats(target:CombatStats)->void:
	## can be used separately to
	for stat:String in Index.all_combat_stats:
		stat_labels[stat].text = str(target[stat]);


func update()->void:
	print("updez?")
	load_stats(source.final_stats())

func refresh_animation()->void:
	var source_stats:CombatStats = source.final_stats()
	if from_player:
		for stat:String in stat_labels.keys():
			var label:Label = stat_labels[stat]
			var tween:Tween = create_tween();
			tween.tween_method(set_stat_value.bind(label), float(label.text), source_stats[stat], .75)
		
func set_stat_value(target:float, label:Label)->void:
	label.text = str(snapped(target,.1))
