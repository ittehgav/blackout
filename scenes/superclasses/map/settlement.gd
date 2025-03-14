extends MapEntity;

class_name Settlement;

@export var background:Texture;
@export var settings:SettlementSettings;

@export var inventory:Inventory;

var player_relation:int=5;


func _ready()->void:
	ColorCoder.color_code_settlement(self)



func get_resource_values(operation:String)->Dictionary:
	const resources = ["food", "fuel", "juice", "scrap", "chips"]
	var values:Dictionary = {
		"food":0,
		"fuel":0,
		
		"juice":0,
		"scrap":0,
		"chips":0
	}
	## take into account
	## relation with player
	## population (or some sort of civilization level that would increase demant)
	## passive production
	## regional market value
	for r in resources:
		var value:float = Trade.resource_base_values[r];
		var production_multiplier:float = get_production_multiplier(r);
		value *= production_multiplier
		if operation == "buy":
			values[r] = value * 2;
		else:
			values[r] = value;
	return values

func get_production_multiplier(resource:String)->float:
	var production:int = settings[resource + "_production"];
	if production == 0:
		production = 5;
	return 5.0/production
