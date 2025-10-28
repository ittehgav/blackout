extends Perk

@export var stat_icon:StatIcon;
@export var stat_label:Label;


var stat:String
var gain:float

func _ready()->void:
	if not (get_parent() is Control):
		return
	print("_R??? ", name)
	stat = Index.all_combat_stats.pick_random();
	stat_icon.stat = stat;
	stat_icon.setup();
	
	icon = Index.textures.icons[stat];
	stat_label.text = str(snapped(Entities.player.final_stat(stat), .01))
	
	gain = Scaling.player_level_stat_gains[stat] * 2;
	title_color = Index.get_color(stat);
	
	name = stat.capitalize() +" Bonus";
	
	description = "Gain " + Index.get_color_tag(stat) + str(snapped(gain, .1)) +" "+ stat.capitalize() +"."

	
	
func set_stat_label_text(target:float)->void:
	if is_instance_valid(stat_label):
		stat_label.text = str(snapped(target, .01));


func animation_callback(display:Control)->void:
	## shows the dropdown in the middle of the screen, scales the 
	## label/icon of the corresponding stat then interpolates the label's text to the new value
	panel.reparent(display)
	panel.show();
	
	var current:float = float(stat_label.text);
	var target_value:float = current + gain
	
	await get_tree().create_timer(.5).timeout
	sfx.play()

	var tween:Tween = create_tween();
	tween.tween_method(set_stat_label_text, current, target_value, 1);
	
	await tween.finished;
	animation_finished.emit()
	


func apply()->void:
	Entities.player.modifier_stats[stat] += gain;
