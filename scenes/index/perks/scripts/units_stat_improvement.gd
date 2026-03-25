extends Perk


const tag_bonus_names:Dictionary[FighterBase.Tag, String]={
	FighterBase.Tag.bodybuilder:"Callusing",
	FighterBase.Tag.scientist:"Field Insight",
	FighterBase.Tag.cyborg:"Machine Learning",
	FighterBase.Tag.mechanic:"Field Expertise"
}

## 2 LEVEL'S WORTH of the stat in question
## possibly being less value for tags that gain less of that stat
## but then it's a bigger gain on an otherwise scarce thing to get?

const tag_stat_gains:Dictionary[FighterBase.Tag, String] = {
	FighterBase.Tag.bodybuilder:"defense",
	FighterBase.Tag.scientist:"agility",
	FighterBase.Tag.cyborg:"technique",
	FighterBase.Tag.mechanic:"attack"
}

const tag_stat_values:Dictionary[String, float] = {
	## probably not balanced at all rn
	"defense":5,
	"agility":.25,
	"technique":.5,
	"attack":10
}

@export var samples_hbox:HBoxContainer;

@export var stat_change_hbox:HBoxContainer;
@export var stat_label:Label;

var target_tag:FighterBase.Tag
var stat:String
var gain:float

var change_labels:Array[Label]

func _ready()->void:
	if not (get_parent() is Control):
		return

	print("_R??? ", name)
	
	target_tag = select_tag();
	title_color = Index.primary_tag_colors[str(target_tag)];
	
	name = tag_bonus_names[target_tag];
	stat = tag_stat_gains[target_tag]
	gain = tag_stat_values[stat];
	
	icon = Index.textures.icons[stat]
	var total_units:int = len(Entities.player.roster.units.filter(func(unit:FighterUnit)->bool:return target_tag in unit.base.tags))

	generate_samples();
	
	description = "Your [color="+title_color.to_html()+"]" + str(target_tag) + "s[/color] gain +"+Index.get_color_tag(stat)+\
	str(snapped(gain, .1))+" " +stat+ "[/color].\n[font_size=16]You have "+str(total_units) + " " + Index.get_color_tag(str(target_tag)) + str(target_tag)+ "s[/color] in your party."

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
		




func select_tag()->FighterBase.Tag:
	var counts:Dictionary[FighterBase.Tag, int] = {}
	for tag:FighterBase.Tag in Index.primary_fighter_tags:
		counts[tag] = 0;
	
	for unit:FighterUnit in Entities.player.roster.units:
		for tag:FighterBase.Tag in unit.base.tags:
			if counts.has(tag):
				counts[tag] += 1;
	var highest_count:int = 0;
	for tag:FighterBase.Tag in counts.keys():
		if counts[tag] > highest_count:
			highest_count = counts[tag];
	
	var valid_tags:Array[String]
	for tag:FighterBase.Tag in counts.keys():
		if counts[tag] == highest_count:
			valid_tags.append(tag)
	
	var final_tag:FighterBase.Tag = valid_tags.pick_random();
	return final_tag

func animation_callback(display:Control)->void:
	## show the units with an icon+label of the stat they're getting
	## interpolate the number + some shaking/scaling
	## play some sound
	panel.reparent(display);
	panel.show();
	
	await get_tree().create_timer(1).timeout
	sfx.play()
	
	const tween_duration = .5
	for label:Label in change_labels:
		var start:float = float(label.text);
		var target:float = start + gain;
		

		var tween:Tween = create_tween();
		tween.tween_method(set_label_text.bind(label), start, target, tween_duration);
	await get_tree().create_timer(tween_duration).timeout
	animation_finished.emit();
	
func set_label_text(target:float, label:Label)->void:
	label.text = str(snapped(target, .01));

func apply()->void:
	var units:Array[FighterUnit] = Entities.player.roster.units.filter(func(unit:FighterUnit)->bool:return target_tag in unit.base.tags);
	for unit:FighterUnit in units:
		unit.modifier_stats[stat] += gain;
