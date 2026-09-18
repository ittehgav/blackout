extends Node
class_name Bounty

signal claimed
var already_claimed:bool=false

enum Type{
	clear_dungeon,
	deliver_resource,
	deliver_unit,
	deliver_item
}

## for context injection in location menu test;
@export var dungeon_override:Dungeon
@export var item_override:Item;

var type:Type

## will be using a lot for generation so might as well have it here
var location:Location; 

var money_reward:int;
var unit_reward:FighterUnit;
var resources_reward:Dictionary[String, int];

var dungeon_clear_target:Dungeon;

var resource_to_deliver:String;
var resource_amount:int;

var unit_base:FighterBase ## points to base index entry;
var unit_level:int;

var item_to_deliver:Item ## just an instance of the item;

## settlements will have 3 bounties that can't be the exact same
var concurrent_bounties:Array[Bounty]





var refresh_unused:bool
var unused_types_cache:Array
var unused_types:Array:
	get():
		if refresh_unused:
			var types:Array = Type.values();
			types = types.filter(
				func(t:Type)->bool:
					return concurrent_bounties.find_custom(
						func(b:Bounty)->bool:return b.type == t) == -1
					)
			unused_types_cache = types;
			refresh_unused = false;
		return unused_types_cache
	
func reroll_type()->Type:
	return unused_types.pick_random();


func refresh()->void:
	refresh_unused = true;
	money_reward = 0;
	unit_reward = null;
	resources_reward = {}
	
	var types:Array = unused_types
	var roll:Type = types.pick_random();
	## will always be compatible so long as the overridden bounties are setup first
	## will always need both overrides to consistently work in test scene
	## which is fine and still much faster than having to play 
	## world map for every test instance
	if dungeon_override:
		roll = Type.clear_dungeon;
	elif item_override:
		roll = Type.deliver_item;


	
	while not compatible(roll):
		roll = reroll_type();
	
	type = roll;
	match type:
		Type.clear_dungeon:
			if dungeon_override:
				dungeon_clear_target = dungeon_override
			else:
				var options:Array[Dungeon];
				for n:Location in location.neighbors:
					var s:Settlement = n.settlements[0];
					if s is Dungeon and not s.special:
						options.append(s);
				dungeon_clear_target = options.pick_random();
			money_reward = dungeon_clear_target.get_danger_level() * 5 * randi_range(10, 15)
			roll_resource_rewards(2)
			
			
		Type.deliver_resource:
			var resource_options:Array = Resources.all_resources.duplicate();
			resource_options.erase("money")
			for b:Building in location.settlements:
				var inv:ShopInventory = b.inventory;
				for c:ResourceContainer in inv.containers:
					resource_options.erase(c.resource)
			roll_resource_rewards(4)
					
			resource_to_deliver = resource_options.pick_random();
			var roll_base:int = Entities.player.level * 5
			match resource_to_deliver:
				"scrap":
					roll_base /= 1.25;
				"chips":
					roll_base /= 2;
					
			resource_amount = randi_range(roll_base/2, roll_base * 1.25);
			
		Type.deliver_unit:
			unit_base = get_random_base();
			var roll_base:int = Entities.player.level;
			unit_level = max(1, randi_range(roll_base/2, roll_base*1.25));
			
			money_reward = max(randi_range(20, 30), roll_base * randf_range(5,10))
			
			unit_reward = Index.scenes.fighter_unit.instantiate()
			unit_reward.base = get_random_base();
			unit_reward.level = unit_level * randf_range(1.0, 1.5)

		Type.deliver_item:
			if item_override:
				item_to_deliver = item_override.duplicate(DUPLICATE_USE_INSTANTIATION)
			else:
				var location_pool:Array[Location] = [location];
				for n:Location in location.neighbors:
					if n not in location_pool:
						location_pool.append(n);
					for subn:Location in n.neighbors:
						if subn not in location_pool:
							location_pool.append(subn);
				
				var pool:Array[Item];
				for l:Location in location_pool:
					for s:Settlement in l.settlements:
						if s is Dungeon:
							for r:NpcRoster in s.waves:
								var loot:LootInventory = r.loot;
								for item:Item in loot.items:
									if not item in pool:pool.append(item)
							if s.final_loot:
								for item:Item in s.final_loot.items:
									if not item in pool:pool.append(item)
						
						elif s is Building:
							## could just be an else but then i woulnt get the autocomplete
							if s.inventory:
								for item:Item in s.inventory.items:
									if not item in pool:pool.append(item)
				item_to_deliver = pool.pick_random().duplicate(DUPLICATE_USE_INSTANTIATION);
			add_child(item_to_deliver)
			item_to_deliver.hide()
			money_reward = item_to_deliver.rarity * 5 * randi_range(10, 15);
			roll_resource_rewards(2)

