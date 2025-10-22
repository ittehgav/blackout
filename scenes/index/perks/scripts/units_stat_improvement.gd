extends Perk


const tag_bonus_names:Dictionary[String, String]={
	"bodybuilder":"Callusing",
	"scientist":"Field Insight",
	"cyborg":"Machine Learning",
	"mechanic":"Field Expertise"
}

## 2 LEVEL'S WORTH of the stat in question
## possibly being less value for tags that gain less of that stat
## but then it's a bigger gain on an otherwise scarce thing to get?

const tag_stat_gains:Dictionary[String, String] = {
	"bodybuilder":"defense",
	"scientist":"agility",
	"cyborg":"technique",
	"mechanic":"attack"
}

@export var samples_hbox:HBoxContainer;

@export var stat_change_hbox:HBoxContainer;
@export var stat_label:Label;

var target_tag:String
var stat:String
var gain:float

var change_labels:Array[Label]

func _ready()->void:
	if not (get_parent() is Control):
		return

	print("_R??? ", name)
	
	target_tag = select_tag();
	title_color = Index.primary_tag_colors[target_tag];
	
	name = tag_bonus_names[target_tag];
	stat = tag_stat_gains[target_tag]
	gain = to_gain();
	icon = Index.textures.icons[stat]

	generate_samples();
	
	description = "Your [color="+title_color.to_html()+"]" + target_tag + "s[/color] gain +"+Index.get_color_tag(stat)+\
	str(snapped(gain, .1))+" " +stat+ "[/color]."

func generate_samples()->void:
	var units:Array[FighterUnit] = Entities.player.roster.units.filter(func(unit:FighterUnit)->bool:return target_tag in unit.base.tags);
	for unit:FighterUnit in units:
		var sample:UnitSample = Index.scenes.ui.unit_sample.instantiate();
		sample.load_unit(unit);
		samples_hbox.add_child(sample)
		
		var hbox:HBoxContainer = stat_change_hbox.duplicate()
		var label:Label = hbox.get_node("stat_label");
		change_labels.append(label)
		
		label.text = str(snapped(unit.final_stat(stat), .01));
		hbox.get_node("icon").stat = stat;
		hbox.show()
	
		sample.add_child(hbox);
		hbox.position = Vector2(50, 90);
		


func to_gain()->float:
	var stats:Dictionary = Scaling.tag_stats_per_level(target_tag);
	## 4 times the tag's correspondign stat/level 
	## to account for how the usual level gain has 2 tags' worth of gains
	## for any individual stat
	return stats[stat] * 4

func select_tag()->String:
	var counts:Dictionary[String, int] = {}
	for tag:String in Index.primary_fighter_tags:
		counts[tag] = 0;
	
	for unit:FighterUnit in Entities.player.roster.units:
		for tag:String in unit.base.tags:
			if counts.has(tag):
				counts[tag] += 1;
	var highest_count:int = 0;
	for tag:String in counts.keys():
		if counts[tag] > highest_count:
			highest_count = counts[tag];
	
	var valid_tags:Array[String]
	for tag:String in counts.keys():
		if counts[tag] == highest_count:
			valid_tags.append(tag)
	
	var final_tag:String = valid_tags.pick_random();
	return final_tag

func animation_callback(display:Control)->void:
	## show the units with an icon+label of the stat they're getting
	## interpolate the number + some shaking/scaling
	## play some sound
	panel.reparent(display);
	panel.show();
	
	await get_tree().create_timer(1).timeout
	sfx.play()
	for label:Label in change_labels:
		var start:float = float(label.text);
		var target:float = start + gain;
		
		var tween:Tween = create_tween();
		tween.tween_method(set_label_text.bind(label), start, target, randi_range(.75, 1));
	
func set_label_text(target:float, label:Label)->void:
	label.text = str(snapped(target, .01));

func apply()->void:
	var units:Array[FighterUnit] = Entities.player.roster.units.filter(func(unit:FighterUnit)->bool:return target_tag in unit.base.tags);
	for unit:FighterUnit in units:
		unit.modifier_stats[stat] += gain;
