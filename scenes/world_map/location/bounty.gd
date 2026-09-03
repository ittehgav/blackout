extends Node
class_name Bounty

enum Type{
	clear_dungeon,
	deliver_resource,
	deliver_unit,
	deliver_item
}

## will be using a lot for generation so might as well have it here
var location:Location; 

var cash_reward:int;
var loot_reward:Array[Item];
var unit_reward:FighterUnit;

var dungeon_clear_target:Dungeon;

var resource_to_deliver:String;
var resource_amount:int;

var unit_base:FighterBase ## points to base index entry;
var unit_level:int;

var item_to_deliver:Item ## just an instance of the item;

func _ready()->void:
	## always consistently 
	location = get_parent().get_parent();


func refresh()->void:
	
	var types:Array[Type] = Type.values();
	var roll:Type = types.pick_random();
	
	while not type_compatible(roll):
		roll = reroll_type();
	
	match roll:
		Type.clear_dungeon:
			var options:Array[Dungeon];
			for n:Location in location.neighbors:
				var s:Settlement = n.settlements[0];
				if s is Dungeon:
					options.append(s);
			dungeon_clear_target = options.pick_random();
			
		Type.deliver_resource:
			var resource_options:Array[String] = Resources.all_resources.duplicate();
			for b:Building in location.settlements:
				var inv:ShopInventory = b.inventory;
				for c:ResourceContainer in inv.containers:
					resource_options.erase(c.resource)
					
			resource_to_deliver = resource_options.pick_random();
			var roll_base:int = (Entities.player.level + Entities.player.roster.get_level()) * 5
			match resource_to_deliver:
				"scrap":
					roll_base /= 1.25;
				"chips":
					roll_base /= 2;
					
			resource_amount = randi_range(roll_base/2, roll_base * 1.25);
			
		Type.deliver_unit:
			unit_base = get_random_base();
			var roll_base:int = Entities.player.level;
			unit_level = randi_range(roll_base/2, roll_base*1.25);

		Type.deliver_item:
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
						for item:Item in s.final_loot.items:
							if not item in pool:pool.append(item)
					
					elif s is Building:
						## could just be an else but then i woulnt get the autocomplete
						if s.inventory:
							for item:Item in s.inventory.items:
								if not item in pool:pool.append(item)
			item_to_deliver = pool.pick_random().duplicate(DUPLICATE_USE_INSTANTIATION);
			add_child(item_to_deliver)
						
			
			

func get_random_base()->FighterBase:
	var bases:Array[FighterBase] = Index.fighters.all_unit_bases.values();
	bases = bases.filter(func(f:FighterBase)->bool:return f.fighter_type == "recruit");
	return bases.pick_random();

func type_compatible(t:Type)->bool:
	match t:
		Type.clear_dungeon:
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
			return len(resources_for_sale) == 5;
			
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


func reroll_type()->Type:
	return Type.values().pick_random();
