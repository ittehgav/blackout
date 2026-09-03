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

var party_cap:int:
	get():
		var cap:int=0;
		for key:CarKey in inventory.car_keys:
			cap += key.party_space;
		return cap

var party_room:int:
	get():
		var cap:int = party_cap;
		return cap - len(roster.units);

@export var bound_items:Array[Item]
## right now just the initial car key but might as well
## leave it ready to add more 

## ANY ITEMS THAT BELONG TO THE PLAYER WILL BE CHILDREN OF THE INVENTORY NODE

## for easier iteration/checks
var equipment:Array[Equipment]

@export var equipped_weapon:Weapon;
@export var alternative_weapon:Weapon=null;

@export var equipped_module:Module;

@export var equipped_accessory_1:Accessory;
@export var equipped_accessory_2:Accessory;

@export var equipped_artifices:Dictionary[int, Artifice]={
	1:null, 2:null, 3:null
}
@export var equipped_artifices_names:Dictionary[int, String]={
	## keep the unique_name property of the artifices so they all
	## count as equipped together
	## some functions will use the obejct-base dict and some the name-based
	## the propagation of any changes start in this script
	## after all values are updated here
	1:"",2:"",3:""
}
func get_equipped_artfice(slot:int)->Artifice:
	return equipped_artifices[slot]

@export var morale:float=3.7;


func level_up()->void:
	level += 1;
	experience = 0;
	leveled_up.emit()


func _on_level_up() -> void:
	for stat:String in CombatStats.all_stats:
		stats[stat] += CombatStats.player_level_stat_gains[stat]
		
func switch_weapons()->void:
	assert(equipped_weapon and alternative_weapon);
	var alt:Weapon = alternative_weapon;
	alternative_weapon = equipped_weapon;
	equipped_weapon = alt
	
	equipment_changed.emit(equipped_weapon)

func equip_weapon(weapon:Weapon)->void:
	assert(weapon in inventory.weapons);
	equipment.erase(equipped_weapon)
	equipped_weapon = weapon;
	weapon.inventory_position = InventoryDisplay.ITEM_UNPLACED;
	
	equipment.append(equipped_weapon)
	equipment_changed.emit(weapon);

func equip_alt_weapon(weapon:Weapon, quiet:bool=false)->void:
	assert(weapon in inventory.weapons);
	equipment.erase(alternative_weapon)
	alternative_weapon = weapon;
	weapon.inventory_position = InventoryDisplay.ITEM_UNPLACED;
	
	equipment.append(alternative_weapon)
	if not quiet:
		equipment_changed.emit(weapon);

func equip_module(module:Module)->void:
	assert(module in inventory.modules);
	equipment.erase(equipped_module)
	equipped_module = module;
	module.inventory_position = InventoryDisplay.ITEM_UNPLACED
	
	equipment.append(equipped_module)
	equipment_changed.emit(module);
	
func equip_accessory(accessory:Accessory, index:int)->Accessory:
	## just changes the accessory appropriately, only gets here after it's verified that there's room
	assert(accessory in inventory.accessories);
	var just_unequipped:Accessory
	accessory.inventory_position = Vector2i(-1, -1)
	
	var key:String = "equipped_accessory_"+str(index);
	just_unequipped = self[key];

	if just_unequipped:
		unequip_accessory(just_unequipped, index, true)

	self[key] = accessory
	equipment.append(accessory);
	equipment_changed.emit(accessory);
	
	return just_unequipped

func unequip_accessory(target:Accessory, index:int, quiet:bool=false)->void:
	equipment.erase(target);
	self["equipped_accessory_"+str(index)] = null;
	if not quiet:
		equipment_changed.emit(target)
	


func equip_artifice(target:Artifice, slot:int)->Artifice:
	var current_slot:Variant = equipped_artifices_names.find_key(target.unique_name);
	if current_slot:
		unequip_artifice(current_slot, true)
	var unequipped:Artifice=null;
	if equipped_artifices[slot] != null:
		unequipped = equipped_artifices[slot]
		unequip_artifice(slot, true);
		
	equipped_artifices[slot] = target;
	equipped_artifices_names[slot] = target.unique_name
	
	equipment_changed.emit(target);
	return unequipped
	
func unequip_artifice(slot:int, quiet:bool=false)->void:

	var eq:Artifice = equipped_artifices[slot]
	equipped_artifices[slot] = null;
	equipped_artifices_names[slot] = ""
	if not quiet:
		equipment_changed.emit(eq)



func travel_upkeep_cost(per_hour:bool=false)->Dictionary[String, int]:
	## EVERY 30 MINUTES BY DEFAULT
	var cost:Dictionary = {
		"food":1.0,
		"fuel":0
	}
	for unit:FighterUnit in roster.units:
		cost.food += .5 * len(unit.base.tags)
	
	for key:CarKey in Entities.player.inventory.car_keys:
		cost.fuel += key.fuel_cost;

	if per_hour:
		cost.food *= 2.0;
		cost.fuel *= 2.0;
	
	var final_dict:Dictionary[String, int] = {
		"food":int(cost.food),
		"fuel":int(cost.fuel)
	}
	return final_dict;




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
