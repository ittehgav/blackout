extends Button

@export var sprite_holder:Control;
@export var base_name:Label;
@export var flavor:Label
@export var tags:Label

@export var skill_name:Label;
@export var skill_cooldown:Label
@export var skill_description:RichTextLabel;

@export var stats_before:StatsDropdown;
@export var stats_after:StatsDropdown;

var target_unit:FighterUnit;
var target_base:FighterBase;

func show_evolution(unit:FighterUnit, new_base:FighterBase)->void:
	target_unit = unit;
	target_base = new_base;
	for c:Node in sprite_holder.get_children():
		c.queue_free();
	skill_name.text = new_base.skill_name;
	
	var sample:FighterBase = new_base.duplicate();
	sample.scale = Vector2(2,2);
	sprite_holder.add_child(sample);
	sample.position.x = 100

	tags.text = "";
	for tag:String in new_base.tags:
		tags.text += tag + "\n";
	
	flavor.text = new_base.flavor
	
	base_name.text = new_base.name;
	
	var new_unit:FighterUnit = Index.scenes.fighter_unit.instantiate();
	new_unit.level = unit.level;
	new_unit.base = new_base;
	new_unit.update_stats();
	new_unit.modifier_stats = unit.modifier_stats;
	new_unit.stat_multipliers = unit.stat_multipliers

	skill_cooldown.text = "Cooldown: "+str(snapped(new_base.final_skill_cooldown(new_unit),.01))+"s"
	
	skill_description.text = new_base.full_skill_description(new_unit)
	var new_stats:CombatStats = new_unit.final_stats();

	stats_before.load_stats(unit.final_stats());
	stats_after.load_stats(new_stats)
