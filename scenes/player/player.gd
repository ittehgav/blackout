@icon("res://assets/visual/editor_ui/IconGodotNode/node/icon_character.png")
extends Leader
class_name Player;

@export var disciplines:DisciplineTree;

signal entered_location(location:Location);
signal left_location;



signal resource_changed(resource:String);
signal morale_changed;
signal party_changed;
signal equipment_changed(equipment:Equipment);

signal upkeep_paid_fully;
signal upkeep_food_shortage;
signal upkeep_fuel_shortage

signal leveled_up;


## ANY ITEMS THAT BELONG TO THE PLAYER WILL BE CHILDREN OF THE INVENTORY NODE

## for easier iteration/checks
var equipment:Array[Equipment]

@export var equipped_weapon:Weapon;
@export var alternative_weapon:Weapon=null;

@export var equipped_module:Module;

@export var equipped_accessory_1:Accessory;
@export var equipped_accessory_2:Accessory;

var morale:float=3.7;

func _ready()->void:
	## TODO remove this once the new world map scene loads from proper context
	Entities.player = self

func level_up()->void:
	level += 1;
	experience = 0;
	leveled_up.emit()


func _on_level_up() -> void:
	for stat:String in Index.all_combat_stats:
		stats[stat] += Scaling.player_level_stat_gains[stat]

func equip_weapon(weapon:Weapon)->void:
	assert(weapon in inventory.weapons);
	equipment.erase(equipped_weapon)
	equipped_weapon = weapon;
	weapon.inventory_position = Vector2(-1, -1);
	
	equipment.append(equipped_weapon)
	equipment_changed.emit(weapon);

func equip_alt_weapon(weapon:Weapon)->void:
	assert(weapon in inventory.weapons);
	equipment.erase(alternative_weapon)
	alternative_weapon = weapon;
	weapon.inventory_position = Vector2(-1, -1);
	
	equipment.append(alternative_weapon)
	equipment_changed.emit(weapon);

func equip_module(module:Module)->void:
	assert(module in inventory.modules);
	equipment.erase(equipped_module)
	equipped_module = module;
	module.inventory_position = Vector2(-1, -1);
	
	equipment.append(equipped_module)
	equipment_changed.emit(module);
	
func equip_accessory(accessory:Accessory, index:int)->Accessory:
	## just changes the accessory appropriately, only gets here after it's verified that there's room
	assert(accessory in inventory.accessories);
	var just_unequipped:Accessory
	accessory.inventory_position = Vector2i(-1, -1)
	match index:
		1:
			just_unequipped = equipped_accessory_1;
			equipped_accessory_1 = accessory
		2:
			just_unequipped = equipped_accessory_2;
			equipped_accessory_2 = accessory
	
	equipment.erase(just_unequipped);
	equipment.append(accessory);
	equipment_changed.emit(accessory);
	
	return just_unequipped
	


func travel_upkeep_cost(per_hour:bool=false)->Dictionary[String, int]:
	## EVERY 30 MINUTES
	var cost:Dictionary = {
		"food":1.0,
		"fuel":1.0
	}
	for unit:FighterUnit in roster.units:
		cost.food += .5 * len(unit.base.tags)
		cost.fuel += .5 * len(unit.base.tags)

	if per_hour:
		cost.food *= 2.0;
		cost.fuel *= 2.0;
	
	var final_dict:Dictionary[String, int] = {
		"food":int(cost.food),
		"fuel":int(cost.fuel)
	}
	return final_dict;



func load_origin(origin:Player)->void:
	## easier to do this than to have to reconnect the signals from the 
	## world map player node
	while len(origin.roster.units):
		var unit:FighterUnit = origin.roster.units[0]
		origin.roster.units.erase(unit)
		roster.add_unit(unit)

	
	inventory.queue_free();
	var new_inventory:Inventory = origin.inventory;
	new_inventory.reparent(self);
	inventory = new_inventory;
	inventory.refresh_resource_counts()
	new_inventory.holder = self;
	stats.queue_free();
	var new_combat_stats:CombatStats = origin.combat_stats;
	new_combat_stats.reparent(self);
	stats = new_combat_stats;
	
	sight_range = origin.sight_range;
	
	color_scheme_index = origin.color_scheme_index
	
	party_name = origin.name;
	name = origin.name;

	level = origin.level;
	
	equipped_weapon = origin.equipped_weapon;
	equipped_module = origin.equipped_module;
	

func change_morale(change:float)->void:
	morale += change;
	morale_changed.emit()

func battle_lost()->void:
	## right now just does the morale and money loss
	## to maybe take into account for losses:
	## party power difference (enemy too high = less morale/money loss?)
	## 
	var morale_loss:float = .5 + (morale/3);
	change_morale(-morale_loss)

	var money_loss:float = inventory.money/3
	inventory.change_resource("money", int(-money_loss))

func battle_won()->void:
	change_morale((5-morale)/2)
