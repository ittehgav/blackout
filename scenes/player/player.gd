extends Leader

class_name Player;

@export var leadership_stats:Node;

signal entered_settlement(settlement:Settlement);
signal left_settlement;

signal resource_changed(resource:String, change:int);
signal morale_changed;
signal party_changed;
signal equipment_changed(equipment:Equipment);


signal leadership_level_up;
signal combat_level_up;

## leadership skills will be a special tree that grants a special bonus at each level
## you can win leadership EXP by fighting (based on the amount of units is the party?)
## and by completing quests (auto-generated tasks from settlements?)
@export var leadership_level:int = 1;
@export var leadership_exp:int = 0;
@export var leadership_points:int = 0;


## combat exp will be gained in parallel with leadership levels, 
## you win combat EXP when fighting
@export var combat_level:int = 1;
@export var combat_exp:int = 0;
@export var combat_stat_points:int=0;

## ANY ITEMS THAT BELONG TO THE PLAYER WILL BE CHILDREN OF THE INVENTORY NODE
@export var equipped_weapon:Weapon;
@export var alternative_weapon:Weapon=null;

@export var equipped_module:Module;




var morale:float=3.7;

func _ready()->void:
	## TODO remove this once the new world map scene loads from proper context
	Entities.player = self;

	
func battle_victory_morale()->void:
	## for now just make all morale changes go through this script
	morale += .5;
	
func battle_defeat_morale()->void:
	morale -= .5




func _on_combat_level_up() -> void:
	combat_stat_points += 1;

func equip_weapon(weapon:Weapon)->void:
	assert(weapon in inventory.weapons);
	equipped_weapon = weapon;
	weapon.inventory_position = Vector2(-1, -1);
	
	equipment_changed.emit(weapon);

func equip_alt_weapon(weapon:Weapon)->void:
	assert(weapon in inventory.weapons);
	alternative_weapon = weapon;
	weapon.inventory_position = Vector2(-1, -1);
	
	equipment_changed.emit(weapon);

func equip_module(module:Module)->void:
	assert(module in inventory.modules);
	equipped_module = module;
	module.inventory_position = Vector2(-1, -1);
	
	equipment_changed.emit(module);


func travel_upkeep_cost()->Dictionary:
	var cost:Dictionary = {
		"food":1.0,
		"fuel":1.0
	}
	for unit:FighterUnit in roster.units:
		cost.food += .5 * len(unit.base.tags)
		cost.fuel += .5 * len(unit.base.tags)
	
	cost.food = int(cost.food);
	cost.fuel = int(cost.fuel)
	
	return cost;

func travel_upkeep()->void:
	## food and fuel start at 1 to account for player's expenses
	if not Entities.current_settlement:
		var cost:Dictionary = travel_upkeep_cost();
		var missing_food:int = 0;
		var missing_fuel:int = 0;
		
		if inventory.food >= cost.food:
			inventory.change_resource("food", cost.food * -1);
		else:
			missing_food = cost.food - inventory.food;
			inventory.change_resource("food", inventory.food * -1)
			
		if inventory.fuel >= cost.fuel:
			inventory.change_resource("fuel", cost.fuel * -1)
		else:
			missing_fuel = cost.fuel - inventory.fuel;
			inventory.change_resource("fuel", inventory.fuel * -1);
		
		var sfx_key:String
		
		if not missing_food and not missing_fuel:
			sfx_key = "travel_upkeep"
			
		
		if missing_food:
			sfx_key = "food_shortage"
			if missing_food > cost.food/2:
				morale /= 3;
			else:
				morale /= 2;
			morale_changed.emit();

		if missing_fuel:
			sfx_key = "fuel_shortage"
			## speed will halve every hour down to a bottom cap
			Entities.player_map_party.move_speed /= 2;
			if Entities.player_map_party.move_speed < 50:
				Entities.player_map_party.move_speed = 50;
		else:
			## make this not take an hour to reset
			## (or not and it's like a properly measured punishment?)
			Entities.player_map_party.move_speed = Entities.player_map_party.navigation*50;
		
		inventory.refresh_resource_counts("", 0, false)
		Entities.world_map.ui.hud.sfx.play_sound_by_key(sfx_key);

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
	inventory.refresh_resource_counts("", 0, false)
	new_inventory.holder = self;
	combat_stats.queue_free();
	var new_combat_stats:CombatStats = origin.combat_stats;
	new_combat_stats.reparent(self);
	combat_stats = new_combat_stats;
	
	sight_range = origin.sight_range;
	
	color_scheme_index = origin.color_scheme_index;
	
	party_name = origin.name;
	name = origin.name;

	leadership_level = origin.leadership_level;
	
	combat_level = origin.combat_level;
	
	equipped_weapon = origin.equipped_weapon;
	equipped_module = origin.equipped_module;
	
