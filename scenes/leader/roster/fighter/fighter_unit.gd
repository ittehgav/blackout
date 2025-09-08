extends Node2D

class_name FighterUnit

signal level_up;
signal accessory_equipped(new:Accessory, old:Accessory)
## fighter bases dont need to be loaded for each individual Fighter node
@export var base:FighterBase;

@export var level:int=1;
@export var experience:int=0;


@export var stats:CombatStats;
@export var modifier_stats:CombatStats;
@export var stat_multipliers:CombatStats;

## can put them in enemy units too btw
@export var equipped_accessory:Accessory

var stats_loaded:bool=false;

func _ready()->void:
	## needs to enter tree to work properly?
	if base and not stats_loaded:
		update_stats();
	level_up.connect(Scaling.level_up_stats)

func final_stats()->CombatStats:
	var modified_stats:CombatStats = Index.scenes.combat_stats.instantiate();
	
	for stat:String in Index.all_combat_stats:
		modified_stats[stat] = (stats[stat] + modifier_stats[stat]) * stat_multipliers[stat]
	
	return modified_stats;

func change_base(new_base:FighterBase)->void:
	base = new_base;
	update_stats();

func update_stats()->void:
	## runs as the fighter is instantiated
	## stats are only changeable by levels for now
	Scaling.initiate_unit_stats(self);
	Scaling.level_up_stats(self, level)
	apply_stat_modifiers();
	stats_loaded = true;



func final_skill_cooldown(agi_acm:float=stats.agility)->float:
	## can check from active fighter and from fighter unit
	var cooldown:float = base.skill_cooldown;
	while agi_acm > 5:
		cooldown -= cooldown/20;
		agi_acm -= 5;
	
	var final_reduction:float = (cooldown/100)*agi_acm
	cooldown -= final_reduction
	return cooldown
	
func upgrade_available()->bool:

	return "evolutions" in base and level >= 5;

func upgrade_affordable()->bool:
	for e:String in base.evolutions.keys():
		var affordable:int=0;
		for resource:String in base.evolutions[e]:
			if Entities.player.inventory[resource] >= base.evolutions[e][resource]:
				affordable += 1
		if affordable == 2:
			return true;
	return false

func gain_stat_modifier(stat:String, value:float)->void:
	## adds the stats right away so doesn't need to refresh all stats
	modifier_stats[stat] += value;
	stats[stat] += value;

func apply_stat_modifiers()->void:
	## only needs to run when figher unit is first loaded on when stats are refreshed
	## (as of right now only when upgraded)
	for stat:String in Index.all_combat_stats:
		stats[stat] += modifier_stats[stat]


func _on_child_entered_tree(node: Node) -> void:
	if node is FighterBase:
		#assert(not base);
		await Index.ready
		base = Index.fighters.find_base(node.name);
		remove_child(node)

func equip_accessory(new:Accessory)->Accessory:
	var previous:Accessory = equipped_accessory;
	equipped_accessory = new;
	accessory_equipped.emit(new, previous);
	return previous


func _on_accessory_equipped(new: Accessory, old: Accessory) -> void:
	## TODO check if there's room for old before equipping
	equipped_accessory = new;
	if new.stat_modifiers:
		for stat:String in Index.all_combat_stats:
			var modifier:float = new.stat_modifiers[stat]
			if modifier:
				modifier_stats[stat] += modifier
				
	if new.stat_multipliers:
		for stat:String in Index.all_combat_stats:
			var modifier:float = new.stat_multipliers[stat]
			if modifier:
				stat_multipliers[stat] += modifier
	
	if old:
		if old.stat_modifiers:
			for stat:String in Index.all_combat_stats:
				var modifier:float = old.stat_modifiers[stat]
				if modifier:
					modifier_stats[stat] -= modifier
					
		if old.stat_multipliers:
			for stat:String in Index.all_combat_stats:
				var modifier:float = old.stat_multipliers[stat]
				if modifier:
					stat_multipliers[stat] -= modifier
