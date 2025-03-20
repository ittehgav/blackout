extends MapEntity;

class_name Settlement;

var ongoing_anomalies:Array[TradeAnomaly];

@export var background:Texture;

@export var inventory:Inventory;

@export_subgroup("Basic Features")
@export var trade:bool=true;
@export var recruit_units:bool=true;
@export var listen_around:bool=true;


@export_subgroup("Resource Production")
@export_range(0, 100) var food_production:int;
@export_range(0, 100) var fuel_production:int;


@export_range(0, 100) var juice_production:int;
@export_range(0, 100) var scrap_production:int;
@export_range(0, 100) var chips_production:int;

var neighbors:Array[Settlement];

const resources = ["food", "fuel", "juice", "scrap", "chips"]

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

var player_relation:int=5;


func _ready()->void:
	ColorCoder.color_code_settlement(self)




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

func add_new_anomaly():
	var anomaly:TradeAnomaly = TradeAnomaly.new();
	anomaly.generate(self);
	while overlapping_anomaly(anomaly):
		anomaly.generate(self);
	ongoing_anomalies.append(anomaly);

func refresh_inventory():
	## affects daily inventory refresh:
	## production
	## trade anomalies
	## price hikes a little or drops a little for a resource if it was bought/sold
	
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
	
	for r in resources:
		for anomaly:TradeAnomaly in ongoing_anomalies:
			if anomaly.resource == r:
				var price_shift = resource_prices[r] * anomaly.change
				var change = to_add[r] * anomaly.change;
				if not anomaly.positive:
					## anomalies are heavily overcorrected
					change *= -1; 
					resource_prices[r] -= price_shift;
				else:
					resource_prices[r] += price_shift
					
				to_add[r] += change;

	for r in to_add.keys():
		resource_selling_prices[r] = resource_prices[r] / 2;
		resource_buying_prices[r] = resource_prices[r] * 2;
		inventory[r] = to_add[r];
				

	
func overlapping_anomaly(anomaly:TradeAnomaly)->bool:
	for a in ongoing_anomalies:
		if a.resource == anomaly.resource:
			return true;
	return false
