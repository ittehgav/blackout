extends UIRoot
class_name UnitSheet;





@export_group("data_nodes")
@export var sample:SpriteSample;
@export var showing_unit:FighterUnit

@export var evolution_display:PanelContainer;

@export var unit_name_label:Label;
@export var skill_name_label:Label;
@export var skill_description_label:RichTextLabel;
@export var flavor_label:Label;

@export var tags_label:Label;

@export var unit_level_label:Label;
@export var level_progress_bar:TextureProgressBar;

@export var stats_dropdown:StatsDropdown

@export var skill_range_label:Label;
@export var skill_cooldown_label:Label;



func display_unit(unit:FighterUnit)->void:
	evolution_display.setup(unit);

	showing_unit = unit;
	
	showing_unit.base.set_material(null);
	sample.set_sample(showing_unit.base);
	sample.target_base.scale *= 6
	sample.target_base.offset.y += 20
	
	
	stats_dropdown.load_stats(unit.final_stats())
	refresh_data();
	fade_in()
	
func refresh_data()->void:
	unit_name_label.text = showing_unit.base.name;

	for tag:String in showing_unit.base.tags:
		tags_label.text += tag.capitalize() + "\n"
	
	unit_level_label.text = "Level " + str(showing_unit.level);
	level_progress_bar.max_value = Scaling.exp_for_next_level(showing_unit.level);
	level_progress_bar.value = showing_unit.experience;
	
	skill_name_label.text = "Skill: " + showing_unit.base.skill_name;
	skill_description_label.text = showing_unit.base.full_skill_description(showing_unit);
	flavor_label.text = showing_unit.base.flavor;

	
	skill_cooldown_label.text = "Cooldown: " + str(snapped(showing_unit.final_skill_cooldown(),.01)) + "s";
	skill_range_label.text = get_skill_range(showing_unit.base);
	

func get_skill_range(fighter:FighterBase)->String:
	if fighter.skill_range == fighter.MELEE_RANGE:
		return "Melee";
	elif fighter.skill_range < 750:
		return "Short Range";
	else:
		return "Long Range"
	

func fade_in()->void:
	modulate.a = 0;
	show();
	Tweens.ui_fade_in(self, .35)

var fading_out:bool=false;
func fade_out()->void:
	ui_sfx.play_stream("cancel")
	var tween:Tween = Tweens.ui_fade_out(self, .35);
	await tween.finished;
	queue_free();


func _input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_exit") and not fading_out:
		fading_out = true;
		fade_out();
