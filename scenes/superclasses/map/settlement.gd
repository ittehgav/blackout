extends MapEntity;

class_name Settlement;

var ongoing_anomalies:Array[TradeAnomaly];

@export var background:Texture;
@export var crowd_1:Texture;
@export var crowd_2:Texture;

@export var inventory:Inventory;

@export_subgroup("Basic Features")
@export var trade:bool=true;
@export var recruit_units:bool=true;
@export var listen_around:bool=true;

@export_subgroup("Resource Production")
@export_range(0, 100) var food_production:int=100;
@export_range(0, 100) var fuel_production:int=100;


@export_range(0, 100) var juice_production:int=100;
@export_range(0, 100) var scrap_production:int=100;
@export_range(0, 100) var chips_production:int=100;

var neighbors:Array[Settlement];


func _ready()->void:
	ColorCoder.color_code_settlement(self)

var resource_prices:Dictionary = {
	"food":1.0,
	"fuel":1.0,
	"juice":2.0,
	"scrap":3.0,
	"chips":5.0
}

var resource_buying_prices:Dictionary = {
	## RESOURCE BUYING PRICE = PLAYER BUYING
	"food":0,
	"fuel":0,
	"juice":0,
	"scrap":0,
	"chips":0
}

var resource_selling_prices:Dictionary = {
	## RESOURCE SELLING PRICE = PLAYER SELLING
	"food":0,
	"fuel":0,
	"juice":0,
	"scrap":0,
	"chips":0
}

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
		return player_relation * -1



func gain_relation_progress(amount:float)->void:
	var to_next_level:float = relation_progress_for_next_level() - relation_progress;
	if amount >= to_next_level:
		player_relation += 1;
		relation_progress = amount - to_next_level;
	else:
		relation_progress += amount;

func get_production_multiplier(resource:String)->float:
	var production:int = self[resource + "_production"];
	if production == 0:
		production = 5;
	return 5.0/production

func daily_reset()->void:
	## every day, in the current state, settlements update their inventory
	## replaces all non-rare items in the inventory and refreshes resource inventory
	## based on trade anomalies and production
	if not len(ongoing_anomalies) or len(ongoing_anomalies) < 3 and randf_range(0, 1) > .5:
		add_new_anomaly();
	while len(ongoing_anomalies) < 3:
		add_new_anomaly()
	
	refresh_inventory();

func add_new_anomaly()->void:
	var anomaly:TradeAnomaly = TradeAnomaly.new();
	anomaly.generate(self);
	while overlapping_anomaly(anomaly):
		anomaly.generate(self);
	ongoing_anomalies.append(anomaly);



func refresh_inventory()->void:
	## affects daily inventory refresh:
	## production
	## trade anomalies
	## price hikes a little or drops a little for a resource if it was bought/sold
	## TODO more price adjusting
	
	
	resource_prices = {
		## resets prices to 0 before routine
		"food":1.0,
		"fuel":1.0,
		"juice":2.0,
		"scrap":3.0,
		"chips":5.0
	}
	
	var to_add:Dictionary = {
		"food":food_production,
		"fuel":fuel_production,
		"juice":juice_production,
		"scrap":scrap_production,
		"chips":chips_production
	}
	
	for r:String in Index.all_resources.filter(func(r:String):return r != "money"):
		for anomaly:TradeAnomaly in ongoing_anomalies:
			if anomaly.resource == r:
				var price_shift:float = resource_prices[r] * anomaly.change
				var change:float = to_add[r] * anomaly.change;
				if not anomaly.positive:
					## anomalies are heavily overcorrected
					change *= -1; 
					resource_prices[r] -= price_shift;
				else:
					resource_prices[r] += price_shift
					
				to_add[r] += change;

	var relationship_modifier:float = relationship_modifiers[player_relation];

	for r:String in to_add.keys():
		resource_selling_prices[r] = resource_prices[r] / relationship_modifier;
		resource_buying_prices[r] = resource_prices[r] * relationship_modifier;
		inventory[r] = to_add[r];
				

	
func overlapping_anomaly(anomaly:TradeAnomaly)->bool:
	for a in ongoing_anomalies:
		if a.resource == anomaly.resource:
			return true;
	return false

func _on_hover_box_mouse_entered()->void:
	Entities.map_entity_under_mouse = self;
	
func _on_hover_box_mouse_exited()->void:
	Entities.clear_map_entity_under_mouse();