func roll_resource_rewards(amount:int)->void:
	while len(resources_reward.keys()) < amount:
		var r:String = Resources.all_resources.pick_random();
		if r not in resources_reward:
			
			var roll_base:int = Entities.player.level * 5;
			if r == "scrap":
				roll_base /= 1.5;
			elif r == "chips":
				roll_base /= 2;
			resources_reward[r] = randi_range(roll_base/2, roll_base * 1.5)


func get_random_base()->FighterBase:
	var bases:Array[FighterBase] = Index.fighters.all_unit_bases.values();
	bases = bases.filter(func(f:FighterBase)->bool:return f.fighter_type == "recruit");
	return bases.pick_random();

func compatible(t:Type)->bool:
	match t:
		Type.clear_dungeon:
			if dungeon_override: return true
			## needs at least one dungeon neighbor
			for n:Location in location.neighbors:
				if n.settlements[0] is Dungeon:
					return true;
			return false;
		Type.deliver_resource:
			## can't have every single resource for sale at time of reroll
			## make sure shop inventories reroll first
			var resources_for_sale:Array[String];
			for b:Building in location.settlements:
				var i:ShopInventory = b.inventory;
				if i:
					for c:ResourceContainer in i.containers:
						if not c.resource in resources_for_sale:
							resources_for_sale.append(c.resource)
			return len(resources_for_sale) < 5;
			
		Type.deliver_item:
			## not much limitation for this i suppose
			## make sure item can be found at least in neighbors of neighbors
			return true
		Type.deliver_unit:
			## same as deliver item but it can just be whoever
			## make sure the level requirement is within the player's party level range;
			return true
	assert(false);
	return false;


func can_claim()->bool:
	match type:
		Type.clear_dungeon:
			return dungeon_clear_target.cleared;
		Type.deliver_item:
			var item_i:int = Entities.player.inventory.items.find_custom(func(i:Item)->bool:return i.unique_name == item_to_deliver.unique_name)
			var not_equipped:= true
			if item_i != 1:
				var item:Item = Entities.player.inventory.items[item_i]
				if item in Entities.player.equipment:
					not_equipped = false
			return item_i != -1 and not_equipped;
		Type.deliver_resource:
			return Entities.player.inventory[resource_to_deliver] >= resource_amount;
		Type.deliver_unit:
			return Entities.player.roster.units.find_custom(
				func(u:FighterUnit)->bool:
					return u.base == unit_base and u.level >= unit_level;
			) != -1;
	assert(false);
	return false;

func claim()->void:
	## gives the player the reward and consumes the resources/units if they're required
	assert(can_claim())
	var player:Player = Entities.player
	if item_to_deliver:
		var i:int = player.inventory.items.find_custom(
			func(item:Item)->bool:return item.unique_name == item_to_deliver.unique_name
		)
		var item:Item = player.inventory.items[i]
		player.inventory.remove_item(item)
	
	
	if money_reward:
		player.inventory.change_resource("money", money_reward);
	if resources_reward:
		for key:String in resources_reward.keys():
			player.inventory.change_resource(key, resources_reward[key])
	if unit_reward:
		player.roster.add_unit(unit_reward)
	
	already_claimed = true
	claimed.emit()
