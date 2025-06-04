extends Leader

class_name Player;

@export var leadership_stats:Node;

signal resource_changed(resource:String, change:int);
signal morale_changed;
signal party_changed;
signal equipment_changed(equipment:Equipment);

signal new_memo(memo:Memo);

signal leadership_level_up;
signal combat_level_up;

## leadership skills will be a special tree that grants a special bonus at each level
## you can win leadership EXP by fighting (based on the amount of units is the party?)
## and by completing quests (auto-generated tasks from settlements?)
@export var leadership_level:int = 0;
@export var leadership_exp:int = 0;
@export var leadership_points:int=0;


## combat exp will be gained in parallel with leadership levels, 
## you win combat EXP when fighting
@export var combat_level:int = 0;
@export var combat_exp:int = 0;
@export var combat_stat_points:int=0;

## ANY ITEMS THAT BELONG TO THE PLAYER WILL BE CHILDREN OF THE INVENTORY NODE
@export var equipped_weapon:Weapon;
@export var alternative_weapon:Weapon=null;

@export var equipped_module:Module;


var memos:Array[Memo];


var morale:float=3.7;

func _ready()->void:
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
	party_changed.emit(weapon);

func equip_module(module:Module)->void:
	assert(module in inventory.modules);
	equipped_module = module;
	module.inventory_position = Vector2(-1, -1);
	
	equipment_changed.emit(module);

func _on_new_memo(memo: Memo) -> void:
	memos.append(memo)

func travel_upkeep()->void:
	## food and fuel start at 1 to account for player's expenses
	var food_cost:float = 1;
	var fuel_cost:float =  1;
	
	for unit:FighterUnit in roster.units:
		for _tag:String in unit.base.tags:
			food_cost += .25;
			fuel_cost += .25;
	
	food_cost = int(food_cost);
	fuel_cost = int(fuel_cost);
	
	var missing_food:int = 0;
	var missing_fuel:int = 0;
	
	if inventory.food >= food_cost:
		inventory.change_resource("food", food_cost * -1);
	else:
		missing_food = food_cost - inventory.food;
		inventory.change_resource("food", inventory.food * -1)
		
	if inventory.fuel >= fuel_cost:
		inventory.change_resource("fuel", fuel_cost * -1)
	else:
		missing_fuel = fuel_cost - inventory.fuel;
		inventory.change_resource("fuel", inventory.fuel * -1);
		
	if not missing_food and not missing_fuel:
		Entities.world_map.ui.hud.sfx.play_sound_by_key("travel_upkeep")
		
	
	if missing_food:
		Entities.world_map.ui.hud.sfx.play_sound_by_key("food_shortage")
		if missing_food > food_cost/2:
			morale /= 3;
		else:
			morale /= 2;
		morale_changed.emit();

	if missing_fuel:
		Entities.world_map.ui.hud.sfx.play_sound_by_key("fuel_shortage")
		## speed will halve every hour down to a bottom cap
		Entities.in_map_player.move_speed /= 2;
		if Entities.in_map_player.move_speed < 50:
			Entities.in_map_player.move_speed = 50;
	else:
		Entities.in_map_player.move_speed = Entities.in_map_player.navigation*50;
