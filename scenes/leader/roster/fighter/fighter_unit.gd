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
	setup()

func setup()->void:
	if not base:
		find_base();
	## needs to run with level and base assigned
	update_stats();

func find_base()->void:

	for c:Node in get_children():
		if c is FighterBase:
			base = c;
			remove_child(c)
			return
	assert(false)

func final_stats()->CombatStats:
	var modified_stats:CombatStats = Index.scenes.combat_stats.instantiate();
	
	for stat:String in Index.all_combat_stats + ["move_speed"]:
		modified_stats[stat] = final_stat(stat);

	return modified_stats;

func final_stat(stat:String)->float:
	if stat == "attack" and base.no_damage:
		return 0;
	return (stats[stat] + modifier_stats[stat]) * stat_multipliers[stat];

func change_base(new_base:FighterBase)->void:
	base = new_base;
	update_stats();

func update_stats()->void:
	## runs as the fighter is instantiated
	## stats are only changeable by levels for now
	stats_loaded = true;
	if base.hard_stats:
		for s:String in Index.all_combat_stats:
			stats[s] = base.hard_stats[s];
		stats.move_speed = base.hard_stats.move_speed
		return
		

	Scaling.initiate_unit_stats(self);
	Scaling.level_up_stats(self, level)



func final_skill_cooldown(_agi_acm:float=stats.agility)->float:
	## can check from active fighter and from fighter unit
	if base.skill_cooldown == 0.0:
		return 0.0
	var cooldown:float = base.skill_cooldown;
	cooldown -= Scaling.agility_cooldown_reduction(base.skill_cooldown, final_stats().agility)
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






func _on_child_entered_tree(node: Node) -> void:
	if node is FighterBase and not node.special:
		assert(not base);
		await Index.ready
		base = Index.fighters.find_base(node.name);
		remove_child(node)

func equip_accessory(new:Accessory)->Accessory:
	var previous:Accessory = equipped_accessory;
	equipped_accessory = new;
	accessory_equipped.emit(new, previous);
	Entities.player_sheet.party_view.unit_accessories_changed.emit()
	return previous


func _on_accessory_equipped(new: Accessory, old: Accessory) -> void:
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
