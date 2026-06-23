@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/icon_character_2.png")
extends Node2D

class_name FighterUnit

signal level_up;
signal accessory_equipped(new:Accessory, old:Accessory)
## fighter bases dont need to be loaded for each individual Fighter node
@export var base:FighterBase:
	set(new_base):
		## this runs when it gets first set and when changed right?
		base = new_base;
		update_stats()

@export var level:int=1;
@export var experience:int=0;


@export var stats:CombatStats; ## EXCLUSIVELY FROM LEVELS
@export var modifier_stats:CombatStats;
@export var stat_multipliers:CombatStats;

## can put them in enemy units too btw
@export var equipped_accessory:Accessory

@export var summon:bool=false;

var stats_loaded:bool=false;

func _ready()->void:
	## needs to enter tree to work properly?
	setup()

func setup()->void:
	if not base:
		find_base();


func find_base()->void:
	for c:Node in get_children():
		if c is FighterBase:
			base = Index.fighters.all_unit_bases[c.name];
			remove_child.call_deferred(c)
			return
	assert(false)

func gain_exp(amount:int)->int:
	## returns the amount of levels gained from the EXP
	## sets level and refreshes stuff all here
	var levels_gained:int = 0;
	var for_next_level:int = CombatStats.exp_for_next_level(level) - experience;
	while amount >= for_next_level:
		experience = 0; ## experience here is the exp the unit previously had
		amount -= for_next_level
		
		levels_gained += 1;
		level += 1;

		level_up.emit()
		for_next_level = CombatStats.exp_for_next_level(level);
	
	experience = amount

	## returns levels for EXP bar animations
	return levels_gained
	
	
func final_stats()->CombatStats:
	var modified_stats:CombatStats = CombatStats.new();
	
	for stat:String in CombatStats.all_stats + ["move_speed"]:
		modified_stats[stat] = final_stat(stat);

	return modified_stats;

func final_stat(stat:String)->float:
	return (stats[stat] + modifier_stats[stat]) * stat_multipliers[stat];

func change_base(new_base:FighterBase)->void:
	base = new_base;
	update_stats();

func update_stats()->void:
	## runs as the fighter is instantiated
	## stats are only changeable by levels for now
	stats_loaded = true;
	
	for stat:String in CombatStats.all_stats:
		stats[stat] = base.base_stats[stat];
		stats[stat] += base.stats_per_level[stat] * level;
	



func final_skill_cooldown(_agi_acm:float=stats.agility)->float:
	## can check from active fighter and from fighter unit
	if base.skill.base_cooldown == 0.0:
		return 0.0
	var cooldown:float = base.skill.base_cooldown;
	cooldown -= CombatStats.agility_cooldown_reduction(base.skill.base_cooldown, final_stats().agility)
	return cooldown
	



func _on_child_entered_tree(node: Node) -> void:
	if node is FighterBase and not summon:
		base = Index.fighters.all_unit_bases[node.name];
		remove_child.call_deferred(node)

func equip_accessory(new:Accessory)->Accessory:
	var previous:Accessory = equipped_accessory;
	equipped_accessory = new;
	accessory_equipped.emit(new, previous);
	Entities.player_sheet.party_view.unit_accessories_changed.emit()
	return previous


func _on_accessory_equipped(new: Accessory, old: Accessory) -> void:
	equipped_accessory = new;
	if new.stat_modifiers:
		for stat:String in CombatStats.all_stats:
			var modifier:float = new.stat_modifiers[stat]
			if modifier:
				modifier_stats[stat] += modifier
				
	if new.stat_multipliers:
		for stat:String in CombatStats.all_stats:
			var modifier:float = new.stat_multipliers[stat]
			if modifier:
				stat_multipliers[stat] += modifier
	
	if old:
		if old.stat_modifiers:
			for stat:String in CombatStats.all_stats:
				var modifier:float = old.stat_modifiers[stat]
				if modifier:
					modifier_stats[stat] -= modifier
					
		if old.stat_multipliers:
			for stat:String in CombatStats.all_stats:
				var modifier:float = old.stat_multipliers[stat]
				if modifier:
					stat_multipliers[stat] -= modifier

func unequip_accessory()->void:
	assert(equipped_accessory)
	get_parent().equipped_accessories.erase(equipped_accessory);
	equipped_accessory = null
