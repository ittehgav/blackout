extends MapEntity;

class_name Settlement;


var ongoing_trade_anomaly:TradeAnomaly;
var local_event:LocalEvent;

var available_recruits:Array[FighterUnit];

var player_inside:bool=false;

@export var background:Texture;
@export var crowd_1:Texture;
@export var crowd_2:Texture;

@export var inventory:Inventory;

@export_subgroup("Basic Features")
@export var trade:bool=true;
@export var recruit_units:bool=true;
@export var listen_around:bool=true;

@export_subgroup("Resource Production")
@export var money_production:int=100;
@export var food_production:int=100;
@export var fuel_production:int=100;


@export var juice_production:int=100;
@export var scrap_production:int=100;
@export var chips_production:int=100;

var neighbors:Array[Settlement];

var food_storage:ResourceContainer;
var fuel_storage:ResourceContainer;

var juice_storage:ResourceContainer;
var scrap_storage:ResourceContainer;
var chips_storage:ResourceContainer;



var resource_daily_balance:Dictionary = {
	## keeps track of changes to affect pricing
	"food":0,
	"fuel":0,
	"money":0,
	"juice":0,
	"scrap":0,
	"chips":0
}

const relation_level_names:Dictionary[int,String] = {
	-5:"dreaded",
	-4:"hated",
	-3:"shunned",
	-2:"disliked",
	-1:"avoided",
	0:"neutral",
	1:"tolerated",
	2:"liked",
	3:"friendly",
	4:"loved",
	5:"local hero"
}

const relationship_modifiers = {
	-5:8,
	-4:5,
	-3:4,
	-2:3,
	-1:2.5,
	0:2,
	1:1.95,
	2:1.9,
	3:1.8,
	4:1.5,
	5:1.2
}



var player_relation:int=0;
## relation progresses as the player trades with and does tasks for the settlement
var relation_progress:float=0.0;

func relation_level_string()->String:
	var color_str := "[color=";
	if player_relation >= 0:
		color_str += "green]";
	else:
		color_str += "red]"
	return color_str +  relation_level_names[player_relation].capitalize() + "[/color]";

func relation_progress_for_next_level()->int:
	if player_relation >= 0:
		return (player_relation + 2) ** 2
	else:
		return -player_relation



func gain_relation_progress(amount:float)->void:
	var to_next_level:float = relation_progress_for_next_level() - relation_progress;
	if amount >= to_next_level:
		player_relation += 1;
		relation_progress = amount - to_next_level;
	else:
		relation_progress += amount;



func daily_reset()->void:
	## every day, in the current state, settlements update their inventory
	## replaces all non-rare items in the inventory and refreshes resource inventory
	## based on trade anomalies and production
	if not player_inside:
		refresh_events();

	refresh_inventory();
	refresh_recruits();


func refresh_events()->void:
	if ongoing_trade_anomaly:
		ongoing_trade_anomaly.time_left -= 1;
		if not ongoing_trade_anomaly.time_left:
			ongoing_trade_anomaly.expire();
		ongoing_trade_anomaly = null;
	## TODO handle behavior for registered memos
	## or make them all work the same way regardless of whether they're registered or not?
	if not ongoing_trade_anomaly:
		ongoing_trade_anomaly = TradeAnomaly.new();
		ongoing_trade_anomaly.generate(self);

	if local_event:
		local_event.time_left -= 1;
		if not local_event.time_left:
			local_event.expire();
			local_event = null;

	if not local_event:
		var roll:float = randf_range(0, 1);
		if roll:
			var event:LocalEvent = Index.local_event_scenes.pick_random().instantiate();
			event.location = self;
			event.generate();
			local_event = event;
	



func refresh_inventory()->void:
	## affects daily inventory refresh:
	## production
	## trade anomalies
	## local events (or lack thereof)
	## price hikes a little or drops a little for a resource if it was bought/sold
	var resource_prices:Dictionary = Index.resource_base_prices.duplicate();
	inventory.money = randi_range(money_production/2, money_production * 1.5)

	var tradeable_resources:PackedStringArray = Index.all_resources.filter(func(r:String)->bool:return r != "money")
	
	var relationship_modifier:float = relationship_modifiers[player_relation];
	for r:String in tradeable_resources:
		var production:int = self[r+'_production'];
		inventory[r] += randi_range(production/1.5, production * 1.5);
		
		inventory.resource_selling_prices[r] = resource_prices[r] / relationship_modifier;
		inventory.resource_buying_prices[r] = resource_prices[r] * relationship_modifier;

		if inventory.resource_selling_prices[r] < 1:
			inventory.resource_selling_prices[r] = 1
		if inventory.resource_buying_prices[r] < 1:
			inventory.resource_buying_prices[r] = 1

	inventory.store_resources();
	inventory.refresh_resource_counts("",0,false)
	apply_trade_anomaly();

func apply_trade_anomaly()->void:
	var a:TradeAnomaly = ongoing_trade_anomaly;

	if a.positive:
		## POSITIVE ANOMALY = SURPLUS = STOCK UP PRICE DOWN
		inventory.resource_buying_prices[a.resource] /= a.change;
		inventory.resource_selling_prices[a.resource] /= a.change
		inventory[a.resource] *= a.change
	else:
		## NEGATIVE ANOMALY = SHORTAGE = STOCK DOWN PRICE UP
		inventory.resource_buying_prices[a.resource] *= a.change;
		inventory.resource_selling_prices[a.resource] *= a.change
		inventory[a.resource] /= a.change
		
func refresh_recruits()->void:
	available_recruits = [];
	while len(available_recruits) < 3:
		var new_recruit_base:FighterBase = Index.basic_fighter_base_scenes.pick_random().instantiate();
		var fighter_unit:FighterUnit = Index.fighter_unit_scene.instantiate();
		fighter_unit.add_child(new_recruit_base);
		fighter_unit.base = new_recruit_base;
		fighter_unit.level = randi_range(1, 5);
		fighter_unit.load_stats();
		available_recruits.append(fighter_unit);
	
	var big_recruit_base:FighterBase = Index.evolved_fighter_base_scenes.pick_random().instantiate();
	var big_fighter_unit:FighterUnit = Index.fighter_unit_scene.instantiate();
	big_fighter_unit.add_child(big_recruit_base);
	big_fighter_unit.base = big_recruit_base;
	big_fighter_unit.level = randi_range(10, 20);
	big_fighter_unit.load_stats();
	available_recruits.append(big_fighter_unit)

func initiate_inventory()->void:
	inventory.generate_storages()

func _on_hover_box_gui_input(event: InputEvent) -> void:
	Entities.world_map.ui.movement_overlay._on_gui_input(event);


func _on_hover_box_mouse_entered()->void:
	Entities.map_entity_under_mouse = self;
	
func _on_hover_box_mouse_exited()->void:
	Entities.clear_map_entity_under_mouse();
